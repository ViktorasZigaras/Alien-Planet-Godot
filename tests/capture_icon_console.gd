extends "res://tests/capture_visual_pass.gd"

func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b09.tscn").instantiate()
	root.add_child(app)
	while not app.world.built: await process_frame
	var folder = "res://reports/icon-console"
	await still(folder+"/Opening.png")
	app.choose_person("explorer",false)
	app.select_tile("1,3")
	app.world.move_preview.emit("1,3")
	await still(folder+"/Explorer.png")
	app.world.cancel_move_preview()
	app.choose_person("pop_a",false)
	app.show_mode("Colony")
	for key in app.state.knowledge.visible:
		if app.E.reason(app.state,{"type":"enqueue","recipe":"farm","tile":key}) == "":
			app.select_tile(key)
			app.send({"type":"enqueue","recipe":"farm","tile":key})
			break
	await still(folder+"/Colony.png")
	app.free()
	for i in range(3): await process_frame
	quit()
