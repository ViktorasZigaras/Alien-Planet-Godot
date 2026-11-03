class_name AILieutenant
extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const X = preload("res://scripts/xeno_ecology.gd")
const C = preload("res://scripts/combat_rules.gd")
const A = preload("res://scripts/ai_assessment.gd")
const P = preload("res://scripts/ai_plan_actions.gd")
static func initial() -> Dictionary:
	return {"retreatHP":55,"chargeOdds":0.6,"minimumSupport":1,"losses":0,"isolatedLosses":0,"terrain":{},"events":[],"lastPositions":{}}
static func terrain_class(tile: Dictionary) -> String:
	return tile.baseTerrain+"/"+tile.relief+"/"+("forest" if tile.feature == "forest" else "clear")
static func combatants(p: Dictionary) -> Array:
	return A.people(p).filter(func(c):return c.qualification == "Soldier" and c.state.kind == "mobile" and ("small_arms" in c.equipment or "flamer" in c.equipment))
static func support(p: Dictionary,c: Dictionary) -> int:
	var n = 0
	for other in combatants(p):
		if R.distance(p.tiles[R.person_tile(p,c)],p.tiles[other.state.tileId]) <= 2: n += 1
	return n
static func occupancy(p: Dictionary,key: String,except: String = "") -> int:
	var n = 0
	for c in combatants(p):
		if c.id == except: continue
		if c.state.tileId == key or (p.movementQueues.has(c.id) and p.movementQueues[c.id].back() == key): n += 1
	return n
static func nearest_home(p: Dictionary,key: String) -> String:
	var best = ""; var distance = INF
	var towns = p.settlements.keys(); towns.sort()
	for id in towns:
		var town = p.settlements[id]
		var d = R.distance(p.tiles[key],p.tiles[town.tileId])
		if d < distance: distance = d; best = town.tileId
	return best
static func step(world: Dictionary,p: Dictionary,c: Dictionary,target: String,retreat: bool = false) -> Dictionary:
	if p.movementQueues.has(c.id) or c.state.movementRemaining <= 0: return {}
	var here = c.state.tileId
	if here == target: return {}
	var best = ""; var score = -INF
	var options = R.neighbours(p,here); options.sort()
	for key in options:
		if p.tiles[key].baseTerrain == "water" or p.tiles[key].get("hostiles",0)>0: continue
		var crowd = occupancy(p,key,c.id)
		if not retreat and crowd >= 3: continue
		var danger = 0.0
		for animal in world.xenos.units.values():
			# Preserve the documented coarse movement+one reach heuristic; not a complete threat solver.
			if animal.kind != "larva" and R.distance(p.tiles[key],p.tiles[animal.tile]) <= X.DATA[animal.kind].moves+1: danger += X.DATA[animal.kind].attack
		var memory = p.ai.lieutenant.terrain.get(terrain_class(p.tiles[key]),{}).get("band",0)
		var value = -R.distance(p.tiles[key],p.tiles[target])*5.0+C.defence(p.tiles[key])*2.0-R.step_cost(p,here,key)*0.4-crowd*0.8-danger*(2.0 if retreat else 0.6)-memory*2.5
		if retreat and crowd>=3: value -= 5
		if value > score: best = key; score = value
	if best == "": return {}
	var result = P.legal(p,{"type":"queueMove","unitId":c.id,"target":best},"retreat" if retreat else "advance")
	if not result.is_empty(): result.context = {"tile":best,"terrain":terrain_class(p.tiles[best]),"quotedCost":R.step_cost(p,here,best),"stackException":retreat and occupancy(p,best,c.id)>=3}
	return result
