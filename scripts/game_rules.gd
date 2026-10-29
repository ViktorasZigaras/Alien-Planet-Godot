class_name GameRules
extends RefCounted
## Pure serialisable simulation. Commands validate before copying or spending.
## Same demo preset as Alien-Planet HTML; no UI or scene-tree dependencies.

const EPSILON = 0.000001
const RESOURCES = ["food", "industry", "credits", "research", "influence"]
const OFFSETS = [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]

static func read_json(path: String):
	return JSON.parse_string(FileAccess.get_file_as_string(path))

static var _preset_cache: Dictionary = {}
static var _nodes_cache: Dictionary = {}
static var _content_cache: Dictionary = {}

static func preset() -> Dictionary:
	if _preset_cache.is_empty():
		_preset_cache = read_json("res://data/preset.json")
	return _preset_cache

static func nodes() -> Dictionary:
	if _nodes_cache.is_empty():
		_nodes_cache = read_json("res://data/nodes.json")
	return _nodes_cache

static func content() -> Dictionary:
	if _content_cache.is_empty(): _content_cache = read_json("res://data/content.json")
	return _content_cache

static func district_key(town: String, kind: String) -> String:
	return "district_"+town+("" if kind == "production" else "_"+kind)

static func building_key(town: String, kind: String) -> String:
	return kind+"_"+town

static func buildable_buildings() -> Array:
	return content().buildings.keys().filter(func(key): return content().buildings[key].has("district"))

static func training_reason(s: Dictionary, qualification) -> String:
	if not qualification is String or not content().qualifications.has(qualification) or not content().qualifications[qualification].trainable:
		return "Unknown or untrainable qualification."
	for key in ["technical_education",content().qualifications[qualification].requires]:
		if key not in s.completed: return "Requires "+nodes()[key].name+"."
	return ""

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
	if s.get("improvements", {}).get(key, {}).get("road", false):
		return 1.0 / 3.0
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
			if not class_id.is_empty() and (supply.get(key, INF) > reach(s, class_id)+EPSILON or movement_cost(s,key) > preset().movement[class_id]+EPSILON):
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
		if district is Dictionary and district.get("tileId") == key:
			return district
	return {}

static func tile_yield(s: Dictionary, key: String) -> Dictionary:
	if not s.tiles.has(key) or is_inf(movement_cost(s, key)) or not site_at(s, key).is_empty() or not district_at(s, key).is_empty():
		return {}
	var t = s.tiles[key]
	var output = {"industry": 2} if t.relief == "hills" or t.feature == "forest" else {"food": 2}
	if key == "1,3": output = {"food": 3}
	if key == "2,2": output = {"industry": 3}
	for improvement in s.get("improvements", {}).get(key, {}):
		if not s.improvements[key][improvement]: continue
		for resource in content().improvements[improvement].yield:
			output[resource] = output.get(resource,0)+content().improvements[improvement].yield[resource]
	return output

static func reserved_for_district(s: Dictionary, key: String) -> bool:
	return s.constructionProject != null and s.constructionProject.order == "district" and s.constructionProject.targetTileId == key

static func project_duration(order: String) -> int:
	if content().improvements.has(order): return int(preset().improvementTurns)
	return int(preset().districtTurns if order == "district" else preset().workshopTurns)

static func improvement_site_reason(s: Dictionary, key, settlement_id: String, kind: String) -> String:
	if not key is String or not s.tiles.has(key) or is_inf(movement_cost(s, key)):
		return "Choose a passable land hex."
	var t = s.tiles[key]
	if distance(t, s.tiles[s.settlements[settlement_id].tileId]) > preset().workRange:
		return "Improvement must be within 2 hexes of its town."
	if supply_field(s).get(key, INF) > reach(s, "cohort") + EPSILON:
		return "Improvement site is outside cohort supply."
	if s.get("improvements", {}).get(key, {}).get(kind, false):
		return kind.capitalize()+" already exists here."
	if kind != "road":
		if not site_at(s,key).is_empty() or not district_at(s,key).is_empty(): return "Site improvements cannot occupy a town or district."
		for other in s.improvements.get(key,{}):
			if other != "road" and s.improvements[key][other]: return "A site improvement already occupies this hex; a Road may coexist."
		var terrain_rule = content().improvements[kind].site
		if terrain_rule == "flat" and (t.relief != "flat" or t.feature != null): return "This improvement needs clear flat plains."
		if terrain_rule == "hills" and t.relief != "hills": return "A Mine needs hills."

	return ""

