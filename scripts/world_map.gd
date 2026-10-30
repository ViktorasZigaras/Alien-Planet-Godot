class_name PlanetWorldMap
extends Control
signal tile_selected(key: String)
signal move_requested(key: String,append: bool)
signal hover_changed(key: String)
const R = preload("res://scripts/game_rules.gd")
const A = preload("res://scripts/world_assets.gd")
const Batch = preload("res://scripts/world_batch.gd")
const Art = preload("res://scripts/starter_art.gd")
var state: Dictionary = {}
var selected_tile = "2,3"
var selected_unit = ""
var overlay = "none"
var show_yields = false
var hovered = ""
var supply: Dictionary = {}
var route: Dictionary = {}
var viewport: SubViewport
var container: SubViewportContainer
var camera: Camera3D
var world: Node3D
var terrain_root: Node3D
var structure_root: Node3D
var actors_root: Node3D
var actors: Dictionary = {}
var actor_tiles: Dictionary = {}
var actor_loadouts: Dictionary = {}
var tweens: Dictionary = {}
var target = Vector3.ZERO
var zoom = 1.0
var pan = Vector2.ZERO
var dragging = false
var left_down = false
var drag_distance = 0.0
var animated = true
var shadows = false
var suspended = false
var building = false
var built = false
var terrain_signature = ""
var structure_signature = ""
var build_ms = 0.0
var progress = ""
var font: Font
var metrics_clock = 0.0
var metrics = ""
var yaw = -PI/4
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	font = ThemeDB.fallback_font
	container = SubViewportContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.stretch = true
	container.show_behind_parent = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(900,540)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(viewport)
	world = Node3D.new()
	viewport.add_child(world)
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("15232c")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("b9ced4")
	env.environment.ambient_light_energy = 0.73
	world.add_child(env)
	var light = DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-48,-30,0)
	light.light_color = Color("ffe5bf")
	light.light_energy = 0.86
	light.shadow_enabled = false
	world.add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	world.add_child(camera)
	terrain_root = Node3D.new()
	world.add_child(terrain_root)
	structure_root = Node3D.new()
	world.add_child(structure_root)
	actors_root = Node3D.new()
	world.add_child(actors_root)
	resized.connect(update_camera)
	visibility_changed.connect(update_activity)
	mouse_exited.connect(func(): hovered = ""; hover_changed.emit(""); queue_redraw())
	update_activity()
func pos(t: Dictionary) -> Vector3: return Vector3(sqrt(3.0)*(t.q+t.r*0.5),0,1.5*t.r)
func screen(p: Vector3) -> Vector2: return camera.unproject_position(p)*size/Vector2(viewport.size)
func clear(root: Node) -> void:
	for child in root.get_children(): child.free()
func update_view(s: Dictionary,tile: String,unit: String,support: String) -> void:
	state = s
	selected_tile = tile
	selected_unit = unit
	overlay = support
	supply = R.supply_field(s)
	var signature = str(hash([s.tiles,s.rivers]))
	if signature != terrain_signature and not building:
		terrain_signature = signature
		build_terrain.call_deferred()
	if built: update_structures(); update_actors()
	queue_redraw()
func build_terrain() -> void:
	if building: return
	building = true
	built = false
	var started = Time.get_ticks_usec()
	clear(terrain_root)
	var batch = Batch.new()
	var templates = {}
	var index = 0
	for t in state.tiles.values():
		var key = str([t.baseTerrain,t.feature,t.relief])
		if not templates.has(key): templates[key] = A.terrain(t)
		var transform = Transform3D(Basis.IDENTITY,pos(t))
		batch.collect(templates[key],transform)
		index += 1
		if index%24 == 0:
			progress = "Preparing 3D terrain %d / %d…" % [index,state.tiles.size()]
			queue_redraw()
			await get_tree().process_frame
	for template in templates.values(): template.free()
	batch.emit(terrain_root)
	var river_batch = Batch.new()
	for edge in state.rivers:
		var ends = edge.split("|")
		var a = pos(state.tiles[ends[0]])
		var b = pos(state.tiles[ends[1]])
		var model = Node3D.new()
		model.position = (a+b)/2+Vector3(0,0.016,0)
		model.rotation.y = atan2((b-a).x,(b-a).z)
		A.P.box(model,Vector3.ZERO,Vector3(1.0,0.025,0.055),Color("70bed0"))
		river_batch.collect(model)
		model.free()
	river_batch.emit(terrain_root)
	build_ms = (Time.get_ticks_usec()-started)/1000.0
	building = false
	built = true
	progress = ""
	structure_signature = ""
	update_structures()
	update_actors()
	update_camera()
	update_activity()
	queue_redraw()
