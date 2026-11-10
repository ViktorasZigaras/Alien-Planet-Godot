extends RefCounted
## B02 trial: assignment is a plan; work occurs once, atomically, at End Turn.
const Base = preload("res://scripts/shell_fixture.gd")
const R = preload("res://scripts/game_rules.gd")
const ID = "b02-economy-v1"
const LOCAL = ["food", "minerals", "industry"]

static func same(a, b) -> bool:
	# JSON stores all numbers as floats; normalize both sides before comparison.
	return JSON.parse_string(JSON.stringify(a)) == JSON.parse_string(JSON.stringify(b))

static func initial() -> Dictionary:
	var s = Base.initial()
	s.scenario = ID
	s.cohorts = {}
	for id in ["pop_a", "pop_b"]:
		s.cohorts[id] = {"id":id,"name":id,"qualification":"Worker","home":"main","equipment":[],"lastUsed":0,"facing":0.0,"lastRoute":[],"state":{"kind":"resident","settlementId":"main","job":null}}
	s.storage = {"main":{"food":8,"minerals":2,"industry":0}}
	s.globalStocks = {"energy":8,"science":0,"culture":0}
	s.lastLedger = {}; s.lastCommands = []; s.obligations = {}
	s.shortages = {"food":0,"energy":0}
	s.log = ["B02 economy trial: two civilians; Food 8, Minerals 2, Energy 8. No growth, construction, AI or fauna."]
	sync(s)
	return s

static func sync(s: Dictionary) -> void:
	for resource in R.RESOURCES:
		s.resources[resource] = 0
		if resource in LOCAL:
			for store in s.storage.values(): s.resources[resource] += store[resource]
		else: s.resources[resource] = s.globalStocks[resource]

static func jobs(s: Dictionary) -> Array:
	var out = [{"id":"idle","label":"Idle · 1 Food","yield":{}} ,{"id":"manufacture","label":"Manufacture · up to 2 Minerals → 2 Industry · 2 Food","yield":{"industry":2}}]
	for key in s.tileAccess.main:
		var amount = R.tile_yield(s,key)
		if not amount.is_empty(): out.append({"id":"tile:"+key,"label":"Hex %s · %s · 2 Food" % [key,R.yield_text(amount)],"yield":amount})
	return out

static func reason(s: Dictionary, cmd: Dictionary) -> String:
	match cmd.get("type", ""):
		"endTurn": return ""
		"assign":
			if not s.cohorts.has(cmd.get("person", "")): return "Unknown person."
			var job = cmd.get("job", "")
			if not jobs(s).any(func(j): return j.id == job): return "Unknown or inaccessible workplace."
			if job.begins_with("tile:"):
				for c in s.cohorts.values():
					if c.id != cmd.person and c.state.job == job: return "That hex already has a worker."
			return ""
	return "Unavailable in B02."

static func change(s: Dictionary, resource: String, amount: int) -> void:
	if resource in LOCAL: s.storage.main[resource] += amount
	else: s.globalStocks[resource] += amount
	sync(s)

