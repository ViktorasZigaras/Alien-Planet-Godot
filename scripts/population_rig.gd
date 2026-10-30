extends Node3D
## Reusable 13-bone rigid-part rig. Every role uses the same hierarchy and gait.
## +Y is up; the character faces +Z. Walk is an in-place preview, not navigation.
const Parts = preload("res://scripts/model_parts.gd")
const ROLES = ["Rig", "Worker", "Farmer", "Engineer", "Merchant", "Scientist", "Administrator", "Security", "Specialist"]
const PALETTES = {
	"Worker": ["c77a32", "795c42", "e2be83"],
	"Farmer": ["667d48", "79694a", "d0ba82"],
	"Engineer": ["4c657d", "e3ad3c", "b6cad1"],
	"Merchant": ["793b51", "b58a4b", "e6d6b7"],
	"Scientist": ["dde2dc", "3d788b", "8ad2ca"],
	"Administrator": ["34475f", "c9a150", "e7d9bb"],
	"Security": ["526579", "8297a5", "d7bd73"],
	"Specialist": ["44727b", "465960", "76cbd1"]
}
const GAME_ROLES = ["Worker","Biologist","Extractor","Engineer","Scientist","Medic","Merchant","Administrator","Soldier","Explorer","Artist"]
var role = "Rig"
var work_suit = false
var reinforced = false
var small_arms = false
var show_tools = true
var tool_groups: Array[Node3D] = []
var skeleton: Skeleton3D
var walking = false
var phase = 0.0
var gait_speed = 1.0
var attachments: Dictionary = {}

func _ready() -> void:
	build()
	pose(0.0)

func bone(label: String, parent: int, offset: Vector3) -> int:
	var id = skeleton.get_bone_count()
	skeleton.add_bone(label)
	skeleton.set_bone_parent(id, parent)
	skeleton.set_bone_rest(id, Transform3D(Basis.IDENTITY, offset))
	skeleton.set_bone_pose_position(id, offset)
	var attachment = BoneAttachment3D.new()
	attachment.bone_name = label
	skeleton.add_child(attachment)
	attachments[label] = attachment
	return id

func build() -> void:
	skeleton = Skeleton3D.new()
	skeleton.name = "Skeleton3D"
	add_child(skeleton)
	bone("pelvis", -1, Vector3(0, 0.98, 0))
	bone("spine", 0, Vector3(0, 0.31, 0))
	bone("head", 1, Vector3(0, 0.42, 0))
	for side in [-1, 1]:
		var suffix = "_l" if side < 0 else "_r"
		var arm = bone("upper_arm" + suffix, 1, Vector3(side * 0.32, 0.25, 0))
		bone("forearm" + suffix, arm, Vector3(0, -0.34, 0))
		var thigh = bone("thigh" + suffix, 0, Vector3(side * 0.16, -0.06, 0))
		var shin = bone("shin" + suffix, thigh, Vector3(0, -0.43, 0))
		bone("foot" + suffix, shin, Vector3(0, -0.40, 0))
	if role == "Rig":
		for key in attachments:
			var part = attachments[key]
			Parts.joint(part, 0.065, Color("efb85d"))
			var end = Vector3.ZERO
			if key == "pelvis": end = Vector3(0, 0.31, 0)
			elif key == "spine": end = Vector3(0, 0.42, 0)
			elif key.begins_with("upper_arm"): end = Vector3(0, -0.34, 0)
			elif key.begins_with("forearm"): end = Vector3(0, -0.31, 0)
			elif key.begins_with("thigh"): end = Vector3(0, -0.43, 0)
			elif key.begins_with("shin"): end = Vector3(0, -0.40, 0)
			elif key.begins_with("foot"): end = Vector3(0, -0.015, 0.19)
			if end.length() > 0:
				var rod = Parts.cylinder(part, end * 0.5, 0.032, end.length(), Color("7dbcc8"), 6)
				if abs(end.normalized().dot(Vector3.UP)) < 0.99:
					rod.quaternion = Quaternion(Vector3.UP, end.normalized())
		# Shoulder and hip crossbars make the articulation easy to read.
		Parts.box(attachments.spine, Vector3(0, 0.25, 0), Vector3(0.64, 0.045, 0.045), Color("7dbcc8"))
		Parts.box(attachments.pelvis, Vector3(0, -0.06, 0), Vector3(0.32, 0.045, 0.045), Color("7dbcc8"))
	else:
		build_outfit()

