extends SceneTree
const R = preload("res://scripts/game_rules.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	app.set_map_mode(1)
	while not app.world_view.built: await process_frame
	print("WORLD BUILD MS ",app.world_view.build_ms)
	for i in range(70): await process_frame
	DirAccess.make_dir_recursive_absolute("res://builds/world-07")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/world-07/landing3d.png")
	app.map_view.fit_map()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/world-07/world3d.png")
	app.set_map_mode(0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/world-07/landing2d.png")
	# Isolated visual fixture: show every layer together without changing new-game data.
	app.state.completed = R.nodes().keys()
	for kind in ["production","agriculture"]:
		var id = R.district_key("main",kind)
		app.state.districts[id] = {"id":id,"type":kind,"tileId":"3,3" if kind == "production" else "3,2","settlementId":"main"}
	for type in ["workshop","generator","greenhouse","clinic"]:
		var id = R.building_key("main",type)
		app.state.buildings[id] = {"id":id,"type":type,"settlementId":"main","tier":1,"districtId":R.district_key("main",R.content().buildings[type].district)}
	app.state.improvements = {"1,3":{"farm":true,"road":true},"2,3":{"road":true},"3,3":{"road":true},"2,2":{"mine":true}}
	app.state.cohorts.pop_c.qualification = "Engineer"
	app.state.cohorts.pop_c.equipment = ["work_suit"]
	app.state.cohorts.pop_c.state.job = "building:workshop_main#0"
	app.select_person("pop_c")
	app.selected_tile = "3,3"
	app.set_map_mode(1)
	app.world_view.zoom = 6
	app.world_view.update_camera()
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/world-07/layers3d.png")
	app.set_map_mode(0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/world-07/layers2d.png")
	print("VIEWPORT ",app.world_view.viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)," draw calls")
	quit()
