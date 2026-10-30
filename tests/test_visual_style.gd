extends SceneTree
const Style = preload("res://scripts/visual_style.gd")
const R = preload("res://scripts/game_rules.gd")
var checks = 0
var failures = []
func check(value: bool,label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize() -> void:
	var before = R.initial_state()
	for kind in Style.SPRITE_TERRAIN:
		for variation in range(4):
			var texture = Style.ground_texture(kind,variation)
			check(texture is AtlasTexture and texture.get_width() == 80 and texture.get_height() == 80,"Prebaked ground: "+kind+str(variation))
			check(texture == Style.ground_texture(kind,variation),"Ground resource reused")
	check(Style.SPRITE_TERRAIN.plains != Style.WORLD_TERRAIN.plains,"Companion palettes differ")
	check(Color(Style.SPRITE_TERRAIN.plains).r > Color(Style.SPRITE_TERRAIN.plains).g,"Rust plains")
	check(Style.DISTRICT_ACCENTS.size() == 5,"Consistent district accents")
	var source = Image.create(5,5,false,Image.FORMAT_RGBA8)
	source.fill(Color.TRANSPARENT)
	source.set_pixel(2,2,Color(0.73,0.68,0.52,1))
	var result = Style.sprite_finish(source)
	check(result.get_pixel(2,2).a == 1 and result.get_pixel(1,2).a > 0,"Sprite contour")
	check(result.get_pixel(0,0).a == 0,"Transparent margin retained")
	check(source.get_pixel(1,2).a == 0,"Sprite finish preserves source")
	check(JSON.stringify(before) == JSON.stringify(R.initial_state()),"Style generation never changes simulation")
	print("VISUAL STYLE CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
