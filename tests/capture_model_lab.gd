extends SceneTree
## Run with a real rendering driver, not --headless. Outputs actual game views.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(2160,1720)
	root.content_scale_size = Vector2i(2160,1720)
	DisplayServer.window_set_size(Vector2i(2160,1720))
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.open_model_lab()
	var lab = app.model_lab
	lab.pages.current_tab = 2
	for frame in range(30): await process_frame
	await RenderingServer.frame_post_draw
	var target = ProjectSettings.globalize_path("res://builds/model-lab")
	DirAccess.make_dir_recursive_absolute(target)
	root.get_texture().get_image().save_png(target+"/Alien_Planet_3D_Comparison_v2.png")
	root.size = Vector2i(2160,1240)
	root.content_scale_size = Vector2i(2160,1240)
	DisplayServer.window_set_size(Vector2i(2160,1240))
	lab.pages.current_tab = 1
	lab.walk_button.pressed.emit()
	for frame in range(10): await process_frame
	# A deterministic pose shared by every outfit for a fair still comparison.
	for rig in lab.rigs:
		rig.set_process(false)
		rig.phase = PI * 0.5
		rig.pose(rig.phase)
	for frame in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(target+"/Alien_Planet_Walking_Lineup_v2.png")
	print("RENDERED COLLAGES: "+target)
	app.queue_free()
	await process_frame
	quit()