func update_structures() -> void:
	var towns = state.settlements.values().map(func(t): return [t.id,t.tileId])
	var sites = state.neutralSites.keys()
	var signature = str(hash([towns,state.districts,state.buildings,state.improvements,sites]))
	if signature == structure_signature: return
	structure_signature = signature
	clear(structure_root)
	var batch = Batch.new()
	for t in state.tiles.values():
		if t.bonus != "":
			var resource = A.bonus(t.bonus)
			resource.position = pos(t)+Vector3(-0.57,0.025,0.07)
			batch.collect(resource)
			resource.free()
	for town in state.settlements.values():
		var model = A.settlement(town.id == "main")
		model.position = pos(state.tiles[town.tileId])
		batch.collect(model)
		model.free()
	for d in state.districts.values():
		var model = A.district(d.type)
		model.position = pos(state.tiles[d.tileId])
		var buildings = state.buildings.values().filter(func(b): return b.get("districtId","") == d.id)
		for i in range(buildings.size()):
			var b = A.building(buildings[i].type,buildings[i].tier)
			b.scale = Vector3.ONE*0.62
			b.position = Vector3(-0.23+i*0.46,0.04,-0.15)
			model.add_child(b)
		batch.collect(model)
		model.free()
	for tile in state.improvements:
		for kind in state.improvements[tile]:
			if not state.improvements[tile][kind]: continue
			if kind == "road":
				for next in R.neighbours(state,tile):
					if next < tile or not state.improvements.get(next,{}).get("road",false): continue
					var a = pos(state.tiles[tile])
					var b = pos(state.tiles[next])
					var road = Node3D.new()
					road.position = (a+b)/2+Vector3(0,0.035,0)
					road.rotation.y = atan2((b-a).x,(b-a).z)
					A.P.box(road,Vector3.ZERO,Vector3(0.14,0.025,a.distance_to(b)),Color("c4b28b"))
					batch.collect(road)
					road.free()
			var model = A.improvement(kind)
			model.position = pos(state.tiles[tile])
			batch.collect(model)
			model.free()
	for tile in state.neutralSites:
		var model = A.building("exchange" if state.neutralSites[tile].resource == "culture" else "research_lab")
		model.scale = Vector3.ONE*0.85
		model.position = pos(state.tiles[tile])
		batch.collect(model)
		model.free()
	batch.emit(structure_root)
func update_actors() -> void:
	var visible_people = R.visible_people(state)
	var wanted = visible_people.values()
	for id in actors.keys():
		if id not in wanted:
			if tweens.has(id): tweens[id].kill(); tweens.erase(id)
			actors[id].free()
			actors.erase(id)
			actor_tiles.erase(id)
			actor_loadouts.erase(id)
	for tile in visible_people:
		var id = visible_people[tile]
		var c = state.cohorts[id]
		var loadout = str([c.qualification,c.equipment])
		if actors.has(id) and actor_loadouts[id] != loadout:
			if tweens.has(id): tweens[id].kill(); tweens.erase(id)
			actors[id].free()
			actors.erase(id)
		if not actors.has(id):
			var actor = A.person(c)
			actor.scale = Vector3.ONE*(0.62 if "rover" in c.equipment else 0.45)
			actors_root.add_child(actor)
			actor.set_process(is_visible_in_tree() and not suspended and animated)
			actors[id] = actor
			actor.position = actor_position(tile)
			actor.rotation.y = c.facing
			actor_loadouts[id] = loadout
			actor_tiles[id] = tile
		var actor = actors[id]
		if actor_tiles[id] != tile:
			if tweens.has(id): tweens[id].kill()
			actor_tiles[id] = tile
			actor.walk()
			var tween = create_tween()
			tweens[id] = tween
			var steps = c.lastRoute.slice(1) if c.state.kind == "mobile" and c.lastRoute.size() > 1 else [tile]
			var from = actor.position
			for next in steps:
				var to = actor_position(next)
				var direction = atan2((to-from).x,(to-from).z)
				tween.tween_callback(func(): if is_instance_valid(actor): actor.rotation.y = direction)
				tween.tween_property(actor,"position",to,0.20 if animated else 0.001)
				from = to
			tween.tween_callback(func():
				if is_instance_valid(actor): actor.stop(); actor.rotation.y = c.facing
				tweens.erase(id))
		elif not tweens.has(id): actor.rotation.y = c.facing
func actor_position(tile: String) -> Vector3:
	var occupied = not R.site_at(state,tile).is_empty() or not R.district_at(state,tile).is_empty() or state.neutralSites.has(tile)
	return pos(state.tiles[tile])+Vector3(0,0.07,0.38 if occupied else 0.16)
func fit_map() -> void:
	if state.is_empty(): return
	target = (pos(state.tiles.values()[0])+pos(state.tiles.values().back()))/2
	zoom = 1.0
	pan = Vector2.ZERO
	update_camera()
func focus_tile(key: String) -> void:
	if not state.tiles.has(key): return
	target = pos(state.tiles[key])
	zoom = 3.4
	update_camera()
func update_camera() -> void:
	if camera == null or state.is_empty(): return
	camera.size = 47.0/zoom
	camera.position = target+Vector3(sin(yaw)*23,26,cos(yaw)*23)
	camera.look_at(target)
	queue_redraw()
