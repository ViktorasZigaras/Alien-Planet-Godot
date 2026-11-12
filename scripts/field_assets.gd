extends RefCounted

const A = preload("res://scripts/world_assets.gd")
const P = preload("res://scripts/model_parts.gd")
const FRAME = Color("#a59e81")
const SOIL = Color("#685342")
const CROPS = [Color("#84974c"),Color("#a3ad58"),Color("#738e54")]
const FITTINGS = Color("#5e8587")

static func pipe(parent: Node3D, start: Vector3, finish: Vector3) -> void:
	var segment = P.box(parent,(start+finish)*0.5,Vector3(0.037,0.037,start.distance_to(finish)+0.035),FITTINGS)
	segment.basis = Basis.looking_at(finish-start)

static func farm(service: bool = true) -> Node3D:
	var root = Node3D.new()
	P.box(root,Vector3(-0.08,0.035,0),Vector3(1.04,0.07,0.78),FRAME)
	for row in range(3):
		var x = -0.44+row*0.29
		P.box(root,Vector3(x,0.081,0),Vector3(0.24,0.055,0.67),SOIL)
		for leaf in range(5):
			var height = 0.12+0.02*((row+leaf)%3)
			P.oval(root,Vector3(x+0.035*(leaf%2),height,-0.25+leaf*0.125),Vector3(0.14,0.09,0.13),CROPS[(row+leaf)%3])
	if service:
		P.box(root,Vector3(0.36,0.07,-0.02),Vector3(0.40,0.11,0.53),Color("#8b8068"))
		P.cylinder(root,Vector3(0.41,0.24,-0.09),0.138,0.33,FITTINGS,10)
		P.cylinder(root,Vector3(0.41,0.42,-0.09),0.105,0.052,FRAME,10)
		P.box(root,Vector3(0.35,0.15,0.16),Vector3(0.21,0.15,0.16),Color("#bf8c52"))
		pipe(root,Vector3(0.40,0.15,0.22),Vector3(0.40,0.15,0.36))
		pipe(root,Vector3(0.40,0.15,0.36),Vector3(-0.44,0.15,0.36))
		for row in range(3):
			var x = -0.44+row*0.29
			pipe(root,Vector3(x,0.15,0.36),Vector3(x,0.15,0.24))
	return root

static func ground_style(tile: Dictionary) -> String:
	if tile.baseTerrain == "water": return ""
	if tile.biome == "coastal": return "coast"
	if tile.relief == "hills": return "hills"
	if tile.vegetation or tile.feature == "forest": return "vegetation"
	return ""

static func ground(style: String, tile: Dictionary, position: Vector3 = Vector3.ZERO) -> Node3D:
	var root = Node3D.new()
	root.position = position
	var variant = posmod(hash(tile.get("id","preview")),6)
	for i in range(3):
		var angle = (variant*0.96)+i*0.24
		var point = Vector3(cos(angle)*0.65,0,sin(angle)*0.65)
		point.y = A.height_at(tile,point.x,point.z)
		match style:
			"coast":
				P.oval(root,point+Vector3.UP*0.028,Vector3(0.18,0.055,0.106),Color("#a59e7b"))
			"hills":
				var rock = P.cylinder(root,point+Vector3.UP*0.056,0.075+i*0.016,0.105,Color("#92806a"),5,0.052)
				rock.rotation.z = 0.25+i*0.17
			"vegetation":
				var color = Color("#9a749a") if tile.biome == "fungal" else Color("#889553")
				var leaf = P.oval(root,point+Vector3.UP*0.074,Vector3(0.09,0.16,0.05),color)
				leaf.rotation.z = -0.45+i*0.45
	return root

static func study(style: String) -> Node3D:
	var tile = {"baseTerrain":"plains","biome":"coastal" if style == "coast" else "temperate",
		"relief":"hills" if style == "hills" else "flat","feature":null}
	var root = A.terrain(tile)
	root.add_child(ground(style,tile))
	return root
