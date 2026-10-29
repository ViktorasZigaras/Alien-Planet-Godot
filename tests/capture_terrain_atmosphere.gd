extends SceneTree
## Actual OpenGL captures; time is fixed for reproducible stills and a short loop.
func _initialize() -> void:
	call_deferred("run")

func settle(frames: int = 8) -> void:
	for frame in range(frames): await process_frame
	await RenderingServer.frame_post_draw

func run() -> void:
	root.size = Vector2i(1600,1160)
	root.content_scale_size = Vector2i(1600,1160)
	DisplayServer.window_set_size(root.size)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.open_model_lab()
	var lab = app.model_lab
	lab.pages.current_tab = 0
	await settle(20)
	for tile in lab.terrains:
		tile.atmosphere.animated = false
		tile.atmosphere.elapsed = 2.0
		tile.atmosphere.apply_time()
	await settle()
	var target = ProjectSettings.globalize_path("res://builds/terrain-atmosphere")
	DirAccess.make_dir_recursive_absolute(target)
	root.get_texture().get_image().save_png(target+"/Alien_Planet_Living_Terrain.png")
	lab.pages.current_tab = 3
	await settle()
	root.get_texture().get_image().save_png(target+"/Alien_Planet_Terrain_Landscape.png")
	# The animation loops the shader/spore positions; no gameplay time advances.
	var frame_path = target+"/frames"
	DirAccess.make_dir_recursive_absolute(frame_path)
	for frame in range(32):
		for tile in lab.terrains:
			tile.atmosphere.elapsed = frame*0.16
			tile.atmosphere.apply_time()
		await settle(1)
		root.get_texture().get_image().save_png(frame_path+"/%03d.png" % frame)
	print("TERRAIN RENDERS: "+target)
	app.queue_free()
	await process_frame
	quit()
