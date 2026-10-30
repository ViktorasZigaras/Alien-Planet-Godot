class_name XenoEcology
extends RefCounted
## Local wildlife, not a civilization: no tech tree, global stocks or player turns.
const C = preload("res://scripts/combat_rules.gd")
const R = preload("res://scripts/game_rules.gd")
const NEST_TILE = "18,12"
const DATA = {
	"larva":{"name":"Mandible larva","hp":100,"attack":0.25,"armor":0,"moves":1,"biomass":6,"minerals":0},
	"predator":{"name":"Hookrunner","hp":100,"attack":1.0,"armor":0,"moves":2,"biomass":8,"minerals":0},
	"armored":{"name":"Carapace predator","hp":100,"attack":1.5,"armor":0,"moves":1,"biomass":14,"minerals":4}}
const FUTURE_MASS_COMBAT_BONUS = 1 # Reserved; not applied until combat design is extended.
const WORKER_CAP = 3
const PREDATOR_CAP = 6
static func initial(s: Dictionary) -> Dictionary:
	var tile = NEST_TILE
	if not s.tiles.has(tile) or s.tiles[tile].baseTerrain != "fungal":
		var options = s.tiles.values()
		options.sort_custom(func(a,b):return a.id < b.id)
		for t in options:
			if t.baseTerrain != "water" and not s.tiles.has(tile): tile = t.id
			if t.baseTerrain == "fungal": tile = t.id; break
	var x = {"tick":0,"rng":int(s.map.seed)+9137,"nextUnit":1,"nests":{},"units":{},"mass":{},"humanHealth":{},"lastHumanAttack":{},"lastEvents":[],"deaths":{"blue":0,"red":0,"animals":0},"lastAnimalAttack":{},"effects":[],"effectSequence":0}
	x.nests.nest_1 = {"id":"nest_1","tile":tile,"biomass":18,"minerals":0,"hp":24,"burned":false,"workerCap":WORKER_CAP,"predatorCap":PREDATOR_CAP}
	x.mass[tile] = "nest_1"
	for next in R.neighbours(s,tile):
		if s.tiles[next].baseTerrain == "fungal" and x.mass.size() < 3: x.mass[next] = "nest_1"
	for kind in ["larva","larva","predator","predator"]: spawn(x,"nest_1",kind)
	var positions = [tile]+R.neighbours(s,tile).filter(func(k):return s.tiles[k].baseTerrain != "water")
	for i in range(x.units.size()):
		var u = x.units.values()[i]
		u.tile = positions[i%positions.size()]
		u.previousTile = u.tile
	return x
static func random_index(x: Dictionary,count: int) -> int:
	x.rng = (int(x.rng)*1103515245+12345)%2147483648
	return int(x.rng)%maxi(1,count)
static func spawn(x: Dictionary,nest_id: String,kind: String) -> void:
	var key = "xeno_"+str(int(x.nextUnit)).pad_zeros(4)
	x.nextUnit = int(x.nextUnit)+1
	var tile = x.nests[nest_id].tile
	x.units[key] = {"id":key,"nestId":nest_id,"kind":kind,"tile":tile,"previousTile":tile,"hp":DATA[kind].hp,"facing":0.0,"target":"","activity":"hatched"}
static func members(x: Dictionary,nest_id: String,workers: bool) -> Array:
	return x.units.values().filter(func(u): return u.nestId == nest_id and (u.kind == "larva") == workers)
static func summary(x: Dictionary) -> Dictionary:
	var counts = {"deaths":{"blue":int(x.deaths.blue),"red":int(x.deaths.red),"animals":int(x.deaths.animals)},"activeNests":x.nests.values().filter(func(n):return not n.get("burned",false)).size(),"nests":x.nests.size(),"workers":0,"predators":0,"armored":0,"massTiles":x.mass.size(),"biomass":0,"minerals":0,"woundedPeople":x.humanHealth.size()}
	for unit in x.units.values():
		if unit.kind == "larva": counts.workers += 1
		else: counts.predators += 1
		if unit.kind == "armored": counts.armored += 1
	for nest in x.nests.values(): counts.biomass += int(nest.biomass); counts.minerals += int(nest.minerals)
	return counts
