extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func run():
	var args = OS.get_cmdline_user_args()
	var path = args[0] if not args.is_empty() else "res://builds/combat-0904/simulation_report.json"
	var report = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not report is Dictionary or report.droppedEvents != 0:push_error("Missing or truncated report");quit(1);return
	var s = S.attach(report.initial.blue)
	s.civilizations.red = report.initial.red.duplicate(true)
	s.xenos = report.initial.xenos.duplicate(true)
	S.X.sync_tiles(s)
	for event in report.events:
		var result = S.command_for(s,event.player,event.command,event.policyRule)
		if result.ok != event.accepted:push_error("Replay acceptance mismatch at "+str(event.sequence));quit(1);return
		s = result.state
	if JSON.parse_string(JSON.stringify(S.summary(s))) != JSON.parse_string(JSON.stringify(report.final)):
		push_error("Final replay summary differs");quit(1);return
	if S.validate(s) != "":push_error(S.validate(s));quit(1);return
	print("REPLAY VERIFIED: ",report.events.size()," recorded actions, ",int(s.turn)-1," rounds; deaths ",JSON.stringify(s.xenos.deaths))
	quit()
