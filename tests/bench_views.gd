extends SceneTree
var results = {}
func _initialize() -> void: call_deferred("run")
func sample(count: int = 45) -> Dictionary:
	var samples = []
	var previous = Time.get_ticks_usec()
	for i in range(count):
		await process_frame
		var now = Time.get_ticks_usec()
		samples.append((now-previous)/1000.0)
		previous = now
	samples.sort()
	return {"median_ms":samples[samples.size()/2],"p95_ms":samples[floori(samples.size()*0.95)],"max_ms":samples.back()}
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for i in range(5): await process_frame
	var start = Time.get_ticks_usec()
	app.open_model_lab()
	results.open_call_ms = (Time.get_ticks_usec()-start)/1000.0
	if app.model_lab.get("built") != null:
		while not app.model_lab.built: await process_frame
	results.full_prepare_ms = (Time.get_ticks_usec()-start)/1000.0
	for page in [0,1,2]:
		app.model_lab.pages.current_tab = page
		app.model_lab.walk()
		for i in range(10): await process_frame
		results["lab_"+str(page)] = await sample()
	app.model_lab.close()
	start = Time.get_ticks_usec()
	app.open_model_lab()
	results.reopen_call_ms = (Time.get_ticks_usec()-start)/1000.0
	app.model_lab.close()
	if app.has_method("set_map_mode"):
		app.set_map_mode(1)
		while not app.world_view.built: await process_frame
		for i in range(10): await process_frame
		results.world_default = await sample()
		results.world_build_ms = app.world_view.build_ms
		results.default_draw_calls = app.world_view.viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
		results.default_visible_figures = app.world_view.actors.size()
		var rules = load("res://scripts/game_rules.gd")
		for i in range(20):
			rules.new_person(app.state,"main")
			var id = "pop_%03d" % (app.state.nextCohortNumber-1)
			app.state.cohorts[id].equipment = ["work_suit"]
			app.state.cohorts[id].state = {"kind":"mobile","tileId":"%d,%d" % [2+i%7,2+i/7],"movementRemaining":1}
		app.world_view.update_view(app.state,"3,3","","none")
		app.world_view.focus_tile("5,4")
		for actor in app.world_view.actors.values(): actor.walk()
		for i in range(10): await process_frame
		results.world_stress = await sample()
		results.stress_draw_calls = app.world_view.viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
		results.stress_visible_figures = app.world_view.actors.size()
		for actor in app.world_view.actors.values(): actor.stop()
		for i in range(10): await process_frame
		results.world_stress_stopped = await sample()
		app.world_view.set_animation(false)
		for i in range(10): await process_frame
		results.world_all_motion_off = await sample()
	print("BENCHMARK ",JSON.stringify(results))
	quit()