static func migrate_save(data):
	if not data is Dictionary: return data
	var s = data.duplicate(true)
	if s.get("schemaVersion") == 1 and s.get("rulesVersion") == 1:
		s.schemaVersion = 2.0
		s.rulesVersion = 2.0
		s.improvements = {}
	if s.get("schemaVersion") == 2 and s.get("rulesVersion") == 2:
		s.schemaVersion = 3.0
		s.rulesVersion = 3.0
		s.movementQueues = {}
	if s.get("schemaVersion") == 3 and s.get("rulesVersion") == 3:
		s.schemaVersion = 4.0
		s.rulesVersion = 4.0
		s.nextCohortNumber = 1.0
	if s.get("schemaVersion") == 4 and s.get("rulesVersion") == 4:
		s.schemaVersion = 5.0
		s.rulesVersion = 5.0
		if s.get("districts") is Dictionary:
			for district in s.districts.values():
				if district is Dictionary: district.type = "production"
		if s.get("constructionProject") is Dictionary and s.constructionProject.get("order") == "district": s.constructionProject.districtType = "production"
	return s

static func building_name(b: Dictionary) -> String:
	return content().buildings.get(b.type,{}).get("name","Unknown")

static func list_jobs(s: Dictionary, settlement_id: String) -> Array:
	var jobs = []
	var centre = s.tiles[s.settlements[settlement_id].tileId]
	for t in s.tiles.values():
		if distance(centre, t) <= preset().workRange and not tile_yield(s, t.id).is_empty() and not reserved_for_district(s, t.id):
			var output = tile_yield(s, t.id)
			var parts = []
			for resource in output: parts.append("%s +%d" % [resource,output[resource]])
			jobs.append({"id":"tile:"+t.id,"label":t.id+" · "+", ".join(parts),"type":"tile"})
	for b in s.buildings.values():
		if b.settlementId == settlement_id and b.type != "training":
			jobs.append({"id": "building:"+b.id, "label": building_name(b), "type": b.type})
	return jobs

static func occupied(s: Dictionary, job: String, except: String = "") -> bool:
	for c in s.cohorts.values():
		if c.id != except and c.state.kind == "resident" and c.state.get("job") == job:
			return true
	return false

static func worker_at(s: Dictionary, tile_key: String) -> Dictionary:
	for c in s.cohorts.values():
		if c.state.kind == "resident" and c.state.get("job") == "tile:"+tile_key:
			return c
	return {}

static func job_output(s: Dictionary, c: Dictionary) -> Dictionary:
	if c.state.kind != "resident" or c.state.get("job") == null: return {}
	var job = c.state.job
	if job.begins_with("tile:"):
		var output = tile_yield(s,job.substr(5))
		var role = content().qualifications[c.qualification]
		if role.tile_bonus > 0 and output.has(role.resource): output[role.resource] += role.tile_bonus
		return output
	var b = s.buildings[job.substr(9)]
	var definition = content().buildings[b.type]
	if definition.resource == "": return {}
	var amount = definition.specialists.get(c.qualification,definition.output)
	if definition.get("upgrade","") in s.completed: amount += 1
	return {definition.resource:amount}

static func map_yield(s: Dictionary, tile: String) -> Dictionary:
	var worker = worker_at(s,tile)
	return tile_yield(s,tile) if worker.is_empty() else job_output(s,worker)

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
		delta.credits -= p.workshopUpkeep if b.type == "workshop" else content().buildings[b.type].upkeep
	return delta

