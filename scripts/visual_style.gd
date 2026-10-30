class_name PlanetVisualStyle
extends RefCounted
## Approved A/B visual contract. Presentation only; never used by game rules.
const SPRITE_TERRAIN = {"plains":"925e48","grassland":"727b51","desert":"c39b57","tundra":"949d9f","fungal":"8f599c","water":"155367"}
const WORLD_TERRAIN = {"plains":"95634d","grassland":"77805a","desert":"c4a06a","tundra":"a6b1ad","fungal":"8e719e","water":"286d7d"}
const GROUND_COVER = {"plains":"9b8766","grassland":"929879","desert":"d1b682","tundra":"c6c9ba","fungal":"b18eab","water":"3e9d9e"}
const DISTRICT_ACCENTS = {"production":"d7a14a","agriculture":"9ab75c","research":"79bdc5","civic":"b988ba","security":"9dabb7"}
const SPRITE_GRID = Color("533d37")
const SELECTION = Color("ffe2a1")
static var ground_textures: Dictionary = {}
static var ground_atlas: Texture2D
static var painted_ground: Image
static func ground_texture(kind: String,variant: int = 0) -> Texture2D:
	var key = kind+str(posmod(variant,4))
	if ground_textures.has(key): return ground_textures[key]
	if FileAccess.file_exists("res://assets/world/symbolic_ground.png"):
		if ground_atlas == null: ground_atlas = load("res://assets/world/symbolic_ground.png")
		var region = AtlasTexture.new()
		region.atlas = ground_atlas
		region.region = Rect2(SPRITE_TERRAIN.keys().find(kind)*80,posmod(variant,4)*80,80,80)
		ground_textures[key] = region
		return region
	return procedural_ground(kind,variant)
static func procedural_ground(kind: String,variant: int = 0) -> Texture2D:
	var image = Image.create(80,80,false,Image.FORMAT_RGBA8)
	var noise = FastNoiseLite.new()
	noise.seed = 381+posmod(variant,4)*31
	noise.frequency = 0.027
	noise.fractal_octaves = 2
	if painted_ground == null and FileAccess.file_exists("res://assets/world/frontier_ground.png"):
		painted_ground = load("res://assets/world/frontier_ground.png").get_image()
	var soil = Color(SPRITE_TERRAIN[kind])
	var cover = Color(GROUND_COVER[kind])
	for y in range(80):
		for x in range(80):
			var patch = noise.get_noise_2d(x,y)
			var grain = posmod(x*73+y*29+x*y*7,17)
			var color = soil
			if kind == "water":
				var wave = posmod(y+int(sin(x*0.12)*2),13)
				color = soil.lightened(0.12 if wave < 2 else 0.025 if grain < 4 else 0.0)
			else:
				color = soil.lerp(cover,clampf((patch+0.25)*0.45,0,0.30))
				if patch < -0.32: color = color.darkened(0.055)
				if grain < 2: color = color.lightened(0.035)
				elif grain > 15: color = color.darkened(0.035)
			if painted_ground != null and kind != "water":
				var sample = painted_ground.get_pixel(posmod(x*4+variant*71,384),posmod(y*4+variant*53,384)).r
				color *= 0.86+sample*0.30
			# Restrained palette steps keep A deliberately symbolic at every map zoom.
			color.r = roundf(color.r*32)/32
			color.g = roundf(color.g*32)/32
			color.b = roundf(color.b*32)/32
			image.set_pixel(x,y,color)
	return ImageTexture.create_from_image(image)
static func sprite_finish(source: Image, outline: bool = true) -> Image:
	var result = source.duplicate()
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var color = source.get_pixel(x,y)
			if color.a < 0.2:
				var edge = false
				for step in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
					var at = Vector2i(x,y)+step
					if at.x >= 0 and at.y >= 0 and at.x < source.get_width() and at.y < source.get_height() and source.get_pixelv(at).a > 0.8: edge = true
				result.set_pixel(x,y,Color(0.10,0.15,0.17,0.8) if edge and outline else Color.TRANSPARENT)
			else:
				color.r = roundf(color.r*32)/32
				color.g = roundf(color.g*32)/32
				color.b = roundf(color.b*32)/32
				color.a = 1
				result.set_pixel(x,y,color)
	return result
