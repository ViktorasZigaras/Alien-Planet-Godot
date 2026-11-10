extends Control
## B01 instrument shell. Selection and camera are local; only issue() changes rules.
const R = preload("res://scripts/game_rules.gd")
const Session = preload("res://scripts/civilization_session.gd")
const Fixture = preload("res://scripts/shell_fixture.gd")
const World = preload("res://scripts/world_map.gd")
const QUICK_SAVE = "user://alien_planet_b01_quicksave.json"
var state: Dictionary
var selected_tile = "2,3"
var selected_unit = "pop_a"
var world_view
var turn_label: Label
var terrain_label: Label
var unit_label: Label
var route_label: Label
var preview_label: Label
var status_label: Label
var record_label: Label
var selection_button: Button
var stop_button: Button
var move_button: Button
var save_dialog: FileDialog
var load_dialog: FileDialog
var reset_dialog: ConfirmationDialog
var motion_button: CheckButton
var trace_button: CheckButton
var revision = 0
var projection_count = 0
var last_command_us = 0

func _ready() -> void:
	state = Fixture.initial()
	apply_theme()
	build_ui()
	refresh_world()
	refresh_selection()
	world_view.focus_tile("3,3")
	status("Survey party ready. Click a destination, then right-click or press M to order travel.")

func apply_theme() -> void:
	var t = Theme.new()
	t.default_font_size = 17
	t.set_color("font_color","Label",Color("c9d7d8"))
	for kind in ["Button","CheckButton"]:
		for style in ["normal","hover","pressed","disabled","focus"]:
			var b = StyleBoxFlat.new()
			b.bg_color = Color("233c43") if style in ["hover","pressed"] else Color("142a31")
			b.border_color = Color("a3c5b9") if style == "focus" else Color("39545a")
			b.set_border_width_all(1)
			b.set_corner_radius_all(3)
			b.content_margin_left = 15; b.content_margin_right = 15
			b.content_margin_top = 10; b.content_margin_bottom = 10
			t.set_stylebox(style,kind,b)
		t.set_color("font_color",kind,Color("d7e6e3"))
		t.set_color("font_disabled_color",kind,Color("718488"))
	t.set_constant("separation","VBoxContainer",12)
	t.set_constant("separation","HBoxContainer",14)
	theme = t

func label(parent: Node,text: String,font_size: int = 17,colour: Color = Color("c9d7d8")) -> Label:
	var node = Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",colour)
	parent.add_child(node)
	return node

func button(parent: Node,text: String,callback: Callable) -> Button:
	var node = Button.new()
	node.text = text
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

func panel(parent: Node) -> VBoxContainer:
	var p = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("101f26")
	style.border_color = Color("30454c")
	style.set_border_width_all(1)
	style.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel",style)
	parent.add_child(p)
	var box = VBoxContainer.new()
	p.add_child(box)
	return box

