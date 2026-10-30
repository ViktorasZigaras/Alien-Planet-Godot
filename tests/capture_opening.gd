extends SceneTree
## Actual default opening state. No fixtures, added buildings, invented units or imagegen.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for i in range(12): await process_frame
	var initial = JSON.stringify(app.state)
	DirAccess.make_dir_recursive_absolute("res://builds/opening-08")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/opening-08/Alien_Planet_Opening_Sprite_A.png")
	app.set_map_mode(1)
	while not app.world_view.built: await process_frame
	for i in range(70): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/opening-08/Alien_Planet_Opening_3D_B.png")
	if JSON.stringify(app.state) != initial: push_error("Capture changed game state"); quit(1); return
	print("OPENING CAPTURES · default state preserved · A and B")
	quit()
