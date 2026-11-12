extends "res://tests/test_b12.gd"
const X = preload("res://scripts/exchange_session.gd")

func run() -> void:
	var ui = load("res://b13.tscn").instantiate()
	root.add_child(ui)
	while not ui.world.built: await process_frame
	for i in range(12):
		var sample = load("res://b13.tscn").instantiate()
		sample.survey_settings = {"seed":i*541+17,"width":9+i%4,"height":7+i%3}
		var trial = sample.opening()
		check(trial.exchange.sites.size() == 2 and trial.expansion.contact != "","Compact and independent relay fit generated start "+str(i))
		sample.free()
	var initial = ui.state
	var relay = initial.exchange.sites.keys().filter(func(k): return k != initial.expansion.contact)[0]
	check(X.validate(initial) == "" and initial.exchange.sites.size() == 2,"Generated start has the two valid service sites")
	var food = {"type":"visitService","person":"explorer","tile":relay,"service":"food"}
	var science = {"type":"visitService","person":"explorer","tile":relay,"service":"science"}
	check(not X.command(initial,food).ok,"Remote visitor cannot use a service")
	var s = advance_to(initial,"explorer",relay)
	check(s.cohorts.explorer.state.tileId == relay and s.knowledge.visible.has(relay),"Explorer reaches relay through ordinary movement")
	var rations = X.command(s,food)
	check(rations.ok and rations.state.resources.food == s.resources.food+2 and rations.state.exchange.sites[relay].food == 6,"Flat visitor yield consumes real inventory")
	check(not X.command(rations.state,science).ok,"One service per faction and site per turn")
	s = X.command(rations.state,{"type":"endTurn"}).state
	var deal = X.command(s,science)
	check(deal.ok and deal.state.resources.science == s.resources.science+3 and deal.state.resources.minerals == s.resources.minerals-2 and deal.state.exchange.sites[relay].science == 9,"Paid exchange credits normal Science and charges input and output once")
	check(not X.command(deal.state,{"type":"research","tech":"cultivation"}).ok,"Science exchange does not bypass operational prerequisite")
	check(X.validate(JSON.parse_string(JSON.stringify(deal.state))) == "", "Visited site and paid deal survive save validation")
	var merchant = X.command(initial,{"type":"train","person":"pop_a","qualification":"Merchant"})
	check(merchant.ok and X.validate(merchant.state) == "","Merchant training uses the normal paid course")
	s = merchant.state
	for i in range(2): s = X.command(s,{"type":"endTurn"}).state
	check(s.cohorts.pop_a.qualification == "Merchant","Merchant qualification completes")
	s = X.command(s,{"type":"deployBuilder","person":"pop_a"}).state
	s = advance_to(s,"pop_a",relay)
	var merchant_cmd = {"type":"visitService","person":"pop_a","tile":relay,"service":"science"}
	var sale = X.command(s,merchant_cmd)
	check(sale.ok and sale.state.resources.science == s.resources.science+5 and sale.state.exchange.sites[relay].science == 7,"Trained visitor receives +2 Science on the same paid deal")
	var scarce = s.duplicate(true)
	scarce.exchange.sites[relay].science = 4
	check(not X.command(scarce,merchant_cmd).ok and scarce.exchange.sites[relay].science == 4,"Site refuses orders beyond its remaining stock")
	var compact = approach(initial)
	var permit = X.command(compact,{"type":"compactOffer","term":"passage"})
	compact = advance_to(permit.state,"explorer",initial.expansion.contact)
	var service = X.command(compact,{"type":"visitService","person":"explorer","tile":initial.expansion.contact,"service":"food"})
	check(permit.ok and service.ok and service.state.resources.food == compact.resources.food+2,"B12 passage gives physical access to the Compact Exchange")
	ui.free()
	for i in range(3): await process_frame
	print(JSON.stringify({"suite":"B13","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
