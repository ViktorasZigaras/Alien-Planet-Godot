extends SceneTree
## Reproducible native model-to-sprite bake; no runtime generation/download step.
const Catalogue = preload("res://scripts/asset_catalogue.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var viewport = SubViewport.new()
	viewport.size = Vector2i(80,80)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	root.add_child(viewport)
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0,0,0,0)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("d0d9dc")
	env.environment.ambient_light_energy = 0.8
	viewport.add_child(env)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50,-35,0)
	light.light_energy = 0.8
	light.light_color = Color("ffe9c8")
	viewport.add_child(light)
	var camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	viewport.add_child(camera)
	var entries = Catalogue.entries()
	var atlas = Image.create(800,ceili(entries.size()/10.0)*80,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var regions = {}
	for i in range(entries.size()):
		var e = entries[i]
		var person = e.kind == "person"
		camera.size = 2.55 if person else 2.25
		camera.position = Vector3(2,2.8,4) if person else Vector3(2.7,4.2,3.7)
		camera.look_at_from_position(camera.position,Vector3(0,0.95 if person else 0.27,0),Vector3.UP)
		var model = Catalogue.create(e)
		viewport.add_child(model)
		model.set_process(false)
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await process_frame
		await RenderingServer.frame_post_draw
		var frame = viewport.get_texture().get_image()
		frame.convert(Image.FORMAT_RGBA8)
		var at = Vector2i(i%10*80,floori(i/10.0)*80)
		atlas.blit_rect(frame,Rect2i(0,0,80,80),at)
		regions[e.key] = [at.x,at.y,80,80]
		model.free()
		if i%10 == 0: print("BAKE ",i," / ",entries.size())
	DirAccess.make_dir_recursive_absolute("res://assets/world")
	atlas.save_png("res://assets/world/pixel_world.png")
	var file = FileAccess.open("res://data/world_sprites.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(regions,"  "))
	file.close()
	print("BAKED ",entries.size()," sprites")
	quit()
