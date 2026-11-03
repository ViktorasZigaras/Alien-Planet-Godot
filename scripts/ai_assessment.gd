class_name AIAssessment
extends RefCounted
const R = preload("res://scripts/game_rules.gd")
static func people(p: Dictionary) -> Array:
	var out = p.cohorts.values()
	out.sort_custom(func(a,b): return a.id < b.id)
	return out
static func forecast(p: Dictionary,horizon: int = 5) -> Dictionary:
	var copy = p.duplicate(false)
	# Forecast own economy and already queued projects, not enemy or future policy.
	copy.erase("civilizations"); copy.erase("testing"); copy.erase("ai")
	copy = copy.duplicate(true)
	var minimum = copy.resources.duplicate()
	for i in range(horizon):
		R.end_turn(copy)
		for k in R.RESOURCES: minimum[k] = mini(minimum[k],copy.resources[k])
	return {"horizon":horizon,"final":copy.resources,"minimum":minimum}
static func read(world: Dictionary,p: Dictionary) -> Dictionary:
	var ledger = R.economy(p)
	var threats = []
	for animal in world.xenos.units.values():
		if animal.kind == "larva": continue
		for town in p.settlements.values():
			if R.distance(p.tiles[town.tileId],p.tiles[animal.tile]) <= 4:
				threats.append(animal.id); break
	return {"stocks":p.resources.duplicate(),"net":ledger.delta,"population":p.cohorts.size(),"threats":threats,"forecast":forecast(p),"militaryUpkeep":ledger.militaryUpkeep}
static func shortage(p: Dictionary) -> String:
	var net = R.economy(p).delta
	for k in ["food","minerals","energy","industry"]:
		if net[k] < 0 or (p.resources[k] < 5 and net[k] < 2): return k
	return ""
