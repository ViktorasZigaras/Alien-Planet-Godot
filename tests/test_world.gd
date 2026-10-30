extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const A = preload("res://scripts/world_assets.gd")
const C = preload("res://scripts/asset_catalogue.gd")
var checks = 0
var failures = []
func check(value: bool,label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var before = JSON.stringify(app.state)
	check(not is_instance_valid(app.world_view),"3D world lazy before first flip")
	app.set_map_mode(1)
	var world = app.world_view
	while not world.built: await process_frame
	check(world.viewport.own_world_3d,"One isolated live world")
	check(world.camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"Orthographic isometric camera")
	check(JSON.stringify(app.state) == before,"View flip preserves simulation")
	check(world.terrain_root.get_child_count() < 100,"Shared static terrain batches")
	var instances = 0
	for item in world.terrain_root.get_children():
		check(item is MultiMeshInstance3D,"Static world geometry batched")
		instances += item.multimesh.instance_count
	check(instances > 384,"Full map and props instantiated")
	check(world.actors.size() == R.visible_people(app.state).size(),"One actor per occupied hex")
	var stacks = {}
	for c in app.state.cohorts.values():
		var tile = R.person_tile(app.state,c)
		stacks[tile] = stacks.get(tile,0)+1
	check(stacks["2,3"] == 3,"Multiple people share town")
	check(world.actors.has("pop_rover"),"Last used/tie-break Rover visible in stack")
	app.select_person("pop_c")
	check(world.actors.has("pop_c") and not world.actors.has("pop_rover"),"Selecting stack resident makes that person visible")
	app.select_mobile("pop_rover")
	check(world.actors.has("pop_rover") and not world.actors.has("pop_c"),"Selecting driver reveals Rover")
	var rover = world.actors.pop_rover
	check(rover.skeleton.get_bone_count() == 5 and rover.wheels.size() == 4,"Reusable body and four wheel bones")
	rover.walk()
	rover._process(0.2)
	check(rover.angle > 0,"Moving wheels rotate")
	rover.stop()
	var angle = rover.angle
	rover._process(0.2)
	check(rover.angle == angle,"Stopped wheels stay still")
	var screen = world.screen(world.pos(app.state.tiles["3,3"]))
	check(world.pick(screen) == "3,3","3D picking matches projected hex")
	var initial_target = world.target
	var down = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = screen
	down.pressed = true
	world._gui_input(down)
	var motion = InputEventMouseMotion.new()
	motion.relative = Vector2(30,20)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	world._gui_input(motion)
	var up = down.duplicate()
	up.pressed = false
	world._gui_input(up)
	check(world.target != initial_target,"Isometric drag pans ground plane")
	world.focus_tile("2,3")
	app.selected_unit = "pop_rover"
	check(app.issue({"type":"queueMove","unitId":"pop_rover","target":"3,3"}),"3D unit command")
	check(is_equal_approx(float(app.state.cohorts.pop_rover.facing),PI/2),"Facing is last movement direction")
	check(app.state.cohorts.pop_rover.lastRoute == ["2,3","3,3"],"Visual movement trace follows actual steps")
	check(world.tweens.has("pop_rover"),"Live movement interpolates")
	world.set_animation(false)
	check(world.tweens.is_empty(),"Motion-off completes visual travel")
	check(world.actors.pop_rover.position == world.actor_position("3,3"),"Motion-off snaps to authoritative tile")
	world.set_animation(true)
	var json = JSON.parse_string(JSON.stringify(app.state))
	check(R.validate(json) == "" and is_equal_approx(float(json.cohorts.pop_rover.facing),PI/2),"Facing/use order survive save roundtrip")
	var identity = world.get_instance_id()
	app.set_map_mode(0)
	check(world.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,"Hidden world stops rendering")
	for actor in world.actors.values(): check(not actor.is_processing(),"Hidden actor stopped")
	app.set_map_mode(1)
	check(app.world_view.get_instance_id() == identity,"Flip reuses built world")
	check(world.viewport.render_target_update_mode == SubViewport.UPDATE_ALWAYS,"Visible world resumes")
	app.open_model_lab()
	while not app.model_lab.built: await process_frame
	check(world.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,"Showcase suspends world behind it")
	app.model_lab.pages.current_tab = 4
	await process_frame
	await process_frame
	var active = app.model_lab.viewports.filter(func(v): return v.render_target_update_mode == SubViewport.UPDATE_ALWAYS)
	check(active.size() == 1,"Catalogue renders one viewport")
	check(app.model_lab.catalogue_entries.size() == C.entries().size(),"All current sprite/model variants catalogued")
	app.model_lab.show_asset(66)
	check(app.model_lab.catalogue_actor is RoverRig,"Catalogue switches to Rover")
	app.model_lab.walk()
	check(app.model_lab.catalogue_actor.rolling,"Catalogue Walk drives wheels")
	app.model_lab.stop()
	check(not app.model_lab.catalogue_actor.rolling,"Catalogue Stop parks vehicle")
	app.model_lab.close()
	check(world.viewport.render_target_update_mode == SubViewport.UPDATE_ALWAYS,"World resumes after showcase")
	for role in R.content().qualifications:
		var p = A.person({"qualification":role,"equipment":["work_suit","small_arms"]})
		root.add_child(p)
		check(p.skeleton.get_bone_count() == 13,"Shared 13-bone rig: "+role)
		check(p.work_suit and p.small_arms and p.attachments.has("head"),"Person inside suit: "+role)
		p.free()
	var definitions = R.read_json("res://data/world_sprites.json")
	var image = Image.new()
	image.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/world/pixel_world.png"))
	check(image.get_format() == Image.FORMAT_RGBA8,"Transparent sprite atlas")
	for entry in C.entries():
		check(definitions.has(entry.key),"Sprite exists: "+entry.key)
		var region = definitions[entry.key]
		var visible = 0
		for y in range(region[1],region[1]+region[3],2):
			for x in range(region[0],region[0]+region[2],2):
				if image.get_pixel(x,y).a > 0.1: visible += 1
		check(visible > 0,"Nonempty sprite: "+entry.key)
	var old = R.initial_state()
	old.schemaVersion = 6
	old.rulesVersion = 6
	old.erase("visualCounter")
	for c in old.cohorts.values():
		c.erase("lastUsed"); c.erase("facing"); c.erase("lastRoute")
	var migrated = R.migrate_save(old)
	check(R.validate(migrated) == "" and migrated.schemaVersion == 7,"Version 6 saves migrate without gameplay loss")
	app.queue_free()
	await process_frame
	print("WORLD CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
