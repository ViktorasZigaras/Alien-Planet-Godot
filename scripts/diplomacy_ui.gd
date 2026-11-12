extends "res://scripts/survey_ui.gd"
const Diplomacy = preload("res://scripts/diplomacy_session.gd")

func opening() -> Dictionary:
	return Diplomacy.attach(super.opening())

func save_path() -> String:
	return "user://alien_planet_b12.json"

func save_format() -> String:
	return "alien-planet-b12-v1"

func validate_opening(game) -> String:
	if not game is Dictionary or not Generator.valid(game.get("survey")): return "Missing seeded map settings."
	return Diplomacy.validate(game)

func execute(cmd: Dictionary) -> Dictionary:
	return Diplomacy.command(state,cmd)

func command_blocker(cmd: Dictionary) -> String:
	return Diplomacy.reason(state,cmd)

func orders_panel() -> void:
	var card_box = card(right_content,"Survey Compact")
	if Diplomacy.known(state):
		var access = "Civilian passage · %d turns remaining" % (state.diplomacy.passage_until-state.turn) if Diplomacy.active(state) else "Border closed · civilian passage available"
		paragraph(card_box,access,CREAM)
		paragraph(card_box,"Compact rations available: %d Food" % state.diplomacy.food)
		diplomatic_offer(card_box,"Civilian passage · 2 Minerals","passage")
		diplomatic_offer(card_box,"Buy 3 Food · 2 Minerals","rations")
		button(card_box,"Center on Compact",func(): world.focus_tile(state.expansion.contact))
	else:
		paragraph(card_box,"Scout beyond Landing Station’s work area to make faction contact.")
	super.orders_panel()

func diplomatic_offer(parent: Node, text: String, term: String) -> void:
	var cmd = {"type":"compactOffer","term":term}
	var blocker = Diplomacy.reason(state,cmd)
	order(parent,text,cmd,blocker)
	if blocker != "": paragraph(parent,blocker)
