extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
func _initialize(): call_deferred("run")
func run():
	var s = S.start_recording(S.initial_state())
	DirAccess.make_dir_recursive_absolute("res://builds/combat-0904")
	var milestones = []
	var burned = false
	for i in range(200):
		s = S.command(s,{"type":"endTurn"}).state
		var error = S.validate(s)
		if error != "": printerr("INVALID ROUND ",i+1,": ",error); quit(1); return
		var red = s.civilizations.red
		var army = red.cohorts.values().filter(func(c):return c.qualification == "Soldier")
		if (i+1)%10 == 0:
			var item = {"round":i+1,"redPopulation":red.cohorts.size(),"soldiers":army.size(),"deployed":army.filter(func(c):return c.state.kind == "mobile").size(),"resources":red.resources.duplicate(),"ecology":S.X.summary(s.xenos)}
			milestones.append(item); print(JSON.stringify(item))
		if i == 59:
			FileAccess.open("res://builds/combat-0904/turn_60.json",FileAccess.WRITE).store_string(JSON.stringify(s))
		burned = s.xenos.nests.values().all(func(n):return n.burned)
		if burned: print("NEST DISABLED at round ",i+1); break
	s = S.finish_recording(s,"nest_disabled" if burned else "turn_limit","One attempt, maximum 200 rounds; fixed seed, ordinary controller actions.")
	var report = S.report(s)
	report.milestones = milestones; report.attempts = 1; report.maximumRounds = 200
	FileAccess.open("res://builds/combat-0904/simulation_report.json",FileAccess.WRITE).store_string(JSON.stringify(report))
	FileAccess.open("res://builds/combat-0904/final_state.json",FileAccess.WRITE).store_string(JSON.stringify(s))
	print("RESULT ",JSON.stringify(s.testing.outcome)," events=",s.testing.events.size())
	quit()
