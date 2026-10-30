extends SceneTree
const R = preload("res://scripts/game_rules.gd")
var checks = 0
var failures = []
func check(ok: bool,what: String) -> void:
	checks += 1
	if not ok: failures.append(what); printerr("FAIL: ",what)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.map_view.focus_tile("4,3")
	var old_size = app.map_view.size
	app.map_view.size += Vector2(120,20)
	var focused = app.map_view.map_origin()+app.map_view.centre(app.state.tiles["4,3"])*app.map_view.map_scale()
	check(focused.distance_to(app.map_view.size/2) < 0.1,"Opening focus stays centred after layout resize")
	app.map_view.size = old_size
	check(app.resource_labels.size() == 6,"Six stock displays")
	check(app.tech_tabs.get_tab_count() == 5,"Five technology tabs")
	var initial = JSON.stringify(app.state)
	var map = app.map_view
	map.fit_map()
	var c = map.map_origin()+map.centre(app.state.tiles["3,3"])*map.map_scale()
	var clicks = []
	map.tile_selected.connect(func(key): clicks.append(key))
	var down = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = c
	down.pressed = true
	map._gui_input(down)
	var up = down.duplicate()
	up.pressed = false
	map._gui_input(up)
	check(clicks == ["3,3"],"Click selects only on release")
	var pan = map.pan
	map._gui_input(down)
	var motion = InputEventMouseMotion.new()
	motion.position = c+Vector2(50,30)
	motion.relative = Vector2(50,30)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	map._gui_input(motion)
	up.position = motion.position
	map._gui_input(up)
	check(map.pan == pan+Vector2(motion.relative.x,-motion.relative.y),"Left drag preserves horizontal and inverts vertical")
	check(clicks.size() == 1,"Drag does not select")
	check(JSON.stringify(app.state) == initial,"Navigation preserves simulation")
	map.fit_map()
	check(map.pan == Vector2.ZERO and map.zoom == 1,"Fit resets navigation")
	var world_width = map.map_dimensions().x*map.map_scale()
	check(world_width <= map.size.x+1,"Fit includes enlarged map")
	check(app.issue({"type":"equip","cohortId":"pop_a","item":"work_suit"}),"Equip through UI command")
	check(app.issue({"type":"mobilise","cohortId":"pop_a"}),"Mobilise through UI")
	check(app.selected_unit == "pop_a","Deployed person selected")
	check(app.issue({"type":"endTurn"}),"End turn UI")
	var turn = app.state.turn
	map.move_requested.emit("3,3",false)
	check(app.state.turn == turn,"Movement needs no turn confirmation")
	check(app.state.cohorts.pop_a.state.tileId == "3,3","Map right-click issues movement")
	var save_path = "user://batch-test-save.json"
	check(app.save_to(save_path),"Save new state")
	var saved = JSON.parse_string(JSON.stringify(app.state))
	app.issue({"type":"endTurn"})
	check(app.load_from(save_path),"Load new state")
	check(JSON.parse_string(JSON.stringify(app.state)) == saved,"Save roundtrip including equipment")
	# Malformed import leaves the running state intact.
	var f = FileAccess.open("user://batch-invalid.json",FileAccess.WRITE)
	f.store_string('{"schemaVersion":6}')
	f.close()
	check(not app.load_from("user://batch-invalid.json"),"Malformed import rejected")
	check(JSON.parse_string(JSON.stringify(app.state)) == saved,"Failed import preserves state")
	app.reset_game()
	check(R.validate(app.state) == "","Reset valid")
	check(app.selected_unit == "" and app.selected_tile == "2,3","Reset selection")
	app.queue_free()
	await process_frame
	print("BATCH UI CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
