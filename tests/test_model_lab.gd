extends SceneTree
const Lab = preload("res://scripts/model_lab.gd")
var checks = 0
var failures = []

func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: "+label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var before = JSON.stringify(app.state)
	app.get_node(".").find_child("OpenModelLab",true,false).pressed.emit()
	await process_frame
	var lab = app.model_lab
	while not lab.built: await process_frame
	check(lab.visible,"Toolbar opens model lab")
	check(lab.pages.get_tab_count() == 5,"Five study pages")
	check(lab.rigs.size() == 18,"Rig and eight roles on population and collage pages")
	for rig in lab.rigs:
		check(rig.skeleton.get_bone_count() == 13,"Same 13 bones: "+rig.role)
		check(rig.attachments.size() == 13,"All attachments: "+rig.role)
		var old_counts = {"Worker":26,"Farmer":28,"Engineer":25,"Merchant":26,"Scientist":27,"Administrator":26,"Security":25,"Specialist":28}
		var shapes = rig.find_children("*","MeshInstance3D",true,false).size()
		if rig.role != "Rig":
			check(shapes >= old_counts[rig.role]*2 and shapes <= old_counts[rig.role]*3,"Two to three times original geometric pieces: "+rig.role)
			check(rig.attachments.head.find_children("*","MeshInstance3D",true,false).size() > 7,"Face and collar-scale detail added: "+rig.role)
		else: check(shapes == 27,"Bare skeleton stays unchanged")
	lab.pages.current_tab = 1
	await process_frame
	lab.walk_button.pressed.emit()
	for frame in range(4): await process_frame
	for rig in lab.rigs: check(rig.walking,"Walk reaches "+rig.role)
	var rig = lab.rigs[0]
	rig.phase = 0.7
	rig.pose(0.7)
	check(not rig.skeleton.get_bone_pose_rotation(rig.skeleton.find_bone("thigh_l")).is_equal_approx(Quaternion.IDENTITY),"Walk articulates thigh")
	lab.stop_button.pressed.emit()
	for person in lab.rigs:
		check(not person.walking and person.phase == 0.0,"Stop resets "+person.role)
		check(person.skeleton.get_bone_pose_rotation(person.skeleton.find_bone("thigh_l")).is_equal_approx(Quaternion.IDENTITY),"Neutral thigh restored")
	var turn = app.state.turn
	var event = InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	app._input(event)
	check(app.state.turn == turn,"Lab blocks End Turn shortcut")
	check(JSON.stringify(app.state) == before,"Model studies do not mutate game state")
	for index in range(5):
		lab.pages.current_tab = index
		await process_frame
		await process_frame
		var active = 0
		for viewport in lab.viewports:
			if viewport.render_target_update_mode == SubViewport.UPDATE_ALWAYS: active += 1
		check(active == ([6,9,15,1,1][index]),"Only current page renders: "+str(index))
	check(lab.terrains.size() == 19,"Twelve studies and seven connected hexes")
	lab.terrain_motion.set_pressed(false)
	for tile in lab.terrains:
		check(not tile.atmosphere.animated,"Terrain motion can pause")
		check(tile.atmosphere.surface_material != null,"Textured surface material")
		check(tile.atmosphere.motes.size() <= 7,"Bounded ambient sprites")
	lab.terrain_detail.set_pressed(false)
	for tile in lab.terrains: check(not tile.atmosphere.detail,"Surface comparison toggle")
	lab.terrain_motion.set_pressed(true)
	lab.terrain_detail.set_pressed(true)
	check(JSON.stringify(app.state) == before,"Terrain controls preserve simulation")
	lab.close()
	check(not lab.visible,"Close returns to game")
	for viewport in lab.viewports: check(viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,"Hidden 3D renderer stopped")
	app.open_model_lab()
	check(app.model_lab == lab,"Reopen reuses same lab")
	lab.close()
	print("MODEL LAB CHECKS: ",checks,"; FAILURES: ",failures.size())
	app.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
