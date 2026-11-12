extends SceneTree
const Generator = preload("res://scripts/survey_generator.gd")
const Rules = preload("res://scripts/game_rules.gd")
var failures: Array[String] = []
var checks = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures.append(caption)
		push_error(caption)

func run() -> void:
	var scene = load("res://b11.tscn")
	var fingerprints = {}
	var starts = {}
	var generation = []
	var dimensions_to_test = [Vector2i(9,7),Vector2i(16,11),Vector2i(30,22),Vector2i(9,22),Vector2i(30,7)]
	for index in range(40):
		var dimensions = dimensions_to_test[index%dimensions_to_test.size()]
		var config = {"seed":index*193+17,"width":dimensions.x,"height":dimensions.y}
		var began = Time.get_ticks_usec()
		var map = Generator.generate(config)
		generation.append((Time.get_ticks_usec()-began)/1000.0)
		var tiles: Dictionary = map.tiles
		var land = tiles.values().filter(func(t): return t.baseTerrain != "water")
		var joined = Generator.land_component(tiles,map.landing,{})
		check(tiles.size() == dimensions.x*dimensions.y and joined.size() == land.size() and land.size() < tiles.size(),"Connected land and real coastline for seed "+str(config.seed))
		check(not map.nest.is_empty() and map.nest in joined and Generator.distance(tiles[map.nest],tiles[map.landing]) >= 4,"Distant reachable nest")
		check(not map.rivers.is_empty() and map.rivers.all(func(edge):
			var ends = edge.split("|")
			return ends[0] in joined and ends[1] in Generator.neighbors(tiles,tiles[ends[0]]) and ends[1] in joined),"Rivers use adjacent land edges")
		fingerprints[hash(tiles)] = true
		starts[map.landing] = true
	check(fingerprints.size() == 40 and starts.size() > 5,"Seeds vary geography and starts")
	check(Generator.generate(Generator.DEFAULT) == Generator.generate(Generator.DEFAULT),"Identical config recreates identical terrain")
	check(not Generator.valid({"seed":3,"width":8,"height":11}),"Unsupported dimensions rejected")
	var app = scene.instantiate()
	root.add_child(app)
	current_scene = app
	while not app.world.built: await process_frame
	var s: Dictionary = app.state
	var worker = app.world.actors["pop_a"]
	check(worker.frontier_outfit and worker.activity == "work" and worker.skeleton.get_bone_count() == 13,"Map civilian uses the frontier work pose and shared rig")
	app.choose_person("explorer",false)
	var scout = app.world.actors["explorer"]
	check(scout.frontier_outfit and scout.activity == "scan","Selecting Explorer uses the scout model and pose")
	scout.walk()
	scout.pose(PI/2)
	var stride = scout.skeleton.get_bone_pose_rotation(scout.skeleton.find_bone("forearm_l"))
	scout.stop()
	check(scout.skeleton.get_bone_pose_rotation(scout.skeleton.find_bone("forearm_l")) != stride,"Shared walking gait returns to the scan pose")
	app.choose_person("guard",false)
	check(app.world.actors["guard"].activity == "guard","Equipped soldier uses the rifle stance")
	check(app.validate_opening(JSON.parse_string(JSON.stringify(s))) == "","Generated opening validates across JSON save")
	check(s.cohorts.pop_a.state.job != null and s.cohorts.pop_b.state.job != null and s.cohorts.pop_a.state.job != s.cohorts.pop_b.state.job,"Two separate starting jobs")
	var unseen = s.tiles.keys().filter(func(key): return not s.knowledge.memory.has(key) and s.tiles[key].bonus != "")
	check(not unseen.is_empty() and unseen.all(func(key): return app.projected.tiles[key].bonus == ""),"Unobserved deposits stay undisclosed")
	check(app.projected.xenos.units.is_empty() and app.projected.xenos.nests.is_empty(),"Distant wildlife stays undisclosed")
	var changed = s.duplicate(true)
	changed.rivers.pop_back()
	check(app.validate_opening(changed) != "","Modified seed geography is rejected")
	for i in range(4): app.send({"type":"endTurn"})
	check(app.state.turn == 5 and app.state.resources.food >= 0,"Default opening plays four turns from the starting stockpile")
	check(app.validate_opening(JSON.parse_string(JSON.stringify(app.state))) == "","Played world validates across JSON save")
	app.open_survey()
	check(app.survey_fields.width.value == s.map.width,"New map dialog shows active settings")
	app.survey_fields.seed.value = 984
	app.survey_fields.width.value = 19
	app.survey_fields.height.value = 13
	app.survey_dialog.hide()
	while app.world.building: await process_frame
	app.generate_survey()
	await scene_changed
	app = current_scene
	while not app.world.built: await process_frame
	check(app.state.map.seed == 984 and app.state.tiles.size() == 247 and app.state.turn == 1,"New map regenerates a fresh scene from entered settings")
	check(app.validate_opening(JSON.parse_string(JSON.stringify(app.state))) == "","Nondefault dimensions validate")
	var home = app.state.settlements.main.tileId
	var neighbor = Generator.neighbors(app.state.tiles,app.state.tiles[home]).filter(func(key): return app.state.tiles[key].baseTerrain != "water")[0]
	var before_move = app.state.cohorts.explorer.state.tileId
	var order = app.execute({"type":"queueMove","unitId":"explorer","target":neighbor})
	check(order.ok and before_move == home and (order.state.cohorts.explorer.state.tileId == neighbor or order.state.movementQueues.has("explorer")),"Explorer uses the normal travel rules on a generated map")
	var last = app.state.tiles["18,12"]
	var p = app.minimap.point(last)
	check(Rect2(Vector2.ZERO,app.minimap.size).has_point(p),"Minimap fits custom dimensions")
	current_scene = null
	app.free()
	for i in range(3): await process_frame
	generation.sort()
	print(JSON.stringify({"suite":"B11","checks":checks,"failures":failures,"map_samples":generation.size(),"generation_median_ms":generation[generation.size()/2],"generation_max_ms":generation.back()}))
	quit(0 if failures.is_empty() else 1)
