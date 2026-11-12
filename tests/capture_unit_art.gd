extends "res://tests/capture_visual_pass.gd"

func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b11.tscn").instantiate()
	root.add_child(app)
	while not app.world.built: await process_frame
	var home = app.state.settlements.main.tileId
	var choices = app.E.R.neighbours(app.state,home).filter(func(key):
		return (app.state.tiles[key].baseTerrain != "water" and
			not app.state.cohorts.values().any(func(person): return app.E.R.person_tile(app.state,person) == key)))
	choices.sort_custom(func(a,b): return app.state.tiles[a].r > app.state.tiles[b].r)
	for i in range(2):
		var id = ["explorer","guard"][i]
		app.send({"type":"queueMove","unitId":id,"target":choices[i]})
	for i in range(4):
		if app.state.movementQueues.is_empty(): break
		app.send({"type":"endTurn"})
	while app.world.building or not app.world.tweens.is_empty(): await process_frame
	var folder = "res://reports/unit-art/"
	for id in ["pop_a","explorer","guard"]:
		app.choose_person(id,false)
		await still(folder+id+".png")
	app.free()
	for i in range(3): await process_frame
	quit()
