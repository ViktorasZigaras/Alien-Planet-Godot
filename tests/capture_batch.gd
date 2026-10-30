extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute("res://builds/batch-06")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/batch-06/landing.png")
	app.map_view.fit_map()
	app.overlay = "none"
	app.update_map()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/batch-06/biomes.png")
	app.tech_dialog.popup_centered(Vector2i(1060,730))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/batch-06/technology.png")
	quit()