func build_ui() -> void:
	var bg = ColorRect.new()
	bg.color = Color("091419")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,22)
	add_child(margin)
	var layout = VBoxContainer.new()
	margin.add_child(layout)
	var header = HBoxContainer.new()
	layout.add_child(header)
	var title = VBoxContainer.new()
	title.custom_minimum_size.x = 320
	header.add_child(title)
	label(title,"ALIEN PLANET",30,Color("e1e8db"))
	label(title,"FIELD SYSTEMS  /  0.911 · B01",13,Color("a9c3b4"))
	for key in R.RESOURCES:
		var box = VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(box)
		label(box,key.to_upper(),12,Color("8fa5aa"))
		label(box,"—",23,Color("819394")).tooltip_text = "Resource accounting starts in B02. No production or upkeep runs in this fixture."
	var turn_box = VBoxContainer.new()
	header.add_child(turn_box)
	turn_label = label(turn_box,"TURN 01",20,Color("e0d8b9"))
	button(turn_box,"End turn  [Space]",func(): issue({"type":"endTurn"})).name = "EndTurn"
	var menu = HBoxContainer.new()
	layout.add_child(menu)
	button(menu,"Quick save",func(): save_to(QUICK_SAVE)).tooltip_text = "Ctrl+S · separate B01 quicksave"
	button(menu,"Quick load",func(): load_from(QUICK_SAVE)).tooltip_text = "Ctrl+L"
	button(menu,"Export save…",func(): save_dialog.popup_centered_ratio(0.75))
	button(menu,"Import save…",func(): load_dialog.popup_centered_ratio(0.75))
	button(menu,"Restart fixture",func(): reset_dialog.popup_centered())
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu.add_child(spacer)
	trace_button = CheckButton.new()
	trace_button.text = "Record commands"
	trace_button.toggled.connect(toggle_recording)
	menu.add_child(trace_button)
	motion_button = CheckButton.new()
	motion_button.text = "Motion"
	motion_button.button_pressed = true
	motion_button.toggled.connect(func(on): world_view.set_animation(on))
	menu.add_child(motion_button)
	label(layout,"DEVELOPMENT FIXTURE B01  ·  9 × 7 fixed map  ·  one town / one ordinary cohort  ·  economy, growth, AI and fauna inactive",14,Color("c7ba91"))
	var center = HBoxContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(center)
	var map_column = VBoxContainer.new()
	map_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(map_column)
	var map_header = HBoxContainer.new()
	map_column.add_child(map_header)
	label(map_header,"01  /  SURFACE TELEMETRY",14,Color("a9c3b4")).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(map_header,"Center party  [C]",center_party)
	button(map_header,"Center station",func(): world_view.focus_tile("2,3"))
	world_view = World.new()
	world_view.name = "WorldMap"
	world_view.fixed_scale = true
	world_view.show_metrics = false
	world_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	world_view.custom_minimum_size = Vector2(1000,480)
	map_column.add_child(world_view)
	world_view.tile_selected.connect(select_tile)
	world_view.move_requested.connect(func(key,append):
		select_tile(key)
		issue({"type":"queueMove","unitId":selected_unit,"target":key,"append":append}))
	world_view.hover_changed.connect(show_hover)
	label(map_column,"Click: inspect / select party    ·    Right-click: travel    ·    Shift + right-click: append    ·    Middle / left drag or arrows: pan",14,Color("8fa5aa"))
	var side = panel(center)
	side.get_parent().custom_minimum_size.x = 370
	side.get_parent().custom_minimum_size.y = 480
	label(side,"02  /  HEX INSPECTOR",14,Color("a9c3b4"))
	terrain_label = label(side,"",19)
	side.add_child(HSeparator.new())
	label(side,"OCCUPANTS",13,Color("8fa5aa"))
	selection_button = button(side,"Survey party",func(): select_unit("pop_a"))
	move_button = button(side,"Travel here  [M]",move_selected)
	preview_label = label(side,"",15,Color("c7ba91"))
	var stretch = Control.new()
	stretch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(stretch)
	label(side,"B01 REVIEW",14,Color("a9c3b4"))
	label(side,"Inspect terrain, take either route around rough ground, queue a return to the station, and save during travel.",16)
	label(side,"This reduced fixture is a controls and state test. The intended opening retains two civilians, a Soldier and an Explorer.",14,Color("8fa5aa"))
	var bottom = panel(layout)
	var unit_row = HBoxContainer.new()
	bottom.add_child(unit_row)
	unit_label = label(unit_row,"",21,Color("e1e8db"))
	unit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(unit_row,"Select party  [Tab]",func(): select_unit("pop_a"))
	stop_button = button(unit_row,"Stop route",func(): issue({"type":"cancelMove","unitId":selected_unit}))
	route_label = label(bottom,"",16)
	record_label = label(bottom,"",13,Color("8fa5aa"))
	status_label = label(layout,"",16,Color("b9cebb"))
	status_label.custom_minimum_size.y = 44
	for saving in [true,false]:
		var dialog = FileDialog.new()
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE if saving else FileDialog.FILE_MODE_OPEN_FILE
		dialog.filters = PackedStringArray(["*.json;Alien Planet B01 save"])
		dialog.current_file = "alien-planet-b01-save.json"
		dialog.title = "Export B01 save" if saving else "Import B01 save"
		add_child(dialog)
		if saving:
			save_dialog = dialog
			dialog.file_selected.connect(save_to)
		else:
			load_dialog = dialog
			dialog.file_selected.connect(load_from)
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.dialog_text = "Restart the B01 fixture? Export your current save first if you want to retain it."
	reset_dialog.confirmed.connect(reset_game)
	add_child(reset_dialog)