static func pick(world: Dictionary,p: Dictionary,ids: Array,target: String,released: bool) -> Dictionary:
	var troops = combatants(p)
	var enemies = world.xenos.units.values(); enemies.sort_custom(func(a,b):return a.hp < b.hp or (a.hp == b.hp and a.id < b.id))
	# Immediate fire and retreat are available even before charter release.
	for c in troops:
		for animal in enemies:
			var fire = {"type":"attackXeno","cohortId":c.id,"targetId":animal.id,"mode":"ranged"}
			if X.attack_reason(world,p,fire) == "": return P.intent(fire,"lieutenant_fire")
		if X.hp(world.xenos,c.id) < p.ai.lieutenant.retreatHP:
			var back = step(world,p,c,nearest_home(p,c.state.tileId),true)
			if not back.is_empty(): return back
		for animal in enemies:
			var charge = {"type":"attackXeno","cohortId":c.id,"targetId":animal.id,"mode":"melee"}
			if X.attack_reason(world,p,charge) != "": continue
			if X.preview(world,p,c,animal) >= p.ai.lieutenant.chargeOdds and (animal.hp <= 45 or ("flamer" in c.equipment and support(p,c)>=2)):
				return P.intent(charge,"lieutenant_charge")
	if not released or target == "" or ids.size() < 2: return {}
	for c in troops:
		if c.id not in ids or X.hp(world.xenos,c.id) < p.ai.lieutenant.retreatHP: continue
		if support(p,c) < p.ai.lieutenant.minimumSupport: continue
		var advance = step(world,p,c,target)
		if not advance.is_empty(): return advance
	return {}
static func append_event(l: Dictionary,event: Dictionary) -> void:
	l.events.append(event.duplicate(true))
	if l.events.size()>128: l.events.pop_front()
static func observe(world: Dictionary,p: Dictionary,player: String,events: Array) -> void:
	var l = p.ai.lieutenant
	for e in events:
		if e.type == "attack" and e.get("player","") == player and e.get("soldier",false):
			var tile = e.get("tile","")
			if not world.tiles.has(tile): continue
			var key = terrain_class(world.tiles[tile])
			if not l.terrain.has(key): l.terrain[key] = {"hits":0,"damage":0,"deaths":0,"band":0}
			var row = l.terrain[key]
			row.hits += 1; row.damage += maxi(0,int(e.damage))
			if e.health <= 0:
				row.deaths += 1; l.losses += 1
				if e.get("support",2)<2: l.isolatedLosses += 1
			if row.hits >= 3 and row.damage >= 60: row.band = 2 if row.deaths > 0 else 1
			append_event(l,{"type":"incoming","turn":world.turn,"terrain":key,"damage":e.damage,"health":e.health})
		if e.type == "human_attack" and e.get("person","") in l.lastPositions and e.get("mode","") == "melee" and e.get("personHealth",100)<=0: l.chargeOdds = 0.78
	if l.losses>=2: l.retreatHP = 70
	if l.isolatedLosses>=2: l.minimumSupport = 2
	for c in combatants(p): l.lastPositions[c.id] = c.state.tileId
static func validate(l) -> String:
	if not l is Dictionary or not R.has_fields(l,["retreatHP","chargeOdds","minimumSupport","losses","isolatedLosses","terrain","events","lastPositions"]): return "Missing lieutenant state."
	if not R.whole(l.retreatHP,55,70) or int(l.retreatHP) not in [55,70] or not R.whole(l.minimumSupport,1,2) or (not is_equal_approx(l.chargeOdds,0.6) and not is_equal_approx(l.chargeOdds,0.78)): return "Invalid learned thresholds."
	if not R.whole(l.losses,0,1000000) or not R.whole(l.isolatedLosses,0,l.losses) or not l.terrain is Dictionary or not l.events is Array or l.events.size()>128 or not l.lastPositions is Dictionary: return "Invalid tactical memory."
	for key in l.terrain:
		var t = l.terrain[key]
		if not key is String or not t is Dictionary or not R.has_fields(t,["hits","damage","deaths","band"]): return "Invalid terrain memory."
		if not R.whole(t.hits,0,1000000) or not R.whole(t.damage,0,100000000) or not R.whole(t.deaths,0,t.hits) or not R.whole(t.band,0,2): return "Invalid terrain counters."
		var expected = (2 if t.deaths>0 else 1) if t.hits>=3 and t.damage>=60 else 0
		if t.band != expected: return "Inconsistent terrain caution."
	return ""
