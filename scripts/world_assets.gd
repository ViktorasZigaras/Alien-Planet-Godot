class_name WorldAssets
extends RefCounted
## Small readable shared geometry. Used by the live world and pixel sprite bake.
const Style = preload("res://scripts/visual_style.gd")
const Ground = preload("res://assets/shaders/world_ground.gdshader")
const Atmosphere = preload("res://scripts/terrain_atmosphere.gd")
const P = preload("res://scripts/model_parts.gd")
const Rig = preload("res://scripts/population_rig.gd")
const Rover = preload("res://scripts/rover_rig.gd")
const Motion = preload("res://assets/shaders/world_motion.gdshader")
const TERRAIN = Style.WORLD_TERRAIN
const DISTRICTS = Style.DISTRICT_ACCENTS
static var ground_materials: Dictionary = {}
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
static func ground(kind: String) -> ShaderMaterial:
	if not ground_materials.has(kind):
		var mat = ShaderMaterial.new()
		mat.shader = Ground
		mat.set_shader_parameter("soil",Color(TERRAIN[kind]))
		mat.set_shader_parameter("cover",Color(Style.GROUND_COVER[kind]))
		mat.set_shader_parameter("ground_noise",Atmosphere.noise())
		mat.set_shader_parameter("painted_detail",load("res://assets/world/frontier_ground.png"))
		ground_materials[kind] = mat
	return ground_materials[kind]
static func rock(parent: Node3D,position: Vector3,size: Vector3,color: Color) -> void:
	var key = "style_b_rock"
	if not P.shapes.has(key):
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var peak = Vector3(-0.15,0.95,0.08)
		for i in range(8):
			var a = float(i)*TAU/8
			var b = float(i+1)*TAU/8
			var radii = [0.90,1.12,0.80,1.0,0.87,1.05,0.75,0.95]
			var points = [peak,Vector3(cos(b),0,sin(b))*radii[(i+1)%8],Vector3(cos(a),0,sin(a))*radii[i]]
			var normal = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
			if normal.y < 0: normal = -normal
			st.set_normal(normal)
			for vertex in points: st.add_vertex(vertex)
		P.shapes[key] = st.commit()
	var node = P.mesh(parent,P.shapes[key],position,color)
	node.material_override = P.material(color,true)
	node.scale = size
static func height_at(t: Dictionary, x: float, z: float) -> float:
	if t.get("relief", "flat") != "hills" or t.baseTerrain == "water": return 0.0
	# Distance to the hex boundary, not a separate boulder on a flat floor.
	var edge = Vector2(x,z).length()/0.86
	var shoulder = maxf(0.0,1.0-edge*edge)
	return 0.68*shoulder*shoulder*(1.0+0.24*sin(x*4.0+z*3.0))
static func land_mesh(hills: bool, hill_only: bool = false) -> Mesh:
	var key = "frontier_land_"+str([hills,hill_only])
	if P.shapes.has(key): return P.shapes[key]
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var t = {"baseTerrain":"plains","relief":"hills" if hills else "flat"}
	# 6 sectors, 6 radial bands; edge samples align between every hex.
	var bands = 6 if hills else 1
	var segments = 36 if hills else 6
	for ring in range(bands):
		for side in range(segments):
			var a = float(side)*6.0/segments
			var b = float(side+1)*6.0/segments
			var points = []
			for at in [Vector2(a,float(ring)/bands),Vector2(b,float(ring)/bands),Vector2(b,float(ring+1)/bands),Vector2(a,float(ring+1)/bands)]:
				var corner = floori(at.x)%6
				var u = at.x-floorf(at.x)
				var aa = deg_to_rad(30+corner*60)
				var bb = aa+PI/3
				var edge = Vector2(cos(aa),sin(aa)).lerp(Vector2(cos(bb),sin(bb)),u)*0.997*at.y
				if hill_only:
					var angle = deg_to_rad(30+at.x*60)
					edge = Vector2(cos(angle),sin(angle))*0.855*at.y
				points.append(Vector3(edge.x,height_at(t,edge.x,edge.y),edge.y))
			for indices in [[0,2,1],[0,3,2]]:
				for index in indices:
					var v = points[index]
					var dx = (height_at(t,v.x+0.003,v.z)-height_at(t,v.x-0.003,v.z))/0.006
					var dz = (height_at(t,v.x,v.z+0.003)-height_at(t,v.x,v.z-0.003))/0.006
					st.set_normal(Vector3(-dx,1,-dz).normalized())
					st.set_uv(Vector2(v.x,v.z))
					st.add_vertex(v)
	P.shapes[key] = st.commit()
	return P.shapes[key]
static func hill_sprite(kind: String) -> Node3D:
	var root = Node3D.new()
	var mesh = P.mesh(root,land_mesh(true,true),Vector3.ZERO,Color(TERRAIN[kind]))
	mesh.material_override = ground(kind)
	return root
