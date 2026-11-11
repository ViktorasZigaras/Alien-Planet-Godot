extends Control
const E = preload("res://scripts/economy_fixture.gd")
const Session = preload("res://scripts/civilization_session.gd")
const World = preload("res://scripts/world_map.gd")
const Planner = preload("res://scripts/economy_planner.gd")
const Projects = preload("res://scripts/construction_session.gd")
const Progression = preload("res://scripts/progression_session.gd")
const Exploration = preload("res://scripts/exploration_session.gd")
@export var exploration_mode = false
var explorer_travel = true
@export var planning_mode = false
@export var construction_mode = false
@export var progression_mode = false
var student_id = "pop_a"
var specialty = "Biologist"
var construction_tile = "3,3"
var construction_recipe = "farm"
var builder_id = "pop_b"
const SAVE = "user://alien_planet_b02.json"
var state = E.initial()
var box: VBoxContainer
var summary: Label
var message: Label
var choices: VBoxContainer
var world
var planning_box: VBoxContainer

func execute(cmd: Dictionary) -> Dictionary:
	if exploration_mode: return Exploration.command(state,cmd)
	if progression_mode: return Progression.command(state,cmd)
	if construction_mode: return Projects.command(state,cmd)
	return Planner.command(state,cmd) if planning_mode else E.command(state,cmd)

func save_path() -> String:
	if exploration_mode: return "user://alien_planet_b06.json"
	if progression_mode: return "user://alien_planet_b05.json"
	if construction_mode: return "user://alien_planet_b04.json"
	return "user://alien_planet_b03.json" if planning_mode else SAVE

func save_format() -> String:
	if exploration_mode: return "alien-planet-b06-v1"
	if progression_mode: return "alien-planet-b05-v1"
	return "alien-planet-b04-v1" if construction_mode else ("alien-planet-b03-v1" if planning_mode else "alien-planet-b02-v1")

func _ready() -> void:
	if planning_mode: state = Planner.attach(state)
	if construction_mode: state = Projects.initial()
	if progression_mode: state = Progression.initial()
	if exploration_mode: state = Exploration.initial()
	box = VBoxContainer.new(); box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation",12); add_child(box)
	var title = Label.new(); title.text = "ALIEN PLANET · B03 SHARED PLANNING" if planning_mode else "ALIEN PLANET · B02 ECONOMY TRIAL"; title.add_theme_font_size_override("font_size",26); box.add_child(title)
	if construction_mode: title.text = "ALIEN PLANET · B04 CONSTRUCTION"
	if progression_mode: title.text = "ALIEN PLANET · B05 GROWTH & LEARNING"
	if exploration_mode: title.text = "ALIEN PLANET · B06 EXPLORATION"
	var note = Label.new(); note.text = "Two ordinary civilians · seed-731 map · work resolves at End Turn · authorized planning optional; growth/projects/fauna inactive" if planning_mode else "Two ordinary civilians · same seed-731 map · planned work resolves at End Turn · AI/growth/projects/fauna inactive"; box.add_child(note)
	if construction_mode: note.text = "Two civilians · one reusable kit · skip held/blocked projects · unused effort carries forward · growth/fauna inactive"
	if progression_mode: note.text = "Growth/support/training/research trial · 10 Food per cohort · 2-turn training costs 2 Industry · fauna inactive"
	summary = Label.new(); box.add_child(summary)
	choices = VBoxContainer.new()
	if progression_mode:
		var people_list = ScrollContainer.new(); people_list.custom_minimum_size.y = 96
		box.add_child(people_list); people_list.add_child(choices)
	else: box.add_child(choices)
	planning_box = VBoxContainer.new()
	if construction_mode:
		var management = ScrollContainer.new(); management.custom_minimum_size.y = 290
		box.add_child(management); management.add_child(planning_box)
	else: box.add_child(planning_box)
	var buttons = HBoxContainer.new(); box.add_child(buttons)
	for text in ["End turn","Save","Load","Restart"]:
		var b = Button.new(); b.text = text; buttons.add_child(b); b.pressed.connect(func(): action(text))
	message = Label.new(); box.add_child(message)
	world = World.new(); world.fixed_scale = true; world.show_metrics = false
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL; box.add_child(world)
	if construction_mode:
		world.tile_selected.connect(func(tile): construction_tile = tile; refresh())
		world.move_requested.connect(func(tile,_append): construction_tile = tile; send({"type":"queueMove","unitId":"explorer" if exploration_mode and explorer_travel else builder_id,"target":tile,"append":_append}))
	refresh()
	world.focus_tile("3,3")

