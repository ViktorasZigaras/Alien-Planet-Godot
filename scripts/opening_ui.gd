extends "res://scripts/economy_ui.gd"

const ModelLab = preload("res://scripts/model_lab.gd")
const ConsoleFace = preload("res://scripts/console_face.gd")
const CommandIcons = preload("res://scripts/command_icons.gd")
const Minimap = preload("res://scripts/opening_minimap.gd")
const GOLD = Color("#e6c685")
const CREAM = Color("#f3ead5")
const MUTED = Color("#afbec2")
const GREEN = Color("#a9c78c")
const RED = Color("#f2a99a")
const ICONS = {"minerals":"minerals","energy":"energy","science":"research","culture":"culture"}
const NAV = ["Map","Colony","Research","Ecology","Orders","Alienopedia"]
var model_lab
var mode = "Map"
var stocks = {}
var navigation = {}
var board: HBoxContainer
var dock: HBoxContainer
var contributors: PanelContainer
var details: PanelContainer
var left_content: VBoxContainer
var right_content: VBoxContainer
var commands: VBoxContainer
var selected_info: VBoxContainer
var tile_info: Label
var preview_info: Label
var location: Label
var turn_label: Label
var minimap
var warn_turn: ConfirmationDialog
var forecast = {}
var projected = {}
var selected = "pop_a"
var hovered_tile = ""
var pending_move = ""
var overlay = 0
var archive_page = "Settlement"
var serif: SystemFont
var context_notice = ""

func opening_state() -> Dictionary:
	return Tactical.initial()

func opening() -> Dictionary:
	var game = opening_state()
	E.change(game,"food",8)
	E.change(game,"minerals",2)
	E.change(game,"industry",2)
	E.change(game,"energy",2)
	game.cohorts.pop_a.name = "Civilian I"
	game.cohorts.pop_b.name = "Civilian II"
	game.knowledge.catalogue = {}
	var available = E.jobs(game).filter(func(job): return job.id.begins_with("tile:") and job.yield.get("food",0)>0)
	available.sort_custom(func(a,b):
		return a.yield.food>b.yield.food if a.yield.food!=b.yield.food else a.id<b.id)
	for i in range(mini(2,available.size())):
		game.cohorts[["pop_a","pop_b"][i]].state.job = available[i].id
	return game

func save_path() -> String:
	return "user://alien_planet_b09.json"

func save_format() -> String:
	return "alien-planet-b09-v1"

func display_name(id: String) -> String:
	var person = state.cohorts[id]
	if id == "pop_a" or id == "pop_b":
		return ("Civilian I" if id == "pop_a" else "Civilian II") if person.qualification == "Worker" else person.qualification+" "+("I" if id == "pop_a" else "II")
	return person.name if person.qualification != "Soldier" or id == "guard" else "Soldier "+id

func frame(fill: Color, edge: Color, border: int = 1, padding: int = 10) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(border)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func apply_theme() -> void:
	var ui = Theme.new()
	var body_font = SystemFont.new()
	body_font.font_names = PackedStringArray(["Inter","Segoe UI","Arial"])
	serif = SystemFont.new()
	serif.font_names = PackedStringArray(["Cinzel","Georgia","Times New Roman"])
	ui.default_font = body_font
	ui.default_font_size = 16
	ui.set_color("font_color","Label",CREAM)
	for kind in ["Button","OptionButton","CheckButton"]:
		ui.set_color("font_color",kind,CREAM)
		ui.set_color("font_disabled_color",kind,Color("#9ea8a8"))
		ui.set_color("font_hover_color",kind,Color("#fff2cc"))
		ui.set_stylebox("normal",kind,frame(Color("#29363b"),Color("#786646"),1,7))
		ui.set_stylebox("hover",kind,frame(Color("#38494b"),GOLD,1,7))
		ui.set_stylebox("pressed",kind,frame(Color("#4b4233"),GOLD,1,7))
		ui.set_stylebox("disabled",kind,frame(Color("#202a2e"),Color("#465052"),1,7))
	ui.set_stylebox("panel","PanelContainer",frame(Color("#202b30"),Color("#8b744c"),1,10))
	ui.set_constant("separation","VBoxContainer",8)
	ui.set_constant("separation","HBoxContainer",8)
	theme = ui

func label(parent: Node, text: String, pixels: int = 16, color: Color = CREAM, heading: bool = false) -> Label:
	var item = Label.new()
	item.text = text
	item.add_theme_color_override("font_color",color)
	item.add_theme_font_size_override("font_size",pixels)
	if heading: item.add_theme_font_override("font",serif)
	parent.add_child(item)
	return item

func paragraph(parent: Node, text: String, color: Color = MUTED) -> Label:
	var item = label(parent,text,15,color)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return item

func button(parent: Node, text: String, callback: Callable, hint: String = "", disabled: bool = false) -> Button:
	var item = Button.new()
	item.text = text
	item.accessibility_name = text
	item.tooltip_text = text if hint.is_empty() else text+"\n"+hint
	item.icon = CommandIcons.for_label(text)
	if item.icon and parent is VBoxContainer: item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.disabled = disabled
	item.pressed.connect(callback)
	parent.add_child(item)
	return item

