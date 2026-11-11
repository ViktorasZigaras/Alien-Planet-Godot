extends SceneTree
const S = preload("res://scripts/tactical_session.gd")
const X = S.X
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
	check(S.validate(s) == "", "Initial tactics state validates")
	var home = s.settlements.main.tileId
	var animal = s.xenos.units.values().filter(func(unit): return unit.kind == "predator")[0]
	var attack = {"type":"attackXeno","cohortId":"guard","targetId":animal.id,"mode":"ranged"}
	check(not S.command(s,attack).ok, "Hidden animal is not a target")
	for tile in s.tiles.values():
		if S.R.distance(tile,s.tiles[home]) == 2 and tile.baseTerrain != "water":
			animal.tile = tile.id
			break
	X.sync_tiles(s)
	S.K.observe(s)
	var forecast = S.preview(s,"guard",animal.id,"ranged")
	var before = animal.hp
	var fired = S.command(s,attack)
	check(fired.ok and forecast == "Fire deals %d damage" % (before-fired.state.xenos.units[animal.id].hp), "Ranged preview agrees with resolution")
	check(not S.command(fired.state,attack).ok, "Second attack has no movement or action allowance")
	var flame = s.duplicate(true)
	E.change(flame,"industry",2)
	var equipped = S.command(flame,{"type":"equipSoldier","person":"guard","weapon":"flamer"})
	check(equipped.ok and equipped.state.resources.industry == flame.resources.industry-2, "Flamer uses local Industry")
	equipped.state.cohorts.guard.state.movementRemaining = 1.0
	check(not S.command(equipped.state,attack).ok, "Flamer cannot reach a two-hex rifle target")
	s.xenos.humanHealth.guard = 40
	s.shortages.food = 2
	s.shortages.energy = 1
	var weakened = X.C.effective(X.human_power(s,s.cohorts.guard),40)
	s.shortages = {"food":0,"energy":0}
	check(X.C.effective(X.human_power(s,s.cohorts.guard),40)>weakened and X.hp(s.xenos,"guard")==40, "Supply recovery improves power without healing wounds")
	var mission = S.command(s,{"type":"expedition","targetId":animal.id})
	check(mission.ok, "Observed expedition can be authorized")
	var planned = S.automate(mission.state)
	check(planned.cohorts.guard.state.tileId == home and not planned.movementQueues.has("guard"), "Only ready Soldier stays as garrison")
	var assembled = S.initial()
	var expeditionary = assembled.cohorts.guard.duplicate(true)
	expeditionary.id = "expeditionary"
	assembled.cohorts.expeditionary = expeditionary
	var larva = assembled.xenos.units.values().filter(func(unit): return unit.kind == "larva")[0]
	for tile in assembled.tiles.values():
		if S.R.distance(tile,assembled.tiles[home]) == 3 and tile.baseTerrain != "water" and not S.R.path(assembled,home,tile.id,"").is_empty():
			larva.tile = tile.id
			assembled.cohorts.explorer.state.tileId = tile.id
			break
	S.K.observe(assembled)
	assembled.tactics.target = larva.id
	var launched = S.automate(assembled)
	check(launched.movementQueues.has("expeditionary") or launched.cohorts.expeditionary.state.tileId != home, "A sufficient expedition advances on an observed target")
	check(not launched.movementQueues.has("guard") and launched.cohorts.guard.state.tileId == home, "Expedition leaves the station defended")
	var outbound = launched.movementQueues.get("expeditionary",[]).duplicate()
	launched.xenos.humanHealth.expeditionary = 30
	var withdrawn = S.automate(launched)
	check(withdrawn.movementQueues.get("expeditionary",[]) != outbound or withdrawn.cohorts.expeditionary.state.tileId == home, "Wounded expedition abandons its advance")
	var emergency = S.initial()
	E.change(emergency,"energy",-int(emergency.resources.energy))
	var power_plan = S.automate(emergency)
	check(power_plan.cohorts.values().any(func(person): return person.state.job == "generate"), "Energy emergency finds a Food-safe generator assignment")
	emergency.planning.enabled = true
	var recovered = S.command(emergency,{"type":"endTurn"}).state
	check(recovered.resources.energy > 0 and recovered.resources.food >= 0, "Automatic economy retains emergency generation without a Food deficit")
	var field = S.initial()
	var site = S.R.neighbours(field,home).filter(func(key): return field.tiles[key].baseTerrain != "water")[0]
	field.cohorts.explorer.state.tileId = site
	S.K.observe(field)
	var retreat = S.command(field,{"type":"retreat","person":"explorer"})
	check(retreat.ok and (retreat.state.cohorts.explorer.state.tileId == home or retreat.state.movementQueues.explorer.back() == home), "Civilian retreats via a land route")
	var defence = S.initial()
	var predator = defence.xenos.units.values().filter(func(unit): return unit.kind == "predator")[0]
	predator.tile = site
	X.sync_tiles(defence)
	S.K.observe(defence)
	defence.tactics.auto = false
	var result = S.command(defence,{"type":"endTurn"}).state
	check(result.xenos.lastEvents.any(func(event): return event.type == "attack" and event.get("victim") == "guard"), "Garrison protects civilians at the station")
	check(X.hp(result.xenos,"pop_a") == 100 and X.hp(result.xenos,"pop_b") == 100, "Sheltered civilians retain health")
	check(S.validate(JSON.parse_string(JSON.stringify(result))) == "", "Combat and wounds survive JSON save")
	var ui = load("res://b08.tscn").instantiate()
	root.add_child(ui)
	for i in range(10): await process_frame
	check(ui.tactical_mode and ui.combat_box.get_child_count() >= 2, "Normal scene provides combat panel")
	ui.free()
	print(JSON.stringify({"suite":"B08","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