func pick(point: Vector2) -> String:
	if not built: return ""
	var local = point*Vector2(viewport.size)/size
	var hit = Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(local),camera.project_ray_normal(local))
	if hit == null: return ""
	var best = ""
	var best_dist = 1.0
	for t in state.tiles.values():
		var d = pos(t).distance_squared_to(hit)
		if d < best_dist:
			best = t.id
			best_dist = d
	return best
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: left_down = true; drag_distance = 0
			else:
				if left_down and drag_distance < 5:
					var key = pick(event.position)
					if key != "": tile_selected.emit(key)
				left_down = false
			accept_event()
		elif event.button_index == MOUSE_BUTTON_MIDDLE: dragging = event.pressed; accept_event()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			zoom = clampf(zoom*(1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1/1.12),0.65,7.0)
			update_camera()
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var key = pick(event.position)
			if key != "": move_requested.emit(key,event.shift_pressed)
			accept_event()
	elif event is InputEventMouseMotion:
		if dragging or left_down:
			drag_distance += event.relative.length()
			if dragging or drag_distance > 5:
				target -= (camera.basis.x*event.relative.x+Vector3(camera.basis.y.x,0,camera.basis.y.z)*event.relative.y)*camera.size/maxf(1,size.y)
				update_camera()
		else:
			var key = pick(event.position)
			if key != hovered: hovered = key; hover_changed.emit(key); queue_redraw()
func set_animation(value: bool) -> void:
	animated = value
	for mat in A.motion_materials.values(): mat.set_shader_parameter("animated",value)
	for actor in actors.values(): actor.set_process(value and is_visible_in_tree() and not suspended)
	if not value:
		for id in tweens:
			tweens[id].kill()
			actors[id].position = actor_position(actor_tiles[id])
			actors[id].stop()
		tweens.clear()
func update_activity() -> void:
	if viewport == null: return
	var active = is_visible_in_tree() and not suspended
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	for actor in actors.values(): actor.set_process(active and animated)
	for tween in tweens.values():
		if active: tween.play()
		else: tween.pause()
	set_process(active)
func _process(delta: float) -> void:
	metrics_clock += delta
	if metrics_clock > 0.5:
		metrics_clock = 0
		metrics = "3D · %d FPS · %d draw calls · %d figures · motion %s" % [Engine.get_frames_per_second(),viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),actors.size(),"on" if animated else "off"]
		queue_redraw()
	if not tweens.is_empty(): queue_redraw()
func _draw() -> void:
	if camera == null or state.is_empty(): return
	for key in [selected_tile,hovered]:
		if not state.tiles.has(key): continue
		var points = PackedVector2Array()
		for i in range(7):
			var a = deg_to_rad(30+(i%6)*60)
			points.append(screen(pos(state.tiles[key])+Vector3(cos(a)*0.97,0.04,sin(a)*0.97)))
		draw_polyline(points,Color("f5d58a") if key == selected_tile else Color("aacac7"),2,true)
	for c in state.cohorts.values():
		if c.state.kind != "resident" or not c.state.get("job") is String or not c.state.job.begins_with("tile:"): continue
		var key = c.state.job.substr(5)
		var points = PackedVector2Array()
		for i in range(7):
			var angle = deg_to_rad(30+(i%6)*60)
			points.append(screen(pos(state.tiles[key])+Vector3(cos(angle)*0.84,0.045,sin(angle)*0.84)))
		var color = Color("8bd4df") if c.home == "main" else Color("d0a2e4")
		draw_polyline(points,color,1.2,true)
		draw_string(font,screen(pos(state.tiles[key])+Vector3(-0.4,0.95,0)),c.name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,color)
	if actors.has(selected_unit): draw_arc(screen(actors[selected_unit].position),13,0,TAU,20,Color("f6d48a"),2,true)
	for site in state.settlements.values():
		draw_string(font,screen(pos(state.tiles[site.tileId])+Vector3(-0.5,1,0)),site.name,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffe5b2"))
	if state.movementQueues.has(selected_unit):
		var prev = R.mobile(state,selected_unit).tileId
		for next in state.movementQueues[selected_unit]:
			draw_line(screen(pos(state.tiles[prev])+Vector3(0,0.07,0)),screen(pos(state.tiles[next])+Vector3(0,0.07,0)),Color("85dce3"),2,true)
			prev = next
	if show_yields:
		for t in state.tiles.values():
			var output = R.map_yield(state,t.id)
			var p = screen(pos(t)+Vector3(0,0.10,0))
			if not Rect2(Vector2.ZERO,size).has_point(p): continue
			var i = 0
			for key in output:
				var at = p+Vector2((i%2)*25-25,floori(i/2.0)*15)
				draw_texture_rect(Art.resource_icon(key),Rect2(at,Vector2(12,12)),false)
				draw_string(font,at+Vector2(13,11),str(output[key]),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff0cb"))
				i += 1
	draw_rect(Rect2(8,size.y-30,minf(size.x-16,570),24),Color(0.02,0.06,0.09,0.85))
	draw_string(font,Vector2(15,size.y-13),progress if building else metrics,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("c2d8d5"))
