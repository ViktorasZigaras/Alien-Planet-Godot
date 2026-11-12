extends RefCounted

const Layers = preload("res://scripts/terrain_layers.gd")
const Edges = preload("res://scripts/map_generator.gd")
const DIRECTIONS = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
const DEFAULT = {"seed":731,"width":16,"height":11}
const LAND = {"temperate":"plains","lush":"grassland","dry":"desert","cold":"tundra","fungal":"fungal"}

static func valid(config) -> bool:
	if not config is Dictionary: return false
	for key in ["seed","width","height"]:
		var value = config.get(key)
		if not (value is int or value is float) or not is_finite(value) or floorf(value) != value: return false
	return config.seed >= 0 and config.seed <= 2147470000 and config.width >= 9 and config.width <= 30 and config.height >= 7 and config.height <= 22

static func id(q: int, r: int) -> String:
	return "%d,%d" % [q,r]

static func distance(a: Dictionary,b: Dictionary) -> int:
	var q = int(a.q)-int(b.q)
	var r = int(a.r)-int(b.r)
	return maxi(absi(q),maxi(absi(r),absi(q+r)))

static func neighbors(tiles: Dictionary,t: Dictionary) -> Array[String]:
	var found: Array[String] = []
	for direction in DIRECTIONS:
		var key = id(t.q+direction.x,t.r+direction.y)
		if tiles.has(key): found.append(key)
	return found

static func land_component(tiles: Dictionary, key: String, seen: Dictionary) -> Array[String]:
	var frontier: Array[String] = [key]
	seen[key] = true
	var cursor = 0
	while cursor < frontier.size():
		for next in neighbors(tiles,tiles[frontier[cursor]]):
			if seen.has(next) or tiles[next].baseTerrain == "water": continue
			seen[next] = true
			frontier.append(next)
		cursor += 1
	return frontier

