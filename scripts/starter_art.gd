class_name StarterArt
extends RefCounted
## Original generated roster, unchanged. Small text chunks avoid upload limits.
## Export filters include the .txt files, so editor and exported game agree.
const CROPS = {
	"Worker": Rect2(20, 468, 80, 100),
	"Specialist": Rect2(370, 468, 80, 100),
	"Administrator": Rect2(550, 468, 90, 100),
	"rover": Rect2(530, 88, 100, 80),
	"main": Rect2(1040, 76, 125, 102),
	"field": Rect2(1170, 218, 120, 100),
	"district": Rect2(936, 218, 115, 100)
}
static var texture: Texture2D

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
	var source = roster()
	if source == null:
		return null
	var atlas = AtlasTexture.new()
	atlas.atlas = source
	atlas.region = CROPS.get(key, CROPS.Worker)
	return atlas
