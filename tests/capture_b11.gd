extends "res://tests/capture_visual_pass.gd"

func run() -> void:
	root.size = Vector2i(1920,1080)
	var scene = load("res://b11.tscn")
	var metrics = []
	for settings in [{"seed":731,"width":16,"height":11},{"seed":984,"width":19,"height":13},{"seed":4102,"width":30,"height":22}]:
		var app = scene.instantiate()
		app.survey_settings = settings
		root.add_child(app)
		while not app.world.built: await process_frame
		var folder = "res://reports/b11/"
		await still(folder+"Seed"+str(settings.seed)+".png")
		if settings.seed == 731:
			app.show_mode("Orders")
			await still(folder+"WorldSurvey.png")
			app.show_mode("Map")
		metrics.append({"settings":settings,"terrain_build_ms":app.world.build_ms,"pan":await sample(app.world)})
		app.free()
		for i in range(3): await process_frame
	var file = FileAccess.open("res://reports/b11/render_metrics.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(metrics,"\t"))
	file.close()
	quit()
