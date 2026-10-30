extends Control
## Native Godot UI. Rules and serialisable state stay in game_rules.gd.
const Rules = preload("res://scripts/game_rules.gd")
const Session = preload("res://scripts/civilization_session.gd")
const MapView = preload("res://scripts/hex_map.gd")
const Art = preload("res://scripts/starter_art.gd")
const WorldView = preload("res://scripts/world_map.gd")
const ModelLab = preload("res://scripts/model_lab.gd")
const QUICK_SAVE = "user://alien_planet_quicksave.json"
var state: Dictionary
var selected_tile = "2,3"
var selected_unit = ""
var selected_cohort = "pop_a"
var overlay = "none"
var map_view
var pixel_view
var world_view
var map_host: Control
var view_selector: OptionButton
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
var training_target = "Biologist"
var district_choice = "production"
var tech_dialog: AcceptDialog
var tech_tabs: TabContainer
var tech_pages: Dictionary = {}
var model_lab
var testing_panel: VBoxContainer
var test_export: FileDialog


func _ready() -> void:
	state = Session.initial_state()
	apply_theme()
	build_ui()
	render()
	map_view.call_deferred("focus_tile","4,3")
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
	title.custom_minimum_size.x = 220
	header.add_child(title)
	label(title, "ALIEN PLANET", 26, Color("e5ebdf"))
	label(title, "GODOT / EXPEDITION SANDBOX 0.904", 11, Color("d5b77a"))
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
	var map_tools = HFlowContainer.new()
	left.add_child(map_tools)
	view_selector = OptionButton.new()
	view_selector.name = "MapMode"
	view_selector.add_item("Sprite / illustrated")
	view_selector.add_item("3D / frontier")
	view_selector.item_selected.connect(set_map_mode)
	map_tools.add_child(view_selector)
	var motion = CheckButton.new()
	motion.name = "WorldMotion"
	motion.text = "Motion"
	motion.button_pressed = true
	motion.toggled.connect(func(on): if is_instance_valid(world_view): world_view.set_animation(on))
	map_tools.add_child(motion)
	overlay = "none"
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
	map_host = Control.new()
	map_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_host.custom_minimum_size = Vector2(500,330)
	left.add_child(map_host)
	pixel_view = MapView.new()
	pixel_view.name = "HexMap"
	map_host.add_child(pixel_view)
	pixel_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	connect_map(pixel_view)
	map_view = pixel_view
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
	testing_panel = make_tab("Testing")
	test_export = FileDialog.new()
	test_export.use_native_dialog = true
	test_export.title = "Export civilization test record"
	test_export.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	test_export.access = FileDialog.ACCESS_FILESYSTEM
	test_export.filters = PackedStringArray(["*.json;Civilization test record"])
	test_export.current_file = "alien-planet-test.json"
	test_export.file_selected.connect(export_test)
	add_child(test_export)
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
	help_dialog.dialog_text = "Click: inspect. Left or middle drag: pan (vertical inverted). Wheel: zoom. Fit map: overview.\nRight-click: replace route and move now. Shift+right-click: append waypoint.\nHard terrain and river crossings cost more; unfinished steps retain progress.\nRoad-to-road: ⅓ move. Entering/leaving roads uses normal destination terrain.\n\nPeople keep their professions and can combine equipment from town stocks.\nWork Suit: builder capability. Transport: driver plus two passengers of any profession. Board/unload on the same tile.\nSelect a resident to assign a tile/building slot, train, equip or deploy.\nIndustry manufactures equipment and builds infrastructure. Workshops convert Minerals.\nBuildings and districts use Energy; unpowered facilities produce nothing.\nTown growth = Food output − consumption − population + medical reduction.\nGrowth reaches 20: a new Worker. Surplus medicine adds to growth.\nNeutral sites: explicit Visit, once per person/site; Merchants receive double.\n\nTechnology: five groups, four capabilities each; inspect prerequisite explanations.\nSpace: End Turn. Ctrl+S/L: quick save/load. Saves use schema 11; older saves migrate.\nNumbers are provisional. Red civilization now develops independently; trains an army to hunt animals and disable the nest."
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
	var blocked = Session.reason_for(state,"blue",cmd)
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
	overlay = "none"
	map_view.update_view(Session.projection(state), selected_tile, selected_unit, overlay)

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
	state = Session.command(state,{"type":"focusPerson","cohortId":key}).state
	selected_unit = key
	var u = Rules.mobile(state, key)
	selected_tile = u.tileId
	overlay = u.classId
	tabs.current_tab = 0
	render()