static func resolve(state: Dictionary, remedies: bool = true) -> Dictionary:
	var s = state.duplicate(true)
	var opening = s.resources.duplicate(true)
	var gross = {}; var inputs = {}; var upkeep = {}; var spent = {}; var net = {}
	for r in R.RESOURCES:
		gross[r] = 0; inputs[r] = 0; upkeep[r] = 0; spent[r] = 0
	# Pending jobs have performed no work and incur no charge. Prior explicit
	# obligations, if any, remain payable regardless of subsequent assignment.
	for r in s.obligations: spent[r] = s.obligations[r]
	# Emergency Food reassignment selects a free, real, accessible tile only.
	if remedies:
		for id in s.cohorts.keys():
			var trial = resolve(s,false)
			if trial.ledger.closing.food >= 0: break
			var best = s; var best_food = trial.ledger.closing.food
			for job in jobs(s):
				if not job.id.begins_with("tile:") or reason(s,{"type":"assign","person":id,"job":job.id}) != "": continue
				var candidate = s.duplicate(true)
				candidate.cohorts[id].state.job = job.id
				var food = resolve(candidate,false).ledger.closing.food
				if food > best_food: best = candidate; best_food = food
			s = best
		for id in s.cohorts.keys():
			if resolve(s,false).ledger.closing.food >= 0: break
			var c = s.cohorts[id]
			if c.state.job == "manufacture" or (c.state.job != null and c.state.job.begins_with("tile:") and R.tile_yield(s,c.state.job.substr(5)).get("food",0) == 0): c.state.job = null
	# Gather all ordinary tile output first. One person occupies one job.
	for c in s.cohorts.values():
		var job = c.state.job
		upkeep.food += 1 if job == null else 2
		if job != null and job.begins_with("tile:"):
			for r in R.tile_yield(s,job.substr(5)): gross[r] += R.tile_yield(s,job.substr(5))[r]
	for r in R.RESOURCES: change(s,r,gross[r])
	# Capital processing uses the shared pile including this turn's raw output.
	for c in s.cohorts.values():
		if c.state.job == "manufacture":
			var units = mini(2,maxi(0,s.resources.minerals-int(spent.minerals)))
			inputs.minerals += units; gross.industry += units
			change(s,"minerals",-units); change(s,"industry",units)
	for r in R.RESOURCES:
		change(s,r,-upkeep[r]-spent[r])
		net[r] = s.resources[r]-opening[r]
	s.shortages.food = maxi(0,-s.resources.food)
	s.shortages.energy = maxi(0,-s.resources.energy)
	s.obligations = {}
	return {"state":s,"ledger":{"opening":opening,"gross":gross,"inputs":inputs,"upkeep":upkeep,"spending":spent,"net":net,"closing":s.resources.duplicate(true)}}

static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	var blocked = reason(state,cmd)
	if blocked != "": return {"ok":false,"state":state,"message":blocked}
	var s = state.duplicate(true)
	if cmd.type == "assign": s.cohorts[cmd.person].state.job = null if cmd.job == "idle" else cmd.job
	else:
		var outcome = resolve(s)
		s = outcome.state; s.lastLedger = outcome.ledger; s.turn += 1
	s.lastCommands.append(cmd.duplicate(true))
	return {"ok":true,"state":s,"message":"Assignment planned." if cmd.type == "assign" else "Turn reconciled once."}

static func validate(s) -> String:
	if not s is Dictionary or s.get("scenario") != ID: return "Not a B02 save."
	var canonical = initial()
	for key in canonical:
		if not s.has(key) or typeof(s[key]) != typeof(canonical[key]) and not (s[key] is float and canonical[key] is int): return "Missing/invalid field: "+key
	if not same(s.tiles,canonical.tiles) or not same(s.tileAccess,canonical.tileAccess) or not same(s.settlements,canonical.settlements): return "Changed fixture geography."
	if not R.whole(s.turn,1,9007199254740991) or s.cohorts.keys() != canonical.cohorts.keys(): return "Invalid turn or people."
	# Shape-check every person before querying occupancy across all people.
	for id in canonical.cohorts:
		var c = s.cohorts[id]
		if not c is Dictionary or not c.get("state") is Dictionary: return "Invalid person."
		if not c.state.has("job") or (c.state.job != null and not c.state.job is String): return "Invalid job."
	for id in canonical.cohorts:
		var c = s.cohorts[id]
		if not c is Dictionary or not c.get("state") is Dictionary or c.get("id") != id or c.get("home") != "main" or c.get("qualification") != "Worker" or c.get("equipment") != [] or not R.whole(c.get("lastUsed"),0,9007199254740991) or not c.get("lastRoute") is Array or not (c.get("facing") is float or c.get("facing") is int): return "Invalid person."
		if c.state.get("kind") != "resident" or c.state.get("settlementId") != "main" or not c.state.has("job"): return "Invalid job state."
		var job = c.state.job
		if job != null and (not job is String or reason(s,{"type":"assign","person":id,"job":job}) != ""): return "Invalid/duplicate job."
	if s.storage.keys() != ["main"] or not s.storage.main is Dictionary or s.storage.main.keys().size() != 3: return "Invalid storage."
	for r in R.RESOURCES:
		var store = s.storage.main if r in LOCAL else s.globalStocks
		if not R.whole(store.get(r),-9007199254740991,9007199254740991): return "Invalid stock."
	var copy = s.duplicate(true); sync(copy)
	if not same(copy.resources,s.resources): return "Stocks disagree with aggregate."
	for r in s.obligations:
		if r not in R.RESOURCES or not R.whole(s.obligations[r],0,9007199254740991): return "Invalid obligation."
	return ""
