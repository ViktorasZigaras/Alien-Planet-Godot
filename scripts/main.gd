extends Control
## Native Godot UI. Rules and serialisable state stay in game_rules.gd.
const Rules = preload("res://scripts/game_rules.gd")
const MapView = preload("res://scripts/hex_map.gd")
const Art = preload("res://scripts/starter_art.gd")
const ModelLab = preload("res://scripts/model_lab.gd")
const QUICK_SAVE = "user://alien_planet_quicksave.json"
var state: Dictionary
var selected_tile = "2,3"
var selected_unit = ""
var selected_cohort = "pop_a"
var overlay = "cohort"
var map_view
var resource_labels: Dictionary = {}
var turn_label: Label
var status_label: Label
var warning_label: Label
var hover_label: Label
var milestones_label: Label
var orders: VBoxContainer
var development: VBoxContainer
var report: VBoxContainer
var mobile_bar: HBoxContainer
var tabs: TabContainer
var save_dialog: FileDialog
var load_dialog: FileDialog
var reset_dialog: ConfirmationDialog
var help_dialog: AcceptDialog
var end_button: Button
var support_selector: OptionButton
var refreshing = false
var training_target = "Specialist"
var district_choice = "production"
var tech_dialog: AcceptDialog
var tech_tabs: TabContainer
var tech_pages: Dictionary = {}
var model_lab


func _ready() -> void:
	state = Rules.initial_state()
	apply_theme()
	build_ui()
	render()
	status("Expedition ready. Select a person at Main Base, or a mobile unit below the map.")

func apply_theme() -> void:
	var t = Theme.new()
	t.default_font_size = 14
	t.set_color("font_color", "Label", Color("dce8eb"))
	for type in ["Button", "OptionButton"]:
		for style in ["normal", "hover", "pressed", "disabled", "focus"]:
			var b = StyleBoxFlat.new()
			b.bg_color = Color("28434e") if style in ["hover", "pressed"] else Color("1b303b")
			if style == "disabled": b.bg_color = Color("17252d")
			b.border_color = Color("d5b77a") if style in ["pressed", "focus"] else Color("3b5662")
			b.set_border_width_all(1)
			b.set_corner_radius_all(4)
			b.content_margin_left = 10
			b.content_margin_right = 10
			b.content_margin_top = 7
			b.content_margin_bottom = 7
			t.set_stylebox(style, type, b)
		t.set_color("font_color", type, Color("dce8eb"))
		t.set_color("font_disabled_color", type, Color("647981"))
	var panel = StyleBoxFlat.new()
	panel.bg_color = Color("14232c")
	panel.border_color = Color("2d4652")
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(5)
	panel.set_content_margin_all(14)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "TabContainer", panel)
	t.set_constant("separation", "VBoxContainer", 9)
	t.set_constant("separation", "HBoxContainer", 9)
	theme = t

