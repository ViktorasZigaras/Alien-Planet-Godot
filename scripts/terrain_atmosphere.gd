extends Node3D
## Bounded decorative sprites and shader clocks. No game-state dependency.
const SurfaceShader = preload("res://assets/shaders/terrain_surface.gdshader")
const FoliageShader = preload("res://assets/shaders/terrain_foliage.gdshader")
static var noise_texture: NoiseTexture2D
static var mote_texture: GradientTexture2D
var animated = true
var detail = true
var elapsed = 0.0
var surface_material: ShaderMaterial
var foliage_materials: Array = []
var motes: Array = []
var kind = "Plains"
var variation = 0

static func noise() -> NoiseTexture2D:
	if noise_texture == null:
		noise_texture = NoiseTexture2D.new()
		noise_texture.width = 128
		noise_texture.height = 128
		noise_texture.seamless = true
		var source = FastNoiseLite.new()
		source.seed = 1937
		source.frequency = 0.065
		source.fractal_octaves = 3
		noise_texture.noise = source
	return noise_texture

static func mote() -> GradientTexture2D:
	if mote_texture == null:
		mote_texture = GradientTexture2D.new()
		mote_texture.width = 24
		mote_texture.height = 24
		mote_texture.fill = GradientTexture2D.FILL_RADIAL
		mote_texture.fill_from = Vector2(0.5,0.5)
		mote_texture.fill_to = Vector2(1.0,0.5)
		var gradient = Gradient.new()
		gradient.set_color(0,Color(1,1,1,0.9))
		gradient.set_color(1,Color(1,1,1,0))
		mote_texture.gradient = gradient
	return mote_texture

func setup(tile: Node3D, surface: MeshInstance3D, color: Color, tile_kind: String, seed_value: int) -> void:
	kind = tile_kind
	variation = seed_value
	surface_material = ShaderMaterial.new()
	surface_material.shader = SurfaceShader
	surface_material.set_shader_parameter("ground_noise",noise())
	surface_material.set_shader_parameter("base_color",color.lightened(float(variation%3)*0.025))
	surface_material.set_shader_parameter("water",kind == "Water")
	surface_material.set_shader_parameter("variation",float(variation))
	surface.material_override = surface_material
	for node in tile.get_children():
		if not node is MeshInstance3D or node == surface or node.position.y <= 0.04: continue
		if kind not in ["Plains","Forest","Fungal"]: continue
		var mat = ShaderMaterial.new()
		mat.shader = FoliageShader
		mat.set_shader_parameter("base_color",node.material_override.albedo_color)
		mat.set_shader_parameter("phase",node.position.x*7.0+node.position.z*5.0+float(variation))
		mat.set_shader_parameter("half_height",maxf(0.01,node.mesh.get_aabb().size.y*0.5))
		mat.set_shader_parameter("amplitude",0.018 if kind=="Fungal" else 0.035)
		node.material_override = mat
		foliage_materials.append(mat)
	var amount = {"Plains":4,"Forest":4,"Hills":0,"Water":0,"Desert":4,"Fungal":7}[kind]
	for i in range(amount):
		var sprite = Sprite3D.new()
		sprite.texture = mote()
		sprite.pixel_size = 0.003 if kind=="Fungal" else 0.002
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.shaded = true
		sprite.no_depth_test = false
		sprite.modulate = {"Plains":Color("d9ca7d"),"Forest":Color("b1bf88"),"Desert":Color("d7b686"),"Fungal":Color("dcc5db")}[kind]
		add_child(sprite)
		motes.append(sprite)
	apply_time()

func set_detail(value: bool) -> void:
	detail = value
	surface_material.set_shader_parameter("detail_amount",1.0 if detail else 0.0)
	for sprite in motes: sprite.visible = detail

func _process(delta: float) -> void:
	if animated:
		elapsed += delta
		apply_time()

func apply_time() -> void:
	if surface_material == null: return
	surface_material.set_shader_parameter("clock",elapsed)
	for mat in foliage_materials: mat.set_shader_parameter("clock",elapsed)
	for i in range(motes.size()):
		var t = elapsed*0.18+float(i)*0.37+float(variation)*0.13
		motes[i].position = Vector3(sin(t*2.7+float(i))*0.65,0.20+fmod(t+float(i)*0.16,0.65),cos(t*2.1+float(i)*2.4)*0.55)
		motes[i].modulate.a = 0.28+0.25*(sin(t*7.0+float(i))+1.0)
