extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
const X = preload("res://scripts/xeno_ecology.gd")
const R = preload("res://scripts/game_rules.gd")
const C = preload("res://scripts/asset_catalogue.gd")
var checks = 0
var failures = []
func check(value: bool,label: String):
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func same_ecology(a: Dictionary,b: Dictionary) -> bool:
	# JSON parses whole numbers as floats. Normalize that representation and
	# tolerate serialization rounding in cosmetic facing, not logical positions/RNG.
	if a.units.keys().size() != b.units.keys().size(): return false
	var aa = a.duplicate(true); var bb = b.duplicate(true)
	for id in aa.units:
		if not bb.units.has(id) or not is_equal_approx(aa.units[id].facing,bb.units[id].facing): return false
		aa.units[id].facing = 0; bb.units[id].facing = 0
	return JSON.parse_string(JSON.stringify(aa)) == JSON.parse_string(JSON.stringify(bb))
func isolated() -> Dictionary:
	var s = S.initial_state()
	s.xenos.units = {"xeno_0003":s.xenos.units.xeno_0003}
	return s
func run():
	var s = S.initial_state()
	check(S.validate(s) == "","Xeno world valid")
	check(s.tiles[s.xenos.nests.nest_1.tile].baseTerrain == "fungal","Nest starts in purple biome")
	check(not S.players(s).has("xeno") and not s.civilizations.has("xeno"),"Wildlife is not a civilization")
	check(X.members(s.xenos,"nest_1",true).size() == 2 and X.members(s.xenos,"nest_1",false).size() == 2,"Small starting brood")
	var blue = JSON.stringify(S.own_state(s))
	var red = JSON.stringify(s.civilizations.red)
	var a = s.duplicate(true)
	var b = s.duplicate(true)
	for i in range(45):
		if i%5 == 0: b = S.migrate(JSON.parse_string(JSON.stringify(b)))
		X.tick(a,S.players(a)); X.tick(b,S.players(b))
		check(S.validate(a) == "","Ecology valid "+str(i))
		check(same_ecology(a.xenos,b.xenos),"Ecology deterministic through saves "+str(i))
		check(X.members(a.xenos,"nest_1",true).size() <= 3 and X.members(a.xenos,"nest_1",false).size() <= 6,"Nest caps hold "+str(i))
	check(a.resources == s.resources and a.civilizations.red.resources == s.civilizations.red.resources,"Uncontacted ecology does not spend civilization resources")
	check(a.xenos.mass.size() > 3,"Workers spread the mat")
	check(a.xenos.units.values().any(func(u):return u.kind == "armored"),"Harvested minerals support armored births")
	check(a.xenos.lastEvents.any(func(e):return e.type == "harvest"),"Worker extraction produces explicit events")
	# Controlled paired extraction: same tile/worker, only mat presence changes.
	var coated = S.initial_state()
	var worker = coated.xenos.units.xeno_0001
	var tile = worker.tile
	coated.tiles[tile].relief = "hills"
	coated.xenos.nests.nest_1.minerals = 10
	coated.xenos.mass = {tile:"nest_1"}
	coated.xenos.tick = 1
	var bare = coated.duplicate(true); bare.xenos.mass = {}
	X.worker_turn(coated,coated.xenos,worker,0)
	X.worker_turn(bare,bare.xenos,bare.xenos.units.xeno_0001,0)
	check(coated.xenos.nests.nest_1.biomass == bare.xenos.nests.nest_1.biomass+1,"Mat adds biomass production")
	check(coated.xenos.nests.nest_1.minerals == bare.xenos.nests.nest_1.minerals+1,"Mat adds mineral extraction")
	# A nest with biomass but no minerals cannot hatch heavy bodies.
	var poor = S.initial_state(); poor.xenos.units = {}
	X.spawn(poor.xenos,"nest_1","larva"); X.spawn(poor.xenos,"nest_1","larva"); X.spawn(poor.xenos,"nest_1","larva")
	poor.xenos.nests.nest_1.biomass = 100
	poor.xenos.nests.nest_1.minerals = 0
	for poor_tile in poor.tiles.values():
		if R.distance(poor_tile,poor.tiles[X.NEST_TILE]) <= 3: poor_tile.relief = "flat"; poor_tile.bonus = ""
	poor.civilizations.red.tiles = poor.tiles.duplicate(true)
	for u in poor.xenos.units.values():u.tile = poor.xenos.nests.nest_1.tile
	X.tick(poor,S.players(poor))
	check(poor.xenos.units.values().filter(func(u):return u.kind == "armored").is_empty(),"Heavy birth not free without minerals")
	var contact = isolated()
	var hunter = contact.xenos.units.xeno_0003
	hunter.tile = "3,3"; hunter.previousTile = "3,3"
	var victim = {"id":"pop_a","player":"blue","tile":"1,3","person":contact.cohorts.pop_a}
	X.predator_turn(contact,S.players(contact),hunter)
	check(hunter.activity == "attacking" and contact.xenos.lastEvents.any(func(e):return e.type == "attack"),"Predator pursues and attacks nearby people")
	check(S.validate(contact) == "","Encounter leaves valid world")
	# Death cleanup includes carried passengers and in-progress projects.
	var casualty = isolated()
	casualty.cohorts.pop_c.state.job = null
	casualty = S.command_for(casualty,"blue",{"type":"board","cohortId":"pop_c","transportId":"pop_rover"}).state
	casualty.xenos.humanHealth.pop_rover = 1
	var attacker = casualty.xenos.units.xeno_0003
	X.hit_person(casualty,S.players(casualty),attacker,{"id":"pop_rover","player":"blue","tile":"2,3","person":casualty.cohorts.pop_rover})
	check(not casualty.cohorts.has("pop_rover") and casualty.cohorts.pop_c.state.kind == "mobile","Destroyed carrier releases passengers")
	check(S.validate(casualty) == "","Casualty cleanup preserves queues/cargo references")
	var manual = isolated()
	manual.xenos.units.xeno_0003.tile = "3,3"
	manual.cohorts.pop_rover.qualification = "Soldier"
	manual.cohorts.pop_rover.equipment.append("small_arms")
	manual.xenos.units.xeno_0003.hp = 1
	var attack = {"type":"attackXeno","cohortId":"pop_rover","targetId":"xeno_0003","mode":"ranged"}
	var hit = S.command_for(manual,"blue",attack)
	check(hit.ok and not hit.state.xenos.units.has("xeno_0003"),"Armed person can attack adjacent wildlife")
	check(S.validate(hit.state) == "","Direct attack produces valid state")
	var collapse = hit.state
	collapse.xenos.nests.nest_1.tile = "2,3"
	X.burn_occupied(collapse)
	check(collapse.xenos.nests.nest_1.burned,"Nest occupation disables operation without erasing mat")
	check(S.validate(collapse) == "","Disabled nest has no dangling references")
	var hungry = S.initial_state()
	for u in hungry.xenos.units.values():u.kind = "predator";u.hp = 1;hungry.xenos.lastAnimalAttack[u.id] = int(hungry.turn)
	# Keep under the shared predator cap; without workers/bio hunger removes them.
	hungry.xenos.nests.nest_1.biomass = 0
	X.tick(hungry,S.players(hungry))
	check(hungry.xenos.units.is_empty(),"Unfed brood cannot persist freely")
	var invalid = S.initial_state(); invalid.xenos.mass["0,0"] = "nest_1"
	check(S.validate(invalid) != "","Mat cannot occupy water")
	invalid = S.initial_state(); invalid.xenos.units.xeno_0001.nestId = "not_a_nest"
	check(S.validate(invalid) != "","Unknown nest reference rejected")
	var older = S.initial_state(); older.worldVersion = 1; older.erase("xenos"); older.schemaVersion = 9; older.rulesVersion = 9
	var upgraded = S.migrate(older)
	check(S.validate(upgraded) == "" and upgraded.schemaVersion == 11 and upgraded.worldVersion == 3,"0.902 save migrates with ecology")
	var trace = S.start_recording(S.initial_state())
	trace = S.command(trace,{"type":"endTurn"}).state
	check(trace.testing.events.any(func(e):return e.player == "xeno" and e.has("environmentEvents")),"Ecology actions/outcomes enter recorder")
	var replay = S.attach(trace.testing.initial.blue)
	replay.civilizations.red = trace.testing.initial.red.duplicate(true)
	replay.xenos = trace.testing.initial.xenos.duplicate(true)
	for e in trace.testing.events:replay = S.command_for(replay,e.player,e.command,e.policyRule).state
	check(S.summary(replay) == S.summary(trace) and same_ecology(replay.xenos,trace.xenos),"Recorded ecology replays without a language model")
	check(C.entries().size() == 144 and C.library_entries().size() == 89,"Nest, three bodies and two mat assets in catalogue")
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate(); root.add_child(app)
	await process_frame
	app.set_map_mode(1)
	while not app.world_view.built:await process_frame
	check(app.world_view.xeno_actors.size() > 0,"Live 3D wildlife models built")
	app.set_map_mode(0)
	check(app.world_view.xeno_actors.values().all(func(u):return not u.is_processing()),"Hidden wildlife animation pauses")
	app.queue_free();await process_frame
	print("0.903 CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