func refresh_world() -> void:
	# One permitted projection per actual world change, never per selection/hover.
	projection_count += 1
	world_view.update_view(Session.projection(state),selected_tile,selected_unit,"none")

func select_tile(key: String) -> void:
	if not state.tiles.has(key): return
	selected_tile = key
	if R.person_tile(state,state.cohorts.pop_a) == key: selected_unit = "pop_a"
	world_view.select_view(selected_tile,selected_unit)
	refresh_selection()

func select_unit(id: String) -> void:
	if not state.cohorts.has(id): return
	selected_unit = id
	selected_tile = R.person_tile(state,state.cohorts[id])
	world_view.select_view(selected_tile,selected_unit)
	refresh_selection()

func refresh_selection() -> void:
	turn_label.text = "TURN %02d" % state.turn
	var t = state.tiles[selected_tile]
	var town = R.site_at(state,selected_tile)
	terrain_label.text = "%s\nHex %s · %s\n%s%s" % [town.get("name",t.baseTerrain.capitalize()),selected_tile,t.biome.capitalize(),t.relief.capitalize()," / forest" if t.feature == "forest" else ""]
	var at = R.person_tile(state,state.cohorts.pop_a)
	selection_button.visible = at == selected_tile
	var c = state.cohorts.get(selected_unit,{})
	unit_label.text = "%s  /  Worker  /  Blue  /  %s  /  %.2f move" % [c.name,c.state.tileId,c.state.movementRemaining] if not c.is_empty() else "No party selected · Tab to select"
	var route = state.movementQueues.get(selected_unit,[])
	route_label.text = "ROUTE  ·  "+("No queued travel" if route.is_empty() else " → ".join(PackedStringArray(route)))
	if state.moveProgress.has(selected_unit): route_label.text += "  ·  %.2f movement paid toward next step" % state.moveProgress[selected_unit]
	stop_button.disabled = route.is_empty()
	var cmd = {"type":"queueMove","unitId":selected_unit,"target":selected_tile}
	var block = Session.reason_for(state,"blue",cmd)
	move_button.disabled = block != ""
	move_button.tooltip_text = block
	if block != "": preview_label.text = block
	else:
		var path = R.path(state,at,selected_tile,"cohort")
		preview_label.text = "TRAVEL PREVIEW\n%.2f movement · %d steps\nRough ground and rivers may need several turns." % [path.cost,path.path.size()-1]
	record_label.text = "COMMAND RECORD  ·  %s  ·  %d events  ·  world revision %d" % ["recording" if state.testing.enabled else "off",state.testing.events.size(),revision]

func show_hover(key: String) -> void:
	if key == "" or not state.tiles.has(key): return
	var t = state.tiles[key]
	world_view.tooltip_text = "Hex %s · %s · %s%s" % [key,t.baseTerrain,t.relief," · forest" if t.feature == "forest" else ""]

func issue(cmd: Dictionary) -> bool:
	var started = Time.get_ticks_usec()
	var result = Session.command(state,cmd)
	last_command_us = Time.get_ticks_usec()-started
	state = result.state
	if result.ok:
		revision += 1
		refresh_world()
	refresh_selection()
	status(result.message,result.ok)
	return result.ok

func move_selected() -> void:
	issue({"type":"queueMove","unitId":selected_unit,"target":selected_tile})

func center_party() -> void:
	world_view.focus_tile(R.person_tile(state,state.cohorts.pop_a))

func toggle_recording(on: bool) -> void:
	state = Session.start_recording(state) if on else Session.finish_recording(state)
	refresh_selection()
	status("Command recording started." if on else "Command recording stopped; events remain in your save.")

