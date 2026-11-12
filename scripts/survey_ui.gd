extends "res://scripts/expansion_ui.gd"
const Generator = preload("res://scripts/survey_generator.gd")
static var next_settings: Dictionary = {}
var survey_settings: Dictionary = Generator.DEFAULT.duplicate()
var survey_dialog: ConfirmationDialog
var survey_fields: Dictionary = {}

func opening_state() -> Dictionary:
	if not next_settings.is_empty():
		survey_settings = next_settings.duplicate()
		next_settings.clear()
	var game = super.opening_state()
	var region = Generator.apply(game,survey_settings)
	game.knowledge = {"visible":{},"memory":{},"identified":{},"investigated":{},"work":""}
	game.xenos = Tactical.X.initial(game,region.nest)
	Tactical.X.sync_tiles(game)
	Exploration.K.observe(game)
	return game

func save_path() -> String:
	return "user://alien_planet_b11.json"

func save_format() -> String:
	return "alien-planet-b11-v1"

func validate_opening(game) -> String:
	if not game is Dictionary or not Generator.valid(game.get("survey")): return "Missing seeded map settings."
	return super.validate_opening(game)

func action(text: String) -> void:
	if text == "Load":
		while world.building: await get_tree().process_frame
	super.action(text)

func orders_panel() -> void:
	var survey = card(right_content,"World survey")
	paragraph(survey,"Seed %d · %d × %d hexes" % [state.survey.seed,state.survey.width,state.survey.height])
	button(survey,"New map",open_survey)
	super.orders_panel()

func open_survey() -> void:
	if not is_instance_valid(survey_dialog):
		survey_dialog = ConfirmationDialog.new()
		survey_dialog.title = "New world"
		survey_dialog.ok_button_text = "Generate"
		survey_dialog.dialog_text = "Generating a map starts a new game. Save first to keep this expedition."
		var fields = VBoxContainer.new()
		survey_dialog.add_child(fields)
		for setting in [["seed","Seed",0,2147470000],["width","Width",9,30],["height","Height",7,22]]:
			var row = HBoxContainer.new()
			fields.add_child(row)
			label(row,setting[1]).size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var field = SpinBox.new()
			field.min_value = setting[2]
			field.max_value = setting[3]
			field.custom_minimum_size.x = 145
			row.add_child(field)
			survey_fields[setting[0]] = field
		survey_dialog.confirmed.connect(generate_survey)
		add_child(survey_dialog)
	for key in survey_fields: survey_fields[key].value = state.survey[key]
	survey_dialog.popup_centered(Vector2i(540,265))

func generate_survey() -> void:
	while world.building: await get_tree().process_frame
	next_settings = {}
	for key in survey_fields: next_settings[key] = int(survey_fields[key].value)
	get_tree().reload_current_scene()
