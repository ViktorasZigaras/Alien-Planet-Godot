extends SceneTree
const D = preload("res://scripts/diplomacy_session.gd")
var failures = []
var checks = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures.append(caption)
		push_error(caption)

func advance_to(s: Dictionary, who: String, target: String) -> Dictionary:
	var cmd = {"type":"queueMove","unitId":who,"target":target}
	if D.R.person_tile(s,s.cohorts[who]) != target:
		s = D.command(s,cmd).state
	for i in range(14):
		if not s.movementQueues.has(who): break
		s = D.command(s,{"type":"endTurn"}).state
	return s

func approach(s: Dictionary) -> Dictionary:
	var contact = s.expansion.contact
	var routes = D.R.routes(s,s.cohorts.explorer.state.tileId).costs
	var best = INF
	var target = ""
	for key in D.R.neighbours(s,contact):
		if routes.get(key,INF) < best:
			best = routes[key]
			target = key
	return advance_to(s,"explorer",target) if target != "" else s

func run() -> void:
	var ui = load("res://b12.tscn").instantiate()
	root.add_child(ui)
	while not ui.world.built: await process_frame
	var initial = ui.state
	var passage = {"type":"compactOffer","term":"passage"}
	var rations = {"type":"compactOffer","term":"rations"}
	check(D.validate(initial) == "" and initial.expansion.contact != "", "B12 starts with a valid Compact")
	check(not D.known(initial) and not D.command(initial,passage).ok,"Undiscovered Compact cannot negotiate")
	var s = approach(initial)
	check(D.known(s),"Explorer can discover the Compact through ordinary movement")
	var contact = s.expansion.contact
	var enter = {"type":"queueMove","unitId":"explorer","target":contact}
	check(not D.command(s,enter).ok and D.R.path(s,s.cohorts.explorer.state.tileId,contact,"cohort").is_empty(),"Closed border blocks order and route")
	var before: int = s.resources.minerals
	var deal = D.command(s,passage)
	s = deal.state
	check(deal.ok and D.active(s) and s.resources.minerals == before-2 and s.diplomacy.minerals == 2,"Passage transfers payment once to the Compact")
	check(not D.command(s,passage).ok and not D.command(s,{"type":"compactOffer","term":"gift"}).ok,"Counterparty refuses duplicate and unsupported terms")
	var soldier = {"type":"queueMove","unitId":"guard","target":contact}
	check(not D.command(s,soldier).ok and D.R.path(s,s.cohorts.guard.state.tileId,contact,"soldier").is_empty(),"Civilian treaty grants no military entry")
	s = advance_to(s,"explorer",contact)
	check(s.cohorts.explorer.state.tileId == contact,"Passage enables physical civilian entry")
	check(D.validate(JSON.parse_string(JSON.stringify(s))) == "", "Active agreement validates after save")
	for i in range(D.DURATION):
		if not D.active(s): break
		s = D.command(s,{"type":"endTurn"}).state
	var exit = D.R.neighbours(s,contact).filter(func(key): return s.tiles[key].baseTerrain != "water")[0]
	check(not D.R.passage_allowed(s,contact,"cohort") and not D.R.path(s,contact,exit,"cohort").is_empty(),"Expiry closes entry while visitors can leave")
	D.E.change(s,"minerals",8)
	var barter = D.command(s,rations)
	check(barter.ok and barter.state.resources.food == s.resources.food+3 and barter.state.diplomacy.food == 3 and not D.command(barter.state,rations).ok,"Ration deal delivers and depletes inventory once per turn")
	s = D.command(barter.state,{"type":"endTurn"}).state
	s = D.command(s,rations).state
	s = D.command(s,{"type":"endTurn"}).state
	check(s.diplomacy.food == 0 and not D.command(s,rations).ok,"Finite Compact reserve refuses further purchases")
	ui.free()
	for i in range(3): await process_frame
	print(JSON.stringify({"suite":"B12","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
