extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func capture(path: String):
	for i in range(10):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func run():
	root.size=Vector2i(1440,900)
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	for i in range(12):await process_frame
	DirAccess.make_dir_recursive_absolute("res://builds/xenos-0903")
	var before=JSON.stringify(app.state)
	app.selected_tile=S.X.NEST_TILE
	app.pixel_view.focus_tile(S.X.NEST_TILE)
	app.render()
	await capture("res://builds/xenos-0903/Alien_Planet_Xeno_Nest_Sprites_0903.png")
	app.set_map_mode(1)
	while not app.world_view.built:await process_frame
	app.world_view.focus_tile(S.X.NEST_TILE)
	await capture("res://builds/xenos-0903/Alien_Planet_Xeno_Nest_3D_0903.png")
	if JSON.stringify(app.state)!=before:push_error("Opening capture changed state");quit(1);return
	# This labelled progression fixture uses twelve ordinary world turns.
	for i in range(12):app.state=S.command(app.state,{"type":"endTurn"}).state
	app.render()
	app.world_view.focus_tile(S.X.NEST_TILE)
	await capture("res://builds/xenos-0903/Alien_Planet_Xenomass_After_12_Turns_0903.png")
	print("0.903 native captures; default scene preserved; growth fixture uses 12 ordinary turns")
	quit()