func issue(cmd: Dictionary) -> bool:
	if refreshing:
		return false
	var result = Session.command(state, cmd)
	state = result.state
	if result.ok:
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
	if not result.ok: render_testing()
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
	render_testing()
	render_mobile()
	milestones_label.text = "Temperate · Lush · Dry · Cold · Fungal · Coastal   |   24 × 16 test world"
	refreshing = false

func render_mobile() -> void:
	clear(mobile_bar)
	var keys = state.units.keys()
	for c in state.cohorts.values():
		if c.state.kind == "mobile": keys.append(c.id)
	for key in keys:
		var u = Rules.mobile(state, key)
		var name_text = "%s%s  %s  [%.2f move]" % ["● " if key == selected_unit else "", u.name, u.tileId, u.movementRemaining]
		if "rover" in state.cohorts[key].equipment: name_text += " · cargo %d/2" % Rules.passengers(state,key).size()
		if state.movementQueues.has(key): name_text += " → " + str(state.movementQueues[key].back())
		var node = button(mobile_bar, name_text, select_mobile.bind(key))
		node.set_meta("unit_id", key)
		node.tooltip_text = "Click to select. Supply ranges disabled."

func render_orders() -> void:
	clear(orders)
	var t = state.tiles[selected_tile]
	if state.xenos.mass.has(selected_tile): label(orders,"Xenomass · animal harvesting +1; human yields −1; cleanse with a suited worker.",12,Color("7cb78d"))
	label(orders,Rules.Layers.description(t),12)
	var cleaner = state.cohorts.get(selected_unit if selected_unit != "" else selected_cohort,{})
	if not cleaner.is_empty() and Rules.builder(cleaner):
		for layer in ["pollution","xenomass","obstacle","vegetation","forest"]:
			var clean = {"type":"cleanse","cohortId":cleaner.id,"target":selected_tile,"layer":layer}
			if Session.reason_for(state,"blue",clean) == "": command_button(orders,"Cleanse "+layer+" · one action",clean)
	var wild = state.xenos.units.values().filter(func(u):return u.tile == selected_tile)
	var nests = state.xenos.nests.values().filter(func(n):return n.tile == selected_tile)
	if not wild.is_empty() or not nests.is_empty():
		heading(orders,"XENO ACTIVITY")
		for nest in nests:
			label(orders,("Disabled nest" if nest.burned else "Active brood nest")+" · biomass %d · minerals %d" % [nest.biomass,nest.minerals],12)
			label(orders,"Larvae %d/%d · predators %d/%d" % [Session.X.members(state.xenos,nest.id,true).size(),nest.workerCap,Session.X.members(state.xenos,nest.id,false).size(),nest.predatorCap],12)
			label(orders,"Clear defenders, then step onto nest with a Soldier to disable it.",12)
		for unit in wild:
			label(orders,"%s · %d/100 HP · strength %.2f · %s" % [Session.X.DATA[unit.kind].name,unit.hp,Session.X.DATA[unit.kind].attack,unit.activity],12)
			var person = state.cohorts.get(selected_unit,{})
			var odds = " · %.1f%% duel win" % (100*Session.X.preview(state,state,person,unit)) if not person.is_empty() else ""
			command_button(orders,"Melee "+Session.X.DATA[unit.kind].name+odds,{"type":"attackXeno","cohortId":selected_unit,"targetId":unit.id})
			command_button(orders,"Ranged attack",{"type":"attackXeno","cohortId":selected_unit,"targetId":unit.id,"mode":"ranged"})
	if not wild.is_empty() or not nests.is_empty():
		var explorer = Rules.mobile(state,selected_unit)
		if explorer.is_empty(): label(orders,"Select a mobile person. Rifles range 2 at half strength; flamers range 1, double power against animals.",12)
		else:
			label(orders,explorer.name+" · health %d/100 · %.2f movement" % [state.xenos.humanHealth.get(explorer.id,100),explorer.movementRemaining],12)
			command_button(orders,"Approach / replace route",{"type":"queueMove","unitId":explorer.id,"target":selected_tile})
		return
	var red = state.civilizations.red
	var foreign_town = Rules.site_at(red,selected_tile)
	var red_people = red.cohorts.values().filter(func(c): return Rules.person_tile(red,c) == selected_tile)
	if not foreign_town.is_empty() or not red_people.is_empty():
		heading(orders,"RED CIVILIZATION")
		label(orders,"Independent population, stocks, technologies and projects.",12)
		if not foreign_town.is_empty(): label(orders,foreign_town.name+" · growth "+str(foreign_town.growth)+"/20",14)
		for c in red_people: label(orders,c.name+" · "+c.qualification,12)
		label(orders,"Observe only. Red hunts animals independently.",12)
		button(orders,"View red progress",func(): tabs.current_tab = 3)
		return
	var site = Rules.site_at(state,selected_tile)
	var district = Rules.district_at(state,selected_tile)
	heading(orders,site.name if not site.is_empty() else "Hex "+selected_tile)
	label(orders,"%s · %s biome · %s%s%s" % [selected_tile,t.biome,t.baseTerrain," / hills" if t.relief == "hills" else ""," / forest" if t.feature == "forest" else ""],12)
	if t.bonus != "": label(orders,Rules.content().bonuses[t.bonus].name+" · "+Rules.yield_text(Rules.content().bonuses[t.bonus].yields),12,Color("e4c47e"))
	var flags = state.improvements.get(selected_tile,{})
	for imp in flags:
		if flags[imp]: label(orders,Rules.content().improvements[imp].name,12)
	label(orders,"Tile: "+Rules.yield_text(Rules.map_yield(state,selected_tile)),12)
	var worker = Rules.worker_at(state,selected_tile)
	if not worker.is_empty(): label(orders,"Worked by "+worker.name+" · "+worker.qualification+" · "+state.settlements[worker.home].name,12,Color("86d8e1"))
	if state.neutralSites.has(selected_tile):
		var n = state.neutralSites[selected_tile]
		heading(orders,n.name)
		label(orders,"Inhabited neutral site · +%d %s per visitor; Merchant ×2. Once per person/site." % [n.amount,n.resource],12)
	var u = Rules.mobile(state,selected_unit)
	if not u.is_empty():
		divider(orders)
		heading(orders,u.name+" · "+state.cohorts[u.id].qualification)
		label(orders,"At %s · %.2f movement left · %d/100 HP" % [u.tileId,u.movementRemaining,state.xenos.humanHealth.get(u.id,100)],12)
		var profile = Rules.combat_profile(state.cohorts[u.id])
		label(orders,"Strength %.2f · ranged %.2f; heal 5 field / 20 town on quiet rounds." % [profile.attack,profile.ranged],12)
		command_button(orders,"Move / replace route",{"type":"queueMove","unitId":u.id,"target":selected_tile})
		command_button(orders,"Append waypoint",{"type":"queueMove","unitId":u.id,"target":selected_tile,"append":true})
		if state.movementQueues.has(u.id):
			label(orders,"Destination %s · %d steps · %.2f move paid toward next step" % [state.movementQueues[u.id].back(),state.movementQueues[u.id].size(),state.moveProgress.get(u.id,0.0)],12,Color("88e3e7"))
			command_button(orders,"Cancel route",{"type":"cancelMove","unitId":u.id})
		command_button(orders,"Join settlement",{"type":"join","cohortId":u.id})
		command_button(orders,"Visit inhabited site",{"type":"visit","cohortId":u.id})
		if "rover" in state.cohorts[u.id].equipment:
			heading(orders,"Transport · passengers %d/2" % Rules.passengers(state,u.id).size())
			label(orders,"Driver is separate. Any profession may board. Unload onto this tile; passenger movement returns next turn.",11)
			for passenger in Rules.passengers(state,u.id):
				command_button(orders,"Unload "+passenger.name+" · "+passenger.qualification,{"type":"unload","cohortId":passenger.id})
			for candidate in state.cohorts.values():
				if candidate.id == u.id or candidate.state.kind not in ["resident","mobile"] or Rules.person_tile(state,candidate) != u.tileId: continue
				command_button(orders,"Board "+candidate.name+" · "+candidate.qualification,{"type":"board","cohortId":candidate.id,"transportId":u.id})
		button(orders,"Deselect unit",func(): selected_unit = ""; render())
	if not site.is_empty():
		var ledger = Rules.economy(state)
		var g = ledger.towns[site.id]
		heading(orders,"Growth %d / 20 (%+d/turn)" % [site.growth,g.growth])
		label(orders,"Food %d − consumption %d − size %d + medical %d" % [g.food,g.consumption,g.penalty,g.medicine],12)
		label(orders,"20 growth creates a Worker automatically; Food stock is shared. Mobile people count toward their home town.",11)
		divider(orders)
		heading(orders,"Residents")
		for role in Rules.content().qualifications:
			var people = state.cohorts.values().filter(func(c): return c.state.get("settlementId") == site.id and c.qualification == role)
			if people.is_empty(): continue
			label(orders,"%s (%d)" % [role,people.size()],12,Color("d5b77a"))
			for c in people:
				var row = HBoxContainer.new()
				orders.add_child(row)
				icon(row,c.qualification)
				var id = c.id
				var node = button(row,("● " if selected_cohort == id else "")+c.name+" · "+c.state.kind,func(): select_person(id))
				node.set_meta("cohort_id",id)
				node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if state.cohorts.has(selected_cohort): render_cohort(state.cohorts[selected_cohort],district)
		divider(orders)
		heading(orders,"Equipment stock")
		for item in Rules.content().equipment:
			var d = Rules.content().equipment[item]
			command_button(orders,"%s (%d) · make for %d Industry" % [d.name,state.equipment[site.id].get(item,0),d.cost],{"type":"manufacture","settlementId":site.id,"item":item})
		divider(orders)
		heading(orders,"Facilities")
		for b in state.buildings.values():
			if b.settlementId != site.id: continue
			var d = Rules.content().buildings[b.type]
			var staff = []
			for c in state.cohorts.values():
				if c.state.get("job") is String and c.state.job.begins_with("building:"+b.id+"#"): staff.append(c.name)
			label(orders,"%s · T%d · %d/%d staff" % [Rules.building_name(b),b.tier,staff.size(),Rules.slots(b)],13)
			label(orders,"%s · %d Energy/t · passive +%d %s; worked +%d/slot%s" % [ledger.status.get(b.id,""),d.upkeep*(2 if b.tier == 2 else 1),d.passive,d.resource,d.output+(1 if b.tier == 2 else 0)," · consumes Minerals 1:1" if d.get("input","") == "minerals" else ""],11)
			if not staff.is_empty(): label(orders,", ".join(staff),11)
			if d.has("upgrade"): command_button(orders,"Upgrade to tier 2 · 6 Industry",{"type":"upgrade","buildingId":b.id})
	if not district.is_empty():
		heading(orders,Rules.content().districts[district.type].name)
		label(orders,"1 Energy/turn. Select an idle suited resident to build here.",12)
	if site.is_empty() and state.cohorts.has(selected_cohort): render_cohort(state.cohorts[selected_cohort],district)
	if state.trainingProject != null: project_progress("Training "+state.trainingProject.qualification,state.trainingProject.turnsRemaining,2)
	if state.constructionProject != null: project_progress(Rules.order_name(state.constructionProject.order,state.constructionProject.get("districtType","production")),state.constructionProject.turnsRemaining,Rules.project_duration(state.constructionProject.order))

