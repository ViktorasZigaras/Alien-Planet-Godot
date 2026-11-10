extends SceneTree
const P = preload("res://scripts/economy_planner.gd")
const E = P.E
var checks = 0
var failures = []
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures.append(text); push_error(text)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s = P.attach(E.initial())
	check(P.validate(s) == "","Initial planning state valid")
	s = P.command(s,{"type":"goal","amount":4}).state
	s = P.command(s,{"type":"planning","enabled":true}).state
	check(s.commitments.stocks.is_empty() and s.commitments.prerequisites.is_empty(),"Unauthorized proposal cannot reserve or execute capital work")
	s = P.command(s,{"type":"authorize","id":"goal_1"}).state
	check(not s.commitments.people.is_empty(),"Authorization allocates real people")
	check(s.planning.review.rejected>0,"Illegal competing occupancy alternatives rejected")
	for id in s.commitments.people:
		var wrong = "idle" if s.commitments.people[id].job != "idle" else "manufacture"
		check(not E.command(s,{"type":"assign","person":id,"job":wrong}).ok,"Shared command gate rejects conflicting assignment")
	s = P.command(s,{"type":"goal","amount":4}).state
	s = P.command(s,{"type":"authorize","id":"goal_2"}).state
	check(s.commitments.prerequisites.size() == 1 and s.commitments.prerequisites[0].purposes.size()==2,"Two goals share one material prerequisite")
	var forged = JSON.parse_string(JSON.stringify(s))
	forged.commitments = {"people":"fake","stocks":{"fake":{"industry":9999}},"prerequisites":[]}
	check(P.validate(forged) == "" and not P.plan(forged).commitments.stocks.has("fake"),"Saved reservation claims rebuilt from authorized purposes")
	var emergency = s.duplicate(true)
	E.change(emergency,"food",-int(emergency.resources.food))
	emergency.cohorts.pop_a.state.job = "manufacture"
	emergency.cohorts.pop_b.state.job = null
	emergency.commitments.people = {"pop_a":{"job":"manufacture","purposes":["goal_1"]}}
	var recovered = E.resolve(emergency)
	check(recovered.ledger.gross.food > 0,"Food emergency may override routine worker commitment")
	var started = Time.get_ticks_usec()
	var replay = JSON.parse_string(JSON.stringify(s))
	for i in range(16):
		s = P.command(s,{"type":"endTurn"}).state
		replay = P.command(JSON.parse_string(JSON.stringify(replay)),{"type":"endTurn"}).state
		check(s.resources.food>=0,"Ordinary automated turn remains Food-safe %d" % i)
	check(E.same(s.resources,replay.resources) and E.same(s.cohorts,replay.cohorts),"JSON continuation agrees with ordinary planner turns")
	check(s.planning.goals.all(func(g):return g.status == "fulfilled"),"Ordinary play acquires prerequisites and fulfills both purposes")
	var allocated = 0
	for stock in s.commitments.stocks.values(): allocated += stock.get("industry",0)
	check(allocated == 8 and P.available(s,"industry") == s.resources.industry-8,"Industry is never reserved twice")
	s = P.command(s,{"type":"cancel","id":"goal_1"}).state
	check(not s.commitments.stocks.has("goal_1") and s.commitments.stocks.has("goal_2"),"Cancel releases only its own reservation")
	s = P.command(s,{"type":"cancel","id":"goal_2"}).state
	check(s.commitments.prerequisites.is_empty(),"Purpose disappearance releases shared capital work")
	var amount = s.resources.industry
	for i in range(4): s = P.command(s,{"type":"endTurn"}).state
	check(s.resources.industry == amount,"No purposeless Industry hoard after cancellation")
	s = P.command(s,{"type":"planning","enabled":false}).state
	check(s.commitments.people.is_empty(),"Disabling automatic work releases people")
	check(P.validate(JSON.parse_string(JSON.stringify(s))) == "","Planning save validates")
	var ui = load("res://b03.tscn").instantiate(); root.add_child(ui)
	for i in range(10): await process_frame
	ui.action("Save"); ui.action("End turn"); ui.action("Load")
	check(ui.state.turn == 1 and ui.planning_mode,"B03 UI real save/load")
	ui.free()
	print(JSON.stringify({"suite":"B03","checks":checks,"failures":failures,"turns":20,"elapsed_us":Time.get_ticks_usec()-started,"industry":s.resources.industry,"food":s.resources.food}))
	quit(0 if failures.is_empty() else 1)