## Empty string means legal; every rejected command has a concrete reason.
static func reason(s: Dictionary, cmd: Dictionary) -> String:
	var c = s.cohorts.get(cmd.get("cohortId", ""), {})
	var p = preset()
	match cmd.get("type", ""):
		"endTurn": return ""
		"grow":
			var town = cmd.get("settlementId", "")
			if not s.settlements.has(town): return "Select a town."
			if not s.cohorts.values().any(func(person): return person.state.get("settlementId") == town): return "Population growth needs an inhabited town."
			return "Growth needs %d Food; available %d." % [p.growthFoodCost, s.resources.food] if s.resources.food < p.growthFoodCost else ""
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
		"cancelMove":
			return "No queued route for this unit." if not s.movementQueues.has(cmd.get("unitId", "")) else ""
		"queueMove":
			var u = mobile(s, cmd.get("unitId", ""))
			if u.is_empty() or not s.tiles.has(cmd.get("target", "")): return "Select a mobile unit and destination."
			var existing = s.movementQueues.get(u.id, [])
			var start = existing.back() if cmd.get("append", false) and not existing.is_empty() else u.tileId
			if start == cmd.target: return "Already at that destination."
			var planned = path(s, start, cmd.target, u.classId)
			if planned.is_empty(): return "No traversable route within this unit's supply reach."
			if planned.path.size()-1+(existing.size() if cmd.get("append",false) else 0) > 1000: return "Movement queue is limited to 1000 hex steps."
			return ""
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
			return "Path needs %.2f movement; %.2f remaining." % [route.cost, u.movementRemaining] if route.cost > u.movementRemaining + EPSILON else ""
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
			if job.type != "tile":
				var eligible = content().buildings[job.type].get("eligible",[])
				if not eligible.is_empty() and c.qualification not in eligible: return "Job requires "+", ".join(eligible)+"."
			return ""
		"mobilise":
			return "Only residents can mobilise." if c.is_empty() or c.state.kind != "resident" else ""
		"join":
			if c.is_empty() or c.state.kind != "mobile":
				return "Only mobile cohorts can join."
			return "Move onto a settlement centre first." if site_at(s, c.state.tileId).is_empty() else ""
		"train":
			if c.is_empty() or c.state.kind != "resident" or c.state.settlementId != "main" or c.qualification != "Worker":
				return "Training requires a resident Worker at Main Base."
			var training_block = training_reason(s,cmd.get("qualification"))
			if not training_block.is_empty(): return training_block
			if s.trainingProject != null:
				return "Training Module is busy."
			if s.resources.food <= 0:
				return "Food shortage: restore Food before starting training."
			return "Training needs %d Credits." % p.trainingCost if s.resources.credits < p.trainingCost else ""
		"improve":
			if not content().improvements.has(cmd.get("improvement","")): return "Unknown improvement."
			var unlock = content().improvements[cmd.improvement].requires
			if unlock != "" and unlock not in s.completed: return "Requires "+nodes()[unlock].name+"."
			if s.constructionProject != null: return "Construction slot is busy."
			if c.is_empty() or c.state.kind != "resident" or c.state.get("job") != null or c.qualification not in ["Worker","Engineer"]: return "Improvement needs an idle resident Worker or Engineer."
			if s.resources.food <= 0: return "Food shortage: restore Food before construction."
			var blocked = improvement_site_reason(s, cmd.get("target"), c.state.settlementId, cmd.improvement)
			if not blocked.is_empty(): return blocked
			for k in p.improvementCost:
				if s.resources[k] < p.improvementCost[k]: return "Improvement needs %d %s." % [p.improvementCost[k], k]
			return ""
		"build":
			if cmd.get("order") != "district" and cmd.get("order") not in buildable_buildings(): return "Unknown construction order."
			if s.constructionProject != null: return "Construction slot is busy."
			if c.is_empty() or c.state.kind != "resident" or c.state.get("job") != null or c.qualification not in ["Worker","Engineer"]: return "Construction needs an idle resident Worker or Engineer."
			if s.resources.food <= 0: return "Food shortage: restore Food before construction."
			var town = c.state.settlementId
			var unlock = ""
			if cmd.order == "district":
				var kind = cmd.get("districtType","production")
				if not content().districts.has(kind): return "Unknown district type."
				unlock = content().districts[kind].requires
				if not eligible_site(s,cmd.get("target",""),town): return "Choose unworked clear flat plains within two hexes, without a site improvement."
				if s.districts.has(district_key(town,kind)): return "This town already has its "+content().districts[kind].name+"."
			else:
				var definition = content().buildings[cmd.order]
				unlock = definition.requires
				var d = s.districts.get(cmd.get("districtId",""),{})
				if d.is_empty() or d.settlementId != town or d.type != definition.district: return "Requires a completed local "+content().districts[definition.district].name+"."
				if s.buildings.has(building_key(town,cmd.order)): return "This building already exists."
			if unlock not in s.completed: return "Requires "+nodes()[unlock].name+"."
			var costs = p.districtCost if cmd.order == "district" else p.workshopCost
			for key in costs:
				if s.resources[key] < costs[key]: return "Construction needs %d %s." % [costs[key],key]
			return ""

	return "Unknown command."

