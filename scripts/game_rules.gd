class_name GameRules
extends RefCounted
## Pure serialisable simulation. Commands validate before copying or spending.
## Same demo preset as Alien-Planet HTML; no UI or scene-tree dependencies.

const RESOURCES = ["food", "industry", "credits", "research", "influence"]
const OFFSETS = [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]

static func read_json(path: String):
	return JSON.parse_string(FileAccess.get_file_as_string(path))

static var _preset_cache: Dictionary = {}
static var _nodes_cache: Dictionary = {}

static func preset() -> Dictionary:
	if _preset_cache.is_empty():
		_preset_cache = read_json("res://data/preset.json")
	return _preset_cache

static func nodes() -> Dictionary:
	if _nodes_cache.is_empty():
		_nodes_cache = read_json("res://data/nodes.json")
	return _nodes_cache

static func initial_state() -> Dictionary:
	return read_json("res://data/initial_state.json")

static func tile_id(q, r) -> String:
	return "%d,%d" % [q, r]

static func distance(a: Dictionary, b: Dictionary) -> int:
	return int((abs(a.q-b.q) + abs(a.r-b.r) + abs(a.q+a.r-b.q-b.r)) / 2)

static func neighbours(s: Dictionary, key: String) -> Array:
	var result = []
	var t = s.tiles[key]
	for offset in OFFSETS:
		var k = tile_id(t.q + offset.x, t.r + offset.y)
		if s.tiles.has(k):
			result.append(k)
	return result

static func movement_cost(s: Dictionary, key: String) -> float:
	var t = s.tiles[key]
	if t.baseTerrain == "water":
		return INF
	return 2.0 if t.relief == "hills" or t.feature == "forest" else 1.0

static func reach(s: Dictionary, kind: String) -> int:
	var p = preset()
	return int(p.extendedReach if kind == "cohort" and "field_coordination" in s.completed else p.supply[kind])

static func routes(s: Dictionary, start: String, class_id: String = "") -> Dictionary:
	var costs = {start: 0.0}
	var previous = {}
	var open = [start]
	var supply = supply_field(s) if not class_id.is_empty() else {}
	while not open.is_empty():
		var current = open[0]
		for candidate in open:
			if costs[candidate] < costs[current]:
				current = candidate
		open.erase(current)
		for key in neighbours(s, current):
			if not class_id.is_empty() and supply.get(key, INF) > reach(s, class_id):
				continue
			var cost = costs[current] + movement_cost(s, key)
			if cost < costs.get(key, INF):
				costs[key] = cost
				previous[key] = current
				if key not in open:
					open.append(key)
	return {"costs": costs, "previous": previous}

static func supply_field(s: Dictionary) -> Dictionary:
	return routes(s, s.settlements.main.tileId).costs

static func path(s: Dictionary, start: String, target: String, kind: String) -> Dictionary:
	var found = routes(s, start, kind)
	if not found.costs.has(target):
		return {}
	var steps = [target]
	while steps[0] != start:
		steps.push_front(found.previous[steps[0]])
	return {"path": steps, "cost": found.costs[target]}

static func mobile(s: Dictionary, key: String) -> Dictionary:
	if s.units.has(key):
		var u = s.units[key].duplicate(true)
		u.classId = "rover"
		return u
	if s.cohorts.has(key) and s.cohorts[key].state.kind == "mobile":
		var c = s.cohorts[key]
		var u = c.state.duplicate(true)
		u.merge({"id": c.id, "name": c.name, "classId": "cohort"})
		return u
	return {}

static func site_at(s: Dictionary, key: String) -> Dictionary:
	for site in s.settlements.values():
		if site.tileId == key:
			return site
	return {}

static func district_at(s: Dictionary, key: String) -> Dictionary:
	for district in s.districts.values():
		if district.tileId == key:
			return district
	return {}

