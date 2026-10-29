extends Node3D
## Shared pointy hex footprint. Decorative studies have no simulation effects.
const Parts = preload("res://scripts/model_parts.gd")
const KINDS = ["Plains", "Forest", "Hills", "Water", "Desert", "Fungal"]
const Atmosphere = preload("res://scripts/terrain_atmosphere.gd")
var kind = "Plains"
var variation = 0
var atmosphere

func _ready() -> void:
	build()

func stone(pos: Vector3, size: Vector3, color: Color) -> void:
	var points = [Vector3(0,1,0), Vector3(1,0,0), Vector3(0,0,1), Vector3(-1,0,0), Vector3(0,0,-1), Vector3(0,-0.2,0)]
	var indices = [0,2,1,0,3,2,0,4,3,0,1,4,5,1,2,5,2,3,5,3,4,5,4,1]
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in range(0,indices.size(),3):
		for corner in [2,1,0]: st.add_vertex(points[indices[face+corner]] * size)
	st.generate_normals()
	Parts.mesh(self, st.commit(), pos, color)

func build() -> void:
	var palette = {"Plains":"7b995e", "Forest":"567b58", "Hills":"929083", "Water":"448c9e", "Desert":"c7a16e", "Fungal":"7c718f"}
	var color = Color(palette[kind])
	Parts.cylinder(self, Vector3(0,-0.17,0), 1.0, 0.32, color.darkened(0.42), 6)
	# The cylinder's vertex ring is rotated to match the top's pointy footprint.
	get_child(0).rotation.y = PI / 6.0
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(6):
		var a = Vector3(cos(i*TAU/6.0), 0, sin(i*TAU/6.0))
		var b = Vector3(cos((i+1)*TAU/6.0), 0, sin((i+1)*TAU/6.0))
		var mid = (a+b)*0.5
		for triangle in [[Vector3.ZERO, b*0.52, a*0.52], [a*0.52,b*0.52,mid], [a*0.52,mid,a], [mid,b*0.52,b]]:
			st.set_color(color.lightened(float((i*3+triangle.size())%5)*0.023))
			for vertex in triangle: st.add_vertex(vertex)
	st.generate_normals()
	var surface = MeshInstance3D.new()
	surface.mesh = st.commit()
	var mat = Parts.material(color)
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	surface.material_override = mat
	add_child(surface)
	if kind == "Forest":
		for p in [Vector3(-0.42,0,-0.22),Vector3(0.23,0,-0.27),Vector3(0.10,0,0.37),Vector3(-0.46,0,0.39)]:
			Parts.cylinder(self,p+Vector3(0,0.17,0),0.055,0.34,Color("6b5948"))
			Parts.cylinder(self,p+Vector3(0,0.47,0),0.26,0.59,Color("31594d"),6,0)
			Parts.cylinder(self,p+Vector3(0,0.70,0),0.18,0.40,Color("4a7960"),6,0)
	elif kind == "Hills":
		stone(Vector3(-0.25,0,-0.17),Vector3(0.59,0.65,0.49),Color("838780"))
		stone(Vector3(0.30,0,0.28),Vector3(0.44,0.39,0.41),Color("acaa94"))
		stone(Vector3(0.50,0,-0.32),Vector3(0.20,0.21,0.22),Color("77796e"))
	elif kind == "Water":
		for i in range(6):
			var p = Vector3(-0.46+float(i%3)*0.37,0.012,-0.32+float(i/3)*0.55)
			Parts.box(self,p,Vector3(0.25,0.016,0.026),Color("86c4cd"))
	elif kind == "Desert":
		stone(Vector3(-0.29,0,-0.13),Vector3(0.55,0.16,0.45),Color("dfbb83"))
		stone(Vector3(0.28,0,0.24),Vector3(0.39,0.12,0.38),Color("b88c61"))
	elif kind == "Fungal":
		for i in range(7):
			var p = Vector3(cos(i*2.4)*0.56,0,sin(i*2.4)*0.52)
			var h = 0.22+float(i%3)*0.10
			Parts.cylinder(self,p+Vector3(0,h*0.5,0),0.045,h,Color("c9c5a2"))
			Parts.cylinder(self,p+Vector3(0,h,0),0.16,0.10,Color("aa7892") if i%2==0 else Color("82aba1"),6,0.07)
	else:
		for p in [Vector3(-0.45,0,0.25),Vector3(0.35,0,-0.30),Vector3(0.28,0,0.44)]:
			Parts.cylinder(self,p+Vector3(0,0.07,0),0.08,0.14,Color("b4b875"),5,0.02)
	# A second scale of detail breaks up the surface without turning the tile
	# into a collection of tiny objects. Everything stays inside the hex.
	for i in range(8):
		var p = Vector3(cos(i*2.4)*0.65,0.02,sin(i*2.4)*0.58)
		if kind in ["Plains", "Forest"]:
			for j in [-1,0,1]:
				var blade = Parts.box(self,p+Vector3(j*0.035,0.05,0),Vector3(0.025,0.10+float(i%3)*0.025,0.025),Color("829b62") if kind=="Forest" else Color("a1ad6c"))
				blade.rotation.z = j*0.3
		elif kind == "Hills":
			stone(p,Vector3(0.09,0.06+float(i%2)*0.04,0.10),Color("8b8f83"))
		elif kind == "Desert":
			stone(p,Vector3(0.08,0.045,0.06),Color("9c7959"))
		elif kind == "Fungal":
			Parts.cylinder(self,p,0.10,0.025,Color("a6b29a"),5)
	atmosphere = Atmosphere.new()
	add_child(atmosphere)
	atmosphere.setup(self,surface,color,kind,variation)
	# Grass/lichen clusters vary deterministically; no global game RNG used.
	if variation != 0:
		for node in get_children():
			if node is MeshInstance3D and node != surface and node.position.y > 0.01:
				node.rotation.y += float(variation%6)*TAU/6.0
