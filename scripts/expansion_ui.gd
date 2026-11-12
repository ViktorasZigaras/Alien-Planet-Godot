extends "res://scripts/opening_ui.gd"
const Expansion = preload("res://scripts/expansion_session.gd")

func opening() -> Dictionary:
	return Expansion.attach(super.opening())

func save_path() -> String:
	return "user://alien_planet_b10.json"

func save_format() -> String:
	return "alien-planet-b10-v1"

func validate_opening(game) -> String:
	return Expansion.validate(game)

func execute(cmd: Dictionary) -> Dictionary:
	return Expansion.command(state,cmd)

func command_blocker(cmd: Dictionary) -> String:
	return Expansion.reason(state,cmd)

func opening_forecast() -> Dictionary:
	var prepared = Expansion.prepare(state)
	var food = prepared.resources.food-state.resources.food
	var result = E.resolve(prepared)
	Expansion.credit_harvest(result.ledger,food)
	return result

func opening_projection() -> Dictionary:
	var view = super.opening_projection()
	for site in state.expansion.outposts:
		var camp = state.expansion.outposts[site]
		var id = "outpost_"+site
		view.settlements[id] = {"id":id,"name":"Outpost "+site,"tileId":site}
		view.settlementOwners[id] = "blue"
		view.claimOwners[site] = "blue"
		view.cohorts[camp.crew].home = id
	var contact: String = state.expansion.contact
	if state.knowledge.memory.has(contact):
		view.settlements.frontier_contact = {"id":"frontier_contact","name":"Survey Compact","tileId":contact}
		view.settlementOwners.frontier_contact = "red"
		view.claimOwners[contact] = "red"
	return view

func select_tile(key: String) -> void:
	if mode != "Orders" or Expansion.staffed(state,selected) == "":
		super.select_tile(key)
		return
	construction_tile = key
	world.select_view(key,selected)
	refresh_selection()
	update_minimap()

func orders_panel() -> void:
	var panel = card(right_content,"Frontier")
	var id = selected
	var site = Expansion.staffed(state,id)
	if site == "":
		paragraph(panel,"Take the build kit in Colony and move a civilian to a clear site three hexes from settlement centers.")
	else:
		var camp = state.expansion.outposts[site]
		paragraph(panel,"Outpost %s · %s" % [site,display_name(id)],CREAM)
		var work: String = camp.work
		var food = E.R.tile_yield(state,work).get("food",0) if work != "" else 0
		paragraph(panel,"Select an adjacent Food hex on the map." if work == "" else "Working hex %s · +%d Food" % [work,food])
		if Expansion.unsafe(state,site):
			paragraph(panel,"Predators nearby · %d / 2 exposed turns. Move a healthy Soldier adjacent or evacuate." % camp.pressure,RED)
		for person in state.cohorts.values():
			if person.state.job == "tile:"+construction_tile:
				paragraph(panel,"Assigning this hex transfers it from "+display_name(person.id)+".",GOLD)
		frontier_order(panel,"Work selected hex",{"type":"workOutpost","person":id,"tile":construction_tile})
		frontier_order(panel,"Release work hex",{"type":"workOutpost","person":id,"tile":""})
		frontier_order(panel,"Evacuate outpost",{"type":"leaveOutpost","person":id})
	for key in state.expansion.outposts:
		var crew: String = state.expansion.outposts[key].crew
		if crew != id: button(panel,"Outpost "+key,func(): choose_person(crew))
	if state.knowledge.memory.has(state.expansion.contact):
		paragraph(panel,"Survey Compact · independent faction at hex "+state.expansion.contact)
	if site == "" and (id in state.construction.holders or state.expansion.fieldCrews.has(id)):
		frontier_order(panel,"Found outpost · 4 Food / 3 Minerals / 2 Industry",{"type":"foundOutpost","person":id})
		if id in state.construction.holders:
			frontier_order(panel,"Lay road · 1 Industry",{"type":"layRoad","person":id})
	super.orders_panel()

func frontier_order(parent: Node, text: String, cmd: Dictionary) -> void:
	var blocker = Expansion.reason(state,cmd)
	order(parent,text,cmd,blocker)
	if blocker != "": paragraph(parent,blocker)

func refresh_dock() -> void:
	super.refresh_dock()
	if Expansion.staffed(state,selected) != "" or selected in state.construction.holders or state.expansion.fieldCrews.has(selected):
		button(commands.get_child(0),"Frontier",func(): show_mode("Orders"))

func job_name(person: Dictionary) -> String:
	var site = Expansion.staffed(state,person.id)
	return "Staffing outpost "+site if site != "" else super.job_name(person)