static func tile_yield(s: Dictionary, key: String) -> Dictionary:
	if not s.tiles.has(key) or is_inf(movement_cost(s, key)) or not site_at(s, key).is_empty() or not district_at(s, key).is_empty():
		return {}
	if key == "1,3":
		return {"food": 3}
	if key == "2,2":
		return {"industry": 3}
	var t = s.tiles[key]
	return {"industry": 2} if t.relief == "hills" or t.feature == "forest" else {"food": 2}

static func building_name(b: Dictionary) -> String:
	return {"lab": "Field Lab", "civic": "Civic Office", "training": "Training Module", "workshop": "Workshop"}.get(b.type, "Unknown")

static func list_jobs(s: Dictionary, settlement_id: String) -> Array:
	var jobs = []
	var centre = s.tiles[s.settlements[settlement_id].tileId]
	for t in s.tiles.values():
		if distance(centre, t) <= preset().workRange and not tile_yield(s, t.id).is_empty() and (s.constructionProject == null or s.constructionProject.targetTileId != t.id):
			var output = tile_yield(s, t.id)
			var k = output.keys()[0]
			jobs.append({"id": "tile:"+t.id, "label": "%s · %s +%d" % [t.id, k, output[k]], "type": "tile"})
	for b in s.buildings.values():
		if b.settlementId == settlement_id and b.type != "training":
			jobs.append({"id": "building:"+b.id, "label": building_name(b), "type": b.type})
	return jobs

static func occupied(s: Dictionary, job: String, except: String = "") -> bool:
	for c in s.cohorts.values():
		if c.id != except and c.state.kind == "resident" and c.state.get("job") == job:
			return true
	return false

static func job_output(s: Dictionary, c: Dictionary) -> Dictionary:
	if c.state.kind != "resident" or c.state.get("job") == null:
		return {}
	var job = c.state.job
	if job.begins_with("tile:"):
		return tile_yield(s, job.substr(5))
	var b = s.buildings[job.substr(9)]
	match b.type:
		"lab": return {"research": 3 if c.qualification == "Specialist" else 1}
		"civic": return {"influence": 2}
		"workshop": return {"industry": 4 if "precision_assembly" in s.completed else 3}
	return {}

static func forecast(s: Dictionary) -> Dictionary:
	var delta = {"food": 0, "industry": 0, "credits": 0, "research": 0, "influence": 0}
	var p = preset()
	for k in p.landing:
		delta[k] += p.landing[k]
	for c in s.cohorts.values():
		var out = job_output(s, c)
		for k in out:
			delta[k] += out[k]
	delta.food -= s.cohorts.size() * p.foodPerCohort
	for b in s.buildings.values():
		if b.type == "workshop":
			delta.credits -= p.workshopUpkeep
	return delta

