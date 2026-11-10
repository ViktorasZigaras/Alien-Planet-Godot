extends Control
const E = preload("res://scripts/economy_fixture.gd")
const Session = preload("res://scripts/civilization_session.gd")
const World = preload("res://scripts/world_map.gd")
const SAVE = "user://alien_planet_b02.json"
var state = E.initial()
var box: VBoxContainer
var summary: Label
var message: Label
var choices: VBoxContainer
var world

func _ready() -> void:
	box = VBoxContainer.new(); box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation",12); add_child(box)
	var title = Label.new(); title.text = "ALIEN PLANET · B02 ECONOMY TRIAL"; title.add_theme_font_size_override("font_size",26); box.add_child(title)
	var note = Label.new(); note.text = "Two ordinary civilians · same seed-731 map · planned work resolves at End Turn · AI/growth/projects/fauna inactive"; box.add_child(note)
	summary = Label.new(); box.add_child(summary)
	choices = VBoxContainer.new(); box.add_child(choices)
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
			var result = E.command(state,{"type":"assign","person":id,"job":jobs[index].id})
			state = result.state; message.text = result.message; refresh())
	message.text = "Food deficit: %d · Energy deficit: %d. Forecast includes emergency Food reassignment when needed." % [state.shortages.food,state.shortages.energy]
	world.update_view(Session.projection(state),"2,3","","none")

func action(text: String) -> void:
	match text:
		"End turn": state = E.command(state,{"type":"endTurn"}).state
		"Restart": state = E.initial()
		"Save":
			var file = FileAccess.open(SAVE,FileAccess.WRITE)
			if file == null: message.text = "Save failed."; return
			file.store_string(JSON.stringify({"format":"alien-planet-b02-v1","game":state})); message.text = "Saved B02."; return
		"Load":
			if not FileAccess.file_exists(SAVE): message.text = "No B02 save yet."; return
			var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
			if not data is Dictionary or data.get("format") != "alien-planet-b02-v1": message.text = "Invalid B02 save."; return
			var error = E.validate(data.get("game"))
			if error != "": message.text = error; return
			state = data.game
	refresh()
