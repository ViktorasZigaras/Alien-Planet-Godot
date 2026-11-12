extends RefCounted
const P = preload("res://scripts/model_parts.gd")
const PROFILES = {
	"Worker":{"cloth":"b68049","shell":"edc174","accent":"ef9e40","width":0.49},
	"Explorer":{"cloth":"3d7773","shell":"75bbb0","accent":"bde4bd","width":0.42},
	"Soldier":{"cloth":"475970","shell":"728298","accent":"c3a475","width":0.58},
}
const DARK = Color("#273640")
const BOOTS = Color("#34424a")
const VISOR = Color("#152e3b")

static func build(a: Dictionary, role: String) -> void:
	var profile: Dictionary = PROFILES[role]
	var cloth = Color(profile.cloth)
	var shell = Color(profile.shell)
	var accent = Color(profile.accent)
	var width: float = profile.width
	P.softened(a.pelvis,Vector3(0,0.04,0),Vector3(width*0.86,0.25,0.29),cloth.darkened(0.18))
	P.softened(a.spine,Vector3(0,0.13,0),Vector3(width,0.43,0.32),cloth)
	P.softened(a.pelvis,Vector3(0,0.12,0),Vector3(width,0.07,0.34),DARK)
	for side in [-1,1]:
		var suffix = "_l" if side < 0 else "_r"
		P.oval(a["upper_arm"+suffix],Vector3(0,-0.145,0),Vector3(0.22,0.36,0.23),cloth)
		P.oval(a["forearm"+suffix],Vector3(0,-0.14,0),Vector3(0.19,0.29,0.20),cloth.darkened(0.09))
		P.softened(a["forearm"+suffix],Vector3(0,-0.28,0.025),Vector3(0.16,0.12,0.16),DARK)
		P.oval(a["thigh"+suffix],Vector3(0,-0.20,0),Vector3(0.24,0.46,0.25),cloth.darkened(0.15))
		P.oval(a["shin"+suffix],Vector3(0,-0.19,0),Vector3(0.20,0.40,0.22),cloth.darkened(0.22))
		P.softened(a["foot"+suffix],Vector3(0,-0.015,0.075),Vector3(0.22,0.15,0.37),BOOTS)
		P.softened(a["shin"+suffix],Vector3(0,-0.11,0.107),Vector3(0.14,0.15,0.046),shell)
	P.cylinder(a.head,Vector3(0,-0.044,0),0.106,0.19,cloth.darkened(0.16),8)
	P.oval(a.head,Vector3(0,0.114,0),Vector3(0.33,0.35,0.34),shell)
	match role:
		"Worker":
			P.softened(a.head,Vector3(0,0.204,0.045),Vector3(0.40,0.10,0.42),accent)
			P.softened(a.head,Vector3(0,0.135,0.175),Vector3(0.25,0.09,0.065),VISOR)
			P.softened(a.head,Vector3(0.08,0.212,0.245),Vector3(0.10,0.065,0.055),Color("#f4e8ba"))
			for side in [-1,1]:
				P.softened(a.spine,Vector3(side*0.16,0.13,0.173),Vector3(0.085,0.40,0.055),accent)
				P.softened(a.pelvis,Vector3(side*0.235,0.025,0.023),Vector3(0.15,0.23,0.20),DARK)
		"Explorer":
			P.softened(a.head,Vector3(0,0.135,0.155),Vector3(0.30,0.16,0.09),VISOR)
			P.box(a.head,Vector3(0.02,0.163,0.207),Vector3(0.20,0.025,0.014),accent)
			P.softened(a.spine,Vector3(0,0.15,-0.255),Vector3(0.36,0.49,0.25),shell)
			P.cylinder(a.spine,Vector3(-0.15,0.46,-0.31),0.018,0.49,DARK,6)
			P.oval(a.spine,Vector3(-0.15,0.72,-0.31),Vector3(0.057,0.057,0.057),accent)
			P.softened(a.spine,Vector3(0.095,0.14,0.174),Vector3(0.12,0.33,0.044),accent.darkened(0.25))
		"Soldier":
			P.softened(a.spine,Vector3(0,0.16,0.178),Vector3(0.54,0.34,0.14),shell)
			P.box(a.spine,Vector3(0,0.27,0.255),Vector3(0.30,0.045,0.022),accent)
			for side in [-1,1]:
				var suffix = "_l" if side < 0 else "_r"
				P.softened(a["upper_arm"+suffix],Vector3(side*0.065,-0.054,-0.014),Vector3(0.29,0.23,0.31),shell)
				P.softened(a.pelvis,Vector3(side*0.14,0.072,0.17),Vector3(0.15,0.14,0.096),DARK)
			P.softened(a.head,Vector3(0,0.106,0.16),Vector3(0.29,0.19,0.13),DARK)
			P.box(a.head,Vector3(0,0.163,0.23),Vector3(0.25,0.043,0.022),accent)

static func tools(a: Dictionary, role: String) -> void:
	match role:
		"Worker":
			var hammer = P.box(a.forearm_r,Vector3(0,-0.32,0.08),Vector3(0.075,0.31,0.075),DARK)
			hammer.rotation.x = 0.32
			P.softened(a.forearm_r,Vector3(0,-0.46,0.025),Vector3(0.24,0.12,0.18),Color("#c59957"))
		"Explorer":
			P.softened(a.forearm_l,Vector3(-0.015,-0.24,0.13),Vector3(0.21,0.26,0.07),DARK)
			P.box(a.forearm_l,Vector3(-0.015,-0.24,0.17),Vector3(0.16,0.19,0.02),Color("#8acbb5"))

static func rifle(spine: Node3D) -> void:
	var carried = Node3D.new()
	carried.position = Vector3(0.06,0.08,0.34)
	carried.rotation = Vector3(-0.09,0.88,0.08)
	spine.add_child(carried)
	P.softened(carried,Vector3(0,0,0),Vector3(0.14,0.14,0.49),DARK)
	P.box(carried,Vector3(0,0.012,0.33),Vector3(0.075,0.075,0.24),BOOTS)
	P.box(carried,Vector3(0,-0.07,0.07),Vector3(0.095,0.15,0.13),DARK)
	P.box(carried,Vector3(0,0.03,-0.27),Vector3(0.13,0.12,0.15),Color("#8d8a76"))
