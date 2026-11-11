extends RefCounted
## B02 trial: assignment is a plan; work occurs once, atomically, at End Turn.
const Base = preload("res://scripts/shell_fixture.gd")
const R = preload("res://scripts/game_rules.gd")
const Construction = preload("res://scripts/construction_rules.gd")
const Progress = preload("res://scripts/progression_rules.gd")
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
	if s.has("construction"):
		out.append_array([{"id":"construct","label":"Construction · 2 effort · 2 Food","yield":{}},{"id":"mixed","label":"Split · 1 manufacturing + 1 construction effort · 2 Food","yield":{"industry":1}},{"id":"builder","label":"On-site builder · 2 effort · 1 Food","yield":{}}])
		for b in s.buildings.values():
			if b.type == "greenhouse": out.append({"id":"building:"+b.id+"#0","label":"Greenhouse · 3 Food · consumes 1 Energy","yield":{"food":3}})
	if s.has("progression"):
		out.append_array([{"id":"study","label":"Study · 1 Science · Scientist +2","yield":{"science":1}},{"id":"generate","label":"Generate · 2 Energy (4 after research)","yield":{"energy":2}},{"id":"training","label":"Continue enrolled training","yield":{}}])
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
			var c = s.cohorts[cmd.person]
			if s.has("progression"):
				if s.progression.training.has(c.id) and job != "training": return "Finish enrolled training before changing this person's job."
				if job == "training" and not s.progression.training.has(c.id): return "Enroll in training first."
				if job != "idle" and c.state.kind == "resident" and c.state.job == null and Progress.working(s)>=Progress.support(s,c.id,job): return "No spare working-population support."
			if c.state.kind == "mobile" and job not in ["idle","builder"]: return "Return the builder to the settlement before assigning settlement work."
			if job == "builder" and (c.state.kind != "mobile" or cmd.person not in s.get("construction",{}).get("holders",[])): return "Equip the reusable kit and travel to the site first."
			var reserved = s.get("commitments",{}).get("people",{}).get(cmd.person,{})
			if not reserved.is_empty() and reserved.job != job: return "Person committed to an authorized plan; cancel its goals or disable planning first."
			if not jobs(s).any(func(j): return j.id == job): return "Unknown or inaccessible workplace."
			if job.begins_with("tile:") or job.begins_with("building:"):
				for occupant in s.cohorts.values():
					if occupant.id != cmd.person and occupant.state.job == job: return "That hex already has a worker."
			return ""
	if s.has("construction"):
		if s.has("progression") and cmd.get("type") == "enqueue" and cmd.get("recipe") == "farm_upgrade" and "cultivation" not in s.progression.techs: return "Research Cultivation to unlock Farm upgrades."
		if cmd.get("type","") in ["enqueue","hold","deployBuilder","returnBuilder"]: return Construction.reason(s,cmd)
		if cmd.get("type","") in ["move","queueMove","cancelMove"]:
			if not s.cohorts.has(cmd.get("unitId","")) or s.cohorts[cmd.unitId].state.kind != "mobile": return "Choose a deployed builder."
			return R.reason(s,cmd)
	return "Unavailable in B02."

static func change(s: Dictionary, resource: String, amount: int) -> void:
	if resource in LOCAL: s.storage.main[resource] += amount
	else: s.globalStocks[resource] += amount
	sync(s)

static func resolve(state: Dictionary, remedies: bool = true) -> Dictionary:
	var s = state.duplicate(true)
	if s.has("progression"):
		var ids = s.cohorts.keys(); ids.sort()
		var ordered = {}
		for id in ids: ordered[id] = s.cohorts[id]
		s.cohorts = ordered
	Progress.prepare(s)
	var opening = s.resources.duplicate(true)
	var gross = {}; var inputs = {}; var upkeep = {}; var spent = {}; var net = {}; var activity = {}
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
			var emergency = s.duplicate(true)
			if emergency.has("commitments"): emergency.commitments.people = {}
			for job in jobs(s):
				if not job.id.begins_with("tile:") or reason(emergency,{"type":"assign","person":id,"job":job.id}) != "": continue
				var candidate = s.duplicate(true)
				candidate.cohorts[id].state.job = job.id
				var food = resolve(candidate,false).ledger.closing.food
				if food > best_food: best = candidate; best_food = food
			s = best
		for id in s.cohorts.keys():
			if resolve(s,false).ledger.closing.food >= 0: break
			var c = s.cohorts[id]
			if c.state.kind == "mobile": continue
			if c.state.job in ["manufacture","construct","mixed"] or (c.state.job != null and c.state.job.begins_with("tile:") and R.tile_yield(s,c.state.job.substr(5)).get("food",0) == 0): c.state.job = null
	# Gather all ordinary tile output first. One person occupies one job.
	for c in s.cohorts.values():
		var job = c.state.job
		if c.id in s.get("construction",{}).get("travelled",[]): upkeep.food += 1; continue
		upkeep.food += 1 if job == null or c.state.kind == "mobile" else 2
		if s.has("progression"):
			var produced = Progress.output(s,c)
			if job is String and job.begins_with("building:"):
				if s.resources.energy<=upkeep.energy: produced = {}
				else: upkeep.energy += 1
			for resource in produced: gross[resource] += produced[resource]
			activity[c.id] = {"qualification":c.qualification,"output":produced}
		elif job != null and job.begins_with("tile:"):
			for r in R.tile_yield(s,job.substr(5)): gross[r] += R.tile_yield(s,job.substr(5))[r]
		elif job != null and job.begins_with("building:") and s.resources.energy>upkeep.energy:
			gross.food += 3; upkeep.energy += 1
	for r in R.RESOURCES: change(s,r,gross[r])
	# Capital processing uses the shared pile including this turn's raw output.
	for c in s.cohorts.values():
		if c.id in s.get("construction",{}).get("travelled",[]): continue
		if c.state.job in ["manufacture","mixed"]:
			var units = mini(1 if c.state.job == "mixed" else 2,maxi(0,s.resources.minerals-int(spent.minerals)))
			inputs.minerals += units; gross.industry += units
			change(s,"minerals",-units); change(s,"industry",units)
	for r in R.RESOURCES:
		change(s,r,-upkeep[r]-spent[r])
	s.obligations = {}
	var ledger = {"opening":opening,"gross":gross,"inputs":inputs,"upkeep":upkeep,"spending":spent,"net":net,"closing":{},"activity":activity}
	Construction.resolve(s,ledger)
	Progress.finish_turn(s,ledger)
	for r in R.RESOURCES:
		net[r] = s.resources[r]-opening[r]
	s.shortages.food = maxi(0,-s.resources.food)
	s.shortages.energy = maxi(0,-s.resources.energy)
	s.obligations = {}
	ledger.closing = s.resources.duplicate(true)
	return {"state":s,"ledger":ledger}