func build_ui() -> void:
	var bg = ColorRect.new()
	bg.color = Color("0a141b")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "top", "right", "bottom"]: margin.add_theme_constant_override("margin_"+edge, 18)
	add_child(margin)
	var layout = VBoxContainer.new()
	margin.add_child(layout)
	var header = HBoxContainer.new()
	layout.add_child(header)
	var title = VBoxContainer.new()
	title.custom_minimum_size.x = 255
	header.add_child(title)
	label(title, "ALIEN PLANET", 26, Color("e5ebdf"))
	label(title, "GODOT / EXPEDITION SANDBOX 0.5", 11, Color("d5b77a"))
	for key in Rules.RESOURCES:
		var box = VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(box)
		var resource_row = HBoxContainer.new()
		box.add_child(resource_row)
		var resource_image = TextureRect.new()
		resource_image.texture = Art.resource_icon(key)
		resource_image.custom_minimum_size = Vector2(27, 27)
		resource_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		resource_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		resource_image.tooltip_text = key.capitalize()
		resource_row.add_child(resource_image)
		label(resource_row, key.to_upper(), 11, Color("99afb6")).custom_minimum_size.x = 66
		resource_labels[key] = label(box, "", 19)
	var turn_box = VBoxContainer.new()
	header.add_child(turn_box)
	turn_label = label(turn_box, "Turn 1", 16)
	end_button = button(turn_box, "End turn  [Space]", func(): issue({"type": "endTurn"}))
	end_button.name = "EndTurn"
	var tools = HBoxContainer.new()
	layout.add_child(tools)
	button(tools, "Quick save", func(): save_to(QUICK_SAVE)).tooltip_text = "Ctrl+S — save to the local Godot user-data folder."
	button(tools, "Quick load", func(): load_from(QUICK_SAVE)).tooltip_text = "Ctrl+L — load the last quick save."
	button(tools, "Export save…", func(): save_dialog.popup_centered_ratio(0.75))
	button(tools, "Import save…", func(): load_dialog.popup_centered_ratio(0.75))
	button(tools, "Reset", func(): reset_dialog.popup_centered())
	button(tools, "Technology", func(): tech_dialog.popup_centered(Vector2i(1060,730)))
	button(tools, "3D Model lab", open_model_lab).name = "OpenModelLab"
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools.add_child(spacer)
	
	button(tools, "Help", func(): help_dialog.popup_centered(Vector2i(680, 420)))
	warning_label = label(layout, "", 13, Color("f6b7a5"))
	warning_label.visible = false
	var content = HSplitContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.split_offset = 930
	layout.add_child(content)
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.custom_minimum_size.x = 580
	content.add_child(left)
	var map_tools = HBoxContainer.new()
	left.add_child(map_tools)
	label(map_tools, "Supply", 12, Color("a5bbc2")).custom_minimum_size.x = 48
	var support = OptionButton.new()
	support_selector = support
	support.add_item("Population")
	support.add_item("Rover")
	support.add_item("Off")
	support.item_selected.connect(func(index): overlay = ["cohort", "rover", "none"][index]; update_map())
	map_tools.add_child(support)
	button(map_tools, "Fit map", func(): map_view.fit_map())
	var yields = CheckButton.new()
	yields.name = "YieldOverlay"
	yields.text = "Yields"
	yields.tooltip_text = "Unworked hexes show potential output; worked hexes show the assigned cohort’s actual output, including specialist bonuses."
	yields.toggled.connect(func(on): map_view.show_yields = on; map_view.queue_redraw())
	map_tools.add_child(yields)
	hover_label = label(map_tools, "", 12, Color("afc5cd"))
	hover_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hover_label.clip_text = true
	map_view = MapView.new()
	map_view.name = "HexMap"
	map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_view.custom_minimum_size = Vector2(500, 330)
	map_view.tile_selected.connect(select_tile)
	map_view.move_requested.connect(func(key, append): select_tile(key); issue({"type": "queueMove", "unitId": selected_unit, "target": key, "append": append}))
	map_view.hover_changed.connect(show_hover)
	left.add_child(map_view)
	milestones_label = label(left, "", 12, Color("c2d3b2"))
	label(left, "MOBILE UNITS  ·  Right-click: queue route / Shift: append", 12, Color("d5b77a"))
	var mobile_scroll = ScrollContainer.new()
	mobile_scroll.custom_minimum_size.y = 60
	mobile_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(mobile_scroll)
	mobile_bar = HBoxContainer.new()
	mobile_scroll.add_child(mobile_bar)
	tabs = TabContainer.new()
	tabs.custom_minimum_size.x = 390
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_stretch_ratio = 0.4
	content.add_child(tabs)
	orders = make_tab("Orders")
	development = make_tab("Technology")
	report = make_tab("Report")
	status_label = label(layout, "", 13, Color("cbdcbf"))
	status_label.custom_minimum_size.y = 34
	# Real native dialogs; saves remain compatible with the HTML engine.
	save_dialog = FileDialog.new()
	save_dialog.use_native_dialog = true
	save_dialog.mode_overrides_title = false
	save_dialog.title = "Export Alien Planet save"
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.filters = PackedStringArray(["*.json;Alien Planet save;application/json"])
	save_dialog.current_file = "alien-planet-save.json"
	save_dialog.file_selected.connect(save_to)
	add_child(save_dialog)
	load_dialog = FileDialog.new()
	load_dialog.use_native_dialog = true
	load_dialog.mode_overrides_title = false
	load_dialog.title = "Import Alien Planet / HTML save"
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_dialog.filters = PackedStringArray(["*.json;Alien Planet save;application/json"])
	load_dialog.file_selected.connect(load_from)
	add_child(load_dialog)
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Reset expedition?"
	reset_dialog.dialog_text = "All current orders and progress will be reset. Export a save first if needed."
	reset_dialog.confirmed.connect(reset_game)
	add_child(reset_dialog)
	help_dialog = AcceptDialog.new()
	help_dialog.title = "Alien Planet — quick controls"
	help_dialog.dialog_text = "Left-click a hex to inspect it. Select a mobile unit below the map.\nRight-click a destination to queue a route; Shift+right-click appends a waypoint.\nUse Move here for immediate movement, or Cancel movement queue to stop.\nWheel zooms; middle-drag pans; Fit map restores the view.\n\nAt Main Base select a cohort, then change its job. Empty buildings do nothing.\nDevelop Technical Education, train a Specialist, then assign the lab again.\nDevelop Standard Tooling; make a Worker idle; select a site and build.\nProduction District: 2 Industry / 1 turn. Workshop: 6 Industry + 2 Credits / 2 turns.\nField Coordination lets population reach Field Station. Join it and assign its lab.\n\nSpace: End Turn     Ctrl+S: Quick save     Ctrl+L: Quick load\nOlder HTML/Godot saves can be imported; new saves use schema 5.\nTown growth costs 20 Food and creates an idle Worker.\nIdle Workers build Roads or Farms for 1 Industry / 1 turn.\nRoads cost 1/3 movement to enter; worked Farms add 1 Food.\nToggle Yields to inspect potential output. Cyan markers name the tile worker.\nUse Technology for five area tabs, two capabilities each.\nTraining also requires Technical Education and the role’s own capability.\nAll numbers are provisional. No opponents or combat."
	add_child(help_dialog)
	tech_dialog = AcceptDialog.new()
	tech_dialog.title = "Technology — expedition capabilities"
	tech_dialog.ok_button_text = "Close"
	tech_dialog.min_size = Vector2i(900,600)
	tech_dialog.size = Vector2i(1060,730)
	tech_dialog.unresizable = false
	add_child(tech_dialog)
	tech_tabs = TabContainer.new()
	tech_tabs.custom_minimum_size = Vector2(850,520)
	tech_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tech_dialog.add_child(tech_tabs)
	tech_tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tech_tabs.offset_left = 16
	tech_tabs.offset_top = 16
	tech_tabs.offset_right = -16
	tech_tabs.offset_bottom = -58
	for key in Rules.content().trees:
		var scroll = ScrollContainer.new()
		scroll.name = key
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		tech_tabs.add_child(scroll)
		tech_tabs.set_tab_title(tech_tabs.get_tab_count()-1,Rules.content().trees[key])
		var page = VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(page)
		tech_pages[key] = page

