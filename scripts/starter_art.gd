class_name StarterArt
extends RefCounted
## Original generated roster, unchanged. Small text chunks avoid upload limits.
## Export filters include the .txt files, so editor and exported game agree.
const CROPS = {
	"district_production": Rect2(936, 218, 115, 100),
	"district_agriculture": Rect2(1293, 74, 111, 110),
	"district_research": Rect2(1170, 218, 120, 100),
	"district_civic": Rect2(1400, 218, 115, 100),
	"district_security": Rect2(1166, 402, 123, 111),
	"improvement_mine": Rect2(1401, 76, 111, 109),
	"improvement_survey_beacon": Rect2(529, 886, 95, 90),
	"improvement_trade_post": Rect2(842, 886, 100, 90),
	"improvement_watchtower": Rect2(744, 886, 92, 90),
	"terrain_plains": Rect2(26, 675, 88, 100),
	"terrain_forest": Rect2(126, 675, 88, 100),
	"terrain_hills": Rect2(326, 675, 88, 100),
	"terrain_water": Rect2(826, 675, 88, 100),
	"food": Rect2(982, 895, 65, 72),
	"industry": Rect2(1062, 896, 65, 70),
	"Worker": Rect2(20, 468, 80, 100),
	"Specialist": Rect2(370, 468, 80, 100),
	"Administrator": Rect2(550, 468, 90, 100),
	"rover": Rect2(530, 88, 100, 80),
	"main": Rect2(1040, 76, 125, 102),
	"field": Rect2(1170, 218, 120, 100),
	"district": Rect2(936, 218, 115, 100)
}
static var texture: Texture2D
static var population_texture: Texture2D
static var population_regions: Dictionary = {}
static var population_icons: Dictionary = {}

static func roster() -> Texture2D:
	if texture != null:
		return texture
	var encoded = ""
	for i in range(28):
		var path = "res://assets/roster-base64/%03d.txt" % i
		if not FileAccess.file_exists(path):
			push_warning("Starter art missing; map will use fallback markers.")
			return null
		encoded += FileAccess.get_file_as_string(path)
	var image = Image.new()
	if image.load_png_from_buffer(Marshalls.base64_to_raw(encoded)) != OK:
		push_warning("Starter art could not be decoded.")
		return null
	texture = ImageTexture.create_from_image(image)
	return texture

static func icon(key: String) -> Texture2D:
	if population_regions.is_empty(): population_regions = JSON.parse_string(FileAccess.get_file_as_string("res://data/population_sprites.json"))
	if population_regions.has(key):
		if population_icons.has(key): return population_icons[key]
		if population_texture == null: population_texture = load("res://assets/population/population_roles_v1.png")
		var region = population_regions[key]
		var portrait = AtlasTexture.new()
		portrait.atlas = population_texture
		portrait.region = Rect2(region[0],region[1],region[2],region[3])
		population_icons[key] = portrait
		return portrait
	var source = roster()
	if source == null:
		return null
	var atlas = AtlasTexture.new()
	atlas.atlas = source
	atlas.region = CROPS.get(key, CROPS.Worker)
	return atlas

static var resource_cache: Dictionary = {}

static func resource_icon(key: String) -> Texture2D:
	if resource_cache.has(key):
		return resource_cache[key]
	var result: Texture2D
	if key in ["food", "industry"]:
		result = icon(key)
	else:
		result = load("res://assets/icons/%s.svg" % key)
	resource_cache[key] = result
	return result