func order(parent: Node, text: String, cmd: Dictionary, blocker: String = "") -> Button:
	return button(parent,text,func(): send(cmd),blocker,blocker!="")

func icon_key(item: Button, extent: int = 42) -> Button:
	item.text = ""
	item.alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.custom_minimum_size = Vector2(extent,extent)
	return item

func meter(parent: Node, value: float, maximum: float, caption: String, tint: Color) -> void:
	var bar = ProgressBar.new()
	bar.custom_minimum_size.y = 7
	bar.max_value = maximum
	bar.value = value
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	bar.tooltip_text = caption
	bar.accessibility_name = caption
	bar.add_theme_stylebox_override("background",frame(Color("#101d22"),Color("#465652"),1,0))
	bar.add_theme_stylebox_override("fill",frame(tint,tint,0,0))
	parent.add_child(bar)

func clear_ui(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func section(parent: Node, caption: String, width: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size.x = width
	panel.add_theme_stylebox_override("panel",frame(Color("#1a282e"),Color("#a18a61"),2,12))
	parent.add_child(panel)
	panel.add_child(ConsoleFace.new())
	var column = VBoxContainer.new()
	panel.add_child(column)
	label(column,caption,22,GOLD,true)
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	panel.set_meta("content",content)
	panel.set_meta("heading",column.get_child(0))
	return panel

func _ready() -> void:
	tactical_mode = true
	state = opening()
	construction_tile = state.settlements.main.tileId
	apply_theme()
	var backdrop = ColorRect.new()
	backdrop.color = Color("#10171c")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+edge,8)
	add_child(margin)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation",6)
	margin.add_child(box)
	build_header()
	board = HBoxContainer.new()
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(board)
	contributors = section(board,"Contributors",275)
	left_content = contributors.get_meta("content")
	var map_panel = PanelContainer.new()
	map_panel.add_theme_stylebox_override("panel",frame(Color("#18272d"),Color("#a58c5b"),2,2))
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.add_child(map_panel)
	var map_layer = Control.new()
	map_layer.custom_minimum_size = Vector2(500,375)
	map_panel.add_child(map_layer)
	world = World.new()
	world.fixed_scale = true
	world.fixed_camera_size = 9.1
	world.opening_presentation = true
	world.show_metrics = false
	world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_layer.add_child(world)
	location = label(map_layer,"Landing Station",21,Color("#fff0c8"),true)
	location.position = Vector2(16,10)
	location.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location.add_theme_color_override("font_shadow_color",Color("#131719"))
	location.add_theme_constant_override("shadow_offset_x",2)
	location.add_theme_constant_override("shadow_offset_y",2)
	details = section(board,"Colony",494)
	right_content = details.get_meta("content")
	world.defer_right_click = true
	world.tile_selected.connect(select_tile)
	world.tile_activated.connect(func(key):
		if key == state.settlements.main.tileId: show_mode("Colony"))
	world.hover_changed.connect(func(key): hovered_tile = key; update_preview())
	world.move_preview.connect(func(key): pending_move = key; update_preview())
	world.move_requested.connect(execute_map_order)
	build_dock()
	world.resized.connect(update_minimap)
	warn_turn = ConfirmationDialog.new()
	warn_turn.title = "Confirm End Turn"
	warn_turn.ok_button_text = "Advance turn"
	warn_turn.confirmed.connect(func(): send({"type":"endTurn"}))
	add_child(warn_turn)
	refresh()
	world.focus_tile(state.settlements.main.tileId if state.has("survey") else "3,3")
	construction_tile = E.R.person_tile(state,state.cohorts[selected])
	world.select_view(construction_tile,selected)
	refresh_selection()
	update_minimap()

func build_header() -> void:
	var header = PanelContainer.new()
	header.add_theme_stylebox_override("panel",frame(Color("#232e32"),Color("#b29965"),1,7))
	box.add_child(header)
	header.add_child(ConsoleFace.new())
	var column = VBoxContainer.new()
	header.add_child(column)
	var upper = HBoxContainer.new()
	column.add_child(upper)
	var title = label(upper,"ALIEN PLANET",28,GOLD,true)
	title.custom_minimum_size.x = 230
	var strip = HBoxContainer.new()
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upper.add_child(strip)
	for resource in E.R.RESOURCES:
		var stock = PanelContainer.new()
		stock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stock.add_theme_stylebox_override("panel",frame(Color("#18242a"),Color("#5b665b"),1,5))
		strip.add_child(stock)
		var row = HBoxContainer.new()
		stock.add_child(row)
		if ICONS.has(resource):
			var icon = TextureRect.new()
			icon.texture = load("res://assets/icons/"+ICONS[resource]+".svg")
			icon.custom_minimum_size = Vector2(22,22)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			row.add_child(icon)
		stocks[resource] = label(row,"",15)
	var lower = HBoxContainer.new()
	column.add_child(lower)
	for tab in NAV:
		navigation[tab] = icon_key(button(lower,tab,func(): show_mode(tab)),38)
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower.add_child(spacer)
	icon_key(button(lower,"Center station",func(): world.focus_tile(state.settlements.main.tileId),"Home"),38)
	icon_key(button(lower,"Overlay",cycle_overlay,"Cycles terrain, yields and pollution"),38)
	var motion = CheckButton.new()
	motion.text = "Motion"
	motion.button_pressed = true
	motion.toggled.connect(func(on): world.set_animation(on))
	lower.add_child(motion)
	icon_key(button(lower,"Model Lab",open_model_lab),38)
	icon_key(button(lower,"Save",func(): action("Save")),38)
	icon_key(button(lower,"Load",func(): action("Load")),38)
	turn_label = label(lower,"",19,GOLD,true)

func build_dock() -> void:
	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = 166
	box.add_child(panel)
	dock = HBoxContainer.new()
	var face = ConsoleFace.new()
	face.cable_run = true
	panel.add_child(face)
	var housing = VBoxContainer.new()
	panel.add_child(housing)
	housing.add_child(dock)
	var wiring_space = Control.new()
	wiring_space.custom_minimum_size.y = 14
	housing.add_child(wiring_space)
	selected_info = VBoxContainer.new()
	selected_info.custom_minimum_size.x = 325
	dock.add_child(selected_info)
	var center = VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.add_child(center)
	commands = VBoxContainer.new()
	center.add_child(commands)
	var glass_readout = PanelContainer.new()
	glass_readout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	glass_readout.add_theme_stylebox_override("panel",frame(Color("#12262d"),Color("#516764"),1,7))
	center.add_child(glass_readout)
	var readout = VBoxContainer.new()
	readout.add_theme_constant_override("separation",3)
	glass_readout.add_child(readout)
	tile_info = paragraph(readout,"",CREAM)
	preview_info = paragraph(readout,"",GOLD)
	message = paragraph(readout,"",MUTED)
	var right = VBoxContainer.new()
	right.custom_minimum_size.x = 252
	dock.add_child(right)
	minimap = Minimap.new()
	minimap.custom_minimum_size = Vector2(252,106)
	minimap.focus_requested.connect(func(key): world.focus_tile(key); update_minimap())
	var glass = PanelContainer.new()
	glass.add_theme_stylebox_override("panel",frame(Color("#11191d"),Color("#766c51"),2,4))
	right.add_child(glass)
	glass.add_child(minimap)
	var end = button(right,"End Turn  ↵",request_turn,"Advance economy, work and wildlife")
	end.add_theme_stylebox_override("normal",frame(Color("#6b5030"),Color("#e7c479"),1,7))

func open_model_lab() -> void:
	if not is_instance_valid(model_lab):
		model_lab = ModelLab.new()
		model_lab.start_in_field_kit = true
		add_child(model_lab)
		model_lab.visibility_changed.connect(func():
			world.suspended = model_lab.visible
			world.update_activity())
	model_lab.open()
	world.suspended = true
	world.update_activity()

func opening_forecast() -> Dictionary:
	return E.resolve(state)

func opening_projection() -> Dictionary:
	return Exploration.K.view(state,Session.projection(state))

func validate_opening(game) -> String:
	return Tactical.validate(game)

func refresh() -> void:
	forecast = opening_forecast()
	projected = opening_projection()
	world.update_view(projected,construction_tile,selected,"none")
	refresh_selection()
	for resource in E.R.RESOURCES:
		var net = int(forecast.ledger.net[resource])
		var stock = stocks[resource]
		stock.text = "%s  %d  %+d" % [resource.capitalize(),state.resources[resource],net]
		stock.add_theme_color_override("font_color",RED if net<0 else CREAM)
		stock.get_parent().get_parent().tooltip_text = "%s reserve %d\nNext turn gross %d · upkeep %d · costs %d · net %+d" % [resource.capitalize(),state.resources[resource],forecast.ledger.gross[resource],forecast.ledger.upkeep[resource],forecast.ledger.inputs[resource]+forecast.ledger.spending[resource],net]
	turn_label.text = "Turn %03d" % int(state.turn)
	message.text = context_notice
	update_minimap()

func send(cmd: Dictionary) -> void:
	var result = execute(cmd)
	context_notice = result.message
	if result.ok:
		state = result.state
		remember_species()
		refresh()
	else: message.text = context_notice

func action(text: String) -> void:
	if text == "Save":
		var file = FileAccess.open(save_path(),FileAccess.WRITE)
		context_notice = "Opening saved." if file else "Save failed."
		if file: file.store_string(JSON.stringify({"format":save_format(),"game":state}))
	elif text == "Load":
		var data = JSON.parse_string(FileAccess.get_file_as_string(save_path())) if FileAccess.file_exists(save_path()) else null
		if data is Dictionary and data.get("format") == save_format() and validate_opening(data.get("game")) == "":
			state = data.game
			if not state.cohorts.has(selected): selected = "pop_a"
			context_notice = "Opening loaded."
			refresh()
			world.focus_tile(state.settlements.main.tileId)
		else: context_notice = "No valid save found."
	message.text = context_notice

func request_turn() -> void:
	var ledger = forecast.ledger
	if ledger.closing.food < 0 or ledger.closing.energy < 0:
		warn_turn.dialog_text = "Projected reserves after this turn: %d Food and %d Energy. Review Colony or advance anyway." % [ledger.closing.food,ledger.closing.energy]
		warn_turn.popup_centered(Vector2i(510,170))
	else: send({"type":"endTurn"})

func show_mode(tab: String) -> void:
	mode = tab
	refresh_selection()
	update_minimap()

func select_tile(key: String) -> void:
	construction_tile = key
	var stationed = state.cohorts.keys().filter(func(id): return E.R.person_tile(state,state.cohorts[id]) == key)
	if mode != "Colony" and not stationed.is_empty():
		var index = stationed.find(selected)
		selected = stationed[(index+1)%stationed.size()]
	world.select_view(key,selected)
	refresh_selection()
	update_minimap()

func choose_person(id: String, center: bool = true) -> void:
	selected = id
	construction_tile = E.R.person_tile(state,state.cohorts[id])
	if center: world.focus_tile(construction_tile)
	world.select_view(construction_tile,selected)
	refresh_selection()
	update_minimap()

func cycle_person() -> void:
	var ids = state.cohorts.keys().filter(func(id): return state.cohorts[id].state.get("job") == null and not state.movementQueues.has(id))
	if ids.is_empty(): ids = state.cohorts.keys()
	choose_person(ids[(ids.find(selected)+1)%ids.size()])

func cycle_overlay() -> void:
	overlay = (overlay+1)%3
	world.show_yields = overlay == 1
	world.highlight_pollution = overlay == 2
	location.text = ["Landing Station","Tile yields","Pollution"][overlay]
	world.queue_redraw()

func update_minimap() -> void:
	minimap.tiles = projected.get("tiles",{})
	minimap.grid = Vector2i(state.map.width,state.map.height)
	minimap.visible_hexes = state.knowledge.visible
	minimap.memory = state.knowledge.memory
	minimap.station = state.settlements.main.tileId
	minimap.selected = construction_tile
	minimap.focus = world.target
	minimap.footprint = Vector2(world.fixed_camera_size*world.size.x/maxf(1,world.size.y),world.fixed_camera_size*sqrt(1.0+pow(23.0/21.0,2)))
	minimap.queue_redraw()

func _process(_delta: float) -> void:
	if world != null and minimap != null and minimap.focus != world.target: update_minimap()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo: return
	if is_instance_valid(model_lab) and model_lab.visible:
		if event.keycode == KEY_ESCAPE: model_lab.close()
		get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_ESCAPE:
			pending_move = ""
			world.cancel_move_preview()
			show_mode("Map")
		KEY_ENTER: request_turn()
		KEY_TAB,KEY_I: cycle_person()
		KEY_HOME: world.focus_tile(state.settlements.main.tileId)
		KEY_C: show_mode("Colony" if mode != "Colony" else "Map")
		KEY_F1: show_mode("Alienopedia")
		KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN:
			var offset = {KEY_LEFT:Vector3(-1,0,0),KEY_RIGHT:Vector3(1,0,0),KEY_UP:Vector3(0,0,-1),KEY_DOWN:Vector3(0,0,1)}
			world.target += offset[event.keycode]
			world.update_camera()
		_: return
	get_viewport().set_input_as_handled()

func refresh_selection() -> void:
	contributors.visible = mode == "Colony"
	details.visible = mode != "Map"
	world.show_work_labels = mode == "Colony"
	world.queue_redraw()
	for tab in NAV:
		navigation[tab].add_theme_color_override("font_color",GOLD if tab == mode else CREAM)
		navigation[tab].add_theme_stylebox_override("normal",frame(Color("#4b4233"),GOLD,1,7) if tab == mode else frame(Color("#29363b"),Color("#786646"),1,7))
	clear_ui(left_content)
	clear_ui(right_content)
	details.get_meta("heading").text = "Landing Station" if mode == "Colony" else mode
	match mode:
		"Colony": colony_panel()
		"Research": research_panel()
		"Ecology": ecology_panel()
		"Orders": orders_panel()
		"Alienopedia": archive_panel()
	refresh_dock()

func job_name(person: Dictionary) -> String:
	var job = person.state.get("job")
	if person.state.kind == "mobile": return "In the field"
	if job == null: return "Idle"
	if job.begins_with("tile:"): return "Working hex "+job.substr(5)
	return job.capitalize()

func card(parent: Node, title: String) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel",frame(Color("#27353a"),Color("#66726a"),1,10))
	parent.add_child(panel)
	var content = VBoxContainer.new()
	panel.add_child(content)
	label(content,title,19,GOLD,true)
	return content

func colony_panel() -> void:
	for id in state.cohorts:
		var person = state.cohorts[id]
		var row = card(left_content,display_name(id))
		paragraph(row,job_name(person)+( " · Reserved" if state.commitments.people.has(id) else ""))
		button(row,"Select",func(): choose_person(id,false))
	var person = state.cohorts[selected]
	if person.state.kind == "resident":
		var worker = card(right_content,display_name(selected)+" · assignment")
		var jobs = E.jobs(state)
		var list = OptionButton.new()
		list.fit_to_longest_item = false
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		worker.add_child(list)
		for job in jobs:
			var short_label = job.label.get_slice(" · ",0)
			if job.id.begins_with("tile:"): short_label = "Hex "+job.id.substr(5)+"  "+yields_text(job.yield)
			list.add_item(short_label)
			var index = list.item_count-1
			var blocker = E.reason(state,{"type":"assign","person":selected,"job":job.id})
			list.set_item_disabled(index,blocker!="")
			list.get_popup().set_item_tooltip(index,job.label if blocker=="" else blocker)
			if person.state.job == job.id or (person.state.job == null and job.id == "idle"): list.select(index)
		list.item_selected.connect(func(index): send({"type":"assign","person":selected,"job":jobs[index].id}))
		var assignment = {"type":"assign","person":selected,"job":"tile:"+construction_tile}
		var blocker = E.reason(state,assignment)
		order(worker,"Work selected hex · "+construction_tile,assignment,blocker)
		if blocker == "":
			var result = E.command(state,assignment)
			var changed = E.resolve(result.state).ledger.net.food-int(forecast.ledger.net.food)
			paragraph(worker,"Projected Food change from reassignment %+d" % changed,GREEN if changed>=0 else RED)
		else: paragraph(worker,blocker)
		var equip = {"type":"deployBuilder","person":selected}
		order(worker,"Take build kit",equip,E.reason(state,equip))
	var production = card(right_content,"Production queue")
	var selected_site = label(production,"Build site  "+construction_tile,16)
	selected_site.tooltip_text = "Select a visible hex on the map"
	var recipes = HBoxContainer.new()
	production.add_child(recipes)
	for id in Projects.C.RECIPES:
		var recipe: Dictionary = Projects.C.RECIPES[id]
		var cmd = {"type":"enqueue","recipe":id,"tile":construction_tile}
		var blocker = command_blocker(cmd)
		var hint = "%d work · %d Industry as work is paid" % [recipe.work,recipe.work]
		if blocker != "": hint += "\n"+blocker
		var choice = button(recipes,recipe.label,func(): choose_recipe(id),hint)
		choice.icon = load("res://assets/ui/build_"+("farm" if id == "farm_upgrade" else id)+".png")
		choice.expand_icon = true
		choice.add_theme_constant_override("icon_max_width",56)
		choice.set_meta("build_recipe",id)
		icon_key(choice,72)
		if id == construction_recipe:
			choice.add_theme_stylebox_override("normal",frame(Color("#365052"),GOLD,2,6))
		if id == "farm_upgrade":
			var tier = Label.new()
			tier.text = "II"
			tier.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tier.add_theme_color_override("font_color",GOLD)
			choice.add_child(tier)
			tier.position = Vector2(53,47)
	var recipe: Dictionary = Projects.C.RECIPES[construction_recipe]
	var choice_readout = HBoxContainer.new()
	production.add_child(choice_readout)
	paragraph(choice_readout,"%s · %d work" % [recipe.label,recipe.work],GOLD)
	var build = {"type":"enqueue","recipe":construction_recipe,"tile":construction_tile}
	var blocked = command_blocker(build)
	icon_key(order(choice_readout,"Queue project",build,blocked))
	if blocked != "": paragraph(production,blocked)
	var any_project = false
	for project in state.construction.queue:
		any_project = true
		var line = HBoxContainer.new()
		production.add_child(line)
		var progress = VBoxContainer.new()
		progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(progress)
		var required = Projects.C.RECIPES[project.recipe].work
		var title = Projects.C.RECIPES[project.recipe].label.get_slice(" (",0)
		var project_label = paragraph(progress,"%s · %s\n%d/%d work · %d Industry paid%s" % [title,project.tile,project.work,required,project.paid," · Held" if project.held else ""])
		meter(progress,project.work,required,title+" progress",GOLD)
		var next_project = forecast.state.construction.queue.filter(func(item):return item.id == project.id)
		var blocker = next_project[0].blocker if not next_project.is_empty() else project.blocker
		project_label.tooltip_text = blocker
		if blocker != "" and not project.held and project.status != "complete": paragraph(production,blocker)
		if project.status != "complete":
			icon_key(order(line,"Resume" if project.held else "Hold",{"type":"hold","id":project.id,"held":not project.held}))
		else: label(line,"Complete",14,GREEN)
	if not any_project: paragraph(production,"No projects queued.")
	var growth = card(right_content,"Growth & reserves")
	paragraph(growth,"%d / 10 local growth · %d stored Food\n%d / %d working support" % [state.settlements.main.growth,state.resources.food,Progression.G.working(state),Progression.G.support(state)])
	meter(growth,state.settlements.main.growth,10,"Local population growth",GREEN)
	var next_food = int(forecast.ledger.closing.food)
	paragraph(growth,"Next reserve %d Food · %+d this turn" % [next_food,forecast.ledger.net.food],RED if next_food<0 else GREEN)
	var policy = CheckButton.new()
	policy.text = "Allow growth"
	policy.button_pressed = state.progression.growthEnabled
	policy.toggled.connect(func(on): send({"type":"growthPolicy","enabled":on}))
	growth.add_child(policy)
	var feed = {"type":"boostGrowth","amount":1}
	order(growth,"Transfer 1 Food to growth",feed,Progression.reason(state,feed))
	var training = card(right_content,"Training · "+display_name(selected))
	for name in Progression.specialties(state):
		var train = {"type":"train","person":selected,"qualification":name}
		order(training,name+" · 2 Industry / 2 turns",train,Progression.reason(state,train))
	var course = state.progression.training.get(selected,{})
	if not course.is_empty(): paragraph(training,"%s · %d turns left" % [course.qualification,course.remaining])
	if person.qualification == "Soldier":
		order(training,"Equip rifle · 1 Industry",{"type":"equipSoldier","person":selected,"weapon":"small_arms"})
		order(training,"Equip flamer · 2 Industry",{"type":"equipSoldier","person":selected,"weapon":"flamer"})

func choose_recipe(id: String) -> void:
	construction_recipe = id
	var scroll = right_content.get_parent()
	var offset = scroll.scroll_vertical
	refresh_selection()
	scroll.set_deferred("scroll_vertical",offset)
	for choice in right_content.find_children("*","Button",true,false):
		if choice.get_meta("build_recipe","") == id:
			choice.grab_focus()
			break

func research_panel() -> void:
	paragraph(right_content,"%d Science available · %+d forecast" % [Planner.available(state,"science"),forecast.ledger.net.science])
	for key in Progression.G.TECHS:
		var tech = Progression.G.TECHS[key]
		var title = tech.label.get_slice(" · ",0)
		var entry = card(right_content,title)
		var effect = tech.label.get_slice(" · ",1)
		paragraph(entry,effect.capitalize(),CREAM)
		var proof = "Biologist produced Food last turn" if tech.evidence == "biologist" else "Energy generated last turn"
		paragraph(entry,"Requires "+proof)
		var command = {"type":"research","tech":key}
		var blocker = Progression.reason(state,command)
		label(entry,"%d Science" % tech.cost,16,GOLD)
		if key in state.progression.techs: label(entry,"Researched",15,GREEN)
		else:
			order(entry,"Research",command,blocker)
			if blocker != "": paragraph(entry,blocker)

func ecology_panel() -> void:
	var conditions = card(right_content,"Settlement conditions")
	var env = state.ecology
	paragraph(conditions,"Health %d / 100\nContained waste %d / 4\nSpill backlog %d" % [env.health,env.tank,env.backlog],CREAM)
	paragraph(conditions,"Last turn generated %d · treated %d · spilled %d" % [env.last.get("generated",0),env.last.get("treated",0),env.last.get("spilled",0)])
	paragraph(conditions,"Growth pauses below 70 health. Assign Waste service or a trained Medic in Colony.")
	var terrain = card(right_content,"Terrain work · "+construction_tile)
	paragraph(terrain,"A stationary builder with the kit clears obstructions or cleans spilled pollution.")
	for item in [["Clear terrain","clearTerrain"],["Clean spill","cleanSpill"],["Cancel terrain work","cancelTerrain"],["Repellent · 2 Energy","repellent"]]:
		order(terrain,item[0],{"type":item[1],"person":selected,"tile":construction_tile})
	var work = env.terrainWork.get(selected,{})
	if not work.is_empty(): paragraph(terrain,"%d work turns remaining" % work.remaining)

func orders_panel() -> void:
	for item in [["Automatic settlement work","planning",state.planning.enabled],["Automatic defence","tacticalAuto",state.tactics.auto]]:
		var toggle = CheckButton.new()
		toggle.text = item[0]
		toggle.button_pressed = item[2]
		toggle.toggled.connect(func(on): send({"type":item[1],"enabled":on}))
		right_content.add_child(toggle)
	var reserve = card(right_content,"Industry reserve")
	var amount = SpinBox.new()
	amount.min_value = 1
	amount.max_value = 100
	amount.value = 4
	reserve.add_child(amount)
	button(reserve,"Propose reserve",func(): send({"type":"goal","amount":int(amount.value)}))
	for goal in state.planning.goals:
		if goal.status == "cancelled": continue
		var entry = card(right_content,"Reserve %d Industry" % goal.amount)
		paragraph(entry,goal.status.capitalize()+" · "+goal.blocker)
		if not goal.authorized: order(entry,"Authorize",{"type":"authorize","id":goal.id})
		order(entry,"Cancel",{"type":"cancel","id":goal.id})
	for plan_order in state.tactics.orders: paragraph(right_content,plan_order)
	if state.tactics.target != "": order(right_content,"Stand down expedition",{"type":"standDown"})

func remember_species() -> void:
	if not state.knowledge.has("catalogue"): state.knowledge.catalogue = {}
	for animal in Tactical.visible_animals(state):
		state.knowledge.catalogue[animal.kind] = true

func archive_panel() -> void:
	var topics = ["Settlement","Terrain","Exploration","Wildlife","Units","Research"]
	var topic = OptionButton.new()
	right_content.add_child(topic)
	for name in topics:
		topic.add_item(name)
		if name == archive_page: topic.select(topic.item_count-1)
	topic.item_selected.connect(func(index): archive_page = topics[index]; refresh_selection())
	match archive_page:
		"Settlement":
			paragraph(card(right_content,"Food and work"),"Food supports every cohort. Working civilians consume two Food. Idle and field cohorts consume one. The stock bar shows reserves and next-turn net change. Colony shows assignments and the local growth pool.")
			paragraph(card(right_content,"Construction"),"Projects consume effort and Industry as work is completed. Hold pauses a project and releases its reservations. The reusable kit lets an equipped builder work at a reachable site.")
			paragraph(card(right_content,"Growth and health"),"Ten local Food grows one cohort when support and health permit. Growth pauses below 70 health. Waste service treats contained pollution. An equipped builder cleans a spill.")
		"Terrain":
			paragraph(card(right_content,"Read the map"),"Clear tiles are observed now. Dim tiles retain the last observation or basic geography. Hills, woods and rivers can slow movement. Use the yield and pollution overlays to compare sites.")
			paragraph(card(right_content,"Obstructions"),"Forests, flora and obstacles can prevent construction. Clear terrain requires a stationary builder and the build kit. Forest close to the station reduces waste generation.")
		"Exploration":
			paragraph(card(right_content,"Signals"),"A question mark marks an observed signal. Bring the Explorer to that hex and Identify it. Investigation takes one stationary turn. Fieldwork claims the site until the Explorer moves or stops.")
			for key in state.knowledge.identified:
				var id = state.knowledge.memory.get(key,{}).get("tile",{}).get("bonus","")
				if not E.R.content().bonuses.has(id): continue
				var site = E.R.content().bonuses[id]
				paragraph(card(right_content,site.name+" · "+key),yields_text(site.yields)+(" · Investigated" if state.knowledge.investigated.has(key) else " · Identified"))
		"Wildlife":
			var found = state.knowledge.get("catalogue",{})
			if found.is_empty(): paragraph(right_content,"Wildlife records appear after a sighting.")
			for id in found:
				if not Tactical.X.DATA.has(id): continue
				var animal = Tactical.X.DATA[id]
				var detail = "Gathers resources and spreads xenomass for its nest." if id == "larva" else "Roams and pursues nearby cohorts. Use the combat preview before engaging."
				paragraph(card(right_content,animal.name),detail)
		"Units":
			paragraph(card(right_content,"Civilian"),"Assign work and training in Colony. A civilian can take the reusable build kit and travel to a work site.")
			paragraph(card(right_content,"Explorer"),"Reveals nearby hexes, identifies signals, investigates and performs fieldwork.")
			paragraph(card(right_content,"Soldier"),"Rifles fire up to two hexes. Flamers reach one hex. A ready garrison protects civilians at the station. Retreat preserves wounded cohorts.")
		"Research":
			for tech in Progression.G.TECHS.values():
				var text = tech.label.get_slice(" · ",1)+"\nCost %d Science." % tech.cost
				paragraph(card(right_content,tech.label.get_slice(" · ",0)),text)

func yields_text(yields: Dictionary) -> String:
	var parts: Array[String] = []
	for resource in E.R.RESOURCES:
		if yields.get(resource,0)>0: parts.append("%d %s" % [yields[resource],resource.capitalize()])
	return " · ".join(parts) if not parts.is_empty() else "No available yield"

func animal_at(key: String) -> String:
	for animal in Tactical.visible_animals(state):
		if animal.tile == key: return animal.id
	return ""

func map_order(key: String, append: bool) -> Dictionary:
	var person = state.cohorts[selected]
	var target = animal_at(key)
	if target != "" and person.qualification == "Soldier":
		return {"type":"attackXeno","cohortId":selected,"targetId":target,"mode":"ranged"}
	return {"type":"queueMove","unitId":selected,"target":key,"append":append}

func execute_map_order(key: String, append: bool) -> void:
	pending_move = ""
	var cmd = map_order(key,append)
	send(cmd)
	update_preview()

func command_blocker(cmd: Dictionary) -> String:
	return E.reason(state,cmd)

func update_preview() -> void:
	if preview_info == null: return
	world.preview_route = []
	world.queue_redraw()
	var key = pending_move if pending_move != "" else hovered_tile if hovered_tile != "" else construction_tile
	if not state.tiles.has(key): return
	var append = Input.is_key_pressed(KEY_SHIFT)
	var cmd = map_order(key,append)
	if cmd.type == "attackXeno":
		preview_info.text = Tactical.preview(state,selected,cmd.targetId,"ranged")+" · "+Tactical.preview(state,selected,cmd.targetId,"melee")
		return
	if pending_move != "":
		var issue = command_blocker(cmd)
		if issue == "":
			var source = E.R.person_tile(state,state.cohorts[selected])
			var queued = state.movementQueues.get(selected,[])
			if append and not queued.is_empty(): source = queued.back()
			var path = E.R.path(state,source,key,"")
			world.preview_route = path.path
			preview_info.text = "Move to %s · %d steps · estimated %.1f effort" % [key,path.path.size()-1,path.cost]
		else: preview_info.text = issue
	else: preview_info.text = "Hold right mouse to preview an order · Esc cancels"

func refresh_dock() -> void:
	clear_ui(selected_info)
	clear_ui(commands)
	var person = state.cohorts[selected]
	var at = E.R.person_tile(state,person)
	var identity = HBoxContainer.new()
	selected_info.add_child(identity)
	var portrait = TextureRect.new()
	var role = "soldier" if person.qualification == "Soldier" else "explorer" if person.qualification == "Explorer" else "civilian"
	var portrait_path = "res://assets/ui/"+role+".png"
	if ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
		portrait.custom_minimum_size = Vector2(70,82)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		identity.add_child(portrait)
	var identity_text = VBoxContainer.new()
	identity.add_child(identity_text)
	label(identity_text,display_name(selected),23,GOLD,true)
	var hp = Tactical.X.hp(state.xenos,selected)
	var mobility = " · %.1f movement" % person.state.movementRemaining if person.state.kind == "mobile" else ""
	label(identity_text,"%d HP · Hex %s%s" % [hp,at,mobility],15,RED if hp<45 else CREAM)
	meter(identity_text,hp,100,"Cohort health",RED if hp<45 else GREEN)
	paragraph(identity_text,job_name(person))
	var roster = OptionButton.new()
	roster.fit_to_longest_item = false
	selected_info.add_child(roster)
	var ids = state.cohorts.keys()
	for id in ids:
		roster.add_item(display_name(id))
		if id == selected: roster.select(roster.item_count-1)
	roster.item_selected.connect(func(index): choose_person(ids[index]))
	var same_hex = ids.filter(func(id): return E.R.person_tile(state,state.cohorts[id]) == at)
	if same_hex.size()>1: roster.tooltip_text = "At this hex: "+" · ".join(same_hex.map(display_name))
	var row = HBoxContainer.new()
	commands.add_child(row)
	icon_key(button(row,"Center",func(): world.focus_tile(at)))
	icon_key(button(row,"Next idle",cycle_person,"I"))
	if person.state.kind == "resident":
		icon_key(button(row,"Manage colony",func(): show_mode("Colony")))
	else:
		var move = {"type":"queueMove","unitId":selected,"target":construction_tile}
		icon_key(order(row,"Move here",move,command_blocker(move)))
		icon_key(order(row,"Retreat",{"type":"retreat","person":selected}))
	if selected in state.construction.holders:
		var kit = {"type":"returnBuilder","person":selected}
		icon_key(order(row,"Return kit",kit,E.reason(state,kit)))
		icon_key(button(row,"Terrain work",func(): show_mode("Ecology")))
	if selected == "explorer":
		var bonus = state.knowledge.memory.get(at,{}).get("signal",false)
		var issue = "Stand on an unidentified signal." if not bonus or state.knowledge.identified.has(at) else ""
		icon_key(order(row,"Identify",{"type":"identify"},issue))
		for item in ["investigate","fieldwork"]:
			icon_key(order(row,item.capitalize(),{"type":item},Exploration.K.work_reason(state,item)))
		if state.knowledge.work != "": icon_key(order(row,"Stop work",{"type":"stopFieldwork"}))
	if person.qualification == "Soldier":
		var target = animal_at(construction_tile)
		if target != "":
			for item in [["Fire","ranged"],["Duel","melee"]]:
				var attack = {"type":"attackXeno","cohortId":selected,"targetId":target,"mode":item[1]}
				icon_key(order(row,item[0],attack,Tactical.X.attack_reason(state,state,attack)))
			icon_key(order(row,"Authorize expedition",{"type":"expedition","targetId":target}))
	var tile = projected.tiles.get(construction_tile,{})
	if tile.is_empty(): tile_info.text = ""; return
	var memory = state.knowledge.memory.get(construction_tile,{})
	var knowledge = "Observed" if state.knowledge.visible.has(construction_tile) else ("Last seen on turn %d" % memory.turn if not memory.is_empty() else "Unobserved")
	var special = ""
	if memory.get("signal",false):
		special = " · Unidentified signal" if tile.bonus == "" else " · "+E.R.content().bonuses[tile.bonus].name
	var terrain = E.R.Layers.description(tile)
	var yields = E.R.tile_yield(projected,construction_tile)
	tile_info.text = "%s · %s %s · %s%s · %s" % [construction_tile,tile.baseTerrain.capitalize(),tile.relief,knowledge,special,yields_text(yields)]
	if terrain != "": tile_info.text += " · "+terrain
	update_preview()