static func people(players: Dictionary) -> Array:
	var result = []
	for player in players:
		for c in players[player].cohorts.values():
			if c.state.kind == "cargo": continue
			result.append({"player":player,"id":c.id,"tile":R.person_tile(players[player],c),"person":c})
	result.sort_custom(func(a,b): return a.id < b.id)
	return result
static func event(x: Dictionary,kind: String,data: Dictionary) -> void:
	var entry = data.duplicate(true)
	entry.type = kind
	x.lastEvents.append(entry)
static func walk(s: Dictionary,u: Dictionary,target: String) -> void:
	if target == u.tile: return
	var from = s.tiles[u.tile]
	var to = s.tiles[target]
	u.previousTile = u.tile
	u.tile = target
	u.facing = atan2(sqrt(3.0)*(to.q-from.q+(to.r-from.r)*0.5),1.5*(to.r-from.r))
static func step_toward(s: Dictionary,origin: String,target: String) -> String:
	var options = R.neighbours(s,origin).filter(func(k): return s.tiles[k].baseTerrain != "water")
	options.sort()
	var best = origin
	var distance = R.distance(s.tiles[origin],s.tiles[target])
	for key in options:
		var d = R.distance(s.tiles[key],s.tiles[target])
		if d < distance: best = key; distance = d
	return best
static func worker_turn(s: Dictionary,x: Dictionary,u: Dictionary,index: int) -> void:
	var nest = x.nests[u.nestId]
	if nest.get("burned",false): u.activity = "nest disabled"; return
	var center = s.tiles[nest.tile]
	if (int(x.tick)+index)%3 == 0 and nest.biomass >= 1:
		var options = R.neighbours(s,u.tile)
		options.sort()
		for key in options:
			if s.tiles[key].baseTerrain == "water" or x.mass.has(key) or R.distance(center,s.tiles[key]) > 3: continue
			var town_tile = R.site_at(s,key).is_empty()
			for red_town in s.civilizations.red.settlements.values():
				if red_town.tileId == key: town_tile = false
			if not town_tile: continue
			x.mass[key] = u.nestId
			nest.biomass -= 1
			walk(s,u,key)
			u.activity = "spreading xenomass"
			event(x,"spread",{"unit":u.id,"tile":key,"nest":u.nestId})
			return
	# Find useful mineral ground; otherwise forage over the growing organic mat.
	var candidates = []
	for tile in s.tiles.values():
		if tile.baseTerrain != "water" and R.distance(center,tile) <= 3: candidates.append(tile)
	candidates.sort_custom(func(a,b): return a.id < b.id)
	var target = u.tile
	var best = -INF
	for tile in candidates:
		var minerals = tile.relief == "hills" or tile.bonus == "ore_seam"
		var score = (9 if minerals and nest.minerals < 4 else 2 if x.mass.has(tile.id) else 0)-R.distance(s.tiles[u.tile],tile)*0.2
		if score > best: target = tile.id; best = score
	var next = step_toward(s,u.tile,target)
	if next != u.tile: walk(s,u,next)
	var tile = s.tiles[u.tile]
	var coated = x.mass.has(u.tile)
	var biomass = 3+(1 if tile.baseTerrain == "fungal" else 0)+(1 if coated else 0)+(1 if tile.get("biomass",0) > 0 else 0)
	if tile.get("biomass",0) > 0: tile.biomass -= 1
	var minerals = (1+(1 if coated else 0)) if tile.relief == "hills" or tile.bonus == "ore_seam" else 0
	# Waste hurts animals as well as humans; xenomass itself benefits animals.
	var pollution = int(tile.get("pollution",0))
	biomass = 0 if pollution == 3 else maxi(0,biomass-pollution)
	minerals = 0 if pollution == 3 else maxi(0,minerals-pollution-(1 if tile.get("obstacle", "") == "brambles" else 2 if tile.get("obstacle", "") == "stones" else 0))
	nest.biomass = int(nest.biomass)+biomass
	nest.minerals = int(nest.minerals)+minerals
	u.activity = "harvesting"
	event(x,"harvest",{"unit":u.id,"tile":u.tile,"biomass":biomass,"minerals":minerals,"massBonus":coated})
