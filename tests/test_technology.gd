extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const Art = preload("res://scripts/starter_art.gd")
var checks = 0
var errors = []
var s: Dictionary
var app

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok: errors.append(description); printerr("FAIL: "+description)

func fresh(unlocked: bool = true) -> void:
	s = R.initial_state()
	for resource in R.RESOURCES: s.resources[resource] = 100
	if unlocked: s.completed = R.nodes().keys()

func act(cmd: Dictionary) -> void:
	var before = JSON.stringify(s)
	var result = R.command(s,cmd)
	check(result.ok,"Accept "+str(cmd)+": "+result.message)
	check(JSON.stringify(s) == before,"Input state is immutable")
	if result.ok: s = result.state
	check(R.validate(s).is_empty(),"Result validates: "+R.validate(s))
	check(R.validate(JSON.parse_string(JSON.stringify(s))).is_empty(),"State roundtrip validates")

func reject(cmd: Dictionary) -> void:
	var before = JSON.stringify(s)
	check(not R.command(s,cmd).ok,"Reject "+str(cmd))
	check(JSON.stringify(s) == before,"Rejected unlock is atomic")

func ui_button(cmd: Dictionary) -> Button:
	for node in app.find_children("*","Button",true,false):
		if node.has_meta("command") and node.get_meta("command") == cmd: return node
	return null

func ui_press(cmd: Dictionary) -> void:
	var node = ui_button(cmd)
	check(node != null,"Native command exists: "+str(cmd))
	if node == null: return
	check(not node.disabled,"Native command is enabled")
	if not node.disabled: node.pressed.emit()

func ui_select(node: OptionButton, value) -> void:
	check(node != null,"Native dropdown exists")
	if node == null: return
	for index in range(node.item_count):
		if node.get_item_metadata(index) == value:
			node.item_selected.emit(index)
			return
	check(false,"Missing dropdown value "+str(value))

