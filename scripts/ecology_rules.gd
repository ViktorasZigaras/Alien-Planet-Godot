extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const TANK_CAPACITY = 4
const HEALTH_GROWTH_THRESHOLD = 70

static func attach(s: Dictionary) -> void:
	s.ecology = {"tank":0,"backlog":0,"health":100,"repellents":{},"terrainWork":{},"last":{}}
	R.Layers.initialise(s.tiles)
	for tile in s.tiles.values():
		if tile.baseTerrain == "water" or tile.id == s.settlements.main.tileId: continue
		var pattern = posmod(int(tile.q)*43+int(tile.r)*79,149)
		if pattern >= 8 and pattern < 21: tile.obstacle = "stones" if pattern%2 == 0 else "brambles"
		if tile.feature == null and pattern%7 == 0: tile.vegetation = true
		if pattern > 132: tile.biomass = 3

static func terrain_reason(s: Dictionary, person_id: String, key: String, kind: String) -> String:
	if person_id not in s.construction.holders: return "Deploy a builder with the kit."
	if not s.tiles.has(key) or s.cohorts[person_id].state.tileId != key: return "Bring the builder to the selected hex."
	if s.tiles[key].hostiles > 0: return "Wildlife occupies the site."
	if s.movementQueues.has(person_id) or person_id in s.construction.travelled: return "Wait for a stationary turn."
	var tile = s.tiles[key]
	if kind == "cleanup" and tile.pollution == 0: return "There is no spilled waste here."
	if kind == "clear" and not R.Layers.blocked(tile): return "There is nothing to clear here."
	return ""

static func terrain_work(s: Dictionary) -> void:
	for person_id in s.ecology.terrainWork.keys():
		var order = s.ecology.terrainWork[person_id]
		if person_id not in s.construction.holders or s.cohorts[person_id].state.tileId != order.tile:
			s.ecology.terrainWork.erase(person_id)
			continue
		if terrain_reason(s,person_id,order.tile,order.kind) != "": continue
		order.remaining -= 1
		if order.remaining > 0: continue
		var tile = s.tiles[order.tile]
		if order.kind == "cleanup": tile.pollution = maxi(0,int(tile.pollution)-2)
		else:
			tile.obstacle = ""
			tile.feature = null
			tile.vegetation = false
		s.ecology.terrainWork.erase(person_id)

static func finish(s: Dictionary, ledger: Dictionary) -> void:
	if not s.has("ecology"): return
	var environment = s.ecology
	var population = 0
	var treatment = 0
	var medics = 0
	for id in ledger.activity:
		var person = s.cohorts[id]
		var job = person.state.get("job")
		if person.state.kind != "resident" or job == null: continue
		population += 1
		if job == "waste": treatment += 3
		if job == "medical" and person.qualification == "Medic": medics += 1
	var industrial = int(ledger.gross.industry)
	var center = s.settlements.main.tileId
	var local = [center] + R.neighbours(s,center)
	var forest = local.any(func(key): return s.tiles[key].feature == "forest")
	var generated = maxi(0,ceili(population/2.0)+industrial-int(forest))
	var total = int(environment.tank)+generated
	var treated = mini(total,treatment)
	total -= treated
	environment.tank = mini(TANK_CAPACITY,total)
	var spill = total-int(environment.tank)+int(environment.backlog)
	var deposited = 0
	for key in local:
		if spill <= 0: break
		var tile = s.tiles[key]
		if tile.baseTerrain == "water": continue
		var amount = mini(spill,3-int(tile.pollution))
		tile.pollution += amount
		spill -= amount
		deposited += amount
	environment.backlog = spill
	var exposure = 0
	for key in local: exposure += int(s.tiles[key].pollution)
	environment.health = clampi(int(environment.health)+2+6*medics-3*exposure,0,100)
	environment.last = {"workers":population,"industrial":industrial,"generated":generated,"treated":treated,"spilled":deposited,"medics":medics}
	ledger.ecology = environment.last.duplicate()
	terrain_work(s)

static func same_geography(tiles: Dictionary, baseline: Dictionary) -> bool:
	if tiles.size() != baseline.size(): return false
	for key in baseline:
		if not tiles.get(key) is Dictionary: return false
		var tile = tiles[key]
		for field in ["id","q","r","baseTerrain","biome","relief","bonus"]:
			if tile.get(field) != baseline[key].get(field): return false
		if tile.get("feature") != null and tile.get("feature") != baseline[key].feature: return false
		if not R.whole(tile.get("pollution"),0,3) or not R.whole(tile.get("biomass"),0,1000) or not R.whole(tile.get("hostiles"),0,1000): return false
		if tile.get("obstacle") not in ["","brambles","stones"] or not tile.get("vegetation") is bool or not tile.get("xenomass") is bool: return false
	return true
