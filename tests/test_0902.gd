extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const S = preload("res://scripts/civilization_session.gd")
const C = preload("res://scripts/claim_map.gd")
var checks = 0
var failures = []
func check(value: bool,label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func run():
	var s = S.initial_state()
	check(S.validate(s) == "","Initial two-player state valid")
	check(s.civilizations.red.tiles[S.RED_TOWN].baseTerrain == "grassland","Southern green landing")
	var players = S.players(s)
	var claimed = C.owners(players)
	for key in claimed:
		var player = players[claimed[key]]
		check(player.settlements.values().any(func(t):return R.distance(player.tiles[t.tileId],player.tiles[key]) <= 2),"Only radius-two land claimed "+key)
	for id in players:
		for t in players[id].settlements.values():
			for tile in s.tiles.values():
				if R.distance(s.tiles[t.tileId],tile) <= 2:check(claimed.get(tile.id) == id,"Town claim radius "+id+tile.id)
	var degrees = {}
	for edge in C.boundary(s.tiles,claimed):
		var midpoint = (edge.a+edge.b)/2
		for point in [edge.a,edge.b]:
			var key = str(point.snapped(Vector2.ONE*0.001))+edge.player
			degrees[key] = degrees.get(key,0)+1
	check(degrees.values().all(func(n):return n == 2),"Continuous closed outer rings without internal branches")
	var red_before = JSON.stringify(s.civilizations.red)
	var changed = S.command_for(s,"blue",{"type":"equip","cohortId":"pop_c","item":"work_suit"})
	check(changed.ok and JSON.stringify(changed.state.civilizations.red) == red_before,"Blue equipment does not mutate red")
	var blue_before = JSON.stringify(S.own_state(s))
	changed = S.command_for(s,"red",{"type":"equip","cohortId":"red_person_0","item":"work_suit"})
	check(changed.ok and JSON.stringify(S.own_state(changed.state)) == blue_before,"Red equipment does not mutate blue")
	var red = s.civilizations.red
	red.resources.science = 100
	changed = S.command_for(s,"red",{"type":"develop","nodeId":"cultivation"})
	check(changed.ok and "cultivation" not in changed.state.completed and "cultivation" in changed.state.civilizations.red.completed,"Research progress/cost are private")
	check(S.reason_for(s,"blue",{"type":"assign","cohortId":"red_person_0","job":null}) != "","Cannot issue foreign-person orders")
	check(S.reason_for(s,"blue",{"type":"improve","cohortId":"pop_c","improvement":"road","target":S.RED_TOWN}) != "","Cannot improve foreign claims")
	var ledger = R.economy(s)
	red.resources.food += 1000
	check(R.economy(s) == ledger,"Foreign stocks do not enter blue forecast")
	var projection = S.projection(s)
	check(projection.settlements.has("main") and projection.settlements.has("field") and projection.settlements.has("red_town"),"Both players appear in map projection")
	check(projection.resources == s.resources and projection.completed == s.completed,"Map projection uses blue information overlays")
	check(projection.cohortOwners.red_person_0 == "red","Map cohort ownership explicit")
	var initial = S.initial_state()
	var a = initial.duplicate(true)
	var b = initial.duplicate(true)
	for i in range(65):
		if i%10 == 0: b = S.migrate(JSON.parse_string(JSON.stringify(b)))
		a = S.command(a,{"type":"endTurn"}).state
		b = S.command(b,{"type":"endTurn"}).state
		check(S.validate(a) == "","Both independent turns valid "+str(i))
		check(S.summary(a) == S.summary(b),"Policy deterministic through save/load "+str(i))
	check(a.civilizations.red.cohorts.size() > 5,"Red grows population")
	check(a.civilizations.red.districts.values().any(func(d):return d.type == "security") and a.civilizations.red.districts.size() == 5,"Red develops all five district types")
	check("protective_equipment" in a.civilizations.red.completed and "perimeter_defence" in a.civilizations.red.completed,"Red obtains current army technologies")
	check(a.completed.is_empty() and a.improvements.is_empty(),"Red development does not unlock or improve blue")
	var recorded = S.start_recording(initial)
	var invalid = S.command(recorded,{"type":"assign","cohortId":"not_a_person","job":null})
	check(not invalid.ok and invalid.state.testing.events.size() == 1,"Rejected human command recorded")
	recorded = invalid.state
	for i in range(3):recorded = S.command(recorded,{"type":"endTurn"}).state
	check(recorded.testing.events.any(func(e):return e.player == "red" and e.policyRule != "human_command"),"Red policy labels recorded")
	check(recorded.testing.events.any(func(e):return e.player == "blue"),"Human actions recorded")
	var replay = S.attach(recorded.testing.initial.blue)
	replay.civilizations.red = recorded.testing.initial.red.duplicate(true)
	for event in recorded.testing.events:
		var applied = S.command_for(replay,event.player,event.command,event.policyRule)
		check(applied.ok == event.accepted,"Replay acceptance")
		replay = applied.state
	check(S.summary(replay) == S.summary(recorded),"Exported commands reproduce outcomes without GPT")
	recorded = S.finish_recording(recorded)
	check(S.validate(recorded) == "" and S.report(recorded).outcome.status == "stopped","Explicit outcome and complete recorded save valid")
	check(S.validate(S.migrate(JSON.parse_string(JSON.stringify(recorded)))) == "","Two-player save/recording roundtrip")
	check(S.validate(S.migrate(R.initial_state())) == "","Older single-player save upgraded")
	var legacy = R.initial_state()
	legacy.schemaVersion = 8
	legacy.rulesVersion = 8
	var migrated_legacy = S.migrate(legacy)
	check(S.validate(migrated_legacy) == "" and migrated_legacy.schemaVersion == 11,"0.901 save migrates safely to multiplayer schema 9")
	var bad = recorded.duplicate(true)
	bad.civilizations.red.resources.food = -1
	check(S.validate(bad) != "","Invalid hidden rival save rejected")
	root.size = Vector2i(1440,900)
	var app=load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.state = S.start_recording(app.state)
	check(app.issue({"type":"endTurn"}),"UI advances both players")
	app.set_map_mode(1)
	while not app.world_view.built:await process_frame
	check(app.world_view.state.settlementOwners.red_town == "red","3D uses shared player projection")
	app.selected_tile = S.RED_TOWN
	app.render()
	check(app.export_test("user://test-0902-record.json"),"Native testing export")
	var exported = JSON.parse_string(FileAccess.get_file_as_string("user://test-0902-record.json"))
	check(exported.format == "alien-planet-test-v4" and exported.events.size() > 0,"Export contains actual actions/outcomes")
	app.queue_free()
	await process_frame
	print("0.902 CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