func make_tab(title: String) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	return box

func label(parent: Node, text: String, font_size: int = 14, colour: Color = Color("dce8eb")) -> Label:
	var node = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", colour)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(node)
	return node

func heading(parent: Node, text: String) -> void:
	label(parent, text.to_upper(), 13, Color("d5b77a"))

func button(parent: Node, text: String, callback: Callable) -> Button:
	var node = Button.new()
	node.text = text
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

func command_button(parent: Node, text: String, cmd: Dictionary) -> Button:
	var node = button(parent, text, func(): issue(cmd))
	node.clip_text = true
	var blocked = Rules.reason(state, cmd)
	node.disabled = not blocked.is_empty()
	node.tooltip_text = text + ("\n"+blocked if not blocked.is_empty() else "")
	node.set_meta("command", cmd)
	return node

func clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func divider(parent: Node) -> void:
	parent.add_child(HSeparator.new())

func icon(parent: Node, key: String, size_px: Vector2 = Vector2(36, 42)) -> void:
	var node = TextureRect.new()
	node.texture = Art.icon(key)
	node.custom_minimum_size = size_px
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)

func status(text: String, good: bool = true) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", Color("cbdcbf") if good else Color("ffb2a0"))

func update_map() -> void:
	support_selector.select(["cohort", "rover", "none"].find(overlay))
	support_selector.set_item_text(0, "Population · reach %d" % Rules.reach(state, "cohort"))
	support_selector.set_item_text(1, "Rover · reach %d" % Rules.reach(state, "rover"))
	map_view.update_view(state, selected_tile, selected_unit, overlay)

