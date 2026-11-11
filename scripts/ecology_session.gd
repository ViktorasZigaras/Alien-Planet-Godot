extends RefCounted
const Previous = preload("res://scripts/exploration_session.gd")
const TerrainEcology = preload("res://scripts/ecology_rules.gd")
const Wildlife = preload("res://scripts/xeno_ecology.gd")
const E = Previous.Previous.E
const K = Previous.K

static func initial() -> Dictionary:
	var s = Previous.initial()
	TerrainEcology.attach(s)
	var center = s.tiles[s.settlements.main.tileId]
	var nest = ""
	var best_score = -1
	for tile in s.tiles.values():
		if tile.baseTerrain == "water": continue
		var candidate = TerrainEcology.R.distance(center,tile) + (100 if tile.baseTerrain == "fungal" else 0)
		if candidate > best_score:
			nest = tile.id
			best_score = candidate
	s.xenos = Wildlife.initial(s,nest)
	Wildlife.sync_tiles(s)
	K.observe(s)
	return s

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var kind = cmd.get("type","")
	if kind not in ["clearTerrain","cleanSpill","cancelTerrain","repellent"]:
		var result = Previous.command(s,cmd)
		if not result.ok: return result
		var next = result.state
		if kind == "endTurn":
			# B07 wildlife forages and roams. Human encounters enter in B08.
			if int(next.turn)%3 == 0:
				for tile in next.tiles.values():
					if tile.vegetation and tile.pollution < 2: tile.biomass = mini(3,int(tile.biomass)+1)
			Wildlife.tick(next,{"blue":next} if next.has("tactics") else {})
			for key in next.ecology.repellents.keys():
				next.ecology.repellents[key] -= 1
				if next.ecology.repellents[key] <= 0: next.ecology.repellents.erase(key)
			K.observe(next)
		elif kind in ["move","queueMove","returnBuilder"]:
			next.ecology.terrainWork.erase(cmd.get("unitId",cmd.get("person","")))
		return result
	var person_id = cmd.get("person","")
	var key = cmd.get("tile","")
	if kind == "repellent":
		if not s.knowledge.visible.has(key) or s.tiles[key].baseTerrain == "water":
			return {"ok":false,"state":s,"message":"Choose visible land for the repellent."}
		if s.ecology.repellents.has(key):
			return {"ok":false,"state":s,"message":"Repellent is already active here."}
		if Previous.Previous.P.available(s,"energy") < 2:
			return {"ok":false,"state":s,"message":"Repellent needs two unreserved Energy."}
	elif kind != "cancelTerrain":
		var error = TerrainEcology.terrain_reason(s,person_id,key,"cleanup" if kind == "cleanSpill" else "clear")
		if error != "": return {"ok":false,"state":s,"message":error}
		if s.ecology.terrainWork.has(person_id):
			return {"ok":false,"state":s,"message":"Cancel the builder's current terrain work first."}
	var next = s.duplicate(true)
	if kind == "repellent":
		E.change(next,"energy",-2)
		next.ecology.repellents[key] = 3
	elif kind == "cancelTerrain":
		next.ecology.terrainWork.erase(person_id)
	else:
		next.ecology.terrainWork[person_id] = {"tile":key,"kind":"cleanup" if kind == "cleanSpill" else "clear","remaining":2}
	return {"ok":true,"state":next,"message":"Ecology order recorded."}

static func validate(s) -> String:
	if not s is Dictionary or not s.get("ecology") is Dictionary: return "Missing ecology state."
	var data = s.ecology
	for field in ["repellents","terrainWork","last"]:
		if not data.get(field) is Dictionary: return "Invalid ecology records."
	if not E.R.whole(data.get("health"),0,100) or not E.R.whole(data.get("tank"),0,4) or not E.R.whole(data.get("backlog"),0,9007199254740991): return "Invalid settlement environment."
	var error = Previous.validate(s)
	if error != "": return error
	for key in data.repellents:
		if not s.tiles.has(key) or not E.R.whole(data.repellents[key],1,3): return "Invalid repellent."
	for id in data.terrainWork:
		var order = data.terrainWork[id]
		if id not in s.construction.holders or not order is Dictionary or not s.tiles.has(order.get("tile","")) or order.get("kind") not in ["clear","cleanup"] or not E.R.whole(order.get("remaining"),1,2): return "Invalid terrain work."
	return Wildlife.validate(s.xenos,s,{"blue":s})