func render_cohort(c: Dictionary,district: Dictionary) -> void:
	divider(orders)
	heading(orders,c.name+" · "+c.qualification)
	label(orders,"Health %d/100" % state.xenos.humanHealth.get(c.id,100),12)
	var st = c.state
	var gear = []
	for item in c.equipment: gear.append(Rules.content().equipment[item].name)
	label(orders,"Equipment: "+(", ".join(gear) if not gear.is_empty() else "none"),12)
	label(orders,"Military support: %d Flamer / Transport slots each; deployed Soldier +1 Food, Flamer/Transport +1 Industry each." % Rules.military_capacity(state),11)
	var combat = Rules.combat_profile(c)
	label(orders,"Strength %.2f · ranged %.2f · heal 5 field / 20 town per quiet round" % [combat.attack,combat.ranged],11)
	if st.kind != "resident":
		label(orders,"State: "+st.kind,12)
		return
	label(orders,"Resident at "+state.settlements[st.settlementId].name,12)
	var option = OptionButton.new()
	option.name = "JobAssignment"
	option.fit_to_longest_item = false
	option.add_item("Idle / no job")
	option.set_item_metadata(0,null)
	var jobs = Rules.list_jobs(state,st.settlementId)
	var groups = {}
	for j in jobs:
		var group = state.tiles[j.id.substr(5)].baseTerrain.capitalize() if j.type == "tile" else Rules.content().buildings[j.type].name
		if not groups.has(group): groups[group] = []
		groups[group].append(j)
	for group in groups:
		option.add_separator("%s (%d)" % [group,groups[group].size()])
		for j in groups[group]:
			var i = option.item_count
			option.add_item(j.label)
			option.set_item_metadata(i,j.id)
			var block = Rules.reason(state,{"type":"assign","cohortId":c.id,"job":j.id})
			option.set_item_disabled(i,block != "")
			option.get_popup().set_item_tooltip(i,block)
			if j.id == st.job: option.select(i)
	option.item_selected.connect(func(i): issue({"type":"assign","cohortId":c.id,"job":option.get_item_metadata(i)}))
	orders.add_child(option)
	for item in Rules.content().equipment:
		var d = Rules.content().equipment[item]
		command_button(orders,("Return " if item in c.equipment else "Equip ")+d.name+" (%d in stock)" % state.equipment[st.settlementId].get(item,0),{"type":"equip","cohortId":c.id,"item":item})
	command_button(orders,"Deploy equipped person",{"type":"mobilise","cohortId":c.id})
	command_button(orders,"Clear specialty",{"type":"clearSpecialty","cohortId":c.id})
	if c.qualification == "Worker":
		heading(orders,"Profession training")
		var training = OptionButton.new()
		training.name = "TrainingQualification"
		training.fit_to_longest_item = false
		for role in Rules.content().qualifications:
			if role == "Worker": continue
			var i = training.item_count
			training.add_item(role)
			training.set_item_metadata(i,role)
			training.get_popup().set_item_tooltip(i,Rules.training_reason(state,role))
			if role == training_target: training.select(i)
		training.item_selected.connect(func(i): training_target = training.get_item_metadata(i); render())
		orders.add_child(training)
		command_button(orders,"Train "+training_target+" · 2 Industry / 2 turns",{"type":"train","cohortId":c.id,"qualification":training_target})
		heading(orders,Rules.training_reason(state,training_target))
	if Rules.builder(c):
		heading(orders,"Builder orders")
		if st.job != null: label(orders,"Choose Idle before construction.",12)
		var choice = OptionButton.new()
		choice.name = "DistrictType"
		choice.fit_to_longest_item = false
		for kind in Rules.content().districts:
			var i = choice.item_count
			choice.add_item(Rules.content().districts[kind].name)
			choice.set_item_metadata(i,kind)
			if kind == district_choice: choice.select(i)
		choice.item_selected.connect(func(i): district_choice = choice.get_item_metadata(i); render())
		orders.add_child(choice)
		command_button(orders,"Build district · 2 Industry / 1 turn",{"type":"build","order":"district","districtType":district_choice,"cohortId":c.id,"target":selected_tile})
		if not district.is_empty():
			for kind in Rules.buildable_buildings():
				if Rules.content().buildings[kind].district == district.type: command_button(orders,"Build "+Rules.content().buildings[kind].name+" · 6 Industry / 2 turns",{"type":"build","order":kind,"cohortId":c.id,"districtId":district.id})
		for kind in Rules.content().improvements:
			command_button(orders,"Build "+Rules.content().improvements[kind].name+" · 1 Industry / 1 turn",{"type":"improve","improvement":kind,"cohortId":c.id,"target":selected_tile})

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
	label(development,"%d / %d capabilities developed. Four starter technologies per area; costs and yields are provisional." % [state.completed.size(),Rules.nodes().size()],13)
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
			var extra = []
			for kind in n.buildings: extra.append("Building: "+Rules.content().buildings[kind].name)
			for role in n.specialists: extra.append("Specialist: "+role)
			for k in n.stocks: extra.append("Retained stock: %d %s" % [n.stocks[k],k])
			if not extra.is_empty(): label(card," · ".join(extra),13,Color("c9b995"))
			label(card,"Unlocks / effects: "+", ".join(n.unlocks),13,Color("9cceca"))
			if key in state.completed:
				label(card,"✓ Developed",14,Color("a5d29a"))
			else:
				var cmd = {"type":"develop","nodeId":key}
				command_button(card,"Develop "+n.name,cmd)
				var blocked = Rules.reason(state,cmd)
				if not blocked.is_empty(): label(card,blocked,12,Color("c9a99a"))
	label(development,"Biologist → biological extraction\nExtractor → Minerals\nEngineer → conversion\nMedic → growth\nScientist → Science\nMerchant → site visits\nArtist → Culture",13,Color("adc8b5"))
	label(development,"Rifle strength 1; larva 0.25; predator 1; heavy 1.5. Flamer: animal bonus, no extra toughness. Security District + Guard Posts limit Flamer/Transport equipment.",12,Color("b9a88a"))

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
	var display = map_view.state
	var worker = Rules.worker_at(display, key)
	hover_label.tooltip_text = "Unworked tile" if worker.is_empty() else "Worked by %s (%s, %s)" % [worker.name, worker.qualification, display.settlements[worker.state.settlementId].name]
	var cost = Rules.movement_cost(state, key)
	hover_label.text = "%s · move %s" % [key, "blocked" if is_inf(cost) else ("⅓" if cost < 1 else str(int(cost)))]

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
	if file.get_length() > 64*1024*1024:
		file.close()
		status("Save rejected: file is too large.", false)
		return false
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		status("Save rejected: invalid JSON.", false)
		return false
	var candidate = Session.migrate(json.data)
	var blocked = Session.validate(candidate)
	if not blocked.is_empty():
		status("Save rejected: "+blocked, false)
		return false
	state = candidate
	selected_tile = "2,3"
	selected_unit = ""
	selected_cohort = "pop_a"
	render()
	status("Save imported; migrated people, equipment and orders are ready.")
	return true