func select_tile(key: String) -> void:
	selected_tile = key
	if not Rules.site_at(state, key).is_empty():
		var site = Rules.site_at(state, key)
		var current = state.cohorts.get(selected_cohort, {})
		if current.is_empty() or current.state.get("settlementId") != site.id:
			selected_cohort = ""
			for c in state.cohorts.values():
				if c.state.get("settlementId") == site.id:
					selected_cohort = c.id
					break
	render()

func select_mobile(key: String) -> void:
	selected_unit = key
	var u = Rules.mobile(state, key)
	selected_tile = u.tileId
	overlay = u.classId
	tabs.current_tab = 0
	render()

func issue(cmd: Dictionary) -> bool:
	if refreshing:
		return false
	var result = Rules.command(state, cmd)
	if result.ok:
		state = result.state
		if cmd.type == "mobilise":
			selected_unit = cmd.cohortId
			selected_tile = state.cohorts[selected_unit].state.tileId
			overlay = "cohort"
		elif cmd.type == "grow":
			selected_cohort = "pop_%03d" % (state.nextCohortNumber-1)
			selected_tile = state.settlements[cmd.settlementId].tileId
		elif cmd.type == "join":
			selected_cohort = cmd.cohortId
			selected_unit = ""
			selected_tile = state.settlements[state.cohorts[selected_cohort].state.settlementId].tileId
		render()
	status(result.message, result.ok)
	return result.ok

func render() -> void:
	refreshing = true
	var delta = Rules.forecast(state)
	for k in Rules.RESOURCES:
		resource_labels[k].text = "%d  (%+d/t)" % [state.resources[k], delta[k]]
	turn_label.text = "TURN %d" % state.turn
	warning_label.text = "  ".join(state.warnings)
	warning_label.visible = not state.warnings.is_empty()
	update_map()
	render_orders()
	render_development()
	render_report()
	render_mobile()
	var flags = ["✓ Tooling" if "standard_tooling" in state.completed else "○ Tooling", "✓ Specialist" if state.cohorts.values().any(func(c): return c.qualification == "Specialist") else "○ Specialist", "✓ Reach 5" if "field_coordination" in state.completed else "○ Reach 5", "✓ Station lab" if state.cohorts.values().any(func(c): return c.state.get("job") == "building:lab_field" and c.qualification == "Specialist") else "○ Station lab"]
	milestones_label.text = "    ".join(flags)
	refreshing = false

func render_mobile() -> void:
	clear(mobile_bar)
	var keys = state.units.keys()
	for c in state.cohorts.values():
		if c.state.kind == "mobile": keys.append(c.id)
	for key in keys:
		var u = Rules.mobile(state, key)
		var name_text = "%s%s  %s  [%.2f move]" % ["● " if key == selected_unit else "", u.name, u.tileId, u.movementRemaining]
		if state.movementQueues.has(key): name_text += " → " + str(state.movementQueues[key].back())
		var node = button(mobile_bar, name_text, select_mobile.bind(key))
		node.set_meta("unit_id", key)
		node.tooltip_text = "Supply reach %d; click to select." % Rules.reach(state, u.classId)

