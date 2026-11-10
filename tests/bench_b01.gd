extends SceneTree
## Run unchanged against baseline and candidate using the same saved B01 state.
const S = preload("res://scripts/civilization_session.gd")
const R = preload("res://scripts/game_rules.gd")
const World = preload("res://scripts/world_map.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var args = OS.get_cmdline_user_args()
	var source = args[0]
	var destination = args[1]
	var label = args[2]
	var s = JSON.parse_string(FileAccess.get_file_as_string(source))
	# Both builds receive identical inert death metadata expected by the old summary.
	s.xenos.deaths.red = 0
	var report = {"label":label,"fixture":"b01-shell-v1","seed":731,"viewport":[1920,1080],"renderer":"software OpenGL llvmpipe; same-host comparison only"}
	for recording in [false,true]:
		s.testing.enabled = recording
		var suffix = "recording" if recording else "plain"
		var started = Time.get_ticks_usec()
		for i in range(100): S.own_state(s)
		report["own_snapshot_100_us_"+suffix] = Time.get_ticks_usec()-started
		started = Time.get_ticks_usec()
		for i in range(100): S.projection(s)
		report["projection_100_us_"+suffix] = Time.get_ticks_usec()-started
		started = Time.get_ticks_usec()
		for i in range(100): S.command_for(s,"blue",{"type":"focusPerson","cohortId":"pop_a"})
		report["focus_command_100_us_"+suffix] = Time.get_ticks_usec()-started
	root.size = Vector2i(1920,1080)
	var world = World.new()
	root.add_child(world)
	world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	world.update_view(S.projection(s),"2,3","pop_a","none")
	while not world.built: await process_frame
	world.zoom = 47.0/13.8
	world.target = world.pos(s.tiles["3,3"])
	world.update_camera()
	for i in range(30): await process_frame
	var view = S.projection(s)
	var started = Time.get_ticks_usec()
	for i in range(100): world.update_view(view,"2,3","pop_a","none")
	report.view_update_100_us = Time.get_ticks_usec()-started
	var samples = []
	var clock = Time.get_ticks_usec()
	for i in range(120):
		await process_frame
		var now = Time.get_ticks_usec()
		samples.append((now-clock)/1000.0); clock = now
	samples.sort()
	report.frame_ms_median = samples[60]; report.frame_ms_p95 = samples[114]; report.frame_ms_max = samples.back()
	report.terrain_build_ms = world.build_ms
	report.memory_static_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	report.save_bytes = JSON.stringify(s).length()
	var out = FileAccess.open(destination,FileAccess.WRITE)
	out.store_string(JSON.stringify(report,"\t")); out.close()
	print(JSON.stringify(report))
	world.free()
	for i in range(3): await process_frame
	quit()