func reset_game() -> void:
	state = Session.initial_state()
	selected_tile = "2,3"
	selected_unit = ""
	selected_cohort = "pop_a"
	map_view.fit_map()
	render()
	status("Expedition reset.")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if test_export.visible or save_dialog.visible or load_dialog.visible or reset_dialog.visible or help_dialog.visible or tech_dialog.visible or (is_instance_valid(model_lab) and model_lab.visible):
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
		model_lab.visibility_changed.connect(func():
			if is_instance_valid(world_view):
				world_view.suspended = model_lab.visible
				world_view.update_activity())
	model_lab.open()
	if is_instance_valid(world_view):
		world_view.suspended = true
		world_view.update_activity()

func connect_map(view: Control) -> void:
	view.tile_selected.connect(select_tile)
	view.move_requested.connect(func(key,append): select_tile(key); issue({"type":"queueMove","unitId":selected_unit,"target":key,"append":append}))
	view.hover_changed.connect(show_hover)

func set_map_mode(index: int) -> void:
	var yields_on = map_view.show_yields
	if index == 1 and not is_instance_valid(world_view):
		world_view = WorldView.new()
		world_view.name = "WorldMap"
		map_host.add_child(world_view)
		world_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		connect_map(world_view)
		world_view.set_animation(find_child("WorldMotion",true,false).button_pressed)
	pixel_view.visible = index == 0
	if is_instance_valid(world_view): world_view.visible = index == 1
	map_view = world_view if index == 1 else pixel_view
	map_view.show_yields = yields_on
	view_selector.select(index)
	update_map()
	map_view.focus_tile("4,3") if index == 1 else pixel_view.focus_tile("4,3")
	status("3D isometric world: click/drag/zoom and right-click orders." if index == 1 else "Pixel top-down world.")