static func eligible_site(s: Dictionary, key: String, settlement_id: String) -> bool:
	if not s.tiles.has(key) or not s.settlements.has(settlement_id):
		return false
	var t = s.tiles[key]
	return t.baseTerrain == "plains" and t.relief == "flat" and t.feature == null and site_at(s, key).is_empty() and district_at(s, key).is_empty() and distance(t, s.tiles[s.settlements[settlement_id].tileId]) <= preset().workRange and not has_site_improvement(s,key) and not occupied(s, "tile:"+key) and supply_field(s).get(key, INF) <= reach(s, "cohort")

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
		"grow":
			s.resources.food -= p.growthFoodCost
			var key = "pop_%03d" % s.nextCohortNumber
			s.nextCohortNumber += 1
			s.cohorts[key] = {"id":key,"name":"Cohort %03d" % (s.nextCohortNumber-1),"qualification":"Worker","state":{"kind":"resident","settlementId":cmd.settlementId,"job":null}}
			message = s.cohorts[key].name+" created at "+s.settlements[cmd.settlementId].name+"; idle Worker, +1 Food upkeep per turn."
		"assign":
			c.state.job = cmd.get("job")
			message = c.name + (": idle." if c.state.job == null else ": job assigned.")
		"mobilise":
			c.state = {"kind": "mobile", "tileId": s.settlements[c.state.settlementId].tileId, "movementRemaining": 0}
			message = c.name + " mobilised. Movement refreshes next turn."
		"join":
			s.movementQueues.erase(c.id)
			c.state = {"kind": "resident", "settlementId": site_at(s, c.state.tileId).id, "job": null}
			message = c.name + " joined; assign a job."
		"cancelMove":
			s.movementQueues.erase(cmd.unitId)
			message = "Movement queue cancelled."
		"queueMove":
			var u = mobile(s, cmd.unitId)
			var existing = s.movementQueues.get(u.id, []).duplicate()
			if not cmd.get("append", false): existing = []
			var start = existing.back() if not existing.is_empty() else u.tileId
			existing.append_array(path(s, start, cmd.target, u.classId).path.slice(1))
			s.movementQueues[u.id] = existing
			message = "Route queued to %s. %s" % [cmd.target, advance_queue(s,u.id)]
		"move":
			s.movementQueues.erase(cmd.unitId)
			var u = mobile(s, cmd.unitId)
			var entity = s.units[cmd.unitId] if s.units.has(cmd.unitId) else s.cohorts[cmd.unitId].state
			entity.movementRemaining = maxf(0, entity.movementRemaining - path(s, u.tileId, cmd.target, u.classId).cost)
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
		"improve":
			for k in p.improvementCost: s.resources[k] -= p.improvementCost[k]
			var town = c.state.settlementId
			s.constructionProject = {"order": cmd.improvement, "cohortId": c.id, "settlementId": town, "targetTileId": cmd.target, "districtId": null, "turnsRemaining": p.improvementTurns}
			c.state = {"kind": "building", "settlementId": town}
			message = order_name(cmd.improvement)+" construction started."
		"build":
			var costs = p.districtCost if cmd.order == "district" else p.workshopCost
			for k in costs:
				s.resources[k] -= costs[k]
			var settlement_id = c.state.settlementId
			s.constructionProject = {"order": cmd.order, "cohortId": c.id, "settlementId": settlement_id, "targetTileId": cmd.get("target") if cmd.order == "district" else null, "districtId": cmd.get("districtId") if cmd.order != "district" else null, "turnsRemaining": p.districtTurns if cmd.order == "district" else p.workshopTurns}
			if cmd.order == "district": s.constructionProject.districtType = cmd.get("districtType","production")
			c.state = {"kind": "building", "settlementId": settlement_id}
			message = order_name(cmd.order,cmd.get("districtType","production"))+" construction started."
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
			if content().improvements.has(t.order):
				if not s.improvements.has(t.targetTileId): s.improvements[t.targetTileId] = {}
				s.improvements[t.targetTileId][t.order] = true
			elif t.order == "district":
				var key = district_key(t.settlementId,t.districtType)
				s.districts[key] = {"id":key,"settlementId":t.settlementId,"tileId":t.targetTileId,"type":t.districtType}
			else:
				var key = building_key(t.settlementId,t.order)
				s.buildings[key] = {"id":key,"type":t.order,"settlementId":t.settlementId,"districtId":t.districtId}
			s.cohorts[t.cohortId].state = {"kind": "resident", "settlementId": t.settlementId, "job": null}
			s.constructionProject = null
			completed.append(order_name(t.order,t.get("districtType","production"))+" complete; builder idle.")
	s.turn += 1
	for c in s.cohorts.values():
		if c.state.kind == "mobile":
			c.state.movementRemaining = preset().movement.cohort
	for u in s.units.values():
		u.movementRemaining = preset().movement.rover
	var ordered_units = s.movementQueues.keys()
	ordered_units.sort()
	for key in ordered_units:
		var movement_report = advance_queue(s, key)
		if not movement_report.is_empty(): completed.append(movement_report)
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
	if s.schemaVersion != 5 or s.rulesVersion != 5:
		return "Unsupported save version."
	if not whole(s.turn, 1, 100000000):
		return "Invalid turn."
	if s.tiles != base.tiles or s.settlements != base.settlements:
		return "Unsupported map or settlement data."
	for key in s.improvements:
		var flags = s.improvements[key]
		if not key is String or not s.tiles.has(key) or s.tiles[key].baseTerrain == "water" or not flags is Dictionary or flags.is_empty(): return "Invalid improvement hex."
		for flag in flags:
			if not content().improvements.has(flag) or not flags[flag] is bool: return "Invalid improvement flag."
		var site_count = 0
		for flag in flags:
			if not flags[flag]: continue
			var def = content().improvements[flag]
			if def.requires != "" and def.requires not in s.completed: return "Missing improvement technology."
			if flag != "road":
				site_count += 1
				if not site_at(s,key).is_empty() or not district_at(s,key).is_empty(): return "Site improvement overlaps a district or town."
			if def.site == "hills" and s.tiles[key].relief != "hills": return "Mine needs hills."
		if site_count > 1: return "Multiple site improvements on one hex."
		if flags.get("farm", false):
			var t = s.tiles[key]
			if t.relief != "flat" or t.feature != null or not site_at(s,key).is_empty() or not district_at(s,key).is_empty(): return "Invalid farm site."
	for k in RESOURCES:
		if not whole(s.resources.get(k), 0, 9007199254740991):
			return "Invalid resource stock."
	if not base.cohorts.keys().all(func(key): return s.cohorts.has(key)) or not same_keys(s.units, base.units):
		return "The four original cohorts and rover must still exist."
	if not whole(s.nextCohortNumber,1,100000000): return "Invalid cohort counter."
	for key in s.cohorts:
		if base.cohorts.has(key): continue
		if not key is String or not key.begins_with("pop_") or not key.substr(4).is_valid_int(): return "Invalid new cohort ID."
		var number = key.substr(4).to_int()
		if number < 1 or number >= s.nextCohortNumber or key != "pop_%03d" % number: return "Invalid new cohort counter or ID."
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
		if not d is Dictionary or not has_fields(d,["id","type","settlementId","tileId"]) or not content().districts.has(d.type) or not s.settlements.has(d.settlementId) or d.id != key or key != district_key(d.settlementId,d.type) or not s.tiles.has(d.tileId) or d.tileId in district_tiles: return "Invalid district."
		if content().districts[d.type].requires not in s.completed: return "Missing district technology."
		district_tiles.append(d.tileId)
		var tile = s.tiles[d.tileId]
		if tile.baseTerrain != "plains" or tile.relief != "flat" or tile.feature != null or has_site_improvement(s,tile.id) or not site_at(s,tile.id).is_empty() or distance(tile,s.tiles[s.settlements[d.settlementId].tileId]) > 2: return "Invalid district site."
	for key in s.buildings:
		if base.buildings.has(key): continue
		var b = s.buildings[key]
		if not b is Dictionary or not has_fields(b,["id","type","settlementId","districtId"]) or b.type not in buildable_buildings() or not b.settlementId is String or not s.settlements.has(b.settlementId) or b.id != key or key != building_key(b.settlementId,b.type) or not s.districts.has(b.districtId): return "Invalid building."
		var definition = content().buildings[b.type]
		if s.districts[b.districtId].settlementId != b.settlementId or s.districts[b.districtId].type != definition.district or definition.requires not in s.completed: return "Wrong building district or missing technology."
	for key in s.cohorts:
		var c = s.cohorts[key]
		if not c is Dictionary or not has_fields(c, ["id", "name", "qualification", "state"]) or c.id != key or not c.name is String or c.name.length() > 100 or not content().qualifications.has(c.qualification) or not c.state is Dictionary or not c.state.has("kind"):
			return "Invalid cohort."
		var st = c.state
		if st.kind == "mobile":
			if not has_fields(st, ["tileId", "movementRemaining"]) or not s.tiles.has(st.tileId) or not valid_movement(st.movementRemaining, 1) or supply_field(s).get(st.tileId, INF) > reach(s, "cohort"):
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
	if not u is Dictionary or not has_fields(u, ["id", "name", "tileId", "movementRemaining"]) or u.id != "rover" or not u.name is String or not s.tiles.has(u.tileId) or not valid_movement(u.movementRemaining, 2) or supply_field(s).get(u.tileId, INF) > 5:
		return "Invalid rover."
	for key in s.movementQueues:
		var queued_unit = mobile(s,key)
		var steps = s.movementQueues[key]
		if queued_unit.is_empty() or not steps is Array or steps.is_empty() or steps.size() > 1000: return "Invalid movement queue."
		var previous = queued_unit.tileId
		var support = supply_field(s)
		for next in steps:
			if not next is String or not s.tiles.has(next) or next not in neighbours(s,previous) or support.get(next,INF) > reach(s,queued_unit.classId)+EPSILON or movement_cost(s,next) > preset().movement[queued_unit.classId]+EPSILON: return "Invalid queued path."
			previous = next
	if s.trainingProject != null:
		var t = s.trainingProject
		if not t is Dictionary or not has_fields(t, ["cohortId", "qualification", "turnsRemaining"]) or not s.cohorts.has(t.cohortId) or not training_reason(s,t.qualification).is_empty() or not whole(t.turnsRemaining, 1, 2) or "technical_education" not in s.completed:
			return "Invalid training project."
		var c = s.cohorts[t.cohortId]
		if c.state.kind != "training" or c.state.settlementId != "main" or c.qualification != "Worker":
			return "Invalid trainee."
	if s.constructionProject != null:
		var t = s.constructionProject
		if not has_fields(t,["order","cohortId","settlementId","targetTileId","districtId","turnsRemaining"]) or not t.order is String or (t.order != "district" and t.order not in buildable_buildings() and not content().improvements.has(t.order)) or not s.cohorts.has(t.cohortId) or not s.settlements.has(t.settlementId) or not whole(t.turnsRemaining,1,project_duration(t.order)): return "Invalid construction project."
		var builder = s.cohorts[t.cohortId]
		if builder.state.kind != "building" or builder.qualification not in ["Worker","Engineer"] or builder.state.settlementId != t.settlementId: return "Invalid builder."
		if content().improvements.has(t.order):
			var required = content().improvements[t.order].requires
			if (required != "" and required not in s.completed) or not improvement_site_reason(s,t.targetTileId,t.settlementId,t.order).is_empty(): return "Invalid improvement project."
		elif t.order == "district":
			if not t.has("districtType") or not content().districts.has(t.districtType) or content().districts[t.districtType].requires not in s.completed or not t.targetTileId is String or not eligible_site(s,t.targetTileId,t.settlementId) or s.districts.has(district_key(t.settlementId,t.districtType)): return "Invalid district project."
		else:
			var definition = content().buildings[t.order]
			if definition.requires not in s.completed or not s.districts.has(t.districtId) or s.districts[t.districtId].type != definition.district or s.districts[t.districtId].settlementId != t.settlementId or s.buildings.has(building_key(t.settlementId,t.order)): return "Invalid building project."
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