func render_orders() -> void:
	clear(orders)
	var t = state.tiles[selected_tile]
	var site = Rules.site_at(state, selected_tile)
	var district = Rules.district_at(state, selected_tile)
	heading(orders, site.name if not site.is_empty() else Rules.content().districts[district.type].name if not district.is_empty() else "Hex "+selected_tile)
	label(orders, "%s · %s%s%s · supply cost %s" % [selected_tile, t.baseTerrain, " / hills" if t.relief == "hills" else "", " / forest" if t.feature == "forest" else "", str(Rules.supply_field(state).get(selected_tile, "∞"))], 12, Color("a3bac2"))
	var flags = state.improvements.get(selected_tile, {})
	if flags.get("road", false): label(orders, "Road: enter for ⅓ movement (also lowers supply-path cost).", 12, Color("dcc49a"))
	for improvement in flags:
		if improvement == "road" or not flags[improvement]: continue
		var definition = Rules.content().improvements[improvement]
		var yields = []
		for resource in definition.yield: yields.append("+%d %s" % [definition.yield[resource],resource])
		label(orders,definition.name+": "+", ".join(yields)+" when worked.",12,Color("adc98b"))
	var tile_worker = Rules.worker_at(state, selected_tile)
	if not tile_worker.is_empty():
		label(orders, "Worked by %s · %s · %s" % [tile_worker.name, tile_worker.qualification, state.settlements[tile_worker.state.settlementId].name], 13, Color("86d8e1"))
	var u = Rules.mobile(state, selected_unit)
	if not u.is_empty():
		divider(orders)
		heading(orders, "Moving: "+u.name)
		var route = Rules.path(state, u.tileId, selected_tile, u.classId)
		label(orders, "At %s · %.2f movement left · supply reach %d\n%s" % [u.tileId, u.movementRemaining, Rules.reach(state, u.classId), "Destination path cost %.2f" % route.cost if not route.is_empty() else "No path inside supply range."], 13)
		var cmd = {"type": "move", "unitId": selected_unit, "target": selected_tile}
		command_button(orders, "Move here", cmd)
		command_button(orders, "Queue route to here", {"type":"queueMove","unitId":u.id,"target":selected_tile})
		command_button(orders, "Append destination to route", {"type":"queueMove","unitId":u.id,"target":selected_tile,"append":true})
		if state.movementQueues.has(u.id):
			label(orders, "Queued: "+" → ".join(state.movementQueues[u.id]), 12, Color("88e3e7"))
			command_button(orders, "Cancel movement queue", {"type":"cancelMove","unitId":u.id})
		var blocked = Rules.reason(state, cmd)
		if not blocked.is_empty(): label(orders, blocked, 12, Color("c2ab89"))
		if u.classId == "cohort": command_button(orders, "Join settlement", {"type": "join", "cohortId": u.id})
		button(orders, "Deselect unit", func(): selected_unit = ""; render())
	if not site.is_empty():
		divider(orders)
		heading(orders, "Town action")
		command_button(orders, "Grow population  ·  20 Food", {"type":"grow","settlementId":site.id})
		label(orders, "Creates one idle Worker here. Each cohort consumes 1 Food/turn.", 12, Color("b4c99c"))
		divider(orders)
		heading(orders, "Residents — select a person")
		var count = 0
		for c in state.cohorts.values():
			if c.state.get("settlementId") != site.id:
				continue
			count += 1
			var row = HBoxContainer.new()
			orders.add_child(row)
			icon(row, c.qualification)
			var node = button(row, ("● " if selected_cohort == c.id else "") + c.name + " · " + c.qualification, func(): selected_cohort = c.id; render())
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node.set_meta("cohort_id", c.id)
		if count == 0:
			label(orders, "Empty station. Bring a mobile cohort onto this hex, then Join settlement.", 13)
		divider(orders)
		heading(orders, "Facilities")
		for b in state.buildings.values():
			if b.settlementId == site.id:
				var employee = "unstaffed"
				for c in state.cohorts.values():
					if c.state.get("job") == "building:"+b.id: employee = c.name
				if b.type == "training": employee = "busy" if state.trainingProject != null else "available"
				label(orders, Rules.building_name(b)+" · "+employee, 12, Color("aac0c7"))
				var definition = Rules.content().buildings[b.type]
				if definition.resource != "":
					var bonuses = []
					for role in definition.specialists: bonuses.append("%s %d" % [role,definition.specialists[role]])
					label(orders,"Staffed: +%d %s%s · upkeep %d Credits" % [definition.output,definition.resource," ("+", ".join(bonuses)+")" if not bonuses.is_empty() else "",definition.upkeep],11,Color("9db5ad"))
	if not district.is_empty():
		var contained = Rules.content().districts[district.type].building
		var definition = Rules.content().buildings[contained]
		var built = state.buildings.has(Rules.building_key(district.settlementId,contained))
		label(orders, "%s: one staffed job; %d Credit upkeep/turn." % [definition.name,definition.upkeep] if built else "Empty district. Build its "+definition.name+" using an idle Worker or Engineer.",13)
	if not selected_cohort.is_empty() and state.cohorts.has(selected_cohort):
		render_cohort(state.cohorts[selected_cohort], district)
	if site.is_empty() and district.is_empty():
		var output = Rules.map_yield(state, selected_tile)
		var parts = []
		for k in output: parts.append("%s +%d" % [k, output[k]])
		label(orders, "Tile job: "+", ".join(parts) if not output.is_empty() else "No ordinary terrain job here.", 12, Color("a0b8aa"))
	if state.trainingProject != null:
		project_progress("Training "+state.trainingProject.qualification, state.trainingProject.turnsRemaining, 2)
	if state.constructionProject != null:
		project_progress(Rules.order_name(state.constructionProject.order,state.constructionProject.get("districtType","production")), state.constructionProject.turnsRemaining, Rules.project_duration(state.constructionProject.order))

