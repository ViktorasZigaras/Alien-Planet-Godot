class_name RoverRig
extends Node3D
## Reusable five-joint vehicle: body and four wheel axles; +Z is forward.
const Parts = preload("res://scripts/model_parts.gd")
var skeleton: Skeleton3D
var wheels: Array[int] = []
var rolling = false
var angle = 0.0
func _ready() -> void:
	skeleton = Skeleton3D.new()
	add_child(skeleton)
	var body = joint("body",-1,Vector3.ZERO)
	Parts.softened(body,Vector3(0,0.42,0),Vector3(1.05,0.28,1.6),Color("a6a68c"))
	Parts.softened(body,Vector3(0,0.74,0.20),Vector3(0.82,0.49,0.75),Color("c5bea0"))
	Parts.box(body,Vector3(0,0.84,0.59),Vector3(0.65,0.27,0.025),Color("477686"))
	Parts.box(body,Vector3(0,0.71,-0.53),Vector3(0.81,0.24,0.47),Color("626f70"))
	Parts.box(body,Vector3(0,0.54,0.85),Vector3(1.04,0.09,0.12),Color("47535a"))
	for side in [-1,1]:
		Parts.box(body,Vector3(side*0.34,0.60,0.83),Vector3(0.18,0.10,0.04),Color("f4df9b"))
		# A small driver's head sits behind the windscreen; vehicle dominates silhouette.
	Parts.softened(body,Vector3(0,0.88,0.30),Vector3(0.18,0.20,0.18),Color("c59b78"))
	for side in [-1,1]:
		for end in [-1,1]:
			var wheel = joint("wheel_%s_%s" % [side,end],0,Vector3(side*0.58,0.30,end*0.53))
			wheels.append(skeleton.get_bone_count()-1)
			var tyre = Parts.cylinder(wheel,Vector3.ZERO,0.27,0.21,Color("303c44"),12)
			tyre.rotation.z = PI/2
			var hub = Parts.cylinder(wheel,Vector3(side*0.12,0,0),0.13,0.02,Color("b7b6a4"),8)
			hub.rotation.z = PI/2
			Parts.box(wheel,Vector3(side*0.14,0,0),Vector3(0.025,0.20,0.035),Color("657e86"))
func joint(label: String,parent: int,offset: Vector3) -> BoneAttachment3D:
	var index = skeleton.get_bone_count()
	skeleton.add_bone(label)
	skeleton.set_bone_parent(index,parent)
	skeleton.set_bone_rest(index,Transform3D(Basis.IDENTITY,offset))
	skeleton.set_bone_pose_position(index,offset)
	var a = BoneAttachment3D.new()
	a.bone_name = label
	skeleton.add_child(a)
	return a
func _process(delta: float) -> void:
	if rolling:
		angle += delta*3.0
		for wheel in wheels: skeleton.set_bone_pose_rotation(wheel,Quaternion(Vector3.RIGHT,angle))
func walk() -> void: rolling = true
func stop() -> void: rolling = false
