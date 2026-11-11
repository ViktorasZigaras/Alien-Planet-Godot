extends SceneTree
const S = preload("res://scripts/exploration_session.gd")
const R = S.K.R
const Session = preload("res://scripts/civilization_session.gd")
var failures = []
var checks = 0
func _initialize() -> void:
	call_deferred("run")
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		push_error(description)
func run() -> void:
	var s = S.initial()
	check(S.validate(s) == "", "Initial save validates")
	var view = S.K.view(s,Session.projection(s))
	var site = "1,3"
	check(view.tiles.size() == s.tiles.size() and view.tiles[site].bonus == "", "Macro geography visible, unidentified bonus hidden")
	var food = R.tile_yield(s,site).get("food",0)
	var move = S.command(s,{"type":"queueMove","unitId":"explorer","target":site})
	check(move.ok, "Explorer uses travel queue")
	s = move.state
	for i in range(6):
		if not s.movementQueues.has("explorer"): break
		s = S.command(s,{"type":"endTurn"}).state
	check(s.cohorts.explorer.state.tileId == site, "Explorer reaches site")
	var identified = S.command(s,{"type":"identify"})
	check(identified.ok, "Identify site in person")
	s = identified.state
	check(R.tile_yield(s,site).get("food",0) == food+2, "Identification enables bonus")
	s = S.command(s,{"type":"endTurn"}).state
	var assigned = S.command(s,{"type":"assign","person":"pop_a","job":"tile:"+site})
	check(assigned.ok and not S.command(assigned.state,{"type":"investigate"}).ok, "Occupied site blocks investigation")
	var invest = S.command(s,{"type":"investigate"})
	check(invest.ok, "Stationary site can be investigated")
	s = invest.state
	var before = s.resources.science
	s = S.command(s,{"type":"endTurn"}).state
	check(s.resources.science == before+2 and not S.command(s,{"type":"investigate"}).ok, "Reward is paid once")
	s = S.command(s,{"type":"fieldwork"}).state
	check(not S.command(s,{"type":"assign","person":"pop_a","job":"tile:"+site}).ok, "Fieldwork blocks settlement assignment")
	s = S.command(s,{"type":"endTurn"}).state
	check(s.lastLedger.gross.food == 2 and s.lastLedger.gross.science == 1 and s.lastLedger.gross.culture == 1, "Fieldwork pays special output and Explorer bonus")
	check(S.validate(JSON.parse_string(JSON.stringify(s))) == "", "Knowledge and reward history survive JSON save")
	for key in s.tiles:
		if s.knowledge.visible.has(key): continue
		var prior = S.K.view(s,Session.projection(s)).tiles[key]
		s.tiles[key].pollution = 9
		s.improvements[key] = {"farm":true}
		var hidden = S.K.view(s,Session.projection(s))
		check(hidden.tiles[key].pollution == prior.pollution and not hidden.improvements.has(key), "Unseen changes stay hidden")
		s.knowledge.memory[key] = {"tile":prior,"turn":1,"district":{},"buildings":{},"improvements":{}}
		check(S.K.view(s,Session.projection(s)).tiles[key].pollution == prior.pollution, "Remembered tile uses snapshot")
		break
	var ui = load("res://b06.tscn").instantiate()
	root.add_child(ui)
	for i in range(10): await process_frame
	check(ui.exploration_mode and ui.state.cohorts.has("explorer"), "Normal scene launches")
	ui.free()
	print(JSON.stringify({"suite":"B06","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
