class_name WorldAssets
extends RefCounted
## Small readable shared geometry. Used by the live world and pixel sprite bake.
const P = preload("res://scripts/model_parts.gd")
const Rig = preload("res://scripts/population_rig.gd")
const Rover = preload("res://scripts/rover_rig.gd")
const Motion = preload("res://assets/shaders/world_motion.gdshader")
const TERRAIN = {"plains":"809657","grassland":"6f994f","desert":"c5a16a","tundra":"aebabc","fungal":"8c739e","water":"407d9a"}
const DISTRICTS = {"production":"ce9d55","agriculture":"91b966","research":"71bfc7","civic":"bb83b6","security":"9da9b4"}
static var motion_materials: Dictionary = {}
static var hex_mesh: Mesh
static func moving(color: Color,water: bool = false) -> ShaderMaterial:
	var key = color.to_html()+str(water)
	if not motion_materials.has(key):
		var mat = ShaderMaterial.new()
		mat.shader = Motion
		mat.set_shader_parameter("base_color",color)
		mat.set_shader_parameter("water",water)
		motion_materials[key] = mat
	return motion_materials[key]
static func hexagon(parent: Node3D,radius: float,color: Color,y: float = 0) -> MeshInstance3D:
	if hex_mesh == null:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(6):
			var a = deg_to_rad(30+i*60)
			var b = deg_to_rad(30+(i+1)*60)
			st.set_normal(Vector3.UP)
			for v in [Vector3.ZERO,Vector3(cos(b),0,sin(b)),Vector3(cos(a),0,sin(a))]: st.add_vertex(v)
		hex_mesh = st.commit()
	var n = P.mesh(parent,hex_mesh,Vector3(0,y,0),color)
	n.material_override = P.material(color,true)
	n.scale = Vector3(radius,1,radius)
	return n
static func tree(parent: Node3D,pos: Vector3,color: Color) -> void:
	P.cylinder(parent,pos+Vector3(0,0.18,0),0.045,0.36,Color("705b45"))
	var leaf = P.cylinder(parent,pos+Vector3(0,0.49,0),0.24,0.65,color,6,0)
	leaf.material_override = moving(color)
static func terrain(t: Dictionary) -> Node3D:
	var root = Node3D.new()
	var color = Color(TERRAIN[t.baseTerrain])
	var base = hexagon(root,0.993,color)
	if t.baseTerrain == "water":
		base.material_override = moving(color,true)
		return root
	for i in range(3):
		var pos = Vector3(cos(i*2.4)*0.72,0.01,sin(i*2.4)*0.65)
		if t.baseTerrain == "fungal":
			P.cylinder(root,pos+Vector3(0,0.12,0),0.035,0.24,Color("cfcaac"))
			var cap = P.cylinder(root,pos+Vector3(0,0.26,0),0.14,0.08,Color("b68baf"),6,0.06)
			cap.material_override = moving(Color("b68baf"))
		else: P.box(root,pos,Vector3(0.12,0.03,0.10),color.lightened(0.08))
	if t.relief == "hills":
		P.cylinder(root,Vector3(0.46,0.13,-0.40),0.32,0.25,color.lightened(0.13),6,0.12)
		P.cylinder(root,Vector3(-0.4,0.10,-0.45),0.20,0.20,color.darkened(0.10),5,0.10)
	if t.feature == "forest":
		for pos in [Vector3(-0.53,0,-0.24),Vector3(0.40,0,-0.38),Vector3(0.48,0,0.32)]: tree(root,pos,Color("3e6a4e"))
	return root
static func district(kind: String) -> Node3D:
	var root = Node3D.new()
	hexagon(root,0.57,Color(DISTRICTS[kind]).darkened(0.35),0.025)
	for x in [-0.4,0.4]: P.box(root,Vector3(x,0.045,0.10),Vector3(0.04,0.04,0.50),Color(DISTRICTS[kind]))
	return root