func refresh() -> void:
	var forecast_state = E.resolve(state)
	var forecast = forecast_state.ledger
	var lines = ["TURN %d · Food/Minerals/Industry: Landing Station storage · other stocks: global" % state.turn]
	for r in E.R.RESOURCES:
		lines.append("%s: %d  | next gross %+d · inputs %d · upkeep %d · obligations %d · net %+d" % [r.capitalize(),state.resources[r],forecast.gross[r],forecast.inputs[r],forecast.upkeep[r],forecast.spending[r],forecast.net[r]])
	if progression_mode: lines.append("Growth: %d/10 local Food · next transfer %d · working support %d/%d" % [state.settlements.main.growth,forecast.growth_food,Progression.G.working(state),Progression.G.support(state)])
	summary.text = "\n".join(lines)
	for child in choices.get_children(): choices.remove_child(child); child.queue_free()
	for id in state.cohorts:
		var row = HBoxContainer.new(); choices.add_child(row)
		var name_label = Label.new(); name_label.text = id+" · "+state.cohorts[id].qualification+" · " if progression_mode else id+" · "; row.add_child(name_label)
		var option = OptionButton.new(); row.add_child(option)
		var jobs = E.jobs(state)
		for j in jobs:
			option.add_item(j.label)
			var index = option.item_count-1
			option.set_item_disabled(index,E.reason(state,{"type":"assign","person":id,"job":j.id}) != "")
			if j.id == state.cohorts[id].state.job or j.id == "idle" and state.cohorts[id].state.job == null: option.select(index)
		option.item_selected.connect(func(index):
			var result = execute({"type":"assign","person":id,"job":jobs[index].id})
			state = result.state; message.text = result.message; refresh())
	message.text = "Food deficit: %d · Energy deficit: %d. Forecast includes emergency Food reassignment when needed." % [state.shortages.food,state.shortages.energy]
	refresh_planning()
	if exploration_mode: refresh_exploration()
	if progression_mode: refresh_progression()
	if construction_mode: refresh_construction(forecast_state.state)
	var projection = Session.projection(state)
	if exploration_mode: projection = Exploration.K.view(state,projection)
	world.update_view(projection,construction_tile if exploration_mode else "2,3","explorer" if exploration_mode and explorer_travel else "","none")

func refresh_planning() -> void:
	for child in planning_box.get_children(): planning_box.remove_child(child); child.queue_free()
	if not planning_mode: return
	var row = HBoxContainer.new(); planning_box.add_child(row)
	var toggle = CheckButton.new(); toggle.text = "Automatic authorized work"; toggle.button_pressed = state.planning.enabled; row.add_child(toggle)
	toggle.toggled.connect(func(on): state = execute({"type":"planning","enabled":on}).state; refresh())
	var amount = SpinBox.new(); amount.min_value = 1; amount.max_value = 100; amount.value = 4; row.add_child(amount)
	var add = Button.new(); add.text = "Propose Industry reserve"; row.add_child(add)
	add.pressed.connect(func(): state = execute({"type":"goal","amount":int(amount.value)}).state; refresh())
	for goal in state.planning.goals:
		if goal.status == "cancelled": continue
		var line = HBoxContainer.new(); planning_box.add_child(line)
		var text = Label.new(); text.text = "%s · reserve %d Industry · %s · %s" % [goal.id,goal.amount,goal.status,goal.blocker]; line.add_child(text)
		for verb in (["authorize","cancel"] if not goal.authorized else ["cancel"]):
			var b = Button.new(); b.text = verb.capitalize(); line.add_child(b)
			b.pressed.connect(func(): state = execute({"type":verb,"id":goal.id}).state; refresh())
	var detail = Label.new(); detail.text = "Available Industry: %d · committed people: %d · shared prerequisites: %d" % [Planner.available(state,"industry"),state.commitments.people.size(),state.commitments.prerequisites.size()]; planning_box.add_child(detail)
	if state.planning.review.has("reason"):
		var why = Label.new(); why.text = state.planning.review.reason; planning_box.add_child(why)