func render_cohort(c: Dictionary, district: Dictionary) -> void:
	divider(orders)
	heading(orders, c.name + " · " + c.qualification)
	var st = c.state
	if st.kind != "resident":
		label(orders, "State: "+st.kind+". This cohort cannot hold a resident job right now.", 13)
		return
	label(orders, "Resident at "+state.settlements[st.settlementId].name, 12, Color("aac0c7"))
	var option = OptionButton.new()
	option.name = "JobAssignment"
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.fit_to_longest_item = false
	option.add_item("Idle / no job")
	option.set_item_metadata(0, null)
	for j in Rules.list_jobs(state, st.settlementId):
		var index = option.item_count
		var blocked = Rules.reason(state, {"type": "assign", "cohortId": c.id, "job": j.id})
		option.add_item(j.label + (" [occupied]" if Rules.occupied(state, j.id, c.id) else ""))
		option.set_item_metadata(index, j.id)
		option.set_item_disabled(index, not blocked.is_empty())
		option.get_popup().set_item_tooltip(index, blocked)
		if j.id == st.job: option.select(index)
	option.item_selected.connect(func(index): issue({"type": "assign", "cohortId": c.id, "job": option.get_item_metadata(index)}))
	orders.add_child(option)
	command_button(orders, "Mobilise as map unit", {"type": "mobilise", "cohortId": c.id})
	if c.qualification == "Worker":
		heading(orders,"Training qualification")
		var training = OptionButton.new()
		training.name = "TrainingQualification"
		training.fit_to_longest_item = false
		for qualification in Rules.content().qualifications:
			var definition = Rules.content().qualifications[qualification]
			if not definition.trainable: continue
			var index = training.item_count
			training.add_item(qualification+" / "+definition.resource.capitalize())
			training.set_item_metadata(index,qualification)
			training.get_popup().set_item_tooltip(index,Rules.training_reason(state,qualification))
			if qualification == training_target: training.select(index)
		training.item_selected.connect(func(index): training_target = training.get_item_metadata(index); render())
		orders.add_child(training)
		command_button(orders,"Train "+training_target+" · 4 Credits / 2 turns",{"type":"train","cohortId":c.id,"qualification":training_target})
		var blocked = Rules.training_reason(state,training_target)
		if not blocked.is_empty(): label(orders,blocked,12,Color("cbb089"))
	if c.qualification in ["Worker","Engineer"]:
		heading(orders,"Construction — selected "+c.qualification)
		if st.job != null: label(orders,"Set this cohort to Idle before building.",12,Color("d4bc8c"))
		var district_select = OptionButton.new()
		district_select.name = "DistrictType"
		district_select.fit_to_longest_item = false
		for kind in Rules.content().districts:
			var index = district_select.item_count
			district_select.add_item(Rules.content().districts[kind].name)
			district_select.set_item_metadata(index,kind)
			if kind == district_choice: district_select.select(index)
		district_select.item_selected.connect(func(index): district_choice = district_select.get_item_metadata(index); render())
		orders.add_child(district_select)
		var district_cmd = {"type":"build","order":"district","cohortId":c.id,"target":selected_tile}
		if district_choice != "production": district_cmd.districtType = district_choice
		command_button(orders,"Build "+Rules.content().districts[district_choice].name+" · 2 Ind / 1 turn",district_cmd)
		if not district.is_empty():
			var building = Rules.content().districts[district.type].building
			command_button(orders,"Build "+Rules.content().buildings[building].name+" · 6 Ind + 2 Cr / 2 turns",{"type":"build","order":building,"cohortId":c.id,"districtId":district.id})
		for improvement in Rules.content().improvements:
			command_button(orders,"Build "+Rules.content().improvements[improvement].name+" · 1 Ind / 1 turn",{"type":"improve","improvement":improvement,"cohortId":c.id,"target":selected_tile})