static func building(kind: String,tier: int = 1) -> Node3D:
	var root = Node3D.new()
	var colors = {"lab":"8ac2c9","civic":"bb88bb","training":"b3a68b","workshop":"c7a06e","greenhouse":"87bd90","clinic":"d7d6c6","research_lab":"81b7cb","exchange":"b582ab","atelier":"d09ba5","guard_post":"91a2af","generator":"d3b45e"}
	var color = Color(colors.get(kind,"b4b6ab"))
	P.softened(root,Vector3(0,0.18,0),Vector3(0.63,0.34,0.53),color)
	P.box(root,Vector3(0,0.12,0.285),Vector3(0.12,0.22,0.025),Color("3a5967"))
	for side in [-1,1]: P.box(root,Vector3(side*0.21,0.22,0.28),Vector3(0.12,0.10,0.02),Color("a7d4d4"))
	match kind:
		"greenhouse":
			P.cylinder(root,Vector3(0,0.38,0),0.33,0.16,Color("86bab3"),8,0.24)
			for x in [-0.2,0,0.2]: P.box(root,Vector3(x,0.47,0),Vector3(0.025,0.04,0.43),Color("d4dfc1"))
		"clinic":
			P.box(root,Vector3(0,0.37,0),Vector3(0.33,0.04,0.10),Color("cb655a"))
			P.box(root,Vector3(0,0.375,0),Vector3(0.10,0.04,0.33),Color("cb655a"))
		"research_lab","lab":
			P.cylinder(root,Vector3(0,0.41,0),0.23,0.22,Color("abc9d1"),8,0.10)
			P.cylinder(root,Vector3(0.24,0.58,-0.15),0.025,0.55,Color("d6d6bd"))
		"workshop":
			P.cylinder(root,Vector3(-0.2,0.54,-0.1),0.08,0.49,Color("79858a"))
			P.box(root,Vector3(0.20,0.40,0),Vector3(0.18,0.12,0.34),Color("c3bda2"))
		"generator":
			for x in [-0.19,0.19]: P.cylinder(root,Vector3(x,0.47,0),0.13,0.30,Color("9db2b5"),8)
			P.box(root,Vector3(0,0.65,0),Vector3(0.09,0.17,0.08),Color("f1d374"))
		"guard_post":
			P.box(root,Vector3(0,0.48,0),Vector3(0.44,0.23,0.34),Color("c3cabd"))
			P.box(root,Vector3(0,0.62,0),Vector3(0.59,0.05,0.49),color.darkened(0.2))
		"exchange","civic":
			P.cylinder(root,Vector3(0.26,0.58,0),0.018,0.65,Color("e1d6b3"))
			P.box(root,Vector3(0.36,0.80,0),Vector3(0.22,0.13,0.02),Color("b56b99"))
		"atelier":
			P.cylinder(root,Vector3(-0.15,0.46,0),0.11,0.28,Color("cc9365"),6)
			P.box(root,Vector3(0.18,0.46,0),Vector3(0.17,0.25,0.06),Color("d7c58b"))
		"training": P.cylinder(root,Vector3(0,0.42,0),0.18,0.14,Color("7b9289"),8)
	if tier == 2:
		P.box(root,Vector3(-0.38,0.14,0),Vector3(0.18,0.26,0.44),color.darkened(0.1))
		P.box(root,Vector3(0,0.68,-0.14),Vector3(0.24,0.05,0.08),Color("e6d38e"))
	return root
static func settlement(main: bool = true) -> Node3D:
	var root = Node3D.new()
	hexagon(root,0.62,Color("657981"),0.03)
	for i in range(3 if main else 2):
		var b = building(["training","lab","civic"][i])
		b.scale = Vector3.ONE*0.57
		b.position = Vector3(-0.30+i*0.28,0.04,-0.15+0.1*(i%2))
		root.add_child(b)
	P.cylinder(root,Vector3(-0.38,0.43,-0.26),0.018,0.82,Color("d5d1b4"))
	P.box(root,Vector3(-0.27,0.77,-0.26),Vector3(0.23,0.16,0.015),Color("ce9e56"))
	return root