## Empty string means legal; every rejected command has a concrete reason.
static func reason(s: Dictionary, cmd: Dictionary) -> String:
	var c = s.cohorts.get(cmd.get("cohortId", ""), {})
	var p = preset()
	match cmd.get("type", ""):
		"endTurn": return ""
		"develop":
			if not nodes().has(cmd.get("nodeId", "")):
				return "Unknown development."
			var n = nodes()[cmd.nodeId]
			if cmd.nodeId in s.completed:
				return "Already developed."
			for key in n.requires:
				if key not in s.completed:
					return "Requires " + nodes()[key].name + "."
			return "Needs %d %s; available %d." % [n.cost, n.resource, s.resources[n.resource]] if s.resources[n.resource] < n.cost else ""
		"move":
			var u = mobile(s, cmd.get("unitId", ""))
			if u.is_empty() or not s.tiles.has(cmd.get("target", "")):
				return "Select a mobile unit and a destination."
			if u.tileId == cmd.target:
				return "Already at that location."
			if is_inf(movement_cost(s, cmd.target)):
				return "Water is impassable."
			var support_cost = supply_field(s).get(cmd.target, INF)
			if support_cost > reach(s, u.classId):
				return "Destination supply cost %s; %s reach %d." % [str(support_cost), u.classId, reach(s, u.classId)]
			var route = path(s, u.tileId, cmd.target, u.classId)
			if route.is_empty():
				return "No path inside supply range."
			return "Path needs %d movement; %d remaining." % [route.cost, u.movementRemaining] if route.cost > u.movementRemaining else ""
		"assign":
			if c.is_empty() or c.state.kind != "resident":
				return "Only residents can take jobs."
			if cmd.get("job") == null:
				return ""
			var job = {}
			for j in list_jobs(s, c.state.settlementId):
				if j.id == cmd.job:
					job = j
			if job.is_empty():
				return "Job is unavailable or outside local work range."
			if occupied(s, cmd.job, c.id):
				return "That job is already occupied."
			return "Civic Office requires an Administrator." if job.type == "civic" and c.qualification != "Administrator" else ""
		"mobilise":
			return "Only residents can mobilise." if c.is_empty() or c.state.kind != "resident" else ""
		"join":
			if c.is_empty() or c.state.kind != "mobile":
				return "Only mobile cohorts can join."
			return "Move onto a settlement centre first." if site_at(s, c.state.tileId).is_empty() else ""
		"train":
			if c.is_empty() or c.state.kind != "resident" or c.state.settlementId != "main" or c.qualification != "Worker":
				return "Training requires a resident Worker at Main Base."
			if cmd.get("qualification") not in ["Specialist", "Administrator"]:
				return "Unknown qualification."
			if "technical_education" not in s.completed:
				return "Requires Technical Education."
			if s.trainingProject != null:
				return "Training Module is busy."
			if s.resources.food <= 0:
				return "Food shortage: restore Food before starting training."
			return "Training needs %d Credits." % p.trainingCost if s.resources.credits < p.trainingCost else ""
		"build":
			if cmd.get("order") not in ["district", "workshop"]:
				return "Unknown construction order."
			if "standard_tooling" not in s.completed:
				return "Requires Standard Tooling."
			if s.constructionProject != null:
				return "Construction slot is busy."
			if c.is_empty() or c.state.kind != "resident" or c.state.get("job") != null or c.qualification != "Worker":
				return "Construction needs one idle resident Worker."
			if s.resources.food <= 0:
				return "Food shortage: restore Food before starting construction."
			var settlement_id = c.state.settlementId
			if cmd.order == "district":
				var key = cmd.get("target", "")
				if not eligible_site(s, key, settlement_id):
					return "Choose clear, unworked flat plains within 2 hexes, inside supply."
				for d in s.districts.values():
					if d.settlementId == settlement_id:
						return "This settlement already has its Production District."
			else:
				var d = s.districts.get(cmd.get("districtId", ""), {})
				if d.is_empty() or d.settlementId != settlement_id:
					return "Select a completed local Production District."
				for b in s.buildings.values():
					if b.get("districtId") == d.id:
						return "This district already contains a Workshop."
			var costs = p.districtCost if cmd.order == "district" else p.workshopCost
			for k in costs:
				if s.resources[k] < costs[k]:
					return "Construction needs %d %s; available %d." % [costs[k], k, s.resources[k]]
			return ""
	return "Unknown command."

static func eligible_site(s: Dictionary, key: String, settlement_id: String) -> bool:
	if not s.tiles.has(key) or not s.settlements.has(settlement_id):
		return false
	var t = s.tiles[key]
	return t.baseTerrain == "plains" and t.relief == "flat" and t.feature == null and site_at(s, key).is_empty() and district_at(s, key).is_empty() and distance(t, s.tiles[s.settlements[settlement_id].tileId]) <= preset().workRange and not occupied(s, "tile:"+key) and supply_field(s).get(key, INF) <= reach(s, "cohort")

