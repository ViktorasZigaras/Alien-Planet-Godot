extends RefCounted
## Group repeated static geometry; no per-tile skeleton or processing node.
var groups: Dictionary = {}
func collect(root: Node3D,transform: Transform3D = Transform3D.IDENTITY) -> void:
	var combined = transform*root.transform
	if root is MeshInstance3D:
		var mat = root.material_override
		var key = str(root.mesh.get_instance_id())+":"+str(mat.get_instance_id())
		if not groups.has(key): groups[key] = {"mesh":root.mesh,"material":mat,"transforms":[]}
		groups[key].transforms.append(combined)
	for child in root.get_children():
		if child is Node3D: collect(child,combined)
func emit(parent: Node3D) -> void:
	for entry in groups.values():
		var multi = MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = entry.mesh
		multi.instance_count = entry.transforms.size()
		for i in range(entry.transforms.size()): multi.set_instance_transform(i,entry.transforms[i])
		var instance = MultiMeshInstance3D.new()
		instance.multimesh = multi
		instance.material_override = entry.material
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(instance)
