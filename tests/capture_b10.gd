extends "res://tests/test_b10.gd"

func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b10.tscn").instantiate()
	root.add_child(app)
	while not app.world.built: await process_frame
	var s = X.command(app.state,{"type":"deployBuilder","person":"pop_a"}).state
	s.tactics.auto = false
	var site = candidate(s)
	s = travel(s,site)
	var found = X.command(s,{"type":"foundOutpost","person":"pop_a"})
	if not found.ok:
		push_error(found.message)
		quit(1)
		return
	s = found.state
	for key in X.R.neighbours(s,site):
		var order = X.command(s,{"type":"workOutpost","person":"pop_a","tile":key})
		if order.ok:
			s = order.state
			break
	app.state = s
	app.choose_person("pop_a")
	app.show_mode("Orders")
	app.select_tile(s.expansion.outposts[site].work)
	app.world.set_animation(false)
	app.refresh()
	for i in range(25): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/b10/Outpost.png")
	app.free()
	for i in range(3): await process_frame
	quit()
