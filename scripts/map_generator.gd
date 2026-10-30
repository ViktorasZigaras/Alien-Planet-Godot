class_name PlanetMapGenerator
extends RefCounted
## Broad geographic regions precede terrain, overlays and context-sensitive deposits.
static func generate(seed_value: int = 731, width: int = 24, height: int = 16) -> Dictionary:
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.13
	var regions = [
		[Vector2(0.15,0.3),"temperate"], [Vector2(0.43,0.22),"lush"],
		[Vector2(0.79,0.3),"dry"], [Vector2(0.27,0.86),"cold"],
		[Vector2(0.71,0.82),"fungal"]]
	var tiles = {}
	for r in range(height):
		for q in range(width):
			var point = Vector2(float(q)/width,float(r)/height)
			var warped = point + Vector2(noise.get_noise_2d(q,r),noise.get_noise_2d(q+90,r+31))*0.1
			var best = INF
			var biome = "temperate"
			for region in regions:
				var dist = warped.distance_squared_to(region[0])
				if dist < best:
					best = dist
					biome = region[1]
			var value = posmod(q*7919+r*104729+seed_value,101)
			var terrain = {"temperate":"plains","lush":"grassland","dry":"desert","cold":"tundra","fungal":"fungal"}[biome]
			if (q == 0 and r < 4) or (r == 0 and q < 3) or (q > width-4 and r > height-5):
				terrain = "water"
				biome = "coastal"
			var forest_chance = {"lush":65,"temperate":28,"cold":18,"dry":0,"fungal":22,"coastal":0}[biome]
			var bonus = ""
			if terrain != "water":
				if value < 11: bonus = "ore_seam" if value % 2 == 0 else ("oasis" if biome == "dry" else "edible_flora")
				elif value == 14: bonus = "geothermal_vent"
				elif value == 17: bonus = "alien_specimens"
				elif value == 20: bonus = "resonant_stones"
			var key = "%d,%d" % [q,r]
			tiles[key] = {"id":key,"q":q,"r":r,"baseTerrain":terrain,"biome":biome,
				"relief":"hills" if terrain != "water" and (value > 70 or bonus == "ore_seam" or bonus == "geothermal_vent") else "flat",
				"feature":"forest" if terrain != "water" and posmod(value*17,100) < forest_chance else null,"bonus":bonus}
	# Deliberate examples around the landing zone make every basic yield testable.
	for key in ["2,3","6,3","1,3","2,2","3,3","3,2","2,4","1,4","4,3","4,2"]:
		tiles[key].baseTerrain = "plains"
		tiles[key].biome = "temperate"
		tiles[key].relief = "flat"
		tiles[key].feature = null
		tiles[key].bonus = ""
	for entry in [["1,3","edible_flora"],["2,2","ore_seam"],["3,2","geothermal_vent"],["2,4","alien_specimens"],["1,4","resonant_stones"]]:
		tiles[entry[0]].bonus = entry[1]
	tiles["2,2"].relief = "hills"
	var rivers = []
	# A connected zigzag of shared edges, never a river occupying a tile.
	for r in range(2,height-2):
		var q = 9
		for pair in [["%d,%d" % [q,r],"%d,%d" % [q-1,r]], ["%d,%d" % [q,r],"%d,%d" % [q-1,r+1]]]:
			rivers.append(edge_key(pair[0],pair[1]))
	rivers.append(edge_key("3,3","3,2"))
	preload("res://scripts/terrain_layers.gd").initialise(tiles,true)
	return {"seed":seed_value,"width":width,"height":height,"tiles":tiles,"rivers":rivers}

static func edge_key(a: String,b: String) -> String:
	return a+"|"+b if a < b else b+"|"+a
