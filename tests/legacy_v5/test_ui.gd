extends SceneTree
const Rules = preload("res://scripts/game_rules.gd")
var checks = 0
var failures = []
var app

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		printerr("FAIL: "+message)

func command_button(cmd: Dictionary) -> Button:
	for node in app.find_children("*", "Button", true, false):
		if node.has_meta("command") and node.get_meta("command") == cmd:
			return node
	return null

func press(cmd: Dictionary) -> void:
	var node = command_button(cmd)
	check(node != null, "UI contains command "+str(cmd))
	if node != null:
		check(not node.disabled, "UI enables legal command "+str(cmd))
		if not node.disabled: node.pressed.emit()

func job(value) -> void:
	var option = app.orders.find_child("JobAssignment", true, false)
	check(option != null, "Job dropdown exists")
	if option != null:
		var index = -1
		for i in range(option.item_count):
			if option.get_item_metadata(i) == value: index = i
		check(index >= 0, "Dropdown contains requested job")
		if index >= 0:
			check(not option.is_item_disabled(index), "Job is available")
			option.item_selected.emit(index)

func tick(n: int = 1) -> void:
	for i in range(n): app.end_button.pressed.emit()

func run() -> void:
	root.size = Vector2i(1440, 900)
	app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for frame in range(8): await process_frame
	check(app.size == Vector2(1440, 900), "Root follows viewport")
	check(app.map_view.size.x >= 500 and app.map_view.size.y >= 330, "Map has useful size")
	check(app.tabs.size.x >= 390, "Inspector has useful width")
	print("LAYOUT 1440: app=", app.size, " status=", app.status_label.get_global_rect(), " tabs=", app.tabs.get_global_rect(), " map=", app.map_view.get_global_rect())
	check(app.status_label.get_global_rect().end.y <= 900, "Status stays in window")
	check(app.end_button.get_global_rect().end.x <= 1440, "Turn control stays in window")
	check(app.map_view.pick(app.map_view.map_origin()+app.map_view.centre(app.state.tiles["2,3"])*app.map_view.map_scale()) == "2,3", "Hex picking targets centres")
	check(app.map_view.pick(Vector2(-1000,-1000)) == "", "Outside click rejected")
	tick(2)
	press({"type":"develop","nodeId":"technical_education"})
	app.selected_cohort = "pop_c"
	app.render()
	press({"type":"train","cohortId":"pop_c","qualification":"Specialist"})
	tick(2)
	job("building:lab_main")
	tick()
	press({"type":"develop","nodeId":"standard_tooling"})
	press({"type":"develop","nodeId":"field_coordination"})
	app.selected_cohort = "pop_b"
	app.render()
	job(null)
	app.select_tile("3,2")
	press({"type":"build","order":"district","cohortId":"pop_b","target":"3,2"})
	tick()
	press({"type":"build","order":"workshop","cohortId":"pop_b","districtId":"district_main"})
	tick(2)
	app.select_tile("2,3")
	job("building:workshop_main")
	tick()
	check(app.state.turn == 10 and app.state.resources.food == 21 and app.state.resources.industry == 10 and app.state.resources.credits == 23 and app.state.resources.research == 13 and app.state.resources.influence == 8, "UI plays exact turn-10 economy")
	app.selected_cohort = "pop_c"
	app.render()
	press({"type":"mobilise","cohortId":"pop_c"})
	check(app.selected_unit == "pop_c", "Mobilise selects the same cohort on map")
	var blocked = Rules.reason(app.state,{"type":"move","unitId":"pop_c","target":"3,3"})
	check(not blocked.is_empty(), "UI movement starts at zero")
	tick()
	for q in range(3,7):
		app.select_tile("%d,3" % q)
		press({"type":"move","unitId":"pop_c","target":"%d,3" % q})
		if q < 6: tick()
	press({"type":"join","cohortId":"pop_c"})
	job("building:lab_field")
	tick()
	check(app.state.cohorts.pop_c.state.settlementId == "field", "UI relocation reaches station")
	check(Rules.forecast(app.state).research == 3, "Station produces specialist research")
	check(app.save_to("user://test-ui-save.json"), "Native save writes JSON")
	var before = JSON.stringify(app.state)
	tick()
	check(app.load_from("user://test-ui-save.json"), "Native load reads JSON")
	check(JSON.stringify(app.state) == before, "Native save/load preserves full state")
	var file = FileAccess.open("user://test-ui-bad.json", FileAccess.WRITE)
	file.store_string('{"schemaVersion":999}')
	file.close()
	check(not app.load_from("user://test-ui-bad.json"), "Bad save rejected by UI")
	check(JSON.stringify(app.state) == before, "Failed load leaves state intact")
	app.reset_game()
	check(app.state.resources == Rules.initial_state().resources and app.state.turn == 1, "Native reset restores preset")
	var ev = InputEventMouseButton.new()
	ev.position = Vector2(300,250)
	ev.button_index = MOUSE_BUTTON_WHEEL_UP
	ev.pressed = true
	app.map_view._gui_input(ev)
	check(app.map_view.zoom > 1.0, "Mouse-wheel zoom works")
	app.map_view.fit_map()
	check(app.map_view.zoom == 1.0 and app.map_view.pan == Vector2.ZERO, "Fit map resets zoom and pan")
	# Current batch: exercise actual new controls, not only engine commands.
	var art = preload("res://scripts/starter_art.gd")
	for key in Rules.RESOURCES:
		check(art.resource_icon(key) != null, "Resource icon is available: "+key)
	var yield_toggle = app.find_child("YieldOverlay",true,false)
	check(yield_toggle != null, "Yield overlay control exists")
	yield_toggle.button_pressed = true
	check(app.map_view.show_yields, "Yield toggle changes map layer")
	check(Rules.worker_at(app.state,"1,3").id == "pop_a", "Map can name the actual tile worker")
	app.state.resources.industry = 10
	app.state.resources.food = 40
	app.selected_cohort = "pop_b"
	app.render()
	job(null)
	app.select_tile("1,3")
	press({"type":"improve","improvement":"farm","cohortId":"pop_b","target":"1,3"})
	tick()
	check(Rules.tile_yield(app.state,"1,3").food == 4, "UI farm completes with food bonus")
	press({"type":"improve","improvement":"road","cohortId":"pop_b","target":"1,3"})
	tick()
	check(is_equal_approx(Rules.movement_cost(app.state,"1,3"),1.0/3), "UI road completes with fractional movement")
	app.select_tile("2,3")
	press({"type":"grow","settlementId":"main"})
	check(app.state.cohorts.size() == 5 and app.selected_cohort == "pop_001", "Town growth selects the newly created Worker")
	job("tile:3,2")
	check(Rules.worker_at(app.state,"3,2").id == "pop_001", "New Worker can be visually attributed to a tile")
	app.select_mobile("rover")
	app.map_view.move_requested.emit("6,3",false)
	check(app.state.movementQueues.has("rover"), "Right-click queues a route through native signal")
	press({"type":"cancelMove","unitId":"rover"})
	check(not app.state.movementQueues.has("rover"), "Native cancel queue button works")
	app.map_view.move_requested.emit("6,3",false)
	tick()
	check(app.state.units.rover.tileId == "6,3" and not app.state.movementQueues.has("rover"), "Queued rover completes on following turn")
	check(app.save_to("user://test-ui-expanded.json"), "New-feature save writes")
	var expanded = JSON.stringify(app.state)
	app.reset_game()
	check(app.load_from("user://test-ui-expanded.json"), "New-feature save imports")
	check(JSON.stringify(app.state) == expanded, "Improvement and expanded population save roundtrip")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test-ui-expanded.json"))
	app.reset_game()
	root.size = Vector2i(1120, 700)
	for frame in range(8): await process_frame
	print("LAYOUT 1120: app=", app.size, " status=", app.status_label.get_global_rect(), " tabs=", app.tabs.get_global_rect(), " map=", app.map_view.get_global_rect())
	check(app.status_label.get_global_rect().end.y <= app.size.y, "Minimum window height keeps status visible")
	check(app.tabs.get_global_rect().end.x <= app.size.x, "Minimum window width keeps inspector visible")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test-ui-save.json"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test-ui-bad.json"))
	app.queue_free()
	await process_frame
	print("Godot native UI: %d checks, %d failures." % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
