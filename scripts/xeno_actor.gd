class_name XenoActor
extends Node3D
const Models = preload("res://scripts/xeno_models.gd")
var kind = "larva"
var walking = false
var phase = 0.0
var model: Node3D
func _ready() -> void:
	model = Models.create(kind)
	add_child(model)
func walk() -> void: walking = true
func stop() -> void:
	walking = false
	phase = 0
	pose()
func _process(delta: float) -> void:
	if walking: phase += delta*8; pose()
func pose() -> void:
	for i in range(model.get_child_count()):
		var part = model.get_child(i)
		if str(part.name).begins_with("Leg"): part.rotation.y = sin(phase+i*1.7)*0.18 if walking else 0.0
		elif str(part.name).begins_with("Segment"): part.position.x = sin(phase-i*0.8)*0.035 if walking else 0.0
		elif str(part.name).begins_with("Mandible"): part.rotation.y = sin(phase)*0.08 if walking else 0.0
