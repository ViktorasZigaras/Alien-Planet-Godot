extends SceneTree
const E = preload("res://scripts/economy_fixture.gd")
var checks = 0
var failures = []
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures.append(text); push_error(text)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var s = E.initial()
	check(E.validate(s) == "","Initial state valid")
	var saved = JSON.parse_string(JSON.stringify(s))
	check(E.validate(saved) == "","JSON round trip: "+E.validate(saved))
	for i in range(20): s = E.command(s,{"type":"assign","person":"pop_a","job":"manufacture"}).state
	check(s.resources == E.initial().resources,"Planning assignments produces and charges nothing")
	var t = E.resolve(s,false)
	check(t.ledger.upkeep.food == 3,"Worker 2 / idle 1 Food")
	check(t.state.resources.industry == 2 and t.state.resources.minerals == 0,"Manufacturing conserves raw inputs")
	for r in E.R.RESOURCES:
		check(t.ledger.closing[r] == t.ledger.opening[r]+t.ledger.gross[r]-t.ledger.inputs[r]-t.ledger.upkeep[r]-t.ledger.spending[r],"Ledger reconciles "+r)
	s.obligations = {"food":3}
	s = E.command(s,{"type":"assign","person":"pop_a","job":"idle"}).state
	check(E.resolve(s,false).state.resources.food == 3,"Reassignment preserves prior obligation")
	check(E.validate(JSON.parse_string(JSON.stringify(s))) == "","Save preserves pending obligations")
	var mine = ""
	for j in E.jobs(s):
		if j.id.begins_with("tile:") and j.yield.get("minerals",0)>0: mine = j.id; break
	check(mine != "","Real raw material source available")
	s = E.initial(); E.change(s,"minerals",-2)
	s = E.command(s,{"type":"assign","person":"pop_a","job":mine}).state
	s = E.command(s,{"type":"assign","person":"pop_b","job":"manufacture"}).state
	t = E.resolve(s,false)
	check(t.ledger.gross.industry>0,"Same-turn raw production feeds manufacturing")
	check(not E.command(s,{"type":"assign","person":"pop_b","job":mine}).ok,"No double occupancy")
	var before = JSON.stringify(s)
	E.resolve(s)
	check(JSON.stringify(s) == before,"Forecast is read-only")
	var commands = [{"type":"assign","person":"pop_a","job":mine},{"type":"endTurn"},{"type":"assign","person":"pop_b","job":"manufacture"},{"type":"endTurn"}]
	var a = E.initial(); var b = E.initial()
	for cmd in commands:
		a = E.command(a,cmd).state
		b = E.command(JSON.parse_string(JSON.stringify(b)),cmd).state
	check(E.same(a.resources,b.resources) and E.same(a.cohorts,b.cohorts) and a.turn == b.turn,"Saved continuation and replay agree")
	s = E.initial(); E.change(s,"food",-100)
	t = E.resolve(s)
	check(t.state.resources.food<0 and t.state.shortages.food>0,"Shortage persists rather than clamping")
	var bad = E.initial(); bad.storage.main.food = "oops"
	check(E.validate(bad) != "","Invalid stock rejected")
	bad = E.initial(); bad.cohorts.pop_b.state = "broken"
	check(E.validate(bad) != "","Malformed second person rejected without occupancy crash")
	var food_job = ""; var food_yield = 0
	for j in E.jobs(E.initial()):
		if j.id.begins_with("tile:") and j.yield.get("food",0)>food_yield:
			food_job = j.id; food_yield = j.yield.food
	s = E.initial()
	s = E.command(s,{"type":"assign","person":"pop_a","job":food_job}).state
	for i in range(12):
		var job = mine if i % 2 == 0 else "manufacture"
		if job == food_job: job = "idle"
		s = E.command(s,{"type":"assign","person":"pop_b","job":job}).state
		s = E.command(s,{"type":"endTurn"}).state
	check(s.resources.food >= 0 and s.resources.industry > 0,"Known-map 12-turn Food and materials bootstrap")
	var started = Time.get_ticks_usec()
	s = E.initial()
	for i in range(100): s = E.command(s,{"type":"endTurn"}).state
	check(s.turn == 101,"100-turn simulation advances once per boundary")
	var ui = load("res://b02.tscn").instantiate()
	root.add_child(ui)
	for i in range(10): await process_frame
	ui.action("Save"); var ui_before = JSON.stringify(ui.state)
	ui.action("End turn"); ui.action("Load")
	check(E.same(ui.state,JSON.parse_string(ui_before)),"UI real-file save restores state")
	ui.free()
	print(JSON.stringify({"suite":"B02","checks":checks,"failures":failures,"simulation_turns":100,"elapsed_us":Time.get_ticks_usec()-started}))
	quit(0 if failures.is_empty() else 1)
