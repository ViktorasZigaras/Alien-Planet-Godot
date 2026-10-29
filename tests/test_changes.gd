extends SceneTree
const R = preload("res://scripts/game_rules.gd")
var checks = 0
var errors = []
var s: Dictionary

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: errors.append(message); printerr("FAIL: "+message)

func act(cmd: Dictionary) -> void:
	var before = JSON.stringify(s)
	var result = R.command(s, cmd)
	check(result.ok, "Accept "+str(cmd)+": "+result.message)
	check(JSON.stringify(s) == before, "Prior state unchanged")
	if result.ok: s = result.state
	check(R.validate(s).is_empty(), "Invariants: "+R.validate(s))

func reject(cmd: Dictionary) -> void:
	var before = JSON.stringify(s)
	var result = R.command(s,cmd)
	check(not result.ok, "Reject "+str(cmd))
	check(JSON.stringify(s) == before, "Failure is atomic")

func run() -> void:
	s = R.initial_state()
	check(R.worker_at(s,"1,3").id == "pop_a", "Worked tile identifies its cohort")
	check(R.worker_at(s,"3,2").is_empty(), "Unworked tile has no marker")
	act({"type":"endTurn"})
	act({"type":"assign","cohortId":"pop_b","job":null})
	act({"type":"improve","improvement":"farm","cohortId":"pop_b","target":"1,3"})
	check(R.validate(JSON.parse_string(JSON.stringify(s))).is_empty(), "Improvement project survives save")
	check(R.tile_yield(s,"1,3").food == 3, "Unfinished farm adds nothing")
	act({"type":"endTurn"})
	check(R.tile_yield(s,"1,3").food == 4, "Finished farm adds exactly one Food")
	check(s.cohorts.pop_b.state.job == null, "Builder returns idle")
	check(R.forecast(s).food == 2, "Worked farm raises net Food")
	reject({"type":"improve","improvement":"farm","cohortId":"pop_b","target":"1,3"})
	reject({"type":"improve","improvement":"farm","cohortId":"pop_b","target":"2,2"})
	reject({"type":"improve","improvement":"road","cohortId":"pop_b","target":"0,0"})
	act({"type":"improve","improvement":"road","cohortId":"pop_b","target":"1,3"})
	act({"type":"endTurn"})
	check(s.improvements["1,3"].farm and s.improvements["1,3"].road, "Farm and road coexist")
	check(is_equal_approx(R.movement_cost(s,"1,3"),1.0/3), "Road entry cost is one third")
	act({"type":"move","unitId":"rover","target":"1,3"})
	check(is_equal_approx(s.units.rover.movementRemaining,5.0/3), "Rover spends fractional movement exactly")
	check(R.validate(JSON.parse_string(JSON.stringify(s))).is_empty(), "Fractional movement save validates")
	# A full one-point budget crosses exactly three road hexes.
	s = R.initial_state()
	for key in ["3,3","4,3","5,3","6,3"]: s.improvements[key] = {"road":true}
	act({"type":"mobilise","cohortId":"pop_c"})
	act({"type":"endTurn"})
	act({"type":"move","unitId":"pop_c","target":"5,3"})
	check(s.cohorts.pop_c.state.movementRemaining == 0, "Three road steps exhaust one movement point")
	reject({"type":"move","unitId":"pop_c","target":"6,3"})
	check(R.supply_field(s)["6,3"] < 3, "Roads also reduce the shared supply-path cost")
	var bad = s.duplicate(true)
	bad.improvements["0,0"] = {"road":true}
	check(not R.validate(bad).is_empty(), "Water-road save rejected")
	bad = s.duplicate(true)
	bad.improvements["2,2"] = {"farm":true}
	check(not R.validate(bad).is_empty(), "Illegal farm save rejected")
	# Queue consumes current allowance, continues after refresh, and can append/cancel.
	s = R.initial_state()
	act({"type":"queueMove","unitId":"rover","target":"6,3"})
	check(s.units.rover.tileId == "4,3" and s.movementQueues.rover == ["5,3","6,3"], "Rover uses current budget and retains remaining route")
	check(R.validate(JSON.parse_string(JSON.stringify(s))).is_empty(), "Queue survives save/load")
	act({"type":"queueMove","unitId":"rover","target":"5,4","append":true})
	check(s.movementQueues.rover.back() == "5,4", "Appending retains the previous destination before waypoint")
	act({"type":"endTurn"})
	check(s.units.rover.tileId == "6,3" and s.movementQueues.rover == ["5,4"], "End Turn advances only within two-point allowance")
	act({"type":"cancelMove","unitId":"rover"})
	check(not s.movementQueues.has("rover"), "Cancel clears queue")
	act({"type":"endTurn"})
	check(s.units.rover.tileId == "6,3", "Cancelled route does not resume")
	s = R.initial_state()
	act({"type":"mobilise","cohortId":"pop_c"})
	reject({"type":"queueMove","unitId":"pop_c","target":"6,3"})
	reject({"type":"queueMove","unitId":"pop_c","target":"2,2"})
	act({"type":"queueMove","unitId":"pop_c","target":"5,3"})
	check(s.cohorts.pop_c.state.tileId == "2,3", "Mobilisation cannot gain movement by queueing")
	act({"type":"endTurn"})
	check(s.cohorts.pop_c.state.tileId == "3,3", "Population queue advances one clear hex per turn")
	var invalid_queue = s.duplicate(true)
	invalid_queue.movementQueues.pop_c = ["8,6"]
	check(not R.validate(invalid_queue).is_empty(), "Nonadjacent queued save rejected")
	act({"type":"endTurn"})
	act({"type":"endTurn"})
	check(s.cohorts.pop_c.state.tileId == "5,3" and not s.movementQueues.has("pop_c"), "Arrival clears route without cloning cohort")
	s = R.initial_state()
	for key in ["3,3","4,3","5,3","6,3"]: s.improvements[key] = {"road":true}
	act({"type":"mobilise","cohortId":"pop_c"})
	act({"type":"queueMove","unitId":"pop_c","target":"6,3"})
	act({"type":"endTurn"})
	check(s.cohorts.pop_c.state.tileId == "5,3" and s.movementQueues.pop_c == ["6,3"], "Road queue crosses exactly three tiles per one-point turn")
	act({"type":"endTurn"})
	check(s.cohorts.pop_c.state.tileId == "6,3" and not s.movementQueues.has("pop_c"), "Road queue completes next turn")
	# Town growth is immediate, costs exactly 20 Food, and creates a persistent idle Worker.
	s = R.initial_state()
	reject({"type":"grow","settlementId":"main"})
	s.resources.food = 40
	reject({"type":"grow","settlementId":"field"})
	var old_food_delta = R.forecast(s).food
	act({"type":"grow","settlementId":"main"})
	check(s.resources.food == 20 and s.cohorts.size() == 5, "20 Food creates exactly one cohort")
	check(s.cohorts.pop_001.qualification == "Worker" and s.cohorts.pop_001.state.job == null, "New cohort is an idle Worker")
	check(R.forecast(s).food == old_food_delta-1, "New cohort adds one Food upkeep")
	act({"type":"grow","settlementId":"main"})
	check(s.resources.food == 0 and s.cohorts.size() == 6 and s.cohorts.has("pop_002"), "Repeated growth uses another stable ID and cannot overspend")
	reject({"type":"grow","settlementId":"main"})
	act({"type":"assign","cohortId":"pop_001","job":"tile:3,2"})
	check(R.worker_at(s,"3,2").id == "pop_001", "New population can work a map tile")
	act({"type":"mobilise","cohortId":"pop_002"})
	act({"type":"join","cohortId":"pop_002"})
	check(s.cohorts.size() == 6, "New population retains identity while joining/mobilising")
	check(R.validate(JSON.parse_string(JSON.stringify(s))).is_empty(), "Expanded population roundtrip validates")
	var bad_population = s.duplicate(true)
	bad_population.nextCohortNumber = 1.0
	check(not R.validate(bad_population).is_empty(), "Counter collision save rejected")
	var legacy = R.read_json("res://tests/html_reference_trace.json")[0].state
	legacy.log = []
	var upgraded = R.migrate_save(legacy)
	check(upgraded.schemaVersion == 5 and upgraded.cohorts.size() == 4 and upgraded.improvements.is_empty() and upgraded.movementQueues.is_empty(), "Original saves migrate without adding people or improvements")
	check(R.validate(upgraded).is_empty(), "Migrated HTML save validates")
	print("Batch changes: %d checks, %d failures." % [checks,errors.size()])
	quit(0 if errors.is_empty() else 1)
