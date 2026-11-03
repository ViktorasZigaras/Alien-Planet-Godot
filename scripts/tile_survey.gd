class_name TileSurvey
extends RefCounted
## Read-only geographic facts. Potential yields are not staffed production.
const R = preload("res://scripts/game_rules.gd")
static func ordered(s: Dictionary) -> Array:
	var tiles = s.tiles.values()
	tiles.sort_custom(func(a,b): return a.r < b.r or (a.r == b.r and a.q < b.q))
	return tiles
static func inspect(s: Dictionary,key: String) -> Dictionary:
	if not s.tiles.has(key): return {}
	var t = s.tiles[key]
	return {"tile":key,"terrain":t.baseTerrain,"biome":t.biome,"relief":t.relief,"forest":t.feature == "forest","bonus":t.bonus,"potential":R.tile_yield(s,key),"workedBy":R.worker_at(s,key).get("id",""),"layers":{"pollution":t.pollution,"obstacle":t.obstacle,"vegetation":t.vegetation,"xenomass":t.xenomass},"improvements":s.improvements.get(key,{}).duplicate(),"hostiles":t.get("hostiles",0)}
static func sites(world: Dictionary,p: Dictionary) -> Array:
	var result = []
	for t in ordered(p):
		if R.founding_reason(p,t.id) != "": continue
		var nearest = 999
		for town in p.settlements.values(): nearest = mini(nearest,R.distance(t,p.tiles[town.tileId]))
		if nearest > 7: continue
		var danger = false
		for animal in world.xenos.units.values():
			if R.distance(t,p.tiles[animal.tile]) <= 3: danger = true; break
		if danger: continue
		for other in world.get("civilizations",{}).values():
			if other == p: continue
			for town in other.settlements.values():
				if R.distance(t,p.tiles[town.tileId]) < 3: danger = true
		if p != world:
			for town in world.settlements.values():
				if R.distance(t,p.tiles[town.tileId]) < 3: danger = true
		if danger: continue
		var score = -nearest*0.7
		var potential = {}
		for near in R.neighbours(p,t.id):
			for resource in R.tile_yield(p,near): potential[resource] = potential.get(resource,0)+R.tile_yield(p,near)[resource]
		for resource in potential: score += potential[resource]*(1.5 if resource == "food" else 1.0)
		result.append({"tile":t.id,"score":score,"potential":potential,"distance":nearest})
	result.sort_custom(func(a,b): return a.score > b.score or (a.score == b.score and a.tile < b.tile))
	return result
