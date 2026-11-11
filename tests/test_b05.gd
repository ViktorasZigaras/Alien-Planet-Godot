extends SceneTree
const S = preload("res://scripts/progression_session.gd")
const E = S.E
var checks = 0
var failures = []
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures.append(text); push_error(text)
func _initialize() -> void: call_deferred("run")
func send(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var result = S.command(s,cmd)
	check(result.ok,"Accepted "+str(cmd)+": "+result.message)
	return result.state
func funded() -> Dictionary:
	# Isolated accounting fixture. Ordinary-play evidence below uses no grants.
	var s = S.initial(); E.change(s,"food",60); E.change(s,"industry",30)
	return s
func run() -> void:
	var base = S.initial()
	check(S.validate(base)=="","Initial B05 validates")
	var food_job = ""; var food_yield = 0; var site = ""
	for j in E.jobs(base):
		if j.id.begins_with("tile:") and j.yield.get("food",0)>food_yield: food_job=j.id; food_yield=j.yield.food
	for tile in base.tileAccess.main:
		if S.S.C.target_reason(base,"district",tile)=="" and tile != food_job.substr(5): site=tile; break
	var s = send(funded(),{"type":"boostGrowth","amount":10})
	s = send(s,{"type":"boostGrowth","amount":10})
	check(s.cohorts.size()==2 and s.settlements.main.growth==20 and s.resources.food==48,"Reserve transfer preserves Food and creates no immediate people")
	s = send(s,{"type":"assign","person":"pop_a","job":food_job})
	s = send(s,{"type":"endTurn"})
	check(s.cohorts.size()==3 and s.settlements.main.growth==10+s.lastLedger.growth_food,"Combined growth methods create at most one person in a boundary")
	check(s.lastLedger.growth_food==1 and s.resources.food==s.lastLedger.opening.food+s.lastLedger.gross.food-s.lastLedger.upkeep.food-1,"Natural growth moves one surplus Food without duplicating it")
	check(S.validate(JSON.parse_string(JSON.stringify(s)))=="","Grown cohort survives save validation")
	s = send(s,{"type":"endTurn"})
	check(s.cohorts.size()==4 and s.settlements.main.growth<10,"Second funded cohort waits for next boundary")
	s = send(s,{"type":"planning","enabled":true})
	check(s.planning.review.candidates>0 and S.G.working(s)<=S.G.support(s),"Planner allocates all grown identities within support")
	check(s.cohorts.has("grown_1") and s.cohorts.has("grown_2"),"New people receive unique persistent identities")
	var course = send(funded(),{"type":"train","person":"pop_b","qualification":"Biologist"})
	check(course.resources.industry==28 and course.cohorts.size()==2,"Training charges immediately without duplicating people")
	check(not S.command(course,{"type":"assign","person":"pop_b","job":"study"}).ok,"Enrolled trainee cannot also produce")
	course = send(course,{"type":"endTurn"})
	check(course.cohorts.pop_b.qualification=="Worker" and course.progression.training.pop_b.remaining==1,"Training needs two productive boundaries")
	course = send(course,{"type":"endTurn"})
	check(course.cohorts.pop_b.qualification=="Biologist" and course.cohorts.pop_b.state.job==null,"Training changes qualification and preserves identity")
	check(not course.progression.evidence.biologist,"Idle newly trained person is not operational evidence")
	course = send(course,{"type":"assign","person":"pop_b","job":food_job})
	course = send(course,{"type":"endTurn"})
	check(course.lastLedger.gross.food==food_yield+2 and course.progression.evidence.biologist,"Supported matching job gets +2 and records actual operation")
	E.change(course,"science",6)
	var stale = send(course,{"type":"assign","person":"pop_b","job":"idle"})
	stale = send(stale,{"type":"endTurn"})
	check(not S.command(stale,{"type":"research","tech":"cultivation"}).ok,"Last productive evidence expires after an idle boundary")
	course = send(course,{"type":"assign","person":"pop_a","job":"generate"})
	course = send(course,{"type":"endTurn"})
	course = send(course,{"type":"research","tech":"cultivation"})
	check(course.resources.science==2 and "cultivation" in course.progression.techs,"Research pays immediately and unlocks a usable upgrade")
	check(not S.command(course,{"type":"research","tech":"cultivation"}).ok,"Duplicate research cannot charge or apply twice")
	check(S.reason(course,{"type":"research","tech":"power_systems"})=="Insufficient unreserved Science.","Same-turn second purchase rechecks reduced available stock")
	var reserved = S.initial(); E.change(reserved,"industry",2)
	reserved = send(reserved,{"type":"enqueue","recipe":"district","tile":site})
	check(not S.command(reserved,{"type":"train","person":"pop_b","qualification":"Scientist"}).ok,"Training cannot spend Industry reserved for a project")
	var idle = send(funded(),{"type":"assign","person":"pop_a","job":food_job})
	idle = send(idle,{"type":"growthPolicy","enabled":false})
	idle = send(idle,{"type":"endTurn"})
	check(idle.lastLedger.growth_food==0 and idle.settlements.main.growth==0,"No-growth retains surplus in accessible Food reserve")
	check(idle.resources.food==idle.lastLedger.opening.food+idle.lastLedger.gross.food-idle.lastLedger.upkeep.food,"Food exported to reserve is not counted twice")
	check(not S.command(idle,{"type":"boostGrowth","amount":1}).ok,"Reserve acceleration respects no-growth policy")
	var infra = send(funded(),{"type":"growthPolicy","enabled":false})
	infra = send(infra,{"type":"enqueue","recipe":"district","tile":site})
	infra = send(infra,{"type":"assign","person":"pop_a","job":"construct"})
	for i in range(3): infra = send(infra,{"type":"endTurn"})
	infra = send(infra,{"type":"enqueue","recipe":"greenhouse","tile":site})
	for i in range(3): infra = send(infra,{"type":"endTurn"})
	check(S.G.support(infra)==2,"Unstaffed infrastructure supplies no extra support")
	var building = "building:"+infra.buildings.keys()[0]+"#0"
	infra = send(infra,{"type":"assign","person":"pop_a","job":building})
	check(S.G.support(infra)==4,"Staffed powered Greenhouse adds two working places")
	# Existing-person extension is an isolated support-loss unit check.
	for n in [1,2]:
		var c = infra.cohorts.pop_b.duplicate(true); c.id="grown_"+str(n); c.name=c.id; c.state.job=null; infra.cohorts[c.id]=c
	infra.nextCohortNumber=3
	infra = send(infra,{"type":"assign","person":"pop_b","job":"study"})
	infra = send(infra,{"type":"assign","person":"grown_1","job":"generate"})
	infra = send(infra,{"type":"assign","person":"grown_2","job":"manufacture"})
	check(S.G.working(infra)==4,"Expanded support admits four workers")
	E.change(infra,"energy",-int(infra.resources.energy))
	var after = E.resolve(infra,false).state
	check(S.G.working(after)<=S.G.support(after),"Support loss idles excess workers without an automatic over-cap Food exception")
	check(after.progression.events.any(func(event):return event.event=="support_loss"),"Displaced work and potential Food recorded for support-loss review")
	check(S.validate(JSON.parse_string(JSON.stringify(after)))=="","Support-loss state saves consistently")
	# Actual ordinary bootstrap: no injected stocks or people.
	var ordinary = send(S.initial(),{"type":"growthPolicy","enabled":false})
	ordinary = send(ordinary,{"type":"assign","person":"pop_a","job":food_job})
	ordinary = send(ordinary,{"type":"assign","person":"pop_b","job":"manufacture"})
	ordinary = send(ordinary,{"type":"endTurn"})
	ordinary = send(ordinary,{"type":"train","person":"pop_b","qualification":"Scientist"})
	for i in range(2): ordinary = send(ordinary,{"type":"endTurn"})
	ordinary = send(ordinary,{"type":"assign","person":"pop_b","job":"study"})
	for i in range(2): ordinary = send(ordinary,{"type":"endTurn"})
	check(ordinary.resources.science==6,"Ordinary trained Scientist earns research stock")
	ordinary = send(ordinary,{"type":"assign","person":"pop_b","job":"generate"})
	ordinary = send(ordinary,{"type":"endTurn"})
	ordinary = send(ordinary,{"type":"research","tech":"power_systems"})
	ordinary = send(ordinary,{"type":"endTurn"})
	check(ordinary.lastLedger.gross.energy==4 and ordinary.resources.food>=0,"Ordinary start legally reaches and operates useful researched capability")
	var bad = ordinary.duplicate(true); bad.progression.training.pop_a={"qualification":"Scientist","remaining":-1}
	check(S.validate(bad)!="","Malformed course rejected")
	var ui = load("res://b05.tscn").instantiate(); root.add_child(ui)
	for i in range(10): await process_frame
	ui.action("Save"); ui.action("End turn"); ui.action("Load")
	check(ui.state.turn==1 and ui.progression_mode,"B05 separate real-file save/load and UI")
	ui.free()
	print(JSON.stringify({"suite":"B05","checks":checks,"failures":failures,"ordinary_turn":ordinary.turn,"food":ordinary.resources.food,"energy":ordinary.resources.energy}))
	quit(0 if failures.is_empty() else 1)
