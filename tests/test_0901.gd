extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const C = preload("res://scripts/asset_catalogue.gd")
const Art = preload("res://scripts/starter_art.gd")
var checks = 0
var failures = []
func check(value: bool,label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func issue(s: Dictionary,cmd: Dictionary) -> Dictionary:
	var result = R.command(s,cmd)
	check(result.ok,"Command "+str(cmd))
	check(R.validate(result.state) == "","Valid after "+cmd.type)
	return result.state
func _initialize(): call_deferred("run")
func run():
	# Every profession can travel, without acquiring a second identity or equipment.
	for role in R.content().qualifications:
		var s = R.initial_state()
		s.cohorts.pop_c.qualification = role
		s.cohorts.pop_c.state.job = null
		s = issue(s,{"type":"board","cohortId":"pop_c","transportId":"pop_rover"})
		check(R.passengers(s,"pop_rover").size() == 1,"Passenger count "+role)
		check(R.person_tile(s,s.cohorts.pop_c) == "2,3","Carried location "+role)
		check("pop_c" not in R.visible_people(s).values(),"Passenger not separately rendered")
		var food = R.economy(s).towns.main.consumption
		s = issue(s,{"type":"queueMove","unitId":"pop_rover","target":"3,3"})
		check(R.person_tile(s,s.cohorts.pop_c) == "3,3","Passenger follows queued movement")
		check(R.economy(s).towns.main.consumption == food,"Passenger remains in upkeep")
		var roundtrip = R.migrate_save(JSON.parse_string(JSON.stringify(s)))
		check(R.validate(roundtrip) == "" and roundtrip.cohorts.pop_c.state.kind == "cargo","Cargo save roundtrip")
		s = issue(s,{"type":"unload","cohortId":"pop_c"})
		check(s.cohorts.pop_c.qualification == role and s.cohorts.pop_c.equipment.is_empty(),"Role/equipment preserved")
		check(s.cohorts.pop_c.state.tileId == "3,3" and s.cohorts.pop_c.state.movementRemaining == 0,"Unload without free movement")
	var s = R.initial_state()
	s.cohorts.pop_a.state.job = null
	s.cohorts.pop_b.state.job = null
	s.cohorts.pop_c.state.job = null
	s = issue(s,{"type":"board","cohortId":"pop_a","transportId":"pop_rover"})
	s = issue(s,{"type":"board","cohortId":"pop_b","transportId":"pop_rover"})
	var before = JSON.stringify(s)
	var full = R.command(s,{"type":"board","cohortId":"pop_c","transportId":"pop_rover"})
	check(not full.ok and JSON.stringify(full.state) == before,"Third passenger rejected atomically")
	check(not R.command(s,{"type":"join","cohortId":"pop_rover"}).ok,"Cannot remove loaded carrier")
	check(not R.command(s,{"type":"queueMove","unitId":"pop_a","target":"3,3"}).ok,"Cargo cannot move independently")
	s = issue(s,{"type":"endTurn"})
	check(R.passengers(s,"pop_rover").size() == 2,"Cargo survives end turn")
	var bad = s.duplicate(true)
	bad.cohorts.pop_a.state.transportId = "pop_a"
	check(R.validate(bad) != "","Self-carrying save rejected")
	bad = s.duplicate(true)
	bad.cohorts.pop_c.state = {"kind":"cargo","transportId":"pop_rover"}
	check(R.validate(bad) != "","Overloaded save rejected")
	var old = R.initial_state()
	old.schemaVersion = 7
	old.rulesVersion = 7
	check(R.validate(R.migrate_save(old)) == "" and R.migrate_save(old).schemaVersion == 8,"0.9 saves migrate to schema 8")
	var people = C.library_entries().filter(func(e): return e.kind == "person")
	check(people.size() == 11,"Eleven base people in library")
	check(C.library_entries().size() == 63 and C.entries().size() == 118,"Configurations separated; complete bake retained")
	for key in ["bonus_edible_flora","bonus_ore_seam","bonus_alien_specimens","settlement_main","person_Worker_0_0"]:
		var full_icon = Art.world_icon(key)
		var tight = Art.tight_icon(key)
		check(tight.atlas == full_icon.atlas and tight.region.size == Vector2(full_icon.get_image().get_used_rect().size),"Flat tight atlas "+key)
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_map_mode(1)
	while not app.world_view.built: await process_frame
	var world = app.world_view
	var a = world.screen(world.pos(app.state.tiles["2,3"]))
	var b = world.screen(world.pos(app.state.tiles["3,3"]))
	var c = world.screen(world.pos(app.state.tiles["2,4"]))
	check(b.x > a.x and absf(b.y-a.y) < 0.01,"East is screen right in both maps")
	check(c.y > a.y,"South is screen down in both maps")
	var marker = world.surface("2,3")
	var before_pan = world.screen(marker)
	world.left_down = true
	var drag = InputEventMouseMotion.new()
	drag.relative = Vector2(30,20)
	world._gui_input(drag)
	world.left_down = false
	var after_pan = world.screen(marker)
	check(after_pan.x > before_pan.x and after_pan.y < before_pan.y,"3D pan moves right/up for right/down drag, matching inverted sprite pan")
	app.select_mobile("pop_rover")
	check(app.issue({"type":"assign","cohortId":"pop_c","job":null}),"Passenger leaves job before boarding")
	check(app.issue({"type":"board","cohortId":"pop_c","transportId":"pop_rover"}),"UI command boards passenger")
	check(app.issue({"type":"queueMove","unitId":"pop_rover","target":"3,3"}),"Transport movement starts")
	world.tweens.pop_rover.custom_step(0.21)
	check(world.tweens.has("pop_rover"),"Transport travel lasts twice former 0.2 seconds")
	var rover = world.actors.pop_rover
	rover.walk()
	rover.angle = 0
	rover._process(0.2)
	check(is_equal_approx(rover.angle,0.6),"Wheel spin halved to 3 radians/second")
	world.set_animation(false)
	app.open_model_lab()
	while not app.model_lab.built: await process_frame
	var lab = app.model_lab
	lab.suit_choice.select(1)
	lab.arms_choice.button_pressed = true
	lab.tools_choice.button_pressed = false
	lab.show_asset(0)
	check(lab.catalogue_actor.work_suit and lab.catalogue_actor.small_arms,"One base person accepts configurations")
	check(lab.catalogue_actor.skeleton.get_bone_count() == 13,"Configuration keeps joint count")
	check(lab.catalogue_actor.tool_groups.all(func(g): return not g.visible),"Profession tools independently hidden")
	app.queue_free()
	await process_frame
	print("0.901 CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
