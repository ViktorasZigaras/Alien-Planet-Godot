extends SceneTree
const Rules = preload("res://scripts/game_rules.gd")
var checks = 0
var failures = []

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		printerr("FAIL: "+message)

func same(a, b) -> bool:
	# JSON numbers are untyped; Godot Dictionary equality distinguishes int/float.
	return JSON.parse_string(JSON.stringify(a)) == JSON.parse_string(JSON.stringify(b))

func run() -> void:
	var state = Rules.initial_state()
	check(Rules.validate(state).is_empty(), "Initial state validates")
	check(same(Rules.forecast(state), {"food":1,"industry":3,"credits":2,"research":1,"influence":2}), "Starting economy")
	check(Rules.supply_field(state)["6,3"] == 4, "Station support cost")
	check(Rules.path(state,"2,3","6,3","cohort").is_empty(), "Initial cohort cannot reach station")
	check(not Rules.path(state,"2,3","6,3","rover").is_empty(), "Rover can reach station")
	check(Rules.movement_cost(state,"4,1") == 2, "Forest cost")
	check(is_inf(Rules.movement_cost(state,"0,0")), "Water blocks movement")
	var trace = Rules.read_json("res://tests/html_reference_trace.json")
	for i in range(trace.size()):
		var step = trace[i]
		var before = state.duplicate(true)
		var result = Rules.command(state, step.command)
		check(result.ok == step.ok, "Command acceptance matches HTML, step %d" % i)
		check(state == before, "Command does not mutate prior state, step %d" % i)
		state = result.state
		var comparable = state.duplicate(true)
		comparable.erase("log")
		check(same(comparable, Rules.migrate_save(step.state)), "Entire simulation state matches HTML, step %d: %s" % [i, str(step.command)])
		check(Rules.validate(state).is_empty(), "State invariants after step %d: %s" % [i, Rules.validate(state)])
		var roundtrip = JSON.parse_string(JSON.stringify(state))
		check(Rules.validate(roundtrip).is_empty() and same(roundtrip, state), "Save roundtrip step %d" % i)
	var variants = []
	var bad = state.duplicate(true)
	bad.schemaVersion = 99
	variants.append(bad)
	bad = state.duplicate(true)
	bad.resources.food = -1
	variants.append(bad)
	bad = state.duplicate(true)
	bad.cohorts.pop_a.state.job = "building:workshop_main"
	variants.append(bad)
	bad = state.duplicate(true)
	bad.units.rover.tileId = "0,0"
	variants.append(bad)
	bad = state.duplicate(true)
	bad.cohorts.pop_a.state = {"kind":"training","settlementId":"main"}
	variants.append(bad)
	bad = state.duplicate(true)
	bad.cohorts.pop_a.state = {"kind":"resident","settlementId":"main","job":null}
	bad.cohorts.pop_b = "bad cohort"
	variants.append(bad)
	bad = state.duplicate(true)
	bad.completed.append("nonexistent")
	variants.append(bad)
	bad = state.duplicate(true)
	bad.buildings["bad"] = {}
	variants.append(bad)
	for v in variants:
		check(not Rules.validate(v).is_empty(), "Malformed state rejected")
	check(not Rules.validate(null).is_empty(), "Non-object rejected")
	state = Rules.initial_state()
	state.cohorts.pop_a.state.job = null
	state.resources.food = 0
	state = Rules.command(state,{"type":"endTurn"}).state
	check(state.resources.food == 0 and not state.warnings.is_empty(), "Shortage clamps and warns")
	state.completed.append("technical_education")
	check(not Rules.reason(state,{"type":"train","cohortId":"pop_c","qualification":"Specialist"}).is_empty(), "Shortage blocks new training")
	state.cohorts.pop_a.state.job = "tile:1,3"
	state = Rules.command(state,{"type":"endTurn"}).state
	check(state.resources.food > 0, "Food recovery possible")
	print("Godot rules: %d checks, %d failures; %d steps compared against actual HTML engine." % [checks, failures.size(), trace.size()])
	quit(0 if failures.is_empty() else 1)
