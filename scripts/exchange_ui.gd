extends "res://scripts/diplomacy_ui.gd"
const Exchange = preload("res://scripts/exchange_session.gd")

func opening() -> Dictionary:
	return Exchange.attach(super.opening())

func save_path() -> String:
	return "user://alien_planet_b13.json"

func save_format() -> String:
	return "alien-planet-b13-v1"

func validate_opening(game) -> String:
	if not game is Dictionary or not Generator.valid(game.get("survey")): return "Missing seeded map settings."
	return Exchange.validate(game)

func execute(cmd: Dictionary) -> Dictionary:
	return Exchange.command(state,cmd)

func command_blocker(cmd: Dictionary) -> String:
	return Exchange.reason(state,cmd)

func opening_projection() -> Dictionary:
	var view = super.opening_projection()
	for key in state.exchange.sites:
		if key == state.expansion.contact or not state.knowledge.memory.has(key): continue
		view.neutralSites[key] = {"name":state.exchange.sites[key].name,"resource":"science"}
	return view

func orders_panel() -> void:
	var underfoot = E.R.person_tile(state,state.cohorts[selected])
	var site = underfoot if state.exchange.sites.has(underfoot) else construction_tile
	if state.exchange.sites.has(site) and state.knowledge.memory.has(site):
		var market = state.exchange.sites[site]
		var box = card(right_content,market.name)
		paragraph(box,"Hex %s · %d Food and %d Science in stock" % [site,market.food,market.science],CREAM)
		paragraph(box,"One service per faction each turn. Move a civilian here to use it.")
		frontier_service(box,"Collect 2 Food","food",site)
		var output = Exchange.science_yield(state.cohorts[selected])
		frontier_service(box,"Exchange 2 Minerals for %d Science" % output,"science",site)
	super.orders_panel()
	var network = card(right_content,"Exchange network")
	var found = false
	for key in state.exchange.sites:
		if not state.knowledge.memory.has(key): continue
		found = true
		button(network,state.exchange.sites[key].name+" · "+key,func():
			construction_tile = key
			world.focus_tile(key)
			world.select_view(key,selected)
			refresh_selection())
	if not found: paragraph(network,"Explore to locate relay services.")

func frontier_service(parent: Node, title: String, service: String, site: String) -> void:
	var cmd = {"type":"visitService","person":selected,"tile":site,"service":service}
	var blocker = Exchange.reason(state,cmd)
	order(parent,title,cmd,blocker)
	if blocker != "": paragraph(parent,blocker)

func refresh_dock() -> void:
	super.refresh_dock()
	var at = E.R.person_tile(state,state.cohorts[selected])
	if state.exchange.sites.has(at):
		icon_key(button(commands.get_child(0),"Exchange",func(): show_mode("Orders")))
