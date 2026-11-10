extends Control
const E = preload("res://scripts/economy_fixture.gd")
const Session = preload("res://scripts/civilization_session.gd")
const World = preload("res://scripts/world_map.gd")
const Planner = preload("res://scripts/economy_planner.gd")
@export var planning_mode = false
const SAVE = "user://alien_planet_b02.json"
var state = E.initial()
var box: VBoxContainer
var summary: Label
var message: Label
var choices: VBoxContainer
var world
var planning_box: VBoxContainer

func execute(cmd: Dictionary) -> Dictionary:
	return Planner.command(state,cmd) if planning_mode else E.command(state,cmd)

func save_path() -> String:
	return "user://alien_planet_b03.json" if planning_mode else SAVE

func _ready() -> void:
	if planning_mode: state = Planner.attach(state)
	box = VBoxContainer.new(); box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation",12); add_child(box)
	var title = Label.new(); title.text = "ALIEN PLANET · B03 SHARED PLANNING" if planning_mode else "ALIEN PLANET · B02 ECONOMY TRIAL"; title.add_theme_font_size_override("font_size",26); box.add_child(title)
	var note = Label.new(); note.text = "Two ordinary civilians · seed-731 map · work resolves at End Turn · authorized planning optional; growth/projects/fauna inactive" if planning_mode else "Two ordinary civilians · same seed-731 map · planned work resolves at End Turn · AI/growth/projects/fauna inactive"; box.add_child(note)
	summary = Label.new(); box.add_child(summary)
	choices = VBoxContainer.new(); box.add_child(choices)
	planning_box = VBoxContainer.new(); box.add_child(planning_box)
	var buttons = HBoxContainer.new(); box.add_child(buttons)
	for text in ["End turn","Save","Load","Restart"]:
		var b = Button.new(); b.text = text; buttons.add_child(b); b.pressed.connect(func(): action(text))
	message = Label.new(); box.add_child(message)
	world = World.new(); world.fixed_scale = true; world.show_metrics = false
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL; box.add_child(world)
	refresh()
	world.focus_tile("3,3")

func refresh() -> void:
	var forecast = E.resolve(state).ledger
	var lines = ["TURN %d · Food/Minerals/Industry: Landing Station storage · other stocks: global" % state.turn]
	for r in E.R.RESOURCES:
		lines.append("%s: %d  | next gross %+d · inputs %d · upkeep %d · obligations %d · net %+d" % [r.capitalize(),state.resources[r],forecast.gross[r],forecast.inputs[r],forecast.upkeep[r],forecast.spending[r],forecast.net[r]])
	summary.text = "\n".join(lines)
	for child in choices.get_children(): choices.remove_child(child); child.queue_free()
	for id in state.cohorts:
		var row = HBoxContainer.new(); choices.add_child(row)
		var name_label = Label.new(); name_label.text = id+" · "; row.add_child(name_label)
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
	world.update_view(Session.projection(state),"2,3","","none")

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

func action(text: String) -> void:
	match text:
		"End turn": state = execute({"type":"endTurn"}).state
		"Restart": state = Planner.attach(E.initial()) if planning_mode else E.initial()
		"Save":
			var file = FileAccess.open(save_path(),FileAccess.WRITE)
			if file == null: message.text = "Save failed."; return
			file.store_string(JSON.stringify({"format":"alien-planet-b03-v1" if planning_mode else "alien-planet-b02-v1","game":state})); message.text = "Saved."; return
		"Load":
			if not FileAccess.file_exists(save_path()): message.text = "No save yet."; return
			var data = JSON.parse_string(FileAccess.get_file_as_string(save_path()))
			if not data is Dictionary or data.get("format") != ("alien-planet-b03-v1" if planning_mode else "alien-planet-b02-v1"): message.text = "Invalid save for this trial."; return
			var error = Planner.validate(data.get("game")) if planning_mode else E.validate(data.get("game"))
			if error != "": message.text = error; return
			state = Planner.plan(data.game) if planning_mode else data.game
	refresh()