func status(message: String,ok: bool = true) -> void:
	status_label.text = message
	status_label.add_theme_color_override("font_color",Color("b9cebb") if ok else Color("e7aa92"))

func save_to(path: String) -> bool:
	var file = FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		status("Save failed: "+error_string(FileAccess.get_open_error()),false)
		return false
	var camera_target = world_view.target
	var envelope = {"format":"alien-planet-b01-save-v1","game":state,"view":{"tile":selected_tile,"unit":selected_unit,"camera":[camera_target.x,camera_target.y,camera_target.z],"motion":world_view.animated}}
	file.store_string(JSON.stringify(envelope,"\t"))
	file.flush()
	var ok = file.get_error() == OK
	file.close()
	status("Save written." if ok else "Save could not be written completely.",ok)
	return ok

func load_from(path: String) -> bool:
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null:
		status("Load failed: "+error_string(FileAccess.get_open_error()),false)
		return false
	if file.get_length() > 64*1024*1024:
		file.close()
		status("Save rejected: file is too large.",false)
		return false
	var parser = JSON.new()
	var parsed = parser.parse(file.get_as_text())
	var envelope = parser.data if parsed == OK else null
	file.close()
	if not envelope is Dictionary or envelope.get("format","") != "alien-planet-b01-save-v1" or not envelope.get("game") is Dictionary:
		status("Choose a B01 save. Historical saves open in the retained main.tscn scene.",false)
		return false
	var candidate = Session.migrate(envelope.game)
	var blocked = Session.validate(candidate)
	if blocked != "" or candidate.get("scenario","") != Fixture.ID:
		status("Save rejected: "+(blocked if blocked != "" else "not the B01 fixture"),false)
		return false
	var view = envelope.get("view",{})
	if not view is Dictionary: view = {}
	state = candidate
	selected_tile = str(view.get("tile","2,3"))
	if not state.tiles.has(selected_tile): selected_tile = "2,3"
	selected_unit = "pop_a" if view.get("unit","") == "pop_a" else ""
	trace_button.set_pressed_no_signal(state.testing.enabled)
	motion_button.set_pressed_no_signal(view.get("motion",true) == true)
	world_view.set_animation(motion_button.button_pressed)
	var camera_target = view.get("camera",[])
	if camera_target is Array and camera_target.size() == 3 and camera_target.all(func(v):return (v is float or v is int) and is_finite(float(v)) and abs(float(v)) < 1000):
		world_view.target = Vector3(camera_target[0],camera_target[1],camera_target[2])
	else: world_view.target = world_view.pos(state.tiles["2,3"])
	revision += 1
	refresh_world()
	world_view.update_camera()
	refresh_selection()
	status("Save restored · party, route, paid movement and view recovered.")
	return true

func reset_game() -> void:
	state = Fixture.initial()
	selected_tile = "2,3"; selected_unit = "pop_a"
	trace_button.set_pressed_no_signal(false)
	revision += 1
	refresh_world()
	world_view.focus_tile("3,3")
	refresh_selection()
	status("B01 fixture restarted.")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if save_dialog.visible or load_dialog.visible or reset_dialog.visible: return
	if event.ctrl_pressed:
		if event.keycode == KEY_S: save_to(QUICK_SAVE)
		elif event.keycode == KEY_L: load_from(QUICK_SAVE)
		else: return
	else:
		match event.keycode:
			KEY_SPACE: issue({"type":"endTurn"})
			KEY_TAB: select_unit("pop_a")
			KEY_C: center_party()
			KEY_M: move_selected()
			KEY_ESCAPE:
				selected_unit = ""
				world_view.select_view(selected_tile,selected_unit)
				refresh_selection()
			KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN:
				var direction = Vector3(-1,0,0) if event.keycode == KEY_LEFT else Vector3(1,0,0) if event.keycode == KEY_RIGHT else Vector3(0,0,-1) if event.keycode == KEY_UP else Vector3(0,0,1)
				world_view.target += direction*1.2
				world_view.update_camera()
			_: return
	get_viewport().set_input_as_handled()