static func remove_person(s: Dictionary,players: Dictionary,victim: Dictionary) -> void:
	var p = players[victim.player]
	for passenger in R.passengers(p,victim.id):
		passenger.state = {"kind":"mobile","tileId":victim.tile,"movementRemaining":0.0}
		passenger.lastRoute = []
	for project in ["trainingProject","constructionProject"]:
		if p[project] != null and p[project].cohortId == victim.id: p[project] = null
	p.movementQueues.erase(victim.id); p.moveProgress.erase(victim.id)
	for site in p.neutralSites.values(): site.visitors.erase(victim.id)
	p.cohorts.erase(victim.id)
	s.xenos.humanHealth.erase(victim.id); s.xenos.lastHumanAttack.erase(victim.id)
static func human_power(p: Dictionary,c: Dictionary,ranged: bool = false,animal: bool = true) -> float:
	var profile = R.combat_profile(c)
	var power = float(profile.ranged if ranged else profile.attack)
	if "flamer" in c.equipment and animal: power *= 2.0
	if p.resources.food <= 0 or (("flamer" in c.equipment or "rover" in c.equipment) and p.resources.industry <= 0): power *= 0.75
	return maxf(0.01,power)
static func hp(x: Dictionary,id: String) -> int: return int(x.humanHealth.get(id,100))
static func effect(x: Dictionary,kind: String,source: String,target: String) -> void:
	x.effectSequence = int(x.effectSequence)+1
	x.effects.append({"id":x.effectSequence,"kind":kind,"source":source,"target":target})
	if x.effects.size() > 24: x.effects.pop_front()
static func kill_animal(x: Dictionary,id: String,cause: String) -> void:
	if not x.units.has(id): return
	x.units.erase(id); x.lastAnimalAttack.erase(id)
	x.deaths.animals = int(x.deaths.animals)+1
	event(x,"xeno_lost",{"unit":id,"cause":cause})
static func kill_person(s: Dictionary,players: Dictionary,victim: Dictionary,cause: String) -> void:
	if not players[victim.player].cohorts.has(victim.id): return
	remove_person(s,players,victim)
	s.xenos.deaths[victim.player] = int(s.xenos.deaths[victim.player])+1
	event(s.xenos,"person_lost",{"person":victim.id,"player":victim.player,"cause":cause})
static func hit_person(s: Dictionary,players: Dictionary,u: Dictionary,victim: Dictionary,ranged: bool = false) -> void:
	var x = s.xenos; var p = players[victim.player]
	var defence = human_power(p,victim.person,false,false)*C.defence(s.tiles[victim.tile],not R.site_at(p,victim.tile).is_empty())
	var power = float(DATA[u.kind].attack)*(0.65 if ranged else 1.0)
	var before = hp(x,victim.id)
	if ranged:
		x.humanHealth[victim.id] = maxi(0,before-C.ranged_damage(power,defence,int(u.hp),before))
	else:
		var duel = C.duel(x,power,defence,int(u.hp),before)
		u.hp = duel.attackerHP; x.humanHealth[victim.id] = duel.defenderHP
	x.lastAnimalAttack[u.id] = int(s.turn)
	# Both duel participants fought; passive healing requires a quiet round.
	x.lastHumanAttack[victim.id] = int(s.turn)
	u.activity = "spitting" if ranged else "attacking"; u.target = victim.id
	effect(x,"spit" if ranged else "claw",u.tile,victim.tile)
	event(x,"attack",{"unit":u.id,"victim":victim.id,"player":victim.player,"ranged":ranged,"damage":before-int(x.humanHealth[victim.id]),"health":x.humanHealth[victim.id],"unitHealth":u.hp})
	p.log.push_front("%s attacks %s (%d/100 HP)." % [DATA[u.kind].name,victim.person.name,x.humanHealth[victim.id]])
	p.log = p.log.slice(0,100)
	if x.humanHealth[victim.id] <= 0: kill_person(s,players,victim,"xeno_combat")
	if u.hp <= 0: kill_animal(x,u.id,"human_defence")