func begin_tools() -> Dictionary:
	var saved = attachments.duplicate()
	for label in attachments:
		var group = Node3D.new()
		group.name = "Tools"
		group.visible = show_tools
		attachments[label].add_child(group)
		attachments[label] = group
		tool_groups.append(group)
	return saved
func build_outfit() -> void:
	var colors = {"Biologist":["68844e","b4cf74","e7dcb6"],"Extractor":["bf7736","e8c76a","bacbd0"],"Medic":["deded1","bd5350","cde9df"],"Soldier":["526579","8297a5","d7bd73"],"Explorer":["44727b","ba9d65","91d4c8"],"Artist":["8a5383","e5ac60","e8d8ca"]}.get(role,PALETTES.get(role,PALETTES.Worker))
	var cloth = Color(colors[0]).lerp(Color("d6d2bb"),0.48)
	var accent = Color(colors[1])
	var light = Color(colors[2])
	var dark = Color("303c42")
	var skin = Color("b99270")
	Parts.softened(attachments.pelvis, Vector3(0, 0.03, 0), Vector3(0.43, 0.23, 0.30), cloth.darkened(0.15))
	Parts.softened(attachments.spine, Vector3(0, 0.12, 0), Vector3(0.51, 0.43, 0.32), cloth)
	Parts.softened(attachments.pelvis, Vector3(0, 0.12, 0.015), Vector3(0.47, 0.065, 0.34), dark)
	Parts.softened(attachments.pelvis, Vector3(0, 0.12, 0.195), Vector3(0.09, 0.055, 0.035), accent)
	Parts.oval(attachments.head, Vector3(0, 0.08, 0), Vector3(0.29, 0.34, 0.27), skin)
	Parts.softened(attachments.head, Vector3(0, 0.245, -0.015), Vector3(0.29, 0.09, 0.27), Color("453b37"))
	Parts.softened(attachments.head, Vector3(0, 0.065, 0.14), Vector3(0.075, 0.075, 0.045), skin.lightened(0.08))
	for side in [-1, 1]:
		var suffix = "_l" if side < 0 else "_r"
		Parts.oval(attachments["upper_arm"+suffix], Vector3(0, -0.145, 0), Vector3(0.22, 0.36, 0.25), cloth)
		Parts.oval(attachments["forearm"+suffix], Vector3(0, -0.13, 0), Vector3(0.18, 0.29, 0.20), cloth)
		Parts.softened(attachments["forearm"+suffix], Vector3(0, -0.285, 0.015), Vector3(0.16, 0.12, 0.19), dark)
		Parts.oval(attachments["thigh"+suffix], Vector3(0, -0.20, 0), Vector3(0.24, 0.46, 0.28), cloth.darkened(0.12))
		Parts.oval(attachments["shin"+suffix], Vector3(0, -0.18, 0), Vector3(0.21, 0.40, 0.24), cloth.darkened(0.20))
		Parts.softened(attachments["foot"+suffix], Vector3(0, -0.015, 0.075), Vector3(0.22, 0.14, 0.37), dark)
		Parts.softened(attachments["thigh"+suffix], Vector3(0, -0.30, 0.14), Vector3(0.14, 0.13, 0.05), accent.darkened(0.2))
	# Large readable props and panels, no fingers, facial rig or cloth simulation.
	if role in ["Worker", "Farmer", "Biologist", "Specialist", "Explorer"]:
		Parts.softened(attachments.spine, Vector3(0, 0.13, -0.25), Vector3(0.34, 0.35, 0.20), accent.darkened(0.25))
		for side in [-1, 1]:
			Parts.softened(attachments.spine, Vector3(side*0.17, 0.13, 0.18), Vector3(0.055, 0.43, 0.04), accent)
	var outfit_attachments = begin_tools()
	if role == "Worker" or role in ["Farmer","Biologist"]:
		Parts.softened(attachments.forearm_r, Vector3(0.08, -0.30, 0), Vector3(0.045, 0.92, 0.045), Color("8e7048"))
		Parts.softened(attachments.forearm_r, Vector3(0.08, -0.80, 0), Vector3(0.22, 0.24, 0.055) if role == "Worker" else Vector3(0.32, 0.08, 0.18), Color("8c9e9d"))
	if role in ["Farmer","Biologist"]:
		Parts.cylinder(attachments.head, Vector3(0, 0.26, 0), 0.26, 0.045, light, 8)
		Parts.cylinder(attachments.head, Vector3(0, 0.33, 0), 0.16, 0.13, light, 6, 0.13)
	if role == "Engineer":
		Parts.cylinder(attachments.head, Vector3(0, 0.25, 0), 0.18, 0.14, accent, 6, 0.13)
		Parts.softened(attachments.head, Vector3(0, 0.26, 0.18), Vector3(0.12, 0.075, 0.06), light)
		Parts.softened(attachments.forearm_r, Vector3(0, -0.47, 0), Vector3(0.40, 0.27, 0.22), dark)
		Parts.softened(attachments.forearm_r, Vector3(0, -0.47, 0.12), Vector3(0.08, 0.27, 0.03), accent)
	if role in ["Merchant", "Scientist", "Administrator", "Specialist"]:
		Parts.softened(attachments.forearm_l, Vector3(0, -0.25, 0.15), Vector3(0.26, 0.32, 0.045), accent)
		Parts.softened(attachments.forearm_l, Vector3(0, -0.25, 0.18), Vector3(0.21, 0.25, 0.018), light.darkened(0.15))
	if role in ["Merchant", "Scientist"]:
		for side in [-1, 1]:
			Parts.softened(attachments.pelvis, Vector3(side*0.15, -0.10, -0.03), Vector3(0.18, 0.48, 0.34), cloth)
	if role == "Merchant":
		Parts.softened(attachments.pelvis, Vector3(0.30, -0.02, 0.06), Vector3(0.22, 0.26, 0.23), accent)
	if role == "Scientist":
		Parts.softened(attachments.head, Vector3(0, 0.12, 0.145), Vector3(0.29, 0.055, 0.035), accent)
		Parts.cylinder(attachments.forearm_r, Vector3(0, -0.22, 0.17), 0.055, 0.19, light, 6)
	if role == "Administrator":
		Parts.softened(attachments.spine, Vector3(0, 0.10, 0.18), Vector3(0.045, 0.36, 0.03), accent)
		for side in [-1, 1]:
			Parts.softened(attachments.spine, Vector3(side*0.24, 0.30, 0), Vector3(0.11, 0.055, 0.31), accent)
	if role in ["Security","Soldier"]:
		Parts.softened(attachments.spine, Vector3(0, 0.13, 0.20), Vector3(0.43, 0.34, 0.11), accent)
		Parts.softened(attachments.head, Vector3(0, 0.25, 0), Vector3(0.31, 0.10, 0.29), cloth)
		for side in [-1, 1]:
			Parts.softened(attachments["upper_arm_l" if side < 0 else "upper_arm_r"], Vector3(side*0.035, -0.05, 0), Vector3(0.25, 0.18, 0.28), accent)
	if role in ["Specialist","Explorer"]:
		Parts.softened(attachments.head, Vector3(-0.17, 0.10, 0), Vector3(0.08, 0.16, 0.18), accent)
		Parts.softened(attachments.spine, Vector3(-0.12, 0.21, -0.36), Vector3(0.045, 0.68, 0.045), light)

	attachments = outfit_attachments
	add_outfit_details(cloth,accent,light,skin,dark)
	add_game_equipment(accent)
	if role in GAME_ROLES and role not in ["Administrator","Artist","Merchant"]:
		Parts.oval(attachments.head,Vector3(0,0.20,-0.01),Vector3(0.34,0.24,0.33),Color("d9d5bf"))
		Parts.softened(attachments.head,Vector3(0,0.13,0.145),Vector3(0.27,0.11,0.06),Color("344d59"))


