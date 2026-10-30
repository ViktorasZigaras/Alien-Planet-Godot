extends SceneTree
const A = preload("res://scripts/world_assets.gd")
const Art = preload("res://scripts/starter_art.gd")
const C = preload("res://scripts/asset_catalogue.gd")
var checks = 0
var failures = []
func check(value: bool,label: String) -> void:
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var hill = {"baseTerrain":"plains","relief":"hills"}
	check(A.height_at(hill,0,0) > 0.5,"Hill is raised ground")
	check(A.height_at(hill,0.4,0) > 0.2,"Hill has broad shoulders")
	for i in range(6):
		var angle = deg_to_rad(30+i*60)
		check(is_zero_approx(A.height_at(hill,cos(angle),sin(angle))),"Hill boundaries meet neighbours")
	check(A.height_at({"baseTerrain":"water","relief":"hills"},0,0) == 0,"Water remains level")
	check(A.height_at({"baseTerrain":"plains","relief":"flat"},0,0) == 0,"Flat ground stays flat")
	for key in ["food","minerals","energy","science","culture"]:
		var icon = Art.resource_icon(key)
		check(icon != null and icon.get_image().get_used_rect().size.x > icon.get_width()*0.75,"UI icon uses tight physical landmark bounds: "+key)
	for entry in C.entries():
		if entry.kind != "hill": continue
		var icon = Art.world_icon(entry.key)
		check(icon != null and icon.get_image().get_used_rect().size.x > 40,"Hill sprite for "+entry.type)
	root.size = Vector2i(1440,900)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var before = JSON.stringify(app.state)
	app.set_map_mode(1)
	while not app.world_view.built: await process_frame
	var world = app.world_view
	# Picking uses mesh triangles, including both shoulders, rather than a flat plane.
	for key in ["2,2","3,3","2,3","4,3"]:
		for offset in [Vector3.ZERO,Vector3(0.30,0,0.1),Vector3(-0.30,0,-0.1)]:
			var point = world.surface(key,offset)
			check(world.pick(world.screen(point)) == key,"Projected surface pick "+key+str(offset))
	check(JSON.stringify(app.state) == before,"Relief and picking leave simulation unchanged")
	app.select_mobile("pop_rover")
	var origin = world.actors.pop_rover.position
	check(app.issue({"type":"queueMove","unitId":"pop_rover","target":"2,2"}),"Queue uphill movement")
	check(world.tweens.has("pop_rover"),"Uphill visual travel starts")
	world.tweens.pop_rover.custom_step(0.30)
	var halfway = world.actors.pop_rover.position
	check(halfway != origin and halfway.y > origin.y,"Travel climbs surface between centres")
	world.set_animation(false)
	check(world.actors.pop_rover.position.is_equal_approx(world.actor_position("2,2")),"Stopped uphill travel lands at surface position")
	var fixture = app.state.duplicate(true)
	fixture.improvements["2,2"] = {"road":true}
	fixture.improvements["2,3"] = {"road":true}
	world.update_view(fixture,"2,2","pop_rover","none")
	check(world.structure_root.get_child_count() > 0,"Road ribbon builds across sloping tiles")
	check(world.surface_world(world.pos(fixture.tiles["2,2"])).y > 0.5,"Road crest follows hill")
	app.queue_free()
	await process_frame
	print("FRONTIER CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