func project_progress(title: String, remaining, duration: int) -> void:
	divider(orders)
	label(orders, "%s · %d turn(s) remaining" % [title, remaining], 12, Color("c9b990"))
	var progress = ProgressBar.new()
	progress.max_value = duration
	progress.value = duration - remaining
	progress.show_percentage = false
	progress.custom_minimum_size.y = 12
	orders.add_child(progress)

func render_development() -> void:
	clear(development)
	heading(development,"Technology view")
	label(development,"%d / %d capabilities developed. Two starter technologies in each area; costs and yields are provisional." % [state.completed.size(),Rules.nodes().size()],13)
	var index = 0
	for tree in Rules.content().trees:
		var tab_index = index
		button(development,Rules.content().trees[tree],func(): tech_tabs.current_tab = tab_index; tech_dialog.popup_centered(Vector2i(1060,730)))
		index += 1
		var page = tech_pages[tree]
		clear(page)
		heading(page,Rules.content().trees[tree])
		label(page,"Starter capabilities for the current playable demo. Hover locked orders to see missing technology.",13,Color("9eb4bd"))
		for key in Rules.nodes():
			var n = Rules.nodes()[key]
			if n.tree != tree: continue
			var panel = PanelContainer.new()
			page.add_child(panel)
			var card = VBoxContainer.new()
			panel.add_child(card)
			label(card,n.name,20)
			label(card,n.effect,14)
			var cost = HBoxContainer.new()
			card.add_child(cost)
			var image = TextureRect.new()
			image.texture = Art.resource_icon(n.resource)
			image.custom_minimum_size = Vector2(26,26)
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			cost.add_child(image)
			label(cost,"Cost %d %s · available %d" % [n.cost,n.resource,state.resources[n.resource]],14).custom_minimum_size.x = 380
			if not n.requires.is_empty():
				var names = []
				for pre in n.requires: names.append(Rules.nodes()[pre].name)
				label(card,"Requires: "+" + ".join(names),13,Color("c9b995"))
			label(card,"Unlocks / effects: "+", ".join(n.unlocks),13,Color("9cceca"))
			if key in state.completed:
				label(card,"✓ Developed",14,Color("a5d29a"))
			else:
				var cmd = {"type":"develop","nodeId":key}
				command_button(card,"Develop "+n.name,cmd)
				var blocked = Rules.reason(state,cmd)
				if not blocked.is_empty(): label(card,blocked,12,Color("c9a99a"))
	label(development,"Farmer → Food\nEngineer → Industry\nMerchant → Credits\nScientist → Research\nAdministrator → Influence\nSecurity → Guard Post",13,Color("adc8b5"))
	label(development,"Roads and Farms remain known starter improvements. Military content has no combat system yet.",12,Color("b9a88a"))

