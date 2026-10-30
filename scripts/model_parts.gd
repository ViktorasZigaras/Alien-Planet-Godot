extends RefCounted
## Small code-native mesh helpers shared by the model studies.

static var materials: Dictionary = {}
static var shapes: Dictionary = {}

static func material(color: Color, double_sided: bool = false) -> StandardMaterial3D:
	var key = color.to_html()+str(double_sided)
	if materials.has(key): return materials[key]
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if double_sided: mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	materials[key] = mat
	return mat

static func mesh(parent: Node3D, shape: Mesh, position: Vector3, color: Color) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	node.mesh = shape
	node.position = position
	node.material_override = material(color)
	parent.add_child(node)
	return node

static func box(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var key = "box"+str(size)
	if shapes.has(key): return mesh(parent,shapes[key],position,color)
	var shape = BoxMesh.new()
	shape.size = size
	shapes[key] = shape
	return mesh(parent, shape, position, color)

static func cylinder(parent: Node3D, position: Vector3, radius: float, height: float, color: Color, sides: int = 6, top: float = -1.0) -> MeshInstance3D:
	var key = "cylinder"+str([radius,height,sides,top])
	if shapes.has(key): return mesh(parent,shapes[key],position,color)
	var shape = CylinderMesh.new()
	shape.bottom_radius = radius
	shape.top_radius = radius if top < 0 else top
	shape.height = height
	shape.radial_segments = sides
	shape.rings = 1
	shapes[key] = shape
	return mesh(parent, shape, position, color)

static func joint(parent: Node3D, radius: float, color: Color) -> MeshInstance3D:
	var shape = SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2
	shape.radial_segments = 8
	shape.rings = 4
	return mesh(parent, shape, Vector3.ZERO, color)

static func softened(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var key = "soft"+str(size)
	if shapes.has(key):
		var cached = mesh(parent,shapes[key],position,color)
		cached.material_override = material(color,true)
		return cached
	# Eight-sided cross-section and inset end rings: a rounded-looking, still
	# faceted solid. One geometric piece, no extra bones or texture dependency.
	var hx = size.x * 0.5
	var hz = size.z * 0.5
	var bevel = minf(size.x,minf(size.y,size.z)) * 0.18
	var outline = [Vector2(-hx+bevel,-hz),Vector2(hx-bevel,-hz),Vector2(hx,-hz+bevel),Vector2(hx,hz-bevel),Vector2(hx-bevel,hz),Vector2(-hx+bevel,hz),Vector2(-hx,hz-bevel),Vector2(-hx,-hz+bevel)]
	var vertices: Array[Vector3] = []
	for ring in range(4):
		var scale = 0.84 if ring in [0,3] else 1.0
		var y = [-size.y*0.5,-size.y*0.5+bevel,size.y*0.5-bevel,size.y*0.5][ring]
		for point in outline: vertices.append(Vector3(point.x*scale,y,point.y*scale))
	var triangles: Array = []
	for ring in range(3):
		for i in range(8):
			var a = ring*8+i
			var b = ring*8+(i+1)%8
			triangles.append([vertices[a],vertices[b],vertices[b+8]])
			triangles.append([vertices[a],vertices[b+8],vertices[a+8]])
	for i in range(8):
		triangles.append([Vector3(0,-size.y*0.5,0),vertices[(i+1)%8],vertices[i]])
		triangles.append([Vector3(0,size.y*0.5,0),vertices[24+i],vertices[24+(i+1)%8]])
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for triangle in triangles:
		var normal = (triangle[1]-triangle[0]).cross(triangle[2]-triangle[0]).normalized()
		var centre = (triangle[0]+triangle[1]+triangle[2])/3.0
		if normal.dot(centre) < 0: normal = -normal
		st.set_normal(normal)
		for vertex in triangle: st.add_vertex(vertex)
	shapes[key] = st.commit()
	var result = mesh(parent,shapes[key],position,color)
	# Explicit normals keep small chamfers readable from both sides.
	result.material_override = material(color,true)
	return result

static func oval(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var key = "oval"+str(size)
	if not shapes.has(key):
		var shape = SphereMesh.new()
		shape.radius = 0.5
		shape.height = 1.0
		shape.radial_segments = 10
		shape.rings = 5
		shapes[key] = shape
	var result = mesh(parent,shapes[key],position,color)
	result.scale = size
	return result
