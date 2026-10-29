extends PanelContainer
## Isolated 3D art test screen; never reads or changes the strategy simulation.
const RigScene = preload("res://assets/models/population_rig.tscn")
const Rig = preload("res://scripts/population_rig.gd")
const Terrain = preload("res://scripts/terrain_study.gd")
const Parts = preload("res://scripts/model_parts.gd")
const Art = preload("res://scripts/starter_art.gd")
var pages: TabContainer
var rigs: Array = []
var models: Array = []
var viewports: Array = []
var terrains: Array = []
var terrain_motion: CheckButton
var terrain_detail: CheckButton
var walk_button: Button
var stop_button: Button
var motion_label: Label
var yaw = -0.45
var speed = 1.0

func text(parent: Node, value: String, size: int = 15, color: Color = Color("dce7e6")) -> Label:
	var label = Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)
	return label

func action(parent: Node, title: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = title
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _ready() -> void:
	name = "ModelLab"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	var style = StyleBoxFlat.new()
	style.bg_color = Color("101b26")
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	add_theme_stylebox_override("panel",style)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation",10)
	add_child(layout)
	var top = HBoxContainer.new()
	layout.add_child(top)
	text(top,"ALIEN PLANET  /  MODEL LAB",26,Color("ead7aa")).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action(top,"Back to game",close).name = "CloseModelLab"
	text(layout,"Faceted terrain • 13-bone shared rig • eight refined sprite-inspired outfits • geometry studies, not final art",14,Color("9fbbc2"))
	var controls = HBoxContainer.new()
	layout.add_child(controls)
	walk_button = action(controls,"Walk",walk)
	walk_button.name = "WalkModels"
	stop_button = action(controls,"Stop / reset pose",stop)
	stop_button.name = "StopModels"
	motion_label = text(controls,"Stopped · in-place gait",14,Color("92cbb7"))
	motion_label.custom_minimum_size.x = 220
	text(controls,"View angle",14)
	var turn = HSlider.new()
	turn.name = "ModelYaw"
	turn.min_value = -180
	turn.max_value = 180
	turn.value = rad_to_deg(yaw)
	turn.custom_minimum_size.x = 160
	controls.add_child(turn)
	turn.value_changed.connect(func(value):
		yaw = deg_to_rad(value)
		for model in models: model.rotation.y = yaw)
	text(controls,"Gait speed",14)
	var pace = HSlider.new()
	pace.name = "GaitSpeed"
	pace.min_value = 0.4
	pace.max_value = 1.6
	pace.step = 0.1
	pace.value = 1.0
	pace.custom_minimum_size.x = 110
	controls.add_child(pace)
	pace.value_changed.connect(func(value):
		speed = value
		for rig in rigs: rig.gait_speed = speed)
	var terrain_controls = HBoxContainer.new()
	layout.add_child(terrain_controls)
	text(terrain_controls,"TERRAIN STUDY",13,Color("ead7aa"))
	terrain_motion = CheckButton.new()
	terrain_motion.name = "TerrainMotion"
	terrain_motion.text = "Wind / water / ambient motion"
	terrain_motion.button_pressed = true
	terrain_controls.add_child(terrain_motion)
	terrain_motion.toggled.connect(func(value):
		for tile in terrains: tile.atmosphere.animated = value)
	terrain_detail = CheckButton.new()
	terrain_detail.name = "TerrainDetail"
	terrain_detail.text = "Surface texture / ambient sprites"
	terrain_detail.button_pressed = true
	terrain_controls.add_child(terrain_detail)
	terrain_detail.toggled.connect(func(value):
		for tile in terrains: tile.atmosphere.set_detail(value))
	pages = TabContainer.new()
	pages.name = "ModelStudyTabs"
	pages.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(pages)
	var terrain_page = page("Terrain hexes")
	text(terrain_page,"Textured surfaces / gentle wind and water / sparse ambient sprites",18)
	var terrain_grid = GridContainer.new()
	terrain_grid.columns = 3
	terrain_page.add_child(terrain_grid)
	for kind in Terrain.KINDS: terrain_card(terrain_grid,kind,260)
	var people_page = page("Population rigs")
	text(people_page,"Left: actual 3D study. Right: existing sprite reference. All outfits share the rig and walk cycle.",16)
	var people_grid = GridContainer.new()
	people_grid.columns = 3
	people_page.add_child(people_grid)
	for role in Rig.ROLES: person_card(people_grid,role,220)
	var compare = page("Comparison collage")
	text(compare,"01  TERRAIN / same hex scale",19,Color("ead7aa"))
	var terrain_row = GridContainer.new()
	terrain_row.columns = 6
	compare.add_child(terrain_row)
	for kind in Terrain.KINDS: terrain_card(terrain_row,kind,210)
	text(compare,"02  PEOPLE / same rig, camera and gait / sprite references at right",19,Color("ead7aa"))
	var compare_grid = GridContainer.new()
	compare_grid.columns = 3
	compare.add_child(compare_grid)
	for role in Rig.ROLES: person_card(compare_grid,role,250)
	var landscape = page("Terrain landscape")
	text(landscape,"Seven joined hexes / shared assets / colour variation / living patches",18)
	var landscape_stage = stage(landscape,680,false)
	var camera = landscape_stage.get_viewport().get_camera_3d()
	camera.size = 7.8
	camera.position = Vector3(5,7,9)
	camera.look_at(Vector3.ZERO,Vector3.UP)
	var sites = [[0,0,"Plains"],[1,0,"Forest"],[0,1,"Fungal"],[-1,1,"Forest"],[-1,0,"Hills"],[0,-1,"Water"],[1,-1,"Plains"]]
	for index in range(sites.size()):
		var site = sites[index]
		var tile = Terrain.new()
		tile.kind = site[2]
		tile.variation = index+1
		tile.position = Vector3(1.5*site[0],0,sqrt(3.0)*(site[1]+site[0]*0.5))
		landscape_stage.add_child(tile)
		terrains.append(tile)
	text(layout,"Walk animates every visible person in place. Stop restores the same neutral stance. Desert and fungal hexes are proposals only.",13,Color("9fbbc2"))
	pages.tab_changed.connect(func(_index): update_activity.call_deferred())
	visibility_changed.connect(update_activity)
	update_activity.call_deferred()

func page(title: String) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.name = title.replace(" ","")
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pages.add_child(scroll)
	pages.set_tab_title(pages.get_tab_count()-1,title)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation",10)
	scroll.add_child(box)
	return box

func card(parent: Node, title: String) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("192b36")
	style.set_corner_radius_all(5)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	panel.add_theme_stylebox_override("panel",style)
	parent.add_child(panel)
	var box = VBoxContainer.new()
	panel.add_child(box)
	text(box,title.to_upper(),17,Color("e4cf9e"))
	return box

func stage(parent: Node, height: int, person: bool) -> Node3D:
	var container = SubViewportContainer.new()
	container.stretch = true
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(100,height)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	var viewport = SubViewport.new()
	viewport.size = Vector2i(320,height)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_2X
	container.add_child(viewport)
	viewports.append(viewport)
	var environment = WorldEnvironment.new()
	var settings = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("15232e")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("b7c9d9")
	settings.ambient_light_energy = 0.45
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	viewport.add_child(environment)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-35,0)
	sun.light_color = Color("ffe6be")
	sun.light_energy = 0.95
	sun.shadow_enabled = true
	viewport.add_child(sun)
	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20,140,0)
	fill.light_color = Color("92c5d6")
	fill.light_energy = 0.25
	viewport.add_child(fill)
	var camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.70 if person else 2.85
	camera.position = Vector3(3,2.0,5) if person else Vector3(3.2,3.4,4.6)
	viewport.add_child(camera)
	camera.look_at(Vector3(0,1.0,0) if person else Vector3(0,0.10,0),Vector3.UP)
	var root = Node3D.new()
	viewport.add_child(root)
	root.rotation.y = yaw
	models.append(root)
	if person: Parts.cylinder(root,Vector3(0,-0.07,0),0.70,0.12,Color("304652"),12)
	return root