static func valid_movement(value, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= -EPSILON and value <= maximum+EPSILON and absf(value*3.0-roundf(value*3.0)) < EPSILON

static func advance_queue(s: Dictionary, key: String) -> String:
	var u = mobile(s,key)
	if u.is_empty():
		s.movementQueues.erase(key)
		return ""
	var steps = s.movementQueues.get(key, [])
	var entity = s.units[key] if s.units.has(key) else s.cohorts[key].state
	var travelled = 0
	var support = supply_field(s)
	while not steps.is_empty():
		var next = steps[0]
		var cost = movement_cost(s,next)
		if next not in neighbours(s,entity.tileId) or support.get(next,INF) > reach(s,u.classId)+EPSILON or cost > preset().movement[u.classId]+EPSILON:
			s.movementQueues.erase(key)
			return u.name+": queued route cancelled because it is no longer legal."
		if cost > entity.movementRemaining+EPSILON: break
		entity.movementRemaining = snappedf(maxf(0.0, entity.movementRemaining-cost), 1.0/3.0)
		entity.tileId = next
		steps.pop_front()
		travelled += 1
	if steps.is_empty():
		s.movementQueues.erase(key)
		return u.name+" arrived at "+entity.tileId+"."
	return "%s advanced %d hex(es); %d queued." % [u.name,travelled,steps.size()] if travelled else "Will continue after End Turn."

static func has_site_improvement(s: Dictionary, key: String) -> bool:
	for flag in s.get("improvements",{}).get(key,{}):
		if flag != "road" and s.improvements[key][flag]: return true
	return false

static func order_name(order: String, district_type: String = "production") -> String:
	if order == "district": return content().districts[district_type].name
	if content().buildings.has(order): return content().buildings[order].name
	return content().improvements.get(order,{}).get("name",order.capitalize())