func send(cmd: Dictionary) -> void:
	var result = execute(cmd); state = result.state; refresh(); message.text = result.message

func refresh_exploration() -> void:
	var row = HBoxContainer.new()
	planning_box.add_child(row)
	var toggle = CheckButton.new()
	toggle.text = "Right-click moves Explorer"
	toggle.button_pressed = explorer_travel
	row.add_child(toggle)
	toggle.toggled.connect(func(on): explorer_travel = on; refresh())
	var key = state.cohorts.explorer.state.tileId
	for order in ["identify","investigate","fieldwork","stopFieldwork"]:
		var button = Button.new()
		button.text = "Stop fieldwork" if order == "stopFieldwork" else order.capitalize()
		row.add_child(button)
		button.pressed.connect(func(): send({"type":order}))
	var label = Label.new()
	var memory = state.knowledge.memory.get(construction_tile,{})
	var site = memory.get("tile",{}).get("bonus","")
	var visibility = "Visible" if state.knowledge.visible.has(construction_tile) else ("Remembered since turn %d" % memory.turn if not memory.is_empty() else "Unobserved")
	var status = ("Unidentified signal" if memory.get("signal",false) else "No known signal") if site == "" else E.R.content().bonuses[site].name
	if site != "" and state.knowledge.investigated.has(construction_tile): status += " · investigated"
	label.text = "%s · %s · %s · Explorer at %s" % [construction_tile,visibility,status,key]
	planning_box.add_child(label)
	var advice = Label.new()
	var block = Exploration.K.work_reason(state,"investigate")
	if block == "" and E.resolve(state,false).ledger.closing.food < 0: block = "Stabilize Food before committing to fieldwork."
	advice.text = "Investigation available for +2 Science" if block == "" else block
	planning_box.add_child(advice)

func refresh_progression() -> void:
	var row = HBoxContainer.new(); planning_box.add_child(row)
	var info = Label.new(); info.text = "People %d · working %d/%d supported · local growth %d/10 · Food reserve %d" % [state.cohorts.size(),Progression.G.working(state),Progression.G.support(state),state.settlements.main.growth,state.resources.food]; row.add_child(info)
	var policy = CheckButton.new(); policy.text = "Growth enabled"; policy.button_pressed = state.progression.growthEnabled; row.add_child(policy)
	policy.toggled.connect(func(on):send({"type":"growthPolicy","enabled":on}))
	var amount = SpinBox.new(); amount.min_value = 1; amount.max_value = 10; amount.value = 1; row.add_child(amount)
	var boost = Button.new(); boost.text = "Food reserve → local growth"; row.add_child(boost)
	boost.pressed.connect(func():send({"type":"boostGrowth","amount":int(amount.value)}))
	var study = HBoxContainer.new(); planning_box.add_child(study)
	var person = OptionButton.new(); study.add_child(person)
	for id in state.cohorts:
		person.add_item(id+" · "+state.cohorts[id].qualification)
		if id == student_id: person.select(person.item_count-1)
	person.item_selected.connect(func(i):student_id = state.cohorts.keys()[i]; refresh())
	var courses = OptionButton.new(); study.add_child(courses)
	for name in ["Biologist","Scientist"]:
		courses.add_item(name)
		if name == specialty: courses.select(courses.item_count-1)
	courses.item_selected.connect(func(i):specialty = courses.get_item_text(i); refresh())
	var train = Button.new(); train.text = "Train · 2 Industry / 2 turns"; study.add_child(train)
	var cmd = {"type":"train","person":student_id,"qualification":specialty}
	train.tooltip_text = Progression.reason(state,cmd); train.disabled = train.tooltip_text != ""
	train.pressed.connect(func():send(cmd))
	for id in state.progression.training:
		var course = Label.new(); course.text = "%s: %s · %d turns remaining" % [id,state.progression.training[id].qualification,state.progression.training[id].remaining]; planning_box.add_child(course)
	var research = HBoxContainer.new(); planning_box.add_child(research)
	for tech in Progression.G.TECHS:
		var button = Button.new(); button.text = "%s · %d Science" % [Progression.G.TECHS[tech].label,Progression.G.TECHS[tech].cost]; research.add_child(button)
		button.tooltip_text = Progression.reason(state,{"type":"research","tech":tech}); button.disabled = button.tooltip_text != ""
		button.pressed.connect(func():send({"type":"research","tech":tech}))