static func predator_turn(s: Dictionary,players: Dictionary,u: Dictionary) -> void:
	var x = s.xenos
	var victim = {}
	var closest = 4
	for candidate in people(players):
		var d = R.distance(s.tiles[u.tile],s.tiles[candidate.tile])
		if d < closest: closest = d; victim = candidate
	u.target = victim.get("id", "")
	if not victim.is_empty():
		for move in range(DATA[u.kind].moves):
			if R.distance(s.tiles[u.tile],s.tiles[victim.tile]) <= (2 if u.kind == "armored" else 1): break
			var next = step_toward(s,u.tile,victim.tile)
			if next == u.tile: break
			walk(s,u,next)
		u.activity = "pursuing"
		if R.distance(s.tiles[u.tile],s.tiles[victim.tile]) <= (2 if u.kind == "armored" else 1): hit_person(s,players,u,victim,u.kind == "armored")
	else:
		var nest = x.nests[u.nestId]
		var options = R.neighbours(s,u.tile).filter(func(k): return s.tiles[k].baseTerrain != "water" and R.distance(s.tiles[nest.tile],s.tiles[k]) <= 5)
		options.sort()
		options.append(u.tile) # Sometimes linger, rather than always marching.
		walk(s,u,options[random_index(x,options.size())])
		u.activity = "roaming"
	event(x,"predator_order",{"unit":u.id,"tile":u.tile,"target":u.target,"activity":u.activity})
static func tick(s: Dictionary,players: Dictionary) -> void:
	var x = s.xenos
	for person in people(players):
		if x.lastHumanAttack.get(person.id,-1) < int(s.turn)-1:
			var healed = mini(100,hp(x,person.id)+(20 if not R.site_at(players[person.player],person.tile).is_empty() else 5))
			if healed == 100: x.humanHealth.erase(person.id)
			elif x.humanHealth.has(person.id): x.humanHealth[person.id] = healed
	for u in x.units.values():
		if x.lastAnimalAttack.get(u.id,-1) < int(s.turn)-1: u.hp = mini(100,int(u.hp)+(15 if u.tile == x.nests[u.nestId].tile else 5))
	x.tick = int(x.tick)+1
	x.lastEvents = []
	var ordered = x.units.keys(); ordered.sort()
	var worker_index = 0
	for key in ordered:
		if not x.units.has(key): continue
		var u = x.units[key]
		u.previousTile = u.tile
		if u.kind == "larva": worker_turn(s,x,u,worker_index); worker_index += 1
		else: predator_turn(s,players,u)
	for nest in x.nests.values():
		if nest.get("burned",false): continue
		var all = members(x,nest.id,true)+members(x,nest.id,false)
		var upkeep = all.size()
		var hungry = maxi(0,upkeep-nest.biomass)
		nest.biomass = maxi(0,nest.biomass-upkeep)
		if hungry > 0:
			for u in all:
				u.hp -= 10
				if u.hp <= 0: kill_animal(x,u.id,"hunger")
			event(x,"hunger",{"nest":nest.id,"missingBiomass":hungry})
		var kind = "larva" if members(x,nest.id,true).size() < nest.workerCap else "armored" if nest.minerals >= DATA.armored.minerals else "predator"
		var room = members(x,nest.id,true).size() < nest.workerCap if kind == "larva" else members(x,nest.id,false).size() < nest.predatorCap
		if room and nest.biomass >= DATA[kind].biomass and nest.minerals >= DATA[kind].minerals:
			nest.biomass -= DATA[kind].biomass; nest.minerals -= DATA[kind].minerals
			spawn(x,nest.id,kind)
			event(x,"hatched",{"nest":nest.id,"kind":kind,"biomassCost":DATA[kind].biomass,"mineralCost":DATA[kind].minerals})
	sync_tiles(s)