func render_report() -> void:
	clear(report)
	heading(report, "Turn report / newest first")
	for line in state.log:
		label(report, line, 12, Color("b4c8cf"))
		divider(report)

func show_hover(key: String) -> void:
	if key.is_empty():
		hover_label.text = ""
		return
	var worker = Rules.worker_at(state, key)
	hover_label.tooltip_text = "Unworked tile" if worker.is_empty() else "Worked by %s (%s, %s)" % [worker.name, worker.qualification, state.settlements[worker.state.settlementId].name]
	var cost = Rules.movement_cost(state, key)
	hover_label.text = "%s · move %s · supply %s" % [key, "blocked" if is_inf(cost) else ("⅓" if cost < 1 else str(int(cost))), str(map_view.supply.get(key, "∞"))]

func save_to(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		status("Save failed: "+error_string(FileAccess.get_open_error()), false)
		return false
	file.store_string(JSON.stringify(state, "\t"))
	file.flush()
	var err = file.get_error()
	file.close()
	if err != OK:
		status("Save failed: "+error_string(err), false)
		return false
	status("Saved to "+ProjectSettings.globalize_path(path))
	return true

func load_from(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		status("Load failed: "+error_string(FileAccess.get_open_error()), false)
		return false
	if file.get_length() > 5*1024*1024:
		file.close()
		status("Save rejected: file is too large.", false)
		return false
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		status("Save rejected: invalid JSON.", false)
		return false
	var candidate = Rules.migrate_save(json.data)
	var blocked = Rules.validate(candidate)
	if not blocked.is_empty():
		status("Save rejected: "+blocked, false)
		return false
	state = candidate
	selected_tile = "2,3"
	selected_unit = ""
	selected_cohort = "pop_a"
	render()
	status("Save imported. Cohorts and orders preserved.")
	return true

func reset_game() -> void:
	state = Rules.initial_state()
	selected_tile = "2,3"
	selected_unit = ""
	selected_cohort = "pop_a"
	map_view.fit_map()
	render()
	status("Expedition reset.")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if save_dialog.visible or load_dialog.visible or reset_dialog.visible or help_dialog.visible or tech_dialog.visible or (is_instance_valid(model_lab) and model_lab.visible):
		return
	if get_viewport().gui_get_focus_owner() is LineEdit or get_viewport().gui_get_focus_owner() is OptionButton:
		return
	if event.ctrl_pressed and event.keycode == KEY_S:
		save_to(QUICK_SAVE)
		get_viewport().set_input_as_handled()
	elif event.ctrl_pressed and event.keycode == KEY_L:
		load_from(QUICK_SAVE)
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_SPACE and not event.ctrl_pressed:
		issue({"type": "endTurn"})
		get_viewport().set_input_as_handled()

func open_model_lab() -> void:
	if not is_instance_valid(model_lab):
		model_lab = ModelLab.new()
		add_child(model_lab)
	model_lab.open()