static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	var blocked = reason(state,cmd)
	if blocked != "": return {"ok":false,"state":state,"message":blocked}
	var s = state.duplicate(true)
	if s.has("construction") and cmd.type in ["enqueue","hold","deployBuilder","returnBuilder"]:
		Construction.apply(s,cmd)
		s.lastCommands.append(cmd.duplicate(true))
		return {"ok":true,"state":s,"message":"Construction order updated."}
	if s.has("construction") and cmd.type in ["move","queueMove","cancelMove"]:
		var result = R.command(s,cmd)
		if result.ok:
			s = result.state
			if s.cohorts[cmd.unitId].state.tileId != state.cohorts[cmd.unitId].state.tileId or s.moveProgress != state.moveProgress:
				if cmd.unitId not in s.construction.travelled: s.construction.travelled.append(cmd.unitId)
			s.cohorts[cmd.unitId].state.job = null
		return {"ok":result.ok,"state":s,"message":result.message}
	if cmd.type == "assign": s.cohorts[cmd.person].state.job = null if cmd.job == "idle" else cmd.job
	else:
		var outcome = resolve(s)
		s = outcome.state; s.lastLedger = outcome.ledger; s.turn += 1
		if s.has("construction"):
			s.construction.travelled = []
			for c in s.cohorts.values():
				c.lastRoute = []
				if c.state.kind == "mobile": c.state.movementRemaining = R.movement_budget(c)
			for id in s.movementQueues.keys():
				var before = s.cohorts[id].state.tileId; var paid = s.moveProgress.get(id,0)
				R.advance_queue(s,id)
				if before != s.cohorts[id].state.tileId or paid != s.moveProgress.get(id,0): s.construction.travelled.append(id)
	s.lastCommands.append(cmd.duplicate(true))
	return {"ok":true,"state":s,"message":"Assignment planned." if cmd.type == "assign" else "Turn reconciled once."}

static func validate(s) -> String:
	if not s is Dictionary or s.get("scenario") != ID: return "Not a B02 save."
	var canonical = initial()
	for key in canonical:
		if not s.has(key) or typeof(s[key]) != typeof(canonical[key]) and not (s[key] is float and canonical[key] is int): return "Missing/invalid field: "+key
	var towns = s.settlements.duplicate(true)
	if s.has("progression") and towns.has("main"): towns.main.growth = 0
	if not same(s.tiles,canonical.tiles) or not same(s.tileAccess,canonical.tileAccess) or not same(towns,canonical.settlements): return "Changed fixture geography."
	if not R.whole(s.turn,1,9007199254740991) or (not s.has("progression") and s.cohorts.keys() != canonical.cohorts.keys()): return "Invalid turn or people."
	if not s.cohorts.has("pop_a") or not s.cohorts.has("pop_b"): return "Missing original people."
	# Shape-check every person before querying occupancy across all people.
	for id in s.cohorts:
		var c = s.cohorts[id]
		if not c is Dictionary or not c.get("state") is Dictionary: return "Invalid person."
		if not c.state.has("job") or (c.state.job != null and not c.state.job is String): return "Invalid job."
	for id in s.cohorts:
		var c = s.cohorts[id]
		var allowed = ["Worker","Biologist","Scientist"] if s.has("progression") else ["Worker"]
		if not c is Dictionary or not c.get("state") is Dictionary or c.get("id") != id or c.get("home") != "main" or c.get("qualification") not in allowed or c.get("equipment") != [] or not R.whole(c.get("lastUsed"),0,9007199254740991) or not c.get("lastRoute") is Array or not (c.get("facing") is float or c.get("facing") is int): return "Invalid person."
		if s.has("construction") and c.state.get("kind") == "mobile":
			if not s.tiles.has(c.state.get("tileId","")) or not (c.state.get("movementRemaining") is float or c.state.get("movementRemaining") is int): return "Invalid builder location."
		elif c.state.get("kind") != "resident" or c.state.get("settlementId") != "main" or not c.state.has("job"): return "Invalid job state."
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