static func attack_reason(s: Dictionary,p: Dictionary,cmd: Dictionary) -> String:
	var c = p.cohorts.get(cmd.get("cohortId", ""),{})
	if c.is_empty() or c.state.kind != "mobile": return "Select a mobile person."
	var target = s.xenos.units.get(cmd.get("targetId", ""),{})
	if target.is_empty(): return "Choose an animal. Disable a cleared nest by stepping onto it."
	var ranged = cmd.get("mode", "melee") == "ranged"
	if cmd.get("mode", "melee") not in ["melee","ranged"]: return "Unknown attack mode."
	if ranged and R.combat_profile(c).ranged <= 0: return "Requires a trained Soldier with rifle or flamer."
	var reach = 1 if not ranged or "flamer" in c.equipment else 2
	if R.distance(s.tiles[c.state.tileId],s.tiles[target.tile]) > reach: return "Target beyond attack range."
	if c.state.movementRemaining < 1: return "Attack needs one movement point."
	return "Already fought this turn." if s.xenos.lastHumanAttack.get(c.id,-1) == s.turn else ""
static func preview(s: Dictionary,p: Dictionary,c: Dictionary,target: Dictionary) -> float:
	return C.odds(human_power(p,c),float(DATA[target.kind].attack)*C.defence(s.tiles[target.tile]),hp(s.xenos,c.id),int(target.hp))
static func attack(s: Dictionary,p: Dictionary,cmd: Dictionary) -> String:
	var x = s.xenos; var c = p.cohorts[cmd.cohortId]; var target = x.units[cmd.targetId]
	var ranged = cmd.get("mode", "melee") == "ranged"
	R.mark_used(p,c.id)
	c.state.movementRemaining -= 1
	p.movementQueues.erase(c.id); p.moveProgress.erase(c.id)
	x.lastHumanAttack[c.id] = int(s.turn)
	x.lastAnimalAttack[target.id] = int(s.turn)
	x.lastEvents = []
	var defence = float(DATA[target.kind].attack)*C.defence(s.tiles[target.tile])
	var before = int(target.hp)
	if ranged: target.hp = maxi(0,int(target.hp)-C.ranged_damage(human_power(p,c,true),defence,hp(x,c.id),int(target.hp)))
	else:
		var duel = C.duel(x,human_power(p,c),defence,hp(x,c.id),int(target.hp))
		x.humanHealth[c.id] = duel.attackerHP; target.hp = duel.defenderHP
	effect(x,"flame" if "flamer" in c.equipment else "rifle" if "small_arms" in c.equipment else "claw",c.state.tileId,target.tile)
	event(x,"human_attack",{"person":c.id,"target":target.id,"mode":"ranged" if ranged else "melee","damage":before-int(target.hp),"personHealth":hp(x,c.id),"targetHealth":target.hp})
	if target.hp <= 0: kill_animal(x,target.id,"human_attack")
	if hp(x,c.id) <= 0:
		var owner = "blue" if s.cohorts.has(c.id) else "red"
		kill_person(s,people_states(s),{"id":c.id,"tile":c.state.tileId,"player":owner},"animal_defence")
	var message = "Animal encounter: %d damage, %d/100 HP remaining." % [before-int(target.hp),target.hp]
	p.log.push_front(message); p.log = p.log.slice(0,100)
	return message
static func people_states(s: Dictionary) -> Dictionary: return {"blue":s,"red":s.civilizations.red}
static func burn_occupied(s: Dictionary,check_routes: bool = false,owner: String = "",unit_id: String = "") -> void:
	for person in people(people_states(s)):
		if person.person.state.kind != "mobile" or person.person.qualification != "Soldier": continue
		for nest in s.xenos.nests.values():
			var stepped = check_routes and (owner == "" or person.player == owner) and (unit_id == "" or person.id == unit_id) and nest.tile in person.person.lastRoute
			if nest.get("burned",false) or (nest.tile != person.tile and not stepped): continue
			if s.xenos.units.values().any(func(u):return u.tile == nest.tile): continue
			nest.burned = true
			event(s.xenos,"nest_burned",{"nest":nest.id,"person":person.id,"player":person.player})
			effect(s.xenos,"flame",nest.tile,nest.tile)
static func sync_tiles(s: Dictionary) -> void:
	for t in s.tiles.values(): t.xenomass = s.xenos.mass.has(t.id); t.hostiles = 0
	for u in s.xenos.units.values(): s.tiles[u.tile].hostiles += 1
	s.civilizations.red.tiles = s.tiles.duplicate(true)