static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	var blocked = reason(state, cmd)
	if not blocked.is_empty():
		return {"ok": false, "state": state, "message": blocked}
	var s = state.duplicate(true)
	var c = s.cohorts.get(cmd.get("cohortId", ""), {})
	var p = preset()
	var message = "Order applied."
	match cmd.type:
		"endTurn":
			end_turn(s)
			return {"ok": true, "state": s, "message": "Turn %d ready." % s.turn}
		"assign":
			c.state.job = cmd.get("job")
			message = c.name + (": idle." if c.state.job == null else ": job assigned.")
		"mobilise":
			c.state = {"kind": "mobile", "tileId": s.settlements[c.state.settlementId].tileId, "movementRemaining": 0}
			message = c.name + " mobilised. Movement refreshes next turn."
		"join":
			c.state = {"kind": "resident", "settlementId": site_at(s, c.state.tileId).id, "job": null}
			message = c.name + " joined; assign a job."
		"move":
			var u = mobile(s, cmd.unitId)
			var entity = s.units[cmd.unitId] if s.units.has(cmd.unitId) else s.cohorts[cmd.unitId].state
			entity.movementRemaining -= path(s, u.tileId, cmd.target, u.classId).cost
			entity.tileId = cmd.target
			message = "%s moved to %s." % [u.name, cmd.target]
		"develop":
			var n = nodes()[cmd.nodeId]
			s.resources[n.resource] -= n.cost
			s.completed.append(cmd.nodeId)
			message = "Developed " + n.name + "."
		"train":
			s.resources.credits -= p.trainingCost
			s.trainingProject = {"cohortId": c.id, "qualification": cmd.qualification, "turnsRemaining": p.trainingTurns}
			c.state = {"kind": "training", "settlementId": "main"}
			message = "%s: %d turns of training." % [c.name, p.trainingTurns]
		"build":
			var costs = p.districtCost if cmd.order == "district" else p.workshopCost
			for k in costs:
				s.resources[k] -= costs[k]
			var settlement_id = c.state.settlementId
			s.constructionProject = {"order": cmd.order, "cohortId": c.id, "settlementId": settlement_id, "targetTileId": cmd.get("target") if cmd.order == "district" else null, "districtId": cmd.get("districtId") if cmd.order == "workshop" else null, "turnsRemaining": p.districtTurns if cmd.order == "district" else p.workshopTurns}
			c.state = {"kind": "building", "settlementId": settlement_id}
			message = cmd.order.capitalize() + " construction started."
	s.log.push_front(message)
	s.log = s.log.slice(0, 100)
	return {"ok": true, "state": s, "message": message}

static func end_turn(s: Dictionary) -> void:
	var delta = forecast(s)
	s.warnings = []
	for k in RESOURCES:
		var total = s.resources[k] + delta[k]
		s.resources[k] = max(0, total)
		if total < 0:
			s.warnings.append("Food shortage. New training and construction require positive Food." if k == "food" else "Unpaid %s upkeep." % k)
	if s.resources.food == 0 and s.warnings.is_empty():
		s.warnings.append("Food stock is empty. New training and construction are blocked.")
	var completed = []
	if s.trainingProject != null:
		s.trainingProject.turnsRemaining -= 1
		if s.trainingProject.turnsRemaining == 0:
			var t = s.trainingProject
			var c = s.cohorts[t.cohortId]
			c.qualification = t.qualification
			c.state = {"kind": "resident", "settlementId": "main", "job": null}
			s.trainingProject = null
			completed.append(c.name + " trained; idle.")
	if s.constructionProject != null:
		s.constructionProject.turnsRemaining -= 1
		if s.constructionProject.turnsRemaining == 0:
			var t = s.constructionProject
			if t.order == "district":
				var key = "district_"+t.settlementId
				s.districts[key] = {"id": key, "settlementId": t.settlementId, "tileId": t.targetTileId}
			else:
				var key = "workshop_"+t.settlementId
				s.buildings[key] = {"id": key, "type": "workshop", "settlementId": t.settlementId, "districtId": t.districtId}
			s.cohorts[t.cohortId].state = {"kind": "resident", "settlementId": t.settlementId, "job": null}
			s.constructionProject = null
			completed.append(t.order.capitalize() + " complete; builder idle.")
	s.turn += 1
	for c in s.cohorts.values():
		if c.state.kind == "mobile":
			c.state.movementRemaining = preset().movement.cohort
	for u in s.units.values():
		u.movementRemaining = preset().movement.rover
	var parts = []
	for k in RESOURCES:
		parts.append("%s %+d" % [k, delta[k]])
	s.log.push_front("Turn %d: %s%s" % [s.turn, " · ".join(parts), " | "+" ".join(completed) if not completed.is_empty() else ""])
	s.log = s.log.slice(0, 100)