func refresh_construction(forecast: Dictionary) -> void:
	var row = HBoxContainer.new(); planning_box.add_child(row)
	var recipes = OptionButton.new(); row.add_child(recipes)
	var names = Projects.C.RECIPES.keys()
	for name in names:
		recipes.add_item(Projects.C.RECIPES[name].label+" · %d Industry / effort" % Projects.C.RECIPES[name].work)
		if name == construction_recipe: recipes.select(recipes.item_count-1)
	recipes.item_selected.connect(func(i): construction_recipe = names[i]; refresh())
	var sites = OptionButton.new(); row.add_child(sites)
	for tile in state.tileAccess.main:
		sites.add_item(tile)
		if tile == construction_tile: sites.select(sites.item_count-1)
	sites.item_selected.connect(func(i): construction_tile = sites.get_item_text(i); refresh())
	var add = Button.new(); add.text = "Queue project"; row.add_child(add)
	var command = {"type":"enqueue","recipe":construction_recipe,"tile":construction_tile}
	add.tooltip_text = E.reason(state,command); add.disabled = add.tooltip_text != ""
	add.pressed.connect(func(): send(command))
	var builders = HBoxContainer.new(); planning_box.add_child(builders)
	var person = OptionButton.new(); builders.add_child(person)
	for id in state.cohorts:
		person.add_item(id)
		if id == builder_id: person.select(person.item_count-1)
	person.item_selected.connect(func(i): builder_id = person.get_item_text(i); refresh())
	for pair in [["Equip kit / deploy",{"type":"deployBuilder","person":builder_id}],["Return kit",{"type":"returnBuilder","person":builder_id}],["Travel to hex "+construction_tile,{"type":"queueMove","unitId":builder_id,"target":construction_tile}]]:
		var button = Button.new(); button.text = pair[0]; builders.add_child(button)
		button.tooltip_text = E.reason(state,pair[1]); button.disabled = button.tooltip_text != ""
		button.pressed.connect(func(): send(pair[1]))
	var position = Label.new(); position.text = "Builder: %s · at %s · kit equipped: %s" % [builder_id,E.R.person_tile(state,state.cohorts[builder_id]),str(builder_id in state.construction.holders)]; builders.add_child(position)
	var scroll = ScrollContainer.new(); scroll.custom_minimum_size.y = 110; planning_box.add_child(scroll)
	var list = VBoxContainer.new(); scroll.add_child(list)
	for p in state.construction.queue:
		var line = HBoxContainer.new(); list.add_child(line)
		var projected = forecast.construction.queue.filter(func(entry):return entry.id == p.id)[0]
		var text = Label.new(); text.text = "%s · %s @ %s · %d/%d effort · paid %d Industry · %s" % [p.id,p.recipe,p.tile,p.work,Projects.C.RECIPES[p.recipe].work,p.paid,projected.blocker if p.status != "complete" else "Complete"]; line.add_child(text)
		if p.status != "complete":
			var hold = Button.new(); hold.text = "Resume" if p.held else "Hold"; line.add_child(hold)
			hold.pressed.connect(func(): send({"type":"hold","id":p.id,"held":not p.held}))

func action(text: String) -> void:
	match text:
		"End turn": state = execute({"type":"endTurn"}).state
		"Restart": state = Exploration.initial() if exploration_mode else Progression.initial() if progression_mode else (Projects.initial() if construction_mode else (Planner.attach(E.initial()) if planning_mode else E.initial()))
		"Save":
			var file = FileAccess.open(save_path(),FileAccess.WRITE)
			if file == null: message.text = "Save failed."; return
			file.store_string(JSON.stringify({"format":save_format(),"game":state})); message.text = "Saved."; return
		"Load":
			if not FileAccess.file_exists(save_path()): message.text = "No save yet."; return
			var data = JSON.parse_string(FileAccess.get_file_as_string(save_path()))
			if not data is Dictionary or data.get("format") != save_format(): message.text = "Invalid save for this trial."; return
			var error = Exploration.validate(data.get("game")) if exploration_mode else Progression.validate(data.get("game")) if progression_mode else (Projects.validate(data.get("game")) if construction_mode else (Planner.validate(data.get("game")) if planning_mode else E.validate(data.get("game"))))
			if error != "": message.text = error; return
			state = Planner.plan(data.game) if planning_mode else data.game
	refresh()