static func validate(x,world: Dictionary,players: Dictionary) -> String:
	if not x is Dictionary or not R.has_fields(x,["tick","rng","nextUnit","nests","units","mass","humanHealth","lastHumanAttack","lastEvents","deaths","lastAnimalAttack","effects","effectSequence"]): return "Missing xeno fields."
	if not R.whole(x.tick,0,1000000) or not R.whole(x.rng,0,2147483647) or not R.whole(x.nextUnit,1,1000000): return "Invalid xeno counters."
	for key in ["nests","units","mass","humanHealth","lastHumanAttack"]:
		if not x[key] is Dictionary: return "Invalid xeno dictionaries."
	if x.nests.size() > 20 or x.units.size() > 180 or not x.lastEvents is Array or x.lastEvents.size() > 1000: return "Xeno population/event limit."
	if not x.deaths is Dictionary or not R.same_keys(x.deaths,{"blue":0,"red":0,"animals":0}) or not x.lastAnimalAttack is Dictionary or not x.effects is Array or x.effects.size() > 24 or not R.whole(x.effectSequence,0,9007199254740991): return "Invalid combat statistics."
	for count in x.deaths.values():
		if not R.whole(count,0,9007199254740991): return "Invalid death count."
	for e in x.effects:
		if not e is Dictionary or not R.has_fields(e,["id","kind","source","target"]) or not R.whole(e.id,1,x.effectSequence) or e.kind not in ["rifle","flame","spit","claw"] or not world.tiles.has(e.source) or not world.tiles.has(e.target): return "Invalid combat effect."
	for id in x.lastAnimalAttack:
		if not x.units.has(id) or not R.whole(x.lastAnimalAttack[id],1,world.turn): return "Invalid animal combat cooldown."
	for key in x.nests:
		var n = x.nests[key]
		if not n is Dictionary or not R.has_fields(n,["id","tile","biomass","minerals","hp","workerCap","predatorCap"]) or n.id != key or not world.tiles.has(n.tile) or world.tiles[n.tile].baseTerrain == "water": return "Invalid nest."
		if not n.get("burned") is bool or not R.whole(n.hp,1,24) or not R.whole(n.biomass,0,1000000) or not R.whole(n.minerals,0,1000000) or n.workerCap != WORKER_CAP or n.predatorCap != PREDATOR_CAP: return "Invalid nest stocks/caps."
	for key in x.units:
		var u = x.units[key]
		if not u is Dictionary or not R.has_fields(u,["id","nestId","kind","tile","previousTile","hp","facing","target","activity"]) or u.id != key or not x.nests.has(u.nestId) or not DATA.has(u.kind) or not world.tiles.has(u.tile) or world.tiles[u.tile].baseTerrain == "water" or not world.tiles.has(u.previousTile): return "Invalid xeno unit."
		if not R.whole(u.hp,1,DATA[u.kind].hp) or not (u.facing is float or u.facing is int) or not is_finite(float(u.facing)) or not u.target is String or not u.activity is String: return "Invalid xeno unit state."
	for n in x.nests.values():
		if members(x,n.id,true).size() > n.workerCap or members(x,n.id,false).size() > n.predatorCap: return "Overfilled nest."
	for tile in x.mass:
		if not world.tiles.has(tile) or world.tiles[tile].baseTerrain == "water" or not x.nests.has(x.mass[tile]): return "Invalid xenomass."
	var ids = {}
	for p in players.values():
		for id in p.cohorts: ids[id] = true
	for id in x.humanHealth:
		if not ids.has(id) or not R.whole(x.humanHealth[id],1,100): return "Invalid wounded person."
	for id in x.lastHumanAttack:
		if not ids.has(id) or not R.whole(x.lastHumanAttack[id],1,world.turn): return "Invalid encounter cooldown."
	return ""

static func visible_units(x: Dictionary) -> Dictionary:
	var result = {}
	var rank = {"larva":0,"predator":1,"armored":2}
	for u in x.units.values():
		if not result.has(u.tile) or rank[u.kind] >= rank[x.units[result[u.tile]].kind]: result[u.tile] = u.id
	return result