static func generate(config: Dictionary) -> Dictionary:
	var width = int(config.width)
	var height = int(config.height)
	var seed_value = int(config.seed)
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.14
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var tiles = {}
	var divides = {}
	var shore_shift = rng.randf_range(-0.11,0.11)
	var river_shift = rng.randf_range(-0.16,0.16)
	for r in range(height):
		for q in range(width):
			var x = 2.0*q/(width-1)-1.0
			var y = 2.0*r/(height-1)-1.0
			var terrain_noise = noise.get_noise_2d(q,r)
			var moisture = noise.get_noise_2d(q*0.56+52,r*0.56+17)
			var elevation = noise.get_noise_2d(q*0.73+103,r*0.73-29)
			var coast = pow(absf(x+shore_shift+y*0.14),2.5)+pow(absf(y-x*0.15),2.5)
			var biome = "temperate"
			if moisture < -0.28: biome = "dry"
			elif y < -0.40 and elevation < -0.07: biome = "cold"
			elif moisture > 0.30 and y > 0.05: biome = "fungal"
			elif moisture > 0.08: biome = "lush"
			if coast > 0.96+terrain_noise*0.55: biome = "coastal"
			var terrain: String = LAND.get(biome,"water")
			var roll = rng.randf()
			var bonus = ""
			if terrain != "water":
				if roll < 0.04: bonus = "ore_seam"
				elif roll < 0.08: bonus = "oasis" if biome == "dry" else "edible_flora"
				elif roll < 0.10: bonus = "geothermal_vent"
				elif roll < 0.12: bonus = "alien_specimens"
				elif roll < 0.14: bonus = "resonant_stones"
			var key = id(q,r)
			tiles[key] = {"id":key,"q":q,"r":r,"baseTerrain":terrain,"biome":biome,"bonus":bonus,
				"relief":"hills" if terrain != "water" and (elevation > 0.27 or bonus == "ore_seam") else "flat",
				"feature":"forest" if terrain != "water" and biome != "dry" and moisture+roll*0.33 > 0.43 else null}
			divides[key] = x < river_shift+0.35*noise.get_noise_2d(r*2.5+110,9)+y*0.19
	var seen = {}
	var mainland: Array[String] = []
	for key in tiles:
		if seen.has(key) or tiles[key].baseTerrain == "water": continue
		var component = land_component(tiles,key,seen)
		if component.size() > mainland.size(): mainland = component
	var connected = {}
	for key in mainland: connected[key] = true
	for key in tiles:
		if connected.has(key): continue
		tiles[key].merge({"baseTerrain":"water","biome":"coastal","bonus":"","relief":"flat","feature":null},true)
	var rivers: Array[String] = []
	for key in mainland:
		for adjacent in neighbors(tiles,tiles[key]):
			if key < adjacent and connected.has(adjacent) and divides[key] != divides[adjacent]:
				rivers.append(Edges.edge_key(key,adjacent))
	rivers.sort()
	var landing = ""
	var score = -INF
	for key in mainland:
		var tile = tiles[key]
		var exits = neighbors(tiles,tile).filter(func(k): return connected.has(k))
		var food_sites = exits.filter(func(k): return tiles[k].baseTerrain in ["grassland","plains"] and tiles[k].relief == "flat")
		var rank = food_sites.size()*4.0+exits.size()+noise.get_noise_2d(tile.q-44,tile.r+20)*3.0
		if tile.relief == "flat" and tile.baseTerrain in ["plains","grassland"]: rank += 5.0
		if tile.bonus != "": rank -= 3.0
		if rank > score:
			score = rank
			landing = key
	Layers.initialise(tiles)
	for key in mainland:
		var tile = tiles[key]
		var scatter = rng.randf()
		if scatter < 0.09: tile.obstacle = "stones" if tile.relief == "hills" or scatter < 0.045 else "brambles"
		if tile.feature == null and scatter > 0.83: tile.vegetation = true
		if scatter > 0.95: tile.biomass = 3
	var start = tiles[landing]
	start.merge({"baseTerrain":"plains","biome":"temperate","relief":"flat","feature":null,"bonus":"","obstacle":"","vegetation":false},true)
	var gardens = neighbors(tiles,start).filter(func(k): return connected.has(k))
	gardens.sort_custom(func(a,b): return (3 if tiles[a].baseTerrain == "grassland" else 0)+(1 if tiles[a].relief == "flat" else 0) > (3 if tiles[b].baseTerrain == "grassland" else 0)+(1 if tiles[b].relief == "flat" else 0))
	for i in range(mini(2,gardens.size())):
		tiles[gardens[i]].merge({"baseTerrain":"grassland","biome":"lush","relief":"flat","feature":null,"obstacle":"","vegetation":false},true)
	var nest = ""
	score = -INF
	for key in mainland:
		var range_from_start = distance(start,tiles[key])
		if range_from_start < 4: continue
		var rank = range_from_start+(5 if tiles[key].baseTerrain == "fungal" else 0)+noise.get_noise_2d(tiles[key].q,tiles[key].r)
		if rank > score:
			nest = key
			score = rank
	if nest != "":
		tiles[nest].merge({"baseTerrain":"fungal","biome":"fungal","bonus":"","feature":null},true)
	return {"tiles":tiles,"rivers":rivers,"landing":landing,"nest":nest}

static func apply(s: Dictionary, config: Dictionary) -> Dictionary:
	var settings = {"seed":int(config.seed),"width":int(config.width),"height":int(config.height)}
	var region = generate(settings)
	s.survey = settings
	s.map = settings.duplicate()
	s.tiles = region.tiles
	s.rivers = region.rivers
	s.settlements.main.tileId = region.landing
	s.tileAccess.main = []
	for key in s.tiles:
		if distance(s.tiles[key],s.tiles[region.landing]) <= 2: s.tileAccess.main.append(key)
	for person in s.cohorts.values():
		if person.state.kind == "mobile": person.state.tileId = region.landing
	return region