func add_game_equipment(accent: Color) -> void:
	var outfit_attachments = begin_tools()
	if role == "Medic":
		Parts.box(attachments.spine,Vector3(0,0.12,0.22),Vector3(0.18,0.06,0.03),Color("bf4c46"))
		Parts.box(attachments.spine,Vector3(0,0.12,0.23),Vector3(0.06,0.18,0.03),Color("bf4c46"))
		Parts.box(attachments.pelvis,Vector3(0.28,0,0),Vector3(0.18,0.23,0.22),Color("d6d6bd"))
	if role == "Extractor":
		Parts.cylinder(attachments.head,Vector3(0,0.25,0),0.19,0.14,accent,8)
		var drill = Parts.cylinder(attachments.forearm_r,Vector3(0,-0.42,0.12),0.09,0.38,Color("94a7b2"),6,0.01)
		drill.rotation.x = PI/2
	if role == "Artist":
		Parts.box(attachments.forearm_l,Vector3(0,-0.31,0.1),Vector3(0.32,0.04,0.20),Color("b5a47d"))
		Parts.cylinder(attachments.forearm_r,Vector3(0,-0.35,0.07),0.018,0.43,Color("dcc394"),5)
	attachments = outfit_attachments
	if small_arms:
		Parts.box(attachments.spine,Vector3(0.20,0.03,0.28),Vector3(0.12,0.13,0.52),Color("343e49"))
	if work_suit or reinforced:
		var metal = Color("90a3a5") if not reinforced else Color("647c92")
		# Exoskeleton rails follow the existing limbs; the clothed person stays inside.
		Parts.box(attachments.spine,Vector3(0,0.10,-0.33),Vector3(0.48,0.47,0.18),metal)
		for side in [-1,1]:
			var suffix = "_l" if side < 0 else "_r"
			Parts.box(attachments.spine,Vector3(side*0.32,0.28,0),Vector3(0.17,0.14,0.34),accent)
			for label in ["upper_arm","forearm","thigh","shin"]:
				Parts.box(attachments[label+suffix],Vector3(side*0.15,-0.16,-0.03),Vector3(0.07,0.32,0.10),metal)
			Parts.cylinder(attachments["shin"+suffix],Vector3(side*0.14,0,0),0.11,0.10,accent,8).rotation.z = PI/2

