extends SceneTree
const Assets = preload("res://scripts/world_assets.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/ui")
	for role in ["civilian","explorer","soldier"]:
		var view = SubViewport.new()
		view.size = Vector2i(112,132)
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var environment = WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("#233138")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color("#bbccd1")
		environment.environment.ambient_light_energy = 0.68
		view.add_child(environment)
		var sun = DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-45,-25,0)
		sun.light_color = Color("#ffe9c7")
		view.add_child(sun)
		var person = Assets.person({"qualification":"Worker" if role == "civilian" else role.capitalize(),"equipment":["small_arms"] if role == "soldier" else []})
		view.add_child(person)
		var camera = Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 1.55
		view.add_child(camera)
		camera.position = Vector3(1.2,1.5,3.8)
		camera.look_at(Vector3(0,1.22,0))
		for i in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://assets/ui/"+role+".png")
		view.free()
	quit()