func run() -> void:
	check(R.content().trees.size() == 5 and R.nodes().size() == 10,"Five areas and ten starter technologies")
	for area in R.content().trees:
		check(R.nodes().values().filter(func(n): return n.tree == area).size() == 2,"Two nodes in "+area)
	for resource in R.RESOURCES:
		check(R.content().qualifications.values().any(func(q): return q.trainable and q.resource == resource),"Trainable role for "+resource)
	fresh(false)
	reject({"type":"train","cohortId":"pop_c","qualification":"Farmer"})
	act({"type":"develop","nodeId":"technical_education"})
	reject({"type":"train","cohortId":"pop_c","qualification":"Farmer"})
	act({"type":"develop","nodeId":"cultivation"})
	act({"type":"train","cohortId":"pop_c","qualification":"Farmer"})
	act({"type":"endTurn"});act({"type":"endTurn"})
	act({"type":"assign","cohortId":"pop_c","job":"tile:3,2"})
	check(R.job_output(s,s.cohorts.pop_c).food == 3,"Farmer adds one Food to a food tile")
	# Each branch's own district, staffed building, and specialist bonus.
	var roles = {"production":"Engineer","agriculture":"Farmer","research":"Scientist","civic":"Merchant","security":"Administrator"}
	for kind in R.content().districts:
		fresh()
		act({"type":"assign","cohortId":"pop_b","job":null})
		act({"type":"build","order":"district","districtType":kind,"cohortId":"pop_b","target":"3,2"})
		act({"type":"endTurn"})
		var district_id = R.district_key("main",kind)
		check(s.districts[district_id].type == kind,"District retains its type")
		reject({"type":"build","order":"district","districtType":kind,"cohortId":"pop_b","target":"3,3"})
		var building = R.content().districts[kind].building
		act({"type":"build","order":building,"cohortId":"pop_b","districtId":district_id})
		act({"type":"endTurn"});act({"type":"endTurn"})
		check(s.cohorts.values().all(func(c): return c.state.get("job") != "building:"+R.building_key("main",building)),"New workplace starts unstaffed")
		act({"type":"train","cohortId":"pop_c","qualification":roles[kind]})
		act({"type":"endTurn"});act({"type":"endTurn"})
		check(s.cohorts.pop_c.id == "pop_c" and s.cohorts.pop_c.qualification == roles[kind],"Training preserves ID")
		act({"type":"assign","cohortId":"pop_c","job":"building:"+R.building_key("main",building)})
		var definition = R.content().buildings[building]
		var amount = definition.specialists[roles[kind]]+(1 if definition.get("upgrade","") in s.completed else 0)
		check(R.job_output(s,s.cohorts.pop_c)[definition.resource] == amount,"Specialist bonus at "+definition.name)
		var bad = s.duplicate(true)
		bad.buildings[R.building_key("main",building)].type = "unknown"
		check(not R.validate(bad).is_empty(),"Unknown building rejected")
	# All five districts coexist; the one-per-type limit does not block other types.
	fresh()
	act({"type":"assign","cohortId":"pop_b","job":null})
	var sites = ["3,2","3,3","2,4","1,4","1,2"]
	var n = 0
	for kind in R.content().districts:
		act({"type":"build","order":"district","districtType":kind,"cohortId":"pop_b","target":sites[n]})
		act({"type":"endTurn"})
		n += 1
	check(s.districts.size() == 5,"Five distinct district types can coexist in one town")
	# Each new terrain workplace has an actual gated output and matching specialist.
	var cases = {"mine":["2,2","industry","Engineer"],"survey_beacon":["3,2","research","Scientist"],"trade_post":["3,3","credits","Merchant"],"watchtower":["1,2","influence","Administrator"]}
	for kind in cases:
		var item = cases[kind]
		fresh(false)
		act({"type":"assign","cohortId":"pop_b","job":null})
		reject({"type":"improve","improvement":kind,"cohortId":"pop_b","target":item[0]})
		s.completed = R.nodes().keys()
		var base = R.tile_yield(s,item[0]).get(item[1],0)
		act({"type":"improve","improvement":kind,"cohortId":"pop_b","target":item[0]})
		act({"type":"endTurn"})
		check(R.tile_yield(s,item[0])[item[1]] == base+1,"Improvement adds one "+item[1])
		act({"type":"train","cohortId":"pop_c","qualification":item[2]})
		act({"type":"endTurn"});act({"type":"endTurn"})
		act({"type":"assign","cohortId":"pop_c","job":"tile:"+item[0]})
		check(R.map_yield(s,item[0])[item[1]] == base+2,"Worked overlay includes actual specialist output")
		reject({"type":"improve","improvement":"farm","cohortId":"pop_b","target":item[0]})
	# Security is trainable without pretending combat exists.
	fresh()
	act({"type":"train","cohortId":"pop_c","qualification":"Security"})
	act({"type":"endTurn"});act({"type":"endTurn"})
	check(s.cohorts.pop_c.qualification == "Security","Military role training completes")
	# Atlas has a real alpha channel and a distinct crop for every population role.
	for role in R.content().qualifications:
		var sprite = Art.icon(role)
		check(sprite is AtlasTexture and sprite.region.size.x > 0 and sprite.region.size.y > 0,"Sprite exists for "+role)
	check(Art.population_texture.get_image().detect_alpha() != Image.ALPHA_NONE,"Population image has real transparency")
	# Native tech tabs and dropdowns drive the same commands.
	root.size = Vector2i(1440,900)
	app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for frame in range(8): await process_frame
	check(app.tech_tabs.get_tab_count() == 5,"Technology view has all five area tabs")
	var index = 0
	for tree in R.content().trees:
		for child in app.development.get_children():
			if child is Button and child.text == R.content().trees[tree]: child.pressed.emit()
		check(app.tech_dialog.visible and app.tech_tabs.current_tab == index,"Area button opens the correct tab")
		check(app.tech_tabs.get_tab_title(index) == R.content().trees[tree],"Technology tab displays the correct area label")
		var page = app.tech_pages[tree]
		check(page.find_children("*","PanelContainer",true,false).size() == 2,"Tab contains two technology cards")
		index += 1
	app.tech_dialog.hide()
	fresh();app.state = s;app.render()
	ui_select(app.orders.find_child("TrainingQualification",true,false),"Farmer")
	ui_press({"type":"train","cohortId":"pop_a","qualification":"Farmer"})
	app.end_button.pressed.emit();app.end_button.pressed.emit()
	check(app.state.cohorts.pop_a.qualification == "Farmer","Native training selector trains the chosen role")
	app.selected_cohort = "pop_b";app.render()
	ui_select(app.orders.find_child("JobAssignment",true,false),null)
	ui_select(app.orders.find_child("DistrictType",true,false),"agriculture")
	app.select_tile("3,2")
	ui_press({"type":"build","order":"district","districtType":"agriculture","cohortId":"pop_b","target":"3,2"})
	app.end_button.pressed.emit()
	ui_press({"type":"build","order":"greenhouse","cohortId":"pop_b","districtId":"district_main_agriculture"})
	app.end_button.pressed.emit();app.end_button.pressed.emit()
	app.select_tile("2,3");app.selected_cohort = "pop_a";app.render()
	ui_select(app.orders.find_child("JobAssignment",true,false),"building:greenhouse_main")
	check(R.job_output(app.state,app.state.cohorts.pop_a).food == 4,"Native district/building/staffing loop produces Food")
	check(R.validate(app.state).is_empty(),"Expanded native UI state validates")
	app.queue_free()
	await process_frame
	print("Technology batch: %d checks, %d failures." % [checks,errors.size()])
	quit(0 if errors.is_empty() else 1)
