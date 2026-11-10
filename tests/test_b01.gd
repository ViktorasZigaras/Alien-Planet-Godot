extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const S = preload("res://scripts/civilization_session.gd")
const F = preload("res://scripts/shell_fixture.gd")
var failures = []
var checks = 0
var measurements = {}
func check(value: bool,description: String) -> void:
	checks += 1
	if not value: failures.append(description); printerr("FAIL: "+description)
func equivalent(a,b) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size()!=b.size(): return false
		for k in a:
			if not b.has(k) or not equivalent(a[k],b[k]): return false
		return true
	if a is Array and b is Array:
		if a.size()!=b.size(): return false
		for i in range(a.size()):
			if not equivalent(a[i],b[i]): return false
		return true
	if (a is float or a is int) and (b is float or b is int): return abs(float(a)-float(b))<0.000000001
	return a==b
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s = F.initial()
	check(S.validate(s) == "","B01 validates: "+S.validate(s))
	check(s.tiles.size() == 63 and s.cohorts.size() == 1 and s.settlements.size() == 1,"explicit minimal fixture")
	check(s.civilizations.is_empty() and s.xenos.units.is_empty(),"no hidden rivals or wildlife")
	var initial = JSON.stringify(s)
	var focused = S.command(s,{"type":"focusPerson","cohortId":"pop_a"})
	check(focused.ok and JSON.stringify(focused.state) == initial,"selection compatibility command is read only")
	var invalid = S.command(s,{"type":"queueMove","unitId":"missing","target":"3,3"})
	check(not invalid.ok and invalid.message != "" and JSON.stringify(invalid.state) == initial,"illegal command explains rejection without mutation")
	check(not S.command(s,{"type":"found","cohortId":"pop_a"}).ok,"legacy founding unavailable in shell")
	var neighbours = R.neighbours(s,"2,3").filter(func(k):return s.tiles[k].baseTerrain != "water")
	check(neighbours.size() >= 2,"at least two reachable choices from station")
	var rough = neighbours.filter(func(k):return R.step_cost(s,"2,3",k) > 1)
	check(not rough.is_empty(),"rough-terrain alternative exists")
	var target = rough[0] if not rough.is_empty() else neighbours[0]
	check(R.routes(s,"2,3").costs.size() >= 20,"connected land allows a return journey")
	var expected = R.step_cost(s,"2,3",target)
	s = S.start_recording(s)
	var command = {"type":"queueMove","unitId":"pop_a","target":target}
	var result = S.command(s,command)
	check(result.ok,"ordinary movement accepted")
	s = result.state
	check(s.testing.sequence == 1 and s.testing.events.size() == 1,"one intent recorded once")
	check(s.cohorts.pop_a.state.movementRemaining == 0,"one movement budget spent once")
	if expected > 1:
		check(s.cohorts.pop_a.state.tileId == "2,3" and s.moveProgress.pop_a == 1,"hard step retains partial payment")
	var loaded = S.migrate(JSON.parse_string(JSON.stringify(s)))
	check(S.validate(loaded) == "","in-flight JSON save validates: "+S.validate(loaded))
	var continued = S.command(loaded,{"type":"endTurn"}).state
	var direct = S.command(s,{"type":"endTurn"}).state
	check(equivalent(continued,direct),"save continuation matches direct execution")
	s = direct
	for i in range(4):
		if s.cohorts.pop_a.state.tileId == target: break
		s = S.command(s,{"type":"endTurn"}).state
	check(s.cohorts.pop_a.state.tileId == target and not s.movementQueues.has("pop_a"),"queued travel reaches destination")
	check(s.resources == F.initial().resources and s.cohorts.size() == 1 and s.settlements.main.growth == 0,"End Turn does not run legacy economy or growth")
	if not FileAccess.file_exists("res://reports/b01/benchmark_state.json"):
		var snapshot_file = FileAccess.open("res://reports/b01/benchmark_state.json",FileAccess.WRITE)
		snapshot_file.store_string(JSON.stringify(s)); snapshot_file.close()
	var replay = S.from_recording(s.testing.initial)
	for event in s.testing.events:
		var repeated = S.command_for(replay,event.player,event.command,event.policyRule)
		check(repeated.ok == event.accepted,"replay acceptance #"+str(event.sequence))
		replay = repeated.state
	var actual = s.duplicate(true); actual.testing = replay.testing
	check(JSON.stringify(replay) == JSON.stringify(actual),"recorded inputs reproduce complete physical state")
	check(S.validate(s) == "","recorded state validates")
	var queued = S.command(s,{"type":"queueMove","unitId":"pop_a","target":"8,6"}).state
	var appended = S.command(queued,{"type":"queueMove","unitId":"pop_a","target":"2,3","append":true})
	check(appended.ok and appended.state.movementQueues.pop_a.back() == "2,3","waypoint appends a legal return route")
	var stopped = S.command(appended.state,{"type":"cancelMove","unitId":"pop_a"})
	check(stopped.ok and not stopped.state.movementQueues.has("pop_a") and not stopped.state.moveProgress.has("pop_a"),"explicit cancellation clears route and partial payment")
	var tampered = F.initial()
	tampered.cohorts.other = tampered.cohorts.pop_a; tampered.cohorts.erase("pop_a"); tampered.cohorts.other.id = "other"
	check(S.validate(tampered) != "","renamed fixture identity rejected before UI load")
	var app = load("res://b01.tscn").instantiate()
	root.size = Vector2i(1920,1080)
	root.add_child(app)
	while not app.world_view.built: await process_frame
	for i in range(3): await process_frame
	var before = JSON.stringify(app.state)
	var projections = app.projection_count
	var started = Time.get_ticks_usec()
	for i in range(100): app.select_tile(neighbours[i%neighbours.size()]); app.select_unit("pop_a")
	measurements.selection_200_us = Time.get_ticks_usec()-started
	check(JSON.stringify(app.state) == before,"200 selections do not change game state")
	check(app.projection_count == projections,"selection reuses permitted world snapshot")
	check(app.world_view.supply.is_empty(),"disabled supply overlay has no route field")
	var camera_before = app.world_view.target
	var down = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_MIDDLE; down.pressed = true
	app.world_view._gui_input(down)
	var drag = InputEventMouseMotion.new(); drag.relative = Vector2(25,15)
	app.world_view._gui_input(drag)
	down.pressed = false; app.world_view._gui_input(down)
	check(app.world_view.target != camera_before and JSON.stringify(app.state) == before,"panning changes camera only")
	var camera_size = app.world_view.camera.size
	var wheel = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP; wheel.pressed = true
	app.world_view._gui_input(wheel)
	check(app.world_view.camera.size == camera_size,"wheel does not zoom fixed-scale view")
	app.world_view.focus_tile(target)
	check(app.world_view.camera.size == camera_size,"centering keeps fixed scale")
	for key in ["2,3",target]:
		check(app.world_view.pick(app.world_view.screen(app.world_view.surface(key))) == key,"3D ray pick agrees with hex "+key)
	app.select_tile(target)
	check(app.issue(command),"UI order uses ordinary command")
	check(app.save_to("user://b01-test-save.json"),"save file written")
	var saved = JSON.stringify(app.state)
	var saved_tile = app.selected_tile
	app.issue({"type":"endTurn"})
	check(app.load_from("user://b01-test-save.json"),"save file loaded")
	check(equivalent(app.state,JSON.parse_string(saved)) and app.selected_tile == saved_tile,"game and view restored separately")
	var after_save = app.state.duplicate(true)
	var direct_after = S.command(after_save,{"type":"endTurn"}).state
	app.world_view.set_animation(false)
	app.issue({"type":"endTurn"})
	check(JSON.stringify(app.state) == JSON.stringify(direct_after),"no-presentation and motion-off UI turn agree")
	var f = FileAccess.open("user://b01-invalid.json",FileAccess.WRITE)
	f.store_string("{invalid"); f.close()
	before = JSON.stringify(app.state)
	check(not app.load_from("user://b01-invalid.json") and JSON.stringify(app.state) == before,"bad save preserves current game")
	app.find_child("EndTurn",true,false).grab_focus()
	var turn_before = app.state.turn
	var key = InputEventKey.new(); key.keycode = KEY_SPACE; key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	key = key.duplicate(); key.pressed = false; Input.parse_input_event(key)
	check(app.state.turn == turn_before+1,"Space with focused button applies End Turn once")
	for i in range(3): await process_frame
	while app.world_view.building: await process_frame
	var stats = Performance.get_monitor(Performance.MEMORY_STATIC)
	measurements.static_memory_bytes = stats
	measurements.save_bytes = FileAccess.get_file_as_bytes("user://b01-test-save.json").size()
	measurements.fixture_state_bytes = JSON.stringify(F.initial()).length()
	measurements.recorded_state_bytes = JSON.stringify(s).length()
	started = Time.get_ticks_usec()
	var clock_state = F.initial()
	for i in range(100): clock_state = S.command(clock_state,{"type":"endTurn"}).state
	measurements.turn_100_us = Time.get_ticks_usec()-started
	app.free()
	for i in range(3): await process_frame
	var report = {"build":"0.911-b01-review","seed":731,"fixture":F.ID,"checks":checks,"failures":failures,"measurements":measurements,"balance":"local movement choices only; no strategic economy/AI claim","renderer":"headless correctness; not GPU performance"}
	var out = FileAccess.open("res://reports/b01/checks.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(report,"\t")); out.close()
	print(JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
