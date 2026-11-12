extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func still(path: String) -> void:
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func sample(world = null) -> Dictionary:
	var samples = []
	var previous = Time.get_ticks_usec()
	var origin = world.target if world != null else Vector3.ZERO
	for i in range(90):
		if world != null:
			world.target = origin + Vector3(sin(i/12.0)*1.4,0,cos(i/16.0)*0.6)
			world.update_camera()
		await RenderingServer.frame_post_draw
		var now = Time.get_ticks_usec()
		samples.append((now-previous)/1000.0)
		previous = now
	if world != null:
		world.target = origin
		world.update_camera()
	samples.sort()
	return {"frames":samples.size(),"median_ms":samples[45],"p95_ms":samples[85]}

func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b09.tscn").instantiate()
	root.add_child(app)
	while not app.world.built: await process_frame
	var folder = "res://reports/b09"
	DirAccess.make_dir_recursive_absolute(folder)
	await still(folder+"/Opening.png")
	app.show_mode("Colony")
	await still(folder+"/Colony.png")
	app.show_mode("Research")
	await still(folder+"/Research.png")
	app.show_mode("Map")
	var opening = await sample()
	var initial_build = app.world.build_ms
	var original = app.state
	app.state = original.duplicate(true)
	var sites = app.state.knowledge.visible.keys().filter(func(key): return app.state.tiles[key].baseTerrain != "water" and key != app.state.settlements.main.tileId)
	for i in range(4):
		var person = app.state.cohorts.explorer.duplicate(true)
		person.id = "review_"+str(i)
		person.name = "Field crew "+str(i+1)
		person.state.tileId = sites[i]
		app.state.cohorts[person.id] = person
	var wildlife = app.state.xenos.units.values()
	for i in range(mini(3,wildlife.size())):
		wildlife[i].tile = sites[i+4]
		wildlife[i].previousTile = sites[i+4]
	app.Tactical.X.sync_tiles(app.state)
	app.Exploration.K.observe(app.state)
	app.remember_species()
	app.refresh()
	app.show_mode("Colony")
	for key in sites:
		if app.E.reason(app.state,{"type":"enqueue","recipe":"farm","tile":key}) == "":
			app.select_tile(key)
			app.send({"type":"enqueue","recipe":"farm","tile":key})
			break
	app.cycle_overlay()
	await still(folder+"/BusyColony.png")
	var busy = await sample(app.world)
	app.show_mode("Alienopedia")
	app.archive_page = "Wildlife"
	app.refresh_selection()
	await still(folder+"/Alienopedia.png")
	app.state = original
	var stats = FileAccess.open(folder+"/render_metrics.json",FileAccess.WRITE)
	stats.store_string(JSON.stringify({"resolution":[root.size.x,root.size.y],"opening":opening,"staged_busy_colony":busy,"terrain_build_ms":initial_build}, "\t"))
	stats.close()
	app.free()
	for i in range(3): await process_frame
	quit()