static func tree(parent: Node3D,pos: Vector3,color: Color) -> void:
	P.cylinder(parent,pos+Vector3(0,0.24,0),0.035,0.48,Color("665746"),7)
	for i in range(4):
		var offset = Vector3(cos(i*2.4)*0.13,0.43+i*0.095,sin(i*2.4)*0.13)
		var leaf = P.oval(parent,pos+offset,Vector3(0.39-i*0.035,0.38,0.36-i*0.03),color.lightened(i*0.035))
		leaf.material_override = moving(color.lightened(i*0.035))
static func terrain(t: Dictionary) -> Node3D:
	var root = Node3D.new()
	var color = Color(TERRAIN[t.baseTerrain])
	var base = P.mesh(root,land_mesh(t.get("relief", "flat") == "hills"),Vector3.ZERO,color)
	base.material_override = moving(color,true) if t.baseTerrain == "water" else ground(t.baseTerrain)
	if t.baseTerrain == "water": return root
	if t.feature == "forest":
		for i in range(5):
			var pos = Vector3(cos(i*2.4)*0.55,0,sin(i*2.4)*0.49)
			pos.y = height_at(t,pos.x,pos.z)
			tree(root,pos,Color("34594b") if t.baseTerrain != "fungal" else Color("63516b"))
	elif t.baseTerrain == "fungal":
		for i in range(3):
			var pos = Vector3(cos(i*2.4)*0.70,0,sin(i*2.4)*0.65)
			pos.y = height_at(t,pos.x,pos.z)
			P.cylinder(root,pos+Vector3(0,0.12,0),0.025,0.24,Color("bcb99b"))
			P.oval(root,pos+Vector3(0,0.25,0),Vector3(0.25,0.09,0.23),Color("a984a2"))
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
	P.softened(root,Vector3(0,0.18,0),Vector3(0.63,0.34,0.53),Color("ccd0bf").lerp(color,0.18))
	P.box(root,Vector3(0,0.04,0),Vector3(0.66,0.06,0.56),Color("465c65"))
	P.box(root,Vector3(0,0.32,0.27),Vector3(0.60,0.04,0.025),color)
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
	# The settlement's focal hab-spine is distinct from the low district workplaces.
	P.softened(root,Vector3(0,0.43,-0.24),Vector3(0.25,0.78,0.24),Color("d4cfb5"))
	P.box(root,Vector3(0,0.43,-0.10),Vector3(0.07,0.62,0.025),Color("516f7a"))
	P.cylinder(root,Vector3(0,0.89,-0.24),0.13,0.20,Color("d5b56e"),8,0.045)
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
			P.cylinder(root,Vector3(0,0.22,0),0.04,0.44,Color("6e6944"),7)
			for i in range(5):
				var a = i*TAU/5
				var leaf = P.oval(root,Vector3(cos(a)*0.16,0.36,sin(a)*0.15),Vector3(0.16,0.12,0.44),Color("55784a").lightened(i*0.025))
				leaf.rotation.y = -a+PI/2
				P.oval(root,Vector3(cos(a)*0.18,0.26,sin(a)*0.16),Vector3(0.13,0.17,0.13),Color("dca844"))
		"ore_seam":
			for i in range(4):
				var pos = Vector3(-0.20+i*0.12,0,(i%2)*0.13-0.06)
				rock(root,pos,Vector3(0.18,0.23+(i%2)*0.16,0.22),Color("606c71").lightened(i*0.035))
				rock(root,pos+Vector3(0,0.06,0.07),Vector3(0.07,0.17,0.08),Color("c29452"))
		"geothermal_vent":
			for i in range(6):
				var a = i*TAU/6
				rock(root,Vector3(cos(a)*0.18,0,sin(a)*0.18),Vector3(0.15,0.22,0.15),Color("756e62"))
			P.cylinder(root,Vector3(0,0.06,0),0.12,0.08,Color("e4ac4e"),10)
			for i in range(2):
				var wisp = P.oval(root,Vector3(i*0.035,0.22+i*0.14,0),Vector3(0.13,0.15,0.12),Color("bfbba2").darkened(i*0.05))
				wisp.material_override = moving(Color("bfbba2").darkened(i*0.05))
		"alien_specimens":
			for i in range(4):
				var pos = Vector3(-0.18+i*0.115,0.18+(i%2)*0.09,(i%2)*0.13)
				var crystal = P.cylinder(root,pos,0.085,0.36+(i%2)*0.18,Color("65b4be").lightened(i*0.04),5,0)
				crystal.rotation.z = (i-1.5)*0.16
		"resonant_stones":
			P.softened(root,Vector3(0,0.29,0),Vector3(0.25,0.58,0.20),Color("896e97"))
			P.softened(root,Vector3(0.21,0.16,0.07),Vector3(0.14,0.32,0.16),Color("a28ca6"))
			for y in [0.19,0.30,0.41]: P.box(root,Vector3(0,y,0.107),Vector3(0.15,0.025,0.014),Color("d3b5cb"))
	return root
static func person(c: Dictionary) -> Node3D:
	if "rover" in c.equipment: return Rover.new()
	var rig = Rig.new()
	rig.role = c.qualification
	rig.work_suit = "work_suit" in c.equipment
	rig.reinforced = "reinforced_suit" in c.equipment
	rig.small_arms = "small_arms" in c.equipment
	return rig
