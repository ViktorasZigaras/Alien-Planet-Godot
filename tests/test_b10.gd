extends SceneTree
const X = preload("res://scripts/expansion_session.gd")
var failures = []
var checks = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func travel(s: Dictionary, site: String) -> Dictionary:
	s = X.command(s,{"type":"queueMove","unitId":"pop_a","target":site}).state
	for i in range(12):
		if s.cohorts.pop_a.state.tileId == site and not s.movementQueues.has("pop_a"): break
		s = X.command(s,{"type":"endTurn"}).state
	return s

func candidate(s: Dictionary) -> String:
	var home = s.settlements.main.tileId
	for key in s.tiles:
		if X.R.distance(s.tiles[home],s.tiles[key]) != 3 or s.tiles[key].obstacle != "": continue
		if X.R.founding_reason(s,key) != "" or X.R.path(s,home,key,"").is_empty(): continue
		if X.R.neighbours(s,key).any(func(tile): return s.tiles[tile].obstacle == "" and X.R.tile_yield(s,tile).get("food",0)>0): return key
	return ""

func run() -> void:
	var app = load("res://b10.tscn").instantiate()
	root.add_child(app)
	while not app.world.built: await process_frame
	var s: Dictionary = app.state
	check(X.validate(s) == "", "Fresh B10 state validates")
	check(s.expansion.contact != "" and not app.opening_projection().settlements.has("frontier_contact"), "Faction site starts outside observation")
	s = X.command(s,{"type":"deployBuilder","person":"pop_a"}).state
	s.tactics.auto = false
	var departure = s.duplicate(true)
	var home = s.cohorts.pop_a.state.tileId
	var adjacent = X.R.neighbours(s,home).filter(func(key): return s.tiles[key].baseTerrain != "water" and s.tiles[key].obstacle == "")[0]
	var before = X.R.step_cost(s,home,adjacent)
	var road = {"type":"layRoad","person":"pop_a"}
	var first = X.command(s,road)
	s = first.state
	s = travel(s,adjacent)
	var second = X.command(s,road)
	s = second.state
	check(second.ok and s.expansion.roads.size() == 2 and X.R.step_cost(s,home,adjacent) < before,"Two paid roads reduce actual route cost: %s / %s (%s, %s)" % [first.message,second.message,home,adjacent])
	check(X.validate(JSON.parse_string(JSON.stringify(s))) == "", "Roads survive save validation")
	s = departure
	var site = candidate(s)
	check(site != "", "Expansion site reachable")
	if site != "":
		s = travel(s,site)
		var found = X.command(s,{"type":"foundOutpost","person":"pop_a"})
		check(found.ok, "Civilian reaches and founds an outpost: "+found.message)
		if found.ok:
			check(found.state.resources.industry == s.resources.industry-2 and found.state.resources.minerals == s.resources.minerals-3 and found.state.resources.food == s.resources.food-4,"Founding pays materials")
			s = found.state
			check(s.cohorts.has("pop_a") and s.construction.holders.is_empty() and X.staffed(s,"pop_a") == site,"Founder retained and kit returned")
			var options = X.R.neighbours(s,site).filter(func(key): return X.reason(s,{"type":"workOutpost","person":"pop_a","tile":key}) == "")
			check(not options.is_empty(),"Outpost has a legal work site")
			if not options.is_empty():
				s = X.command(s,{"type":"workOutpost","person":"pop_a","tile":options[0]}).state
				check(X.E.reason(s,{"type":"assign","person":"pop_b","job":"tile:"+options[0]}).contains("frontier"),"Outpost work cannot be double-assigned")
				var crop = X.R.tile_yield(s,options[0]).food
				var turn = X.command(s,{"type":"endTurn"})
				check(turn.ok and turn.state.lastLedger.opening.food == s.resources.food and turn.state.lastLedger.gross.food >= crop,"Operating outpost contributes Food to the turn ledger")
			check(X.validate(JSON.parse_string(JSON.stringify(s))) == "", "Operating outpost survives save validation")
			app.state = s
			app.choose_person("pop_a",false)
			app.show_mode("Orders")
			app.refresh()
			check(app.projected.settlements.has("outpost_"+site),"Outpost visible in normal game projection")
			var leave = X.command(s,{"type":"leaveOutpost","person":"pop_a"})
			check(leave.ok and leave.state.settlements.has("main") and not X.command(leave.state,{"type":"leaveOutpost","person":"pop_a"}).ok,"Evacuation preserves the last settlement")
			var siege = s.duplicate(true)
			var animals = siege.xenos.units.values()
			if not animals.is_empty():
				animals[0].kind = "predator"
				animals[0].tile = site
				var warned = X.prepare(siege)
				var lost = X.prepare(warned)
				check(warned.expansion.outposts[site].pressure == 1 and lost.expansion.lost == 1 and lost.expansion.outposts.is_empty() and lost.cohorts.has("pop_a"),"Two exposed turns can overrun an outpost without deleting its crew")
				lost.xenos.units.clear()
				X.Tactical.X.sync_tiles(lost)
				for resource in X.COST: X.E.change(lost,resource,X.COST[resource])
				check(X.command(lost,{"type":"foundOutpost","person":"pop_a"}).ok,"Survivor can refound after the danger clears")
			s.cohorts.explorer.state.tileId = s.expansion.contact
			X.Tactical.K.observe(s)
			check(app.opening_projection().settlementOwners.get("frontier_contact") == "red","Observed faction contact has distinct ownership")
	while app.world.building: await process_frame
	app.free()
	for i in range(3): await process_frame
	print(JSON.stringify({"suite":"B10","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
