extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func capture(path: String):
	for i in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func run():
	root.size=Vector2i(1440,900)
	var app=load("res://main.tscn").instantiate()
	root.add_child(app)
	for i in range(12):await process_frame
	var initial=JSON.stringify(app.state)
	DirAccess.make_dir_recursive_absolute("res://builds/civilizations-0902")
	await capture("res://builds/civilizations-0902/blue_claims_sprite.png")
	app.pixel_view.focus_tile(S.RED_TOWN)
	app.selected_tile=S.RED_TOWN
	app.render()
	await capture("res://builds/civilizations-0902/red_claims_sprite.png")
	app.set_map_mode(1)
	while not app.world_view.built:await process_frame
	app.world_view.focus_tile(S.RED_TOWN)
	await capture("res://builds/civilizations-0902/red_claims_3d.png")
	if JSON.stringify(app.state)!=initial:push_error("Capture changed initial state");quit(1);return
	# Labelled development fixture: 65 normal world turns, no invented tech/buildings.
	for i in range(65):app.state=S.command(app.state,{"type":"endTurn"}).state
	app.update_map()
	app.render()
	app.world_view.focus_tile(S.RED_TOWN)
	await capture("res://builds/civilizations-0902/red_after_65_turns_3d.png")
	app.tabs.current_tab=3
	app.render_testing()
	await capture("res://builds/civilizations-0902/testing_summary_after_65_turns.png")
	print("0.902 native captures; opening state preserved; developed fixture uses 65 rule turns")
	quit()