func terrain_card(parent: Node, kind: String, height: int) -> void:
	var box = card(parent,kind)
	var world = stage(box,height,false)
	var tile = Terrain.new()
	tile.kind = kind
	world.add_child(tile)
	terrains.append(tile)
	var descriptions = {"Plains":"Ground patches · grass · drifting motes", "Forest":"Canopy sway · ground litter", "Hills":"Stone grain · stable ridges", "Water":"Moving ripples · teal highlights", "Desert":"Sand grain · slow dust", "Fungal":"Soft cap sway · rising spores"}
	text(box,descriptions[kind],12,Color("9fbbc2"))

func person_card(parent: Node, role: String, height: int) -> void:
	var box = card(parent,"Joint / limb rig" if role == "Rig" else role)
	var row = HBoxContainer.new()
	box.add_child(row)
	var world = stage(row,height,true)
	var rig = RigScene.instantiate()
	rig.role = role
	world.add_child(rig)
	rigs.append(rig)
	# The reference is a texture, never a billboard pretending to be a 3D model.
	if role != "Rig":
		var reference = TextureRect.new()
		reference.texture = Art.icon(role)
		reference.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		reference.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		reference.custom_minimum_size = Vector2(78,height)
		row.add_child(reference)
	else:
		var note = text(row,"13 bones\nRigid limbs\nNo fingers\nSame gait",13,Color("8ec7d2"))
		note.custom_minimum_size.x = 78
	var notes = {"Rig":"Gold joints · cyan limb links", "Worker":"Ochre workwear · shovel · pack", "Farmer":"Olive overalls · brim · hoe", "Engineer":"Slate suit · hardhat · toolbox", "Merchant":"Burgundy coat · satchel · tablet", "Scientist":"Lab coat · goggles · sample", "Administrator":"Navy uniform · gold trim · slate", "Security":"Grey-blue armour · cap", "Specialist":"Teal field gear · headset · terminal"}
	text(box,notes[role],12,Color("9fbbc2"))
	if role != "Rig": text(box,"%d pieces · same 13 bones" % rig.find_children("*","MeshInstance3D",true,false).size(),12,Color("91b4bd"))

func walk() -> void:
	for rig in rigs: rig.walk()
	motion_label.text = "Walking · shared in-place gait"

func stop() -> void:
	for rig in rigs: rig.stop()
	if motion_label: motion_label.text = "Stopped · in-place gait"

func close() -> void:
	stop()
	hide()

func open() -> void:
	show()
	update_activity()

func update_activity() -> void:
	for viewport in viewports:
		var active = viewport.get_parent().is_visible_in_tree()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
		for rig in rigs:
			if rig.get_viewport() == viewport: rig.set_process(active)
		for tile in terrains:
			if tile.get_viewport() == viewport: tile.atmosphere.set_process(active)
