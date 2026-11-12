extends SceneTree
const FieldAssets = preload("res://scripts/field_assets.gd")
const Assets = preload("res://scripts/world_assets.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/ui")
	for recipe in ["farm","district","greenhouse"]:
		var view = SubViewport.new()
		view.size = Vector2i(112,112)
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var environment = WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("#182a30")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color("#bbccd1")
		environment.environment.ambient_light_energy = 0.68
		view.add_child(environment)
		var sun = DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-45,-25,0)
		sun.light_color = Color("#ffe9c7")
		view.add_child(sun)
		var model: Node3D
		match recipe:
			"farm": model = FieldAssets.farm()
			"district": model = Assets.district("agriculture")
			"greenhouse": model = Assets.building("greenhouse",1)
		view.add_child(model)
		var camera = Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 1.66
		view.add_child(camera)
		camera.position = Vector3(2.5,3.0,3.5)
		camera.look_at(Vector3(0,0.16,0))
		for i in range(8): await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://assets/ui/"+"build_"+recipe+".png")
		view.free()
	quit()
