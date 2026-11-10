extends SceneTree
const S = preload("res://scripts/construction_session.gd")
const E = S.E
var checks = 0
var failures = []
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures.append(text); push_error(text)
func _initialize() -> void: call_deferred("run")
func funded() -> Dictionary:
	# Isolated accounting unit fixture, not a claimed ordinary-game start.
	var s = S.initial(); E.change(s,"industry",30); E.change(s,"food",50)
	return s
func send(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var result = S.command(s,cmd)
	check(result.ok,"Command accepted: "+str(cmd))
	return result.state
func run() -> void:
	var base = S.initial()
	check(S.validate(base) == "","Initial B04 validates")
	var sites = []
	for tile in base.tileAccess.main:
		if S.C.target_reason(base,"farm",tile) == "": sites.append(tile)
	check(sites.size()>=2,"Approved map supports distinct farm sites")
	var first = sites[0]; var second = sites[1]
	var s = send(funded(),{"type":"enqueue","recipe":"farm","tile":first})
	check(s.construction.queue[0].work == 0 and s.resources.industry == 30,"Queueing creates no progress or payment")
	s = send(s,{"type":"assign","person":"pop_a","job":"construct"})
	s = send(s,{"type":"endTurn"})
	check(s.construction.queue[0].work == 2 and s.resources.industry == 28,"One worker pays exactly for two effort")
	check(not s.improvements.has(first),"Unfinished farm has no benefit")
	check(S.validate(JSON.parse_string(JSON.stringify(s))) == "","Partial payment survives validated JSON save")
	s = send(s,{"type":"hold","id":"project_1","held":true})
	s = send(s,{"type":"enqueue","recipe":"farm","tile":second})
	s = send(s,{"type":"endTurn"})
	check(s.construction.queue[0].work==2 and s.construction.queue[1].work==2,"Held head skipped; later eligible entry gets labor")
	s = send(s,{"type":"hold","id":"project_1","held":false})
	s = send(s,{"type":"assign","person":"pop_b","job":"construct"})
	s = send(s,{"type":"endTurn"})
	check(s.construction.queue.all(func(p):return p.status=="complete"),"Completion overflow serves following project with one budget")
	check(s.lastLedger.work == 4 and s.resources.industry == 22,"Assisted four-point budget paid once")
	check(S.validate(s)=="","Completed farms validate")
	s = send(s,{"type":"enqueue","recipe":"farm_upgrade","tile":first})
	var old_food = E.R.tile_yield(s,first).get("food",0)
	s = send(s,{"type":"assign","person":"pop_b","job":"idle"})
	s = send(s,{"type":"endTurn"})
	check(E.R.tile_yield(s,first).get("food",0)==old_food,"Old output retained during upgrade")
	s = send(s,{"type":"endTurn"})
	check(E.R.tile_yield(s,first).get("food",0)==old_food+1,"Completed representative upgrade improves yield")
	var poor = send(S.initial(),{"type":"enqueue","recipe":"farm","tile":first})
	E.change(poor,"industry",1)
	poor = send(poor,{"type":"assign","person":"pop_a","job":"construct"})
	poor = send(poor,{"type":"endTurn"})
	check(poor.construction.queue[0].work==1 and poor.resources.industry==0,"Underfunded project makes only affordable progress")
	poor = send(poor,{"type":"endTurn"})
	check(poor.construction.queue[0].work==1,"Blocked project retains paid work")
	var mixed = send(funded(),{"type":"enqueue","recipe":"farm","tile":first})
	mixed = send(mixed,{"type":"assign","person":"pop_a","job":"mixed"})
	mixed = send(mixed,{"type":"endTurn"})
	check(mixed.lastLedger.gross.industry==1 and mixed.lastLedger.work==1 and mixed.lastLedger.inputs.minerals==1,"Split worker has one two-point manufacturing/construction budget")
	var district = send(funded(),{"type":"enqueue","recipe":"district","tile":first})
	district = send(district,{"type":"assign","person":"pop_a","job":"construct"})
	district = send(district,{"type":"endTurn"})
	check(E.R.tile_yield(district,first).is_empty() and district.districts.is_empty(),"Started district suppresses natural output before benefits")
	district = send(district,{"type":"hold","id":"project_1","held":true})
	district = send(district,{"type":"endTurn"})
	check(E.R.tile_yield(district,first).is_empty(),"Held district stays suppressed")
	district = send(district,{"type":"hold","id":"project_1","held":false})
	for i in range(2): district = send(district,{"type":"endTurn"})
	district = send(district,{"type":"enqueue","recipe":"greenhouse","tile":first})
	for i in range(3): district = send(district,{"type":"endTurn"})
	check(district.buildings.size()==1 and S.validate(district)=="","District and staffed building chain completes consistently")
	var building_job = "building:"+district.buildings.keys()[0]+"#0"
	district = send(district,{"type":"assign","person":"pop_a","job":building_job})
	district = send(district,{"type":"endTurn"})
	check(district.lastLedger.gross.food==3 and district.lastLedger.upkeep.energy==1,"Completed building pays operating inputs for staffed benefit")
	var builder = send(funded(),{"type":"enqueue","recipe":"farm","tile":first})
	builder = send(builder,{"type":"deployBuilder","person":"pop_b"})
	check(not S.command(builder,{"type":"deployBuilder","person":"pop_a"}).ok,"Reusable kit cannot be duplicated")
	builder = send(builder,{"type":"queueMove","unitId":"pop_b","target":first})
	for i in range(12):
		if builder.cohorts.pop_b.state.tileId == first and builder.moveProgress.is_empty(): break
		builder = send(builder,{"type":"endTurn"})
	check(builder.cohorts.pop_b.state.tileId==first,"Builder physically reaches site using shared movement")
	builder = send(builder,{"type":"assign","person":"pop_b","job":"builder"})
	var arrived = builder.construction.queue[0].work
	builder = send(builder,{"type":"endTurn"})
	check(builder.construction.queue[0].work==arrived,"Arrival turn cannot also provide builder labor")
	builder = send(builder,{"type":"endTurn"})
	check(builder.construction.queue[0].work==arrived+2 and builder.lastLedger.upkeep.food==2,"Stationary builder contributes two effort and eats one Food")
	check(S.validate(JSON.parse_string(JSON.stringify(builder)))=="","Builder activity and kit survive save validation")
	var returning = send(builder,{"type":"queueMove","unitId":"pop_b","target":"2,3"})
	for i in range(12):
		if returning.cohorts.pop_b.state.tileId == "2,3": break
		returning = send(returning,{"type":"endTurn"})
	returning = send(returning,{"type":"returnBuilder","person":"pop_b"})
	check(returning.construction.holders.is_empty() and returning.construction.kits==1,"Builder returns reusable kit without consuming or duplicating it")
	var assisted = builder.duplicate(true)
	assisted = send(assisted,{"type":"assign","person":"pop_a","job":"construct"})
	assisted = send(assisted,{"type":"endTurn"})
	check(assisted.construction.queue[0].status=="complete" and assisted.lastLedger.work==2,"Settlement and on-site builder share remaining affordable project work")
	var remote = ""
	for tile in base.tiles:
		if tile not in base.tileAccess.main and S.C.target_reason(base,"farm",tile)=="": remote = tile; break
	var blocked = send(funded(),{"type":"enqueue","recipe":"farm","tile":remote})
	blocked = send(blocked,{"type":"enqueue","recipe":"farm","tile":second})
	blocked = send(blocked,{"type":"assign","person":"pop_a","job":"construct"})
	blocked = send(blocked,{"type":"endTurn"})
	check(blocked.construction.queue[0].work==0 and blocked.construction.queue[1].work==2,"Remote head blocks settlement labor but later local project progresses")
	blocked = send(blocked,{"type":"cancel","id":blocked.construction.queue[1].goal})
	blocked = send(blocked,{"type":"endTurn"})
	check(blocked.construction.queue[1].work==2 and blocked.construction.queue[1].held,"Cancelled funding purpose cannot secretly continue construction")
	var bad = builder.duplicate(true); bad.construction.queue[0].paid += 1
	check(S.validate(bad)!="","Forged paid progress rejected")
	var ordinary = send(S.initial(),{"type":"enqueue","recipe":"farm","tile":first})
	ordinary = send(ordinary,{"type":"planning","enabled":true})
	var started = Time.get_ticks_usec()
	for i in range(24):
		ordinary = S.command(ordinary,{"type":"endTurn"}).state
		if ordinary.construction.queue[0].status=="complete": break
	check(ordinary.construction.queue[0].status=="complete" and ordinary.resources.food>=0,"Ordinary approved-map AI acquires materials and builds useful Farm without grants")
	var timings = {}
	for count in [10,100,1000]:
		# Pure queue iteration benchmark, not a new gameplay scenario.
		var synthetic = funded()
		for i in range(count): synthetic.construction.queue.append({"id":"held_"+str(i),"held":true,"status":"queued","blocker":""})
		var ledger = {"spending":{"industry":0}}
		var clock = Time.get_ticks_usec()
		for i in range(10): S.C.resolve(synthetic,ledger)
		timings[str(count)] = Time.get_ticks_usec()-clock
		check(ledger.work==0 and synthetic.resources.industry==30,"Held queue causes no spending or labor at size %d" % count)
	var ui = load("res://b04.tscn").instantiate(); root.add_child(ui)
	for i in range(10): await process_frame
	ui.action("Save"); ui.action("End turn"); ui.action("Load")
	check(ui.state.turn==1 and ui.construction_mode,"B04 UI and separate file save/load")
	ui.free()
	print(JSON.stringify({"suite":"B04","checks":checks,"failures":failures,"ordinary_turn":ordinary.turn,"industry":ordinary.resources.industry,"food":ordinary.resources.food,"ordinary_us":Time.get_ticks_usec()-started,"held_queue_10_passes_us":timings}))
	quit(0 if failures.is_empty() else 1)
