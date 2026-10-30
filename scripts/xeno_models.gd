class_name XenoModels
extends RefCounted
const P = preload("res://scripts/model_parts.gd")
const A = preload("res://scripts/world_assets.gd")
const Mass = preload("res://assets/shaders/xenomass.gdshader")
static var mass_material: ShaderMaterial
static func rod(parent: Node3D,a: Vector3,b: Vector3,radius: float,color: Color) -> Node3D:
	var n = P.cylinder(parent,(a+b)/2,radius,a.distance_to(b),color,5,radius*0.65)
	n.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
	return n
static func mass(hills: bool = false) -> Node3D:
	var root = Node3D.new()
	if mass_material == null:
		mass_material = ShaderMaterial.new(); mass_material.shader = Mass
	var ground = P.mesh(root,A.land_mesh(hills),Vector3(0,0.016,0),Color("183c2c"))
	ground.material_override = mass_material
	return root
static func create(kind: String) -> Node3D:
	if kind in ["mass","mass_hills"]: return mass(kind == "mass_hills")
	var root = Node3D.new()
	var shell = Color("456e49")
	var flesh = Color("243e32")
	var bone = Color("c6c39a")
	if kind == "nest":
		for i in range(3):
			P.oval(root,Vector3(cos(i*2.1)*0.22,0.24+i*0.05,sin(i*2.1)*0.20),Vector3(0.72,0.58,0.74),flesh.lightened(i*0.025))
			P.oval(root,Vector3(cos(i*2.1)*0.25,0.48+i*0.035,sin(i*2.1)*0.24),Vector3(0.37,0.16,0.48),shell.lightened(0.18))
		P.oval(root,Vector3(0,0.26,0.45),Vector3(0.42,0.29,0.08),Color("11231e"))
		for side in [-1,1]:
			rod(root,Vector3(side*0.16,0.27,0.47),Vector3(side*0.08,0.17,0.51),0.035,bone)
		for i in range(6):
			var a = i*TAU/6
			var middle = Vector3(cos(a)*0.47,0.06,sin(a)*0.43)
			rod(root,Vector3(0,0.13,0),middle,0.065,flesh)
			rod(root,middle,Vector3(cos(a+0.2)*0.76,0.015,sin(a+0.2)*0.68),0.038,shell)
		return root
	if kind == "larva":
		for i in range(5):
			var segment = Node3D.new(); segment.name = "Segment"+str(i); root.add_child(segment)
			P.oval(segment,Vector3(sin(i*0.7)*0.035,0.13,0.32-i*0.18),Vector3(0.29-i*0.022,0.24-i*0.018,0.28),shell.darkened(i*0.045))
		P.oval(root,Vector3(0,0.16,0.45),Vector3(0.29,0.25,0.26),flesh)
	else:
		var heavy = kind == "armored"
		P.oval(root,Vector3(0,0.29,-0.08),Vector3(0.73 if heavy else 0.43,0.45 if heavy else 0.33,0.88),flesh)
		for i in range(3):
			var plate = P.softened(root,Vector3(0,0.43-i*0.025,-0.31+i*0.24),Vector3(0.72 if heavy else 0.40,0.13,0.32),shell.lightened(i*0.035))
			plate.rotation.x = 0.13
		P.oval(root,Vector3(0,0.26,0.46),Vector3(0.48 if heavy else 0.30,0.26,0.35),shell.darkened(0.08))
		for side in [-1,1]:
			for i in range(3 if heavy else 2):
				var leg = Node3D.new(); leg.name = "Leg%d_%d" % [side,i]; root.add_child(leg)
				var z = -0.34+i*(0.29 if heavy else 0.54)
				var a = Vector3(side*0.20,0.25,z)
				var b = Vector3(side*(0.52 if heavy else 0.43),0.18,z+0.10)
				rod(leg,a,b,0.046 if heavy else 0.035,shell)
				rod(leg,b,Vector3(side*(0.57 if heavy else 0.49),0.01,z+0.26),0.034,flesh)
				P.oval(leg,b,Vector3(0.10,0.09,0.10),bone.darkened(0.3))
	# Independent hooked mandibles and amber eyes distinguish all three bodies.
	for side in [-1,1]:
		P.oval(root,Vector3(side*0.105,0.29,0.54),Vector3(0.065,0.055,0.055),Color("cfc66b"))
		var claw = Node3D.new(); claw.name = "Mandible"+str(side); root.add_child(claw)
		rod(claw,Vector3(side*0.12,0.16,0.52),Vector3(side*0.22,0.12,0.70),0.035,bone)
		rod(claw,Vector3(side*0.22,0.12,0.70),Vector3(side*0.07,0.14,0.77),0.025,bone)
	return root