static func improvement(kind: String) -> Node3D:
	var root = Node3D.new()
	match kind:
		"road": P.box(root,Vector3(0,0.015,0),Vector3(0.9,0.02,0.14),Color("b7a68b"))
		"farm","fungal_garden":
			P.box(root,Vector3(0,0.02,0),Vector3(0.83,0.03,0.65),Color("746044"))
			for i in range(4):
				P.box(root,Vector3(-0.30+i*0.20,0.07,0),Vector3(0.08,0.07,0.60),Color("9eb76a") if kind == "farm" else Color("bb8eaa"))
		"mine":
			P.box(root,Vector3(0,0.13,-0.1),Vector3(0.65,0.25,0.24),Color("877660"))
			P.box(root,Vector3(0,0.12,0.03),Vector3(0.24,0.22,0.04),Color("35434b"))
			P.box(root,Vector3(0,0.03,0.40),Vector3(0.12,0.03,0.46),Color("8f9a9c"))
		"survey_beacon","watchtower":
			for x in [-0.17,0.17]: P.box(root,Vector3(x,0.37,0),Vector3(0.04,0.74,0.05),Color("9fada9"))
			P.box(root,Vector3(0,0.72,0),Vector3(0.49,0.07,0.32),Color("e1c680"))
			if kind == "survey_beacon": P.cylinder(root,Vector3(0,0.91,0),0.11,0.27,Color("7fc9d1"),8,0.025)
		"energy_tap":
			P.cylinder(root,Vector3(0,0.16,0),0.17,0.32,Color("b4a885"))
			for side in [-1,1]:
				var panel = P.box(root,Vector3(side*0.32,0.34,0),Vector3(0.40,0.04,0.46),Color("648fa3"))
				panel.rotation.z = side*0.25
		"trade_post","field_camp":
			for x in [-0.29,0.29]: P.cylinder(root,Vector3(x,0.21,0),0.024,0.42,Color("b8ac8c"))
			P.softened(root,Vector3(0,0.45,0),Vector3(0.74,0.14,0.48),Color("a67496") if kind == "trade_post" else Color("889b69"))
			P.box(root,Vector3(0,0.09,0.06),Vector3(0.42,0.16,0.24),Color("b3a783"))
	return root
static func bonus(kind: String) -> Node3D:
	var root = Node3D.new()
	match kind:
		"edible_flora","oasis":
			for i in range(3):
				var p = Vector3(-0.14+i*0.14,0.08,0)
				P.cylinder(root,p,0.045,0.16,Color("719653"))
				P.cylinder(root,p+Vector3(0,0.12,0),0.10,0.13,Color("dbb36b"),5,0.025)
		"ore_seam":
			for i in range(3): P.cylinder(root,Vector3(-0.14+i*0.14,0.1,0),0.12,0.18+0.07*(i%2),Color("a8b6b8"),5,0.055)
		"geothermal_vent":
			P.cylinder(root,Vector3(0,0.05,0),0.23,0.10,Color("a89679"),6,0.14)
			P.cylinder(root,Vector3(0,0.11,0),0.10,0.07,Color("e3c76b"),6)
		"alien_specimens":
			for i in range(3): P.cylinder(root,Vector3(-0.12+i*0.12,0.17,0),0.085,0.34,Color("7bc5bd"),5,0.01)
		"resonant_stones":
			for i in [-1,1]: P.box(root,Vector3(i*0.13,0.22,0),Vector3(0.13,0.44,0.15),Color("b08fbf"))
	return root
static func person(c: Dictionary) -> Node3D:
	if "rover" in c.equipment: return Rover.new()
	var rig = Rig.new()
	rig.role = c.qualification
	rig.work_suit = "work_suit" in c.equipment
	rig.reinforced = "reinforced_suit" in c.equipment
	rig.small_arms = "small_arms" in c.equipment
	return rig