func select_person(id: String) -> void:
	state = Session.command(state,{"type":"focusPerson","cohortId":id}).state
	selected_cohort = id
	render()

func render_testing() -> void:
	clear(testing_panel)
	heading(testing_panel,"Civilization testing")
	label(testing_panel,"Blue: human commands. Red: deterministic growth / development / research policy. Red acts once per End Turn.",12)
	button(testing_panel,"Focus Red Haven",func(): map_view.focus_tile(Session.RED_TOWN); selected_tile = Session.RED_TOWN; render())
	button(testing_panel,"Focus blue settlements",func(): map_view.focus_tile("4,3"))
	var snapshot = Session.summary(state)
	for id in Session.players(state):
		var item = snapshot[id]
		heading(testing_panel,id.capitalize()+" civilization")
		label(testing_panel,"%d people · %d/20 techs · %d buildings · %d improved tiles" % [item.population,item.techs.size(),item.buildings,item.improvedTiles],12)
		label(testing_panel,", ".join(item.resources.keys().map(func(k): return k.capitalize()+" "+str(item.resources[k]))),11)
		label(testing_panel,"Growth: "+", ".join(item.growth.map(func(g): return Session.players(state)[id].settlements[g.id].name+" "+str(g.growth)+"/20")),11)
	heading(testing_panel,"Xeno ecology · wildlife")
	var ecology = Session.X.summary(state.xenos)
	label(testing_panel,"Deaths — blue %d · red %d · animals %d; active nests %d" % [ecology.deaths.blue,ecology.deaths.red,ecology.deaths.animals,ecology.activeNests],13)
	label(testing_panel,"%d nests · %d larvae · %d predators (%d armored) · %d xenomass tiles" % [ecology.nests,ecology.workers,ecology.predators,ecology.armored,ecology.massTiles],12)
	button(testing_panel,"Focus xeno nest",func():
		if not state.xenos.nests.is_empty(): map_view.focus_tile(state.xenos.nests.values()[0].tile))
	divider(testing_panel)
	label(testing_panel,"Recording: "+("ON" if state.testing.enabled else "OFF")+" · "+str(state.testing.events.size())+" events · dropped "+str(state.testing.dropped),12)
	button(testing_panel,"Start new recording (clears previous trace)",func(): state = Session.start_recording(state); render())
	button(testing_panel,"Finish recording (manual stop)",func(): state = Session.finish_recording(state); render())
	button(testing_panel,"Export test record…",func(): test_export.popup_centered_ratio(0.7))
	label(testing_panel,"Records accepted/rejected commands, policy-rule labels, before/after outcomes and final summaries. Deaths counted separately for blue, red and animals; nest occupation disables breeding/spread.",11)
	for event in state.testing.events.slice(maxi(0,state.testing.events.size()-8)):
		label(testing_panel,"#%d T%d %s · %s · %s" % [event.sequence,event.turn,event.player,event.command.type,event.policyRule],11)
func export_test(path: String) -> bool:
	var file = FileAccess.open(path,FileAccess.WRITE)
	if file == null: status("Test export failed.",false); return false
	file.store_string(JSON.stringify(Session.report(state),"  "))
	file.flush()
	var success = file.get_error() == OK
	file.close()
	status("Test record exported." if success else "Test export failed.",success)
	return success