func add_outfit_details(cloth: Color, accent: Color, light: Color, skin: Color, dark: Color) -> void:
	# Forty useful silhouette/wardrobe pieces per person, on the same bones.
	Parts.cylinder(attachments.head,Vector3(0,-0.10,0),0.075,0.12,skin,8)
	Parts.softened(attachments.spine,Vector3(0,0.12,0.178),Vector3(0.035,0.33,0.022),accent)
	for side in [-1,1]:
		var suffix = "_l" if side < 0 else "_r"
		var head = attachments.head
		Parts.softened(head,Vector3(side*0.072,0.125,0.132),Vector3(0.038,0.032,0.024),dark)
		Parts.softened(head,Vector3(side*0.075,0.169,0.13),Vector3(0.065,0.020,0.024),Color("514137"))
		Parts.softened(head,Vector3(side*0.143,0.075,0),Vector3(0.048,0.092,0.085),skin)
		Parts.softened(head,Vector3(side*0.12,0.20,-0.035),Vector3(0.060,0.12,0.21),Color("514137"))
		var collar = Parts.softened(attachments.spine,Vector3(side*0.095,0.30,0.15),Vector3(0.14,0.095,0.07),light)
		collar.rotation.z = side*0.23
		var lapel = Parts.softened(attachments.spine,Vector3(side*0.085,0.225,0.185),Vector3(0.085,0.14,0.035),accent)
		lapel.rotation.z = side*0.24
		Parts.softened(attachments.spine,Vector3(side*0.17,0.12,0.185),Vector3(0.12,0.105,0.055),cloth.darkened(0.13))
		Parts.softened(attachments.spine,Vector3(side*0.17,0.174,0.19),Vector3(0.13,0.035,0.06),cloth.lightened(0.12))
		Parts.softened(attachments.spine,Vector3(side*0.17,0.16,0.226),Vector3(0.022,0.022,0.018),light)
		Parts.softened(attachments["forearm"+suffix],Vector3(0,-0.225,0),Vector3(0.18,0.060,0.21),accent)
		Parts.softened(attachments["forearm"+suffix],Vector3(0,-0.285,0.11),Vector3(0.12,0.06,0.045),dark.lightened(0.16))
		Parts.softened(attachments["upper_arm"+suffix],Vector3(side*0.105,-0.10,0.025),Vector3(0.030,0.10,0.10),accent)
		Parts.softened(attachments["thigh"+suffix],Vector3(side*0.10,-0.17,0),Vector3(0.065,0.13,0.17),cloth.lightened(0.10))
		Parts.softened(attachments["thigh"+suffix],Vector3(side*0.12,-0.11,0),Vector3(0.040,0.04,0.18),accent)
		Parts.softened(attachments["shin"+suffix],Vector3(0,-0.02,0.10),Vector3(0.15,0.12,0.065),accent.darkened(0.15))
		Parts.softened(attachments["shin"+suffix],Vector3(0,-0.31,0),Vector3(0.20,0.06,0.23),dark)
		Parts.softened(attachments["foot"+suffix],Vector3(0,-0.07,0.08),Vector3(0.23,0.035,0.38),dark.darkened(0.18))
		Parts.softened(attachments["foot"+suffix],Vector3(0,0.015,0.19),Vector3(0.21,0.07,0.13),dark.lightened(0.12))
		Parts.softened(attachments["foot"+suffix],Vector3(0,0.06,0.06),Vector3(0.13,0.025,0.12),accent.darkened(0.30))

func walk() -> void:
	walking = true

func stop() -> void:
	walking = false
	phase = 0.0
	pose(phase)

func _process(delta: float) -> void:
	if walking:
		phase += delta * TAU * 0.8 * gait_speed
		pose(phase)

func rotate_bone(label: String, x: float, z: float = 0.0) -> void:
	skeleton.set_bone_pose_rotation(skeleton.find_bone(label), Quaternion.from_euler(Vector3(x, 0, z)))

func pose(time: float) -> void:
	if skeleton == null: return
	var stride = sin(time) * 0.48 if walking else 0.0
	var lift = abs(sin(time)) * 0.035 if walking else 0.0
	skeleton.set_bone_pose_position(0, Vector3(0, 0.98 + lift, 0))
	for side in [-1, 1]:
		var suffix = "_l" if side < 0 else "_r"
		var swing = stride * side
		rotate_bone("thigh"+suffix, swing)
		rotate_bone("shin"+suffix, -maxf(0.0, swing) * 1.10)
		rotate_bone("foot"+suffix, -swing * 0.20)
		rotate_bone("upper_arm"+suffix, -swing * 0.65, side * 0.08)
		rotate_bone("forearm"+suffix, -0.12 - abs(swing)*0.15)
