extends SceneTree
## Actual default B01 fixture at 1080p; no supplied art or staged assets.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b01.tscn").instantiate()
	root.add_child(app)
	while not app.world_view.built: await process_frame
	for i in range(30): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/b01/B01_Opening.png")
	var original = JSON.stringify(app.state)
	var samples = []
	var clock = Time.get_ticks_usec()
	for i in range(120):
		await process_frame
		var now = Time.get_ticks_usec()
		samples.append((now-clock)/1000.0)
		clock = now
	samples.sort()
	var metrics = {"build":"0.911-b01-review","viewport":[1920,1080],"samples":120,"frame_ms_median":samples[60],"frame_ms_p95":samples[114],"frame_ms_max":samples.back(),"terrain_build_ms":app.world_view.build_ms,"static_memory_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"draw_calls":app.world_view.viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),"unchanged_state":JSON.stringify(app.state)==original,"note":"Xvfb software OpenGL on this host; not representative of the user's GPU"}
	var out = FileAccess.open("res://reports/b01/render_metrics.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(metrics,"\t")); out.close()
	print(JSON.stringify(metrics))
	app.free()
	for i in range(3): await process_frame
	quit()
