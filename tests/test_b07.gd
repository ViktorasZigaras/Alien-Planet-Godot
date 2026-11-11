extends SceneTree
const S = preload("res://scripts/ecology_session.gd")
const E = S.E
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
	check(S.validate(s) == "", "Initial ecology state validates")
	check(not s.xenos.mass.is_empty() and not s.xenos.units.is_empty(), "Wildlife begins with xenomass")
	check(E.resolve(s).ledger.ecology.industrial == 0, "Idle industry contributes no pollution")
	var industrial = S.command(s,{"type":"assign","person":"pop_a","job":"manufacture"}).state
	var ledger = E.resolve(industrial).ledger
	check(ledger.gross.industry > 0 and ledger.ecology.industrial == ledger.gross.industry, "Real processing drives waste")
	s.ecology.tank = 4
	var treated = S.command(s,{"type":"assign","person":"pop_a","job":"waste"}).state
	treated = S.command(treated,{"type":"endTurn"}).state
	check(treated.ecology.last.treated == 3 and treated.ecology.tank < 4, "Staffed waste service treats contained waste")
	check(treated.xenos.tick == 1 and treated.xenos.lastEvents.any(func(event): return event.type == "harvest" or event.type == "spread"), "Wildlife runs on turn advance")
	industrial.ecology.tank = 4
	var spilled = S.command(industrial,{"type":"endTurn"}).state
	check(spilled.ecology.last.spilled > 0 and spilled.tiles["2,3"].pollution > 0, "Full tank spills onto land")
	spilled.ecology.health = 50
	check(not S.command(spilled,{"type":"boostGrowth","amount":1}).ok, "Poor health blocks growth spending")
	var deployed = S.command(spilled,{"type":"deployBuilder","person":"pop_b"})
	check(deployed.ok, "Deploy reusable kit")
	var clean = S.command(deployed.state,{"type":"cleanSpill","person":"pop_b","tile":"2,3"})
	check(clean.ok, "Stationary equipped builder can clean spills")
	if clean.ok:
		var first = S.command(clean.state,{"type":"endTurn"}).state
		check(first.ecology.terrainWork.pop_b.remaining == 1, "Cleanup takes time")
		var second = S.command(first,{"type":"endTurn"}).state
		check(not second.ecology.terrainWork.has("pop_b") and second.tiles["2,3"].pollution < first.tiles["2,3"].pollution, "Cleanup removes spilled pollution")
	var field = S.initial()
	var key = "1,3"
	field.tiles[key].obstacle = "stones"
	check(not S.command(field,{"type":"enqueue","tile":key,"recipe":"district"}).ok, "Obstruction blocks construction")
	field = S.command(field,{"type":"deployBuilder","person":"pop_b"}).state
	field.cohorts.pop_b.state.tileId = key
	var clearing = S.command(field,{"type":"clearTerrain","person":"pop_b","tile":key})
	check(clearing.ok, "Builder can clear a local obstruction")
	for i in range(2): clearing.state = S.command(clearing.state,{"type":"endTurn"}).state
	check(clearing.state.tiles[key].obstacle == "", "Completed clearing removes obstruction")
	var repellent = S.command(s,{"type":"repellent","tile":"2,3"})
	check(repellent.ok and repellent.state.resources.energy == s.resources.energy-2, "Repellent costs energy")
	var roaming = S.initial()
	var predator = roaming.xenos.units.values().filter(func(unit): return unit.kind == "predator")[0]
	var predator_tile = predator.tile
	roaming.cohorts.explorer.state.tileId = predator_tile
	S.K.observe(roaming)
	var deterrent = S.command(roaming,{"type":"repellent","tile":predator_tile})
	check(deterrent.ok, "Repellent can be placed on visible wildlife ground")
	var dispersed = S.command(deterrent.state,{"type":"endTurn"}).state
	check(dispersed.xenos.units[predator.id].tile != predator_tile, "Roaming predator leaves repellent when a clear step exists")
	check(not S.command(repellent.state,{"type":"repellent","tile":"2,3"}).ok, "Active repellent cannot stack")
	for i in range(3): repellent.state = S.command(repellent.state,{"type":"endTurn"}).state
	check(not repellent.state.ecology.repellents.has("2,3"), "Repellent expires after three turns")
	check(S.validate(JSON.parse_string(JSON.stringify(repellent.state))) == "", "Changed environment survives JSON save")
	var medic = S.initial()
	medic.ecology.health = 50
	medic.cohorts.pop_a.qualification = "Medic"
	medic = S.command(medic,{"type":"assign","person":"pop_a","job":"medical"}).state
	check(E.resolve(medic).state.ecology.health == 58, "Staffed Medic improves settlement health")
	var ui = load("res://b07.tscn").instantiate()
	root.add_child(ui)
	for i in range(10): await process_frame
	check(ui.ecology_mode and ui.state.has("ecology"), "B07 normal scene launches")
	ui.free()
	print(JSON.stringify({"suite":"B07","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