## Imported JSON is accepted only after structural and simulation checks.
static func validate(s) -> String:
	if not s is Dictionary:
		return "Save must be a JSON object."
	var base = initial_state()
	for k in base:
		if not s.has(k):
			return "Missing field: " + k
		if k in ["trainingProject", "constructionProject"]:
			if s[k] != null and not s[k] is Dictionary:
				return "Invalid project field: " + k
			continue
		if typeof(s[k]) != typeof(base[k]):
			# JSON numbers may be floats; initial JSON is parsed the same way.
			return "Missing or invalid field: " + k
	if s.schemaVersion != 1 or s.rulesVersion != 1:
		return "Unsupported save version."
	if not whole(s.turn, 1, 100000000):
		return "Invalid turn."
	if s.tiles != base.tiles or s.settlements != base.settlements:
		return "Unsupported map or settlement data."
	for k in RESOURCES:
		if not whole(s.resources.get(k), 0, 9007199254740991):
			return "Invalid resource stock."
	if not same_keys(s.cohorts, base.cohorts) or not same_keys(s.units, base.units):
		return "Expected four original cohorts and one rover."
	var seen = []
	for key in s.completed:
		if not key is String or not nodes().has(key) or key in seen:
			return "Invalid development nodes."
		seen.append(key)
		for pre in nodes()[key].requires:
			if pre not in s.completed:
				return "Missing development prerequisite."
	for key in base.buildings:
		if s.buildings.get(key) != base.buildings[key]:
			return "Starter facility changed."
	var district_tiles = []
	for key in s.districts:
		var d = s.districts[key]
		if not d is Dictionary or not has_fields(d, ["id", "settlementId", "tileId"]) or not d.settlementId is String or not s.settlements.has(d.settlementId) or d.id != key or key != "district_"+d.settlementId or not d.tileId is String or not s.tiles.has(d.tileId) or d.tileId in district_tiles or "standard_tooling" not in s.completed:
			return "Invalid district."
		district_tiles.append(d.tileId)
		var t = s.tiles[d.tileId]
		if t.baseTerrain != "plains" or t.relief != "flat" or t.feature != null or not site_at(s, t.id).is_empty() or distance(t, s.tiles[s.settlements[d.settlementId].tileId]) > 2:
			return "Invalid district site."
	for key in s.buildings:
		if base.buildings.has(key):
			continue
		var b = s.buildings[key]
		if not b is Dictionary or not has_fields(b, ["id", "type", "settlementId", "districtId"]) or not b.settlementId is String or b.id != key or key != "workshop_"+b.settlementId or b.type != "workshop" or not s.districts.has(b.districtId) or s.districts[b.districtId].settlementId != b.settlementId:
			return "Invalid building."
	for key in s.cohorts:
		var c = s.cohorts[key]
		if not c is Dictionary or not has_fields(c, ["id", "name", "qualification", "state"]) or c.id != key or not c.name is String or c.name.length() > 100 or c.qualification not in ["Worker", "Specialist", "Administrator"] or not c.state is Dictionary or not c.state.has("kind"):
			return "Invalid cohort."
		var st = c.state
		if st.kind == "mobile":
			if not has_fields(st, ["tileId", "movementRemaining"]) or not s.tiles.has(st.tileId) or not whole(st.movementRemaining, 0, 1) or supply_field(s).get(st.tileId, INF) > reach(s, "cohort"):
				return "Invalid mobile cohort."
		elif st.kind in ["resident", "training", "building"]:
			if not s.settlements.has(st.get("settlementId", "")) or (st.kind == "resident" and not st.has("job")):
				return "Invalid resident or project participant."
		else:
			return "Invalid population state."
	# Validate all cohort structures first; assignment checks inspect other cohorts.
	for key in s.cohorts:
		var c = s.cohorts[key]
		if c.state.kind == "resident" and c.state.job != null:
			if not c.state.job is String or not reason(s, {"type": "assign", "cohortId": key, "job": c.state.job}).is_empty():
				return "Invalid or duplicate job."
	var u = s.units.rover
	if not u is Dictionary or not has_fields(u, ["id", "name", "tileId", "movementRemaining"]) or u.id != "rover" or not u.name is String or not s.tiles.has(u.tileId) or not whole(u.movementRemaining, 0, 2) or supply_field(s).get(u.tileId, INF) > 5:
		return "Invalid rover."
	if s.trainingProject != null:
		var t = s.trainingProject
		if not t is Dictionary or not has_fields(t, ["cohortId", "qualification", "turnsRemaining"]) or not s.cohorts.has(t.cohortId) or t.qualification not in ["Specialist", "Administrator"] or not whole(t.turnsRemaining, 1, 2) or "technical_education" not in s.completed:
			return "Invalid training project."
		var c = s.cohorts[t.cohortId]
		if c.state.kind != "training" or c.state.settlementId != "main" or c.qualification != "Worker":
			return "Invalid trainee."
	if s.constructionProject != null:
		var t = s.constructionProject
		if not t is Dictionary or not has_fields(t, ["order", "cohortId", "settlementId", "targetTileId", "districtId", "turnsRemaining"]) or t.order not in ["district", "workshop"] or not s.cohorts.has(t.cohortId) or not s.settlements.has(t.settlementId) or not whole(t.turnsRemaining, 1, 1 if t.order == "district" else 2) or "standard_tooling" not in s.completed:
			return "Invalid construction project."
		var c = s.cohorts[t.cohortId]
		if c.state.kind != "building" or c.qualification != "Worker" or c.state.settlementId != t.settlementId:
			return "Invalid builder."
		if t.order == "district":
			if not t.targetTileId is String or not eligible_site(s, t.targetTileId, t.settlementId):
				return "Invalid reserved site."
			for d in s.districts.values():
				if d.settlementId == t.settlementId:
					return "District already exists."
		else:
			if not s.districts.has(t.districtId) or s.districts[t.districtId].settlementId != t.settlementId:
				return "Invalid Workshop project."
			for b in s.buildings.values():
				if b.get("districtId") == t.districtId:
					return "Workshop already exists."
	for c in s.cohorts.values():
		if c.state.kind == "training" and (s.trainingProject == null or s.trainingProject.cohortId != c.id):
			return "Orphan trainee."
		if c.state.kind == "building" and (s.constructionProject == null or s.constructionProject.cohortId != c.id):
			return "Orphan builder."
	if s.log.size() > 100 or s.warnings.size() > 10:
		return "Oversized log."
	for line in s.log + s.warnings:
		if not line is String or line.length() > 4000:
			return "Invalid log text."
	return ""

static func whole(value, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(float(value)) and value >= minimum and value <= maximum

static func same_keys(a: Dictionary, b: Dictionary) -> bool:
	return a.size() == b.size() and a.keys().all(func(k): return b.has(k))

static func has_fields(d: Dictionary, fields: Array) -> bool:
	return fields.all(func(k): return d.has(k))
