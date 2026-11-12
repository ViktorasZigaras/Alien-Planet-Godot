extends "res://tests/test_b12.gd"

func still(path: String, ui) -> void:
	while ui.world.building or not ui.world.tweens.is_empty(): await process_frame
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func run() -> void:
	root.size = Vector2i(1920,1080)
	var ui = load("res://b12.tscn").instantiate()
	root.add_child(ui)
	while not ui.world.built: await process_frame
	ui.state = approach(ui.state)
	ui.choose_person("explorer")
	ui.show_mode("Orders")
	ui.refresh()
	await still("res://reports/b12/Compact.png",ui)
	ui.free()
	for i in range(3): await process_frame
	ui = load("res://b13.tscn").instantiate()
	root.add_child(ui)
	while not ui.world.built: await process_frame
	var site = ui.state.exchange.sites.keys().filter(func(key): return key != ui.state.expansion.contact)[0]
	ui.state = advance_to(ui.state,"explorer",site)
	ui.choose_person("explorer")
	ui.show_mode("Orders")
	ui.refresh()
	await still("res://reports/b13/Relay.png",ui)
	ui.state = D.command(ui.state,{"type":"compactOffer","term":"passage"}).state
	ui.state = advance_to(ui.state,"explorer",ui.state.expansion.contact)
	ui.choose_person("explorer")
	ui.refresh()
	await still("res://reports/b13/CompactExchange.png",ui)
	ui.free()
	for i in range(3): await process_frame
	quit()
