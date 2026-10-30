class_name GameRules
extends RefCounted
## Small serialisable sandbox. Commands validate before copying or spending.
const Generator = preload("res://scripts/map_generator.gd")
const Layers = preload("res://scripts/terrain_layers.gd")
const EPSILON = 0.000001
const RESOURCES = ["food","minerals","industry","energy","science","culture"]
const OFFSETS = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
static var _preset_cache: Dictionary = {}
static var _nodes_cache: Dictionary = {}
static var _content_cache: Dictionary = {}
static func read_json(path: String): return JSON.parse_string(FileAccess.get_file_as_string(path))
static func preset() -> Dictionary:
	if _preset_cache.is_empty(): _preset_cache = read_json("res://data/preset.json")
	return _preset_cache
static func nodes() -> Dictionary:
	if _nodes_cache.is_empty(): _nodes_cache = read_json("res://data/nodes.json")
	return _nodes_cache
static func content() -> Dictionary:
	if _content_cache.is_empty(): _content_cache = read_json("res://data/content.json")
	return _content_cache
static func initial_state() -> Dictionary:
	var s = read_json("res://data/initial_state.json")
	s.resources = preset().start.duplicate(true)
	# Generate geography from a small starting-state template.
	var world = Generator.generate(int(s.map.seed),int(s.map.width),int(s.map.height))
	s.tiles = world.tiles
	s.rivers = world.rivers
	for key in s.neutralSites:
		s.tiles[key].baseTerrain = "plains"
		s.tiles[key].feature = null
	return migrate_save(s)
static func tile_id(q,r) -> String: return "%d,%d" % [q,r]
static func district_key(town: String,kind: String) -> String: return "district_"+town+("" if kind == "production" else "_"+kind)
static func building_key(town: String,kind: String) -> String: return kind+"_"+town
static func building_name(b: Dictionary) -> String: return content().buildings.get(b.type,{}).get("name","Unknown")
static func buildable_buildings() -> Array: return content().buildings.keys().filter(func(k): return content().buildings[k].has("district"))
static func distance(a: Dictionary,b: Dictionary) -> int: return int((abs(a.q-b.q)+abs(a.r-b.r)+abs(a.q+a.r-b.q-b.r))/2)
static func neighbours(s: Dictionary,key: String) -> Array:
	var result = []
	for o in OFFSETS:
		var k = tile_id(s.tiles[key].q+o.x,s.tiles[key].r+o.y)
		if s.tiles.has(k): result.append(k)
	return result
static func site_at(s: Dictionary,key: String) -> Dictionary:
	for site in s.settlements.values():
		if site.tileId == key: return site
	return {}
static func district_at(s: Dictionary,key: String) -> Dictionary:
	for d in s.districts.values():
		if d.tileId == key: return d
	return {}
static func movement_cost(s: Dictionary,key: String) -> float:
	var t = s.tiles[key]
	if t.baseTerrain == "water": return INF
	return 1.0 + (1 if t.relief == "hills" else 0) + (1 if t.feature == "forest" else 0)
static func river_between(s: Dictionary,a: String,b: String) -> bool: return Generator.edge_key(a,b) in s.rivers
static func step_cost(s: Dictionary,a: String,b: String) -> float:
	var cost = movement_cost(s,b)
	if is_inf(cost): return cost
	if s.improvements.get(a,{}).get("road",false) and s.improvements.get(b,{}).get("road",false): cost = 1.0/3.0
	return cost + (1.0 if river_between(s,a,b) else 0.0)
static func reach(_s: Dictionary,_kind: String) -> int: return 1000000 # Supply ranges disabled.
static func routes(s: Dictionary,start: String,class_id: String = "") -> Dictionary:
	var costs = {start:0.0}
	var previous = {}
	var open = [start]
	while not open.is_empty():
		var current = open[0]
		for candidate in open:
			if costs[candidate] < costs[current]: current = candidate
		open.erase(current)
		for key in neighbours(s,current):
			var cost = costs[current]+step_cost(s,current,key)
			if cost < costs.get(key,INF):
				costs[key] = cost
				previous[key] = current
				if key not in open: open.append(key)
	return {"costs":costs,"previous":previous}
static func supply_field(s: Dictionary) -> Dictionary:
	var costs = {}
	for town in s.settlements.values():
		if s.get("settlementOwners",{}).get(town.id,"blue") != "blue": continue
		for key in routes(s,town.tileId).costs:
			# Supply is distance to the nearest settlement; no hard-terrain exclusion.
			var d = distance(s.tiles[town.tileId],s.tiles[key])
			costs[key] = minf(costs.get(key,INF),d)
	return costs
static func path(s: Dictionary,start: String,target: String,kind: String) -> Dictionary:
	if not s.tiles.has(start) or not s.tiles.has(target): return {}
	var found = routes(s,start,kind)
	if not found.costs.has(target): return {}
	var steps = [target]
	while steps[0] != start: steps.push_front(found.previous[steps[0]])
	return {"path":steps,"cost":found.costs[target]}
static func movement_budget(c: Dictionary) -> float: return 3.0 if "rover" in c.get("equipment",[]) else 1.0
static func mobile(s: Dictionary,key: String) -> Dictionary:
	if not s.cohorts.has(key) or s.cohorts[key].state.kind != "mobile": return {}
	var c = s.cohorts[key]
	var u = c.state.duplicate(true)
	u.merge({"id":c.id,"name":c.name,"classId":"rover" if "rover" in c.equipment else "cohort"})
	return u
static func passengers(s: Dictionary,transport_id: String) -> Array:
	return s.cohorts.values().filter(func(c): return c is Dictionary and c.get("state") is Dictionary and c.state.get("kind") == "cargo" and c.state.get("transportId", "") == transport_id)
static func builder(c: Dictionary) -> bool: return "work_suit" in c.get("equipment",[]) or "reinforced_suit" in c.get("equipment",[])
static func has_site_improvement(s: Dictionary,key: String) -> bool:
	for k in s.improvements.get(key,{}):
		if k != "road" and s.improvements[key][k]: return true
	return false
static func tile_yield(s: Dictionary,key: String, penalties: bool = true) -> Dictionary:
	if not s.tiles.has(key) or is_inf(movement_cost(s,key)) or not site_at(s,key).is_empty() or not district_at(s,key).is_empty(): return {}
	var t = s.tiles[key]
	var out = {"plains":{"food":2,"minerals":1},"grassland":{"food":3},"desert":{"minerals":1},"tundra":{"food":1,"minerals":1},"fungal":{"food":2,"science":1}}.get(t.baseTerrain,{}).duplicate()
	for modifier in [t.feature == "forest",t.relief == "hills"]:
		if modifier:
			out.food = out.get("food",0)-1
			out.minerals = out.get("minerals",0)+1
	for edge in s.rivers:
		if key in edge.split("|"):
			out.food = out.get("food",0)+1
			break
	for resource in content().bonuses.get(t.get("bonus",""),{}).get("yields",{}):
		out[resource] = out.get(resource,0)+content().bonuses[t.bonus].yields[resource]
	for imp in s.improvements.get(key,{}):
		if s.improvements[key][imp]:
			for resource in content().improvements[imp].yield: out[resource] = out.get(resource,0)+content().improvements[imp].yield[resource]
	for k in out.keys():
		out[k] = maxi(0,int(out[k]))
		if out[k] == 0: out.erase(k)
	return Layers.apply(t,out) if penalties else out
static func reserved_for_district(s: Dictionary,key: String) -> bool: return s.constructionProject != null and s.constructionProject.order == "district" and s.constructionProject.targetTileId == key
static func job_building(job: String) -> String: return job.substr(9).split("#")[0]
static func slots(b: Dictionary) -> int: return 2 if b.get("tier",1) == 2 else 1
static func list_jobs(s: Dictionary,town: String) -> Array:
	var jobs = []
	for t in s.tiles.values():
		if distance(t,s.tiles[s.settlements[town].tileId]) <= preset().workRange and not tile_yield(s,t.id).is_empty() and not reserved_for_district(s,t.id):
			jobs.append({"id":"tile:"+t.id,"label":t.baseTerrain.capitalize()+" · "+t.id+" · "+yield_text(tile_yield(s,t.id)),"type":"tile"})
	for b in s.buildings.values():
		if b.settlementId != town or b.type == "training": continue
		for i in range(slots(b)):
			jobs.append({"id":"building:"+b.id+"#"+str(i),"label":building_name(b)+" · slot "+str(i+1),"type":b.type})
	return jobs
static func occupied(s: Dictionary,job: String,except: String = "") -> bool:
	return s.cohorts.values().any(func(c): return c.id != except and c.state.kind == "resident" and c.state.get("job") == job)
static func worker_at(s: Dictionary,key: String) -> Dictionary:
	for c in s.cohorts.values():
		if c.state.kind == "resident" and c.state.get("job") == "tile:"+key: return c
	return {}
static func job_output(s: Dictionary,c: Dictionary) -> Dictionary:
	if c.state.kind != "resident" or c.state.get("job") == null: return {}
	var job = c.state.job
	if job.begins_with("tile:"):
		var out = tile_yield(s,job.substr(5),false)
		var role = content().qualifications[c.qualification]
		if role.tile_bonus > 0 and out.has(role.resource): out[role.resource] += role.tile_bonus
		if c.qualification == "Biologist":
			var tile = s.tiles[job.substr(5)]
			if tile.feature == "forest" and out.has("minerals"): out.minerals += 1
			if (tile.baseTerrain == "fungal" or tile.bonus == "alien_specimens") and out.has("science"): out.science += 1
		if "survey_kit" in c.equipment and out.has("science"): out.science += 1
		return Layers.apply(s.tiles[job.substr(5)],out)
	var b = s.buildings[job_building(job)]
	var d = content().buildings[b.type]
	if d.resource == "": return {}
	return {d.resource:d.specialists.get(c.qualification,d.output)+(1 if b.get("tier",1) == 2 else 0)}
static func map_yield(s: Dictionary,key: String) -> Dictionary:
	var c = worker_at(s,key)
	return tile_yield(s,key) if c.is_empty() else job_output(s,c)
static func yield_text(out: Dictionary) -> String:
	var parts = []
	for k in out: parts.append("%+d %s" % [out[k],k])
	return ", ".join(parts)
static func population(s: Dictionary,town: String) -> int:
	return s.cohorts.values().filter(func(c): return c.get("home","main") == town).size()
## One deterministic ledger drives forecast, shortages, powered output and growth.
static func economy(s: Dictionary) -> Dictionary:
	var delta = {}
	for k in RESOURCES: delta[k] = 0
	var towns = {}
	for town in s.settlements:
		towns[town] = {"food":0,"consumption":population(s,town),"penalty":population(s,town),"medicine":0,"growth":0}
		if population(s,town) == 0: continue
		for k in preset().landing: delta[k] += preset().landing[k]
		towns[town].food += preset().landing.food
		# A one-unit starter converter uses Minerals; Industry is never mined.
		delta.minerals -= 1
	for c in s.cohorts.values():
		if c.state.kind != "resident" or c.state.get("job") == null or not c.state.job.begins_with("tile:"): continue
		var out = job_output(s,c)
		for k in out: delta[k] += out[k]
		towns[c.home].food += out.get("food",0)
	var available = maxf(0,s.resources.energy+delta.energy)
	var minerals = maxf(0,s.resources.minerals+delta.minerals)
	var status = {}
	var keys = s.buildings.keys()
	keys.sort_custom(func(a,b):
		if (s.buildings[a].type == "generator") != (s.buildings[b].type == "generator"): return s.buildings[a].type == "generator"
		return str(a) < str(b))
	for key in keys:
		var b = s.buildings[key]
		var d = content().buildings[b.type]
		var power = d.upkeep*(2 if b.get("tier",1) == 2 else 1)
		if b.has("districtId"):
			var district = b.districtId
			if not status.has(district):
				var district_cost = content().districts[s.districts[district].type].upkeep
				status[district] = "Powered" if available >= district_cost else "No Energy"
				if status[district] == "Powered":
					available -= district_cost
					delta.energy -= district_cost
			if status[district] != "Powered":
				status[key] = "District has no Energy"
				continue
		if available < power:
			status[key] = "No Energy"
			continue
		available -= power
		delta.energy -= power
		var out = {}
		if d.resource != "": out[d.resource] = d.passive
		for c in s.cohorts.values():
			if c.state.kind == "resident" and c.state.get("job") != null and c.state.job.begins_with("building:") and job_building(c.state.job) == key:
				for k in job_output(s,c): out[k] = out.get(k,0)+job_output(s,c)[k]
		var produced = out.get(d.resource,0)
		if d.get("input","") == "minerals":
			produced = mini(produced,int(minerals))
			minerals -= produced
			delta.minerals -= produced
			out[d.resource] = produced
		status[key] = "Powered" if produced > 0 or d.resource == "" else "Powered · no input / staff"
		for k in out:
			if k == "growth": towns[b.settlementId].medicine += out[k]
			else: delta[k] += out[k]
		towns[b.settlementId].food += out.get("food",0)
		available += out.get("energy",0)
	for district in s.districts.values():
		if status.has(district.id): continue
		var cost = content().districts[district.type].upkeep
		status[district.id] = "Powered" if available >= cost else "No Energy"
		if available >= cost:
			available -= cost
			delta.energy -= cost
	for town in towns:
		var g = towns[town]
		delta.food -= g.consumption
		g.growth = g.food-g.consumption-g.penalty+g.medicine
	var upkeep = {"food":0,"industry":0}
	for c in s.cohorts.values():
		if c.state.kind not in ["mobile","cargo"]: continue
		if c.qualification == "Soldier": upkeep.food += 1
		if "flamer" in c.equipment: upkeep.industry += 1
		if "rover" in c.equipment: upkeep.industry += 1
	for resource in upkeep: delta[resource] -= upkeep[resource]
	return {"delta":delta,"towns":towns,"status":status,"militaryUpkeep":upkeep}
static func forecast(s: Dictionary) -> Dictionary: return economy(s).delta
static func tech_reason(s: Dictionary,key: String) -> String:
	if not nodes().has(key): return "Unknown technology."
	if key in s.completed: return "Already developed."
	var n = nodes()[key]
	for pre in n.requires:
		if pre not in s.completed: return "Requires technology: "+nodes()[pre].name+"."
	for b in n.buildings:
		if not s.buildings.values().any(func(x): return x.type == b): return "Requires building: "+content().buildings[b].name+"."
	for role in n.specialists:
		if not s.cohorts.values().any(func(c): return c.qualification == role): return "Requires specialist: "+role+"."
	for k in n.stocks:
		if s.resources[k] < n.stocks[k]: return "Requires stock: %d %s (retained)." % [n.stocks[k],k]
	return "Needs %d %s." % [n.cost,n.resource] if s.resources[n.resource] < n.cost else ""
static func training_reason(s: Dictionary,qualification) -> String:
	if not qualification is String or not content().qualifications.has(qualification) or not content().qualifications[qualification].trainable: return "Choose a trainable profession."
	for key in ["technical_education",content().qualifications[qualification].requires]:
		if key not in s.completed: return "Requires "+nodes()[key].name+"."
	return ""
static func eligible_site(s: Dictionary,key: String,town: String) -> bool:
	if not s.tiles.has(key) or not s.settlements.has(town): return false
	var t = s.tiles[key]
	return t.baseTerrain != "water" and t.relief == "flat" and not Layers.blocked(t) and site_at(s,key).is_empty() and district_at(s,key).is_empty() and distance(t,s.tiles[s.settlements[town].tileId]) <= preset().workRange and not has_site_improvement(s,key) and not occupied(s,"tile:"+key) and not s.neutralSites.has(key)
static func improvement_site_reason(s: Dictionary,key,town: String,kind: String) -> String:
	if not key is String or not s.tiles.has(key) or is_inf(movement_cost(s,key)): return "Choose a land hex."
	if distance(s.tiles[key],s.tiles[s.settlements[town].tileId]) > preset().workRange: return "Improvement must be within two hexes of its town."
	if s.improvements.get(key,{}).get(kind,false): return "Already built here."
	if Layers.blocked(s.tiles[key]): return "Clear forest, vegetation and obstacles first."
	if kind == "road": return ""
	if not site_at(s,key).is_empty() or not district_at(s,key).is_empty() or has_site_improvement(s,key) or s.neutralSites.has(key): return "Site occupied; a Road may coexist with one improvement."
	var t = s.tiles[key]
	var rule = content().improvements[kind].site
	if rule == "flat" and (t.relief != "flat" or t.feature != null): return "Needs clear flat land."
	if rule == "hills" and t.relief != "hills": return "Needs hills."
	if rule == "fungal" and t.baseTerrain != "fungal": return "Needs fungal terrain."
	return ""
static func project_duration(order: String) -> int: return 1 if order == "district" or content().improvements.has(order) else 2
static func order_name(order: String,district_type: String = "production") -> String:
	if order == "district": return content().districts[district_type].name
	return content().buildings.get(order,content().improvements.get(order,{})).get("name",order.capitalize())
static func reason(s: Dictionary,cmd: Dictionary) -> String:
	var c = s.cohorts.get(cmd.get("cohortId",""),{})
	match cmd.get("type",""):
		"endTurn": return ""
		"focusPerson": return "Unknown person." if c.is_empty() else ""
		"develop": return tech_reason(s,cmd.get("nodeId",""))
		"grow": return "Growth now accumulates automatically; inspect the town's growth meter."
		"assign":
			if c.is_empty() or c.state.kind != "resident": return "Only residents take jobs."
			if cmd.get("job") == null: return ""
			if not list_jobs(s,c.state.settlementId).any(func(j): return j.id == cmd.job): return "Unavailable job."
			return "Slot already occupied." if occupied(s,cmd.job,c.id) else ""
		"mobilise","clearSpecialty","equip":
			if c.is_empty() or c.state.kind != "resident": return "Requires a resident person."
			if cmd.type == "clearSpecialty": return "Already untrained." if c.qualification == "Worker" else ""
			if cmd.type == "mobilise": return "Equip at least one item before deploying." if c.equipment.is_empty() else ""
			var item = cmd.get("item","")
			if not content().equipment.has(item): return "Unknown equipment."
			if item == "flamer" and item not in c.equipment and c.qualification != "Soldier": return "Flamer equipment requires a trained Soldier."
			return "No stock at this settlement." if item not in c.equipment and s.equipment[c.state.settlementId].get(item,0) < 1 else ""
		"cleanse":
			if c.is_empty() or not builder(c) or c.state.kind not in ["resident","mobile"]: return "Requires a worker with a Work Suit."
			if c.state.kind == "resident" and c.state.job != null: return "Set worker to Idle."
			var tile = s.tiles.get(cmd.get("target", ""),{})
			if tile.is_empty() or tile.baseTerrain == "water": return "Choose a land tile."
			if c.state.kind == "resident" and distance(tile,s.tiles[person_tile(s,c)]) > 2: return "Resident cleansing is within two hexes."
			if c.state.kind == "mobile" and (person_tile(s,c) != tile.id or c.state.movementRemaining < 1): return "Move onto tile with one movement available."
			if c.get("lastCleanse",-1) == s.turn: return "Already cleansed this turn."
			var layer = cmd.get("layer", "")
			if layer not in ["pollution","obstacle","vegetation","forest","xenomass"]: return "Choose a removable overlay."
			var present = tile.feature == "forest" if layer == "forest" else tile.pollution > 0 if layer == "pollution" else tile.obstacle != "" if layer == "obstacle" else tile.get(layer,false) == true
			return "Overlay already absent." if not present else ""
		"manufacture":
			var item = cmd.get("item","")
			if not s.settlements.has(cmd.get("settlementId","")) or not content().equipment.has(item): return "Choose a settlement and equipment."
			var d = content().equipment[item]
			if item in ["flamer","rover"] and equipment_total(s,item) >= military_capacity(s): return "Military capacity full: build a Security District / Guard Post."
			if d.requires not in s.completed: return "Requires "+nodes()[d.requires].name+"."
			return "Needs %d Industry." % d.cost if s.resources.industry < d.cost else ""
		"board":
			var carrier = s.cohorts.get(cmd.get("transportId", ""),{})
			if carrier.is_empty() or carrier.state.kind != "mobile" or "rover" not in carrier.equipment: return "Choose a deployed Transport."
			if c.is_empty() or c.id == carrier.id or c.state.kind not in ["resident","mobile"]: return "Choose another resident or mobile person."
			if c.state.kind == "resident" and c.state.job != null: return "Set the passenger to Idle first."
			if person_tile(s,c) != carrier.state.tileId: return "Passenger must share the Transport's tile."
			if not passengers(s,c.id).is_empty(): return "Unload that Transport before boarding it."
			return "Transport full (2/2)." if passengers(s,carrier.id).size() >= 2 else ""
		"unload":
			return "Choose a carried person." if c.is_empty() or c.state.kind != "cargo" else ""
		"join":
			if c.is_empty() or c.state.kind != "mobile": return "Only mobile people can join."
			if not passengers(s,c.id).is_empty(): return "Unload passengers before joining a settlement."
			return "Move onto a settlement." if site_at(s,c.state.tileId).is_empty() else ""
		"visit":
			if c.is_empty() or c.state.kind != "mobile" or not s.neutralSites.has(c.state.get("tileId","")): return "Move onto a neutral inhabited site."
			return "This person already visited this site." if c.id in s.neutralSites[c.state.tileId].visitors else ""
		"cancelMove": return "No queued route." if not s.movementQueues.has(cmd.get("unitId","")) else ""
		"move","queueMove":
			var u = mobile(s,cmd.get("unitId",""))
			if u.is_empty() or not s.tiles.has(cmd.get("target","")): return "Choose a mobile person and destination."
			var existing = s.movementQueues.get(u.id,[])
			var start = existing.back() if cmd.get("append",false) and not existing.is_empty() else u.tileId
			if start == cmd.target: return "Already at that destination."
			var route = path(s,start,cmd.target,u.classId)
			if route.is_empty(): return "No land route within expedition reach."
			return "Queue too long." if route.path.size()+existing.size() > 1000 else ""
		"train":
			if c.is_empty() or c.state.kind != "resident" or c.qualification != "Worker": return "Clear specialty first; training needs a resident Worker."
			var block = training_reason(s,cmd.get("qualification"))
			if block != "": return block
			if s.trainingProject != null: return "Training service busy."
			return "Training needs 2 Industry." if s.resources.industry < 2 else ""
		"upgrade":
			var b = s.buildings.get(cmd.get("buildingId",""),{})
			if b.is_empty() or b.get("tier",1) >= 2: return "Choose a tier 1 workplace."
			if not s.cohorts.values().any(func(person): return person.state.kind == "resident" and person.state.settlementId == b.settlementId and person.state.job == null and builder(person)): return "Upgrade needs an idle local builder in a Work Suit."
			var tech = content().buildings[b.type].get("upgrade","")
			if tech == "" or tech not in s.completed: return "Requires advanced workplace technology."
			return "Upgrade needs 6 Industry." if s.resources.industry < 6 else ""
		"build","improve":
			if s.constructionProject != null: return "Construction slot busy."
			if c.is_empty() or c.state.kind != "resident" or c.state.job != null or not builder(c): return "Needs an idle resident builder equipped with a Work Suit."
			var town = c.state.settlementId
			var unlock = ""
			if cmd.type == "improve":
				if not content().improvements.has(cmd.get("improvement","")): return "Unknown improvement."
				unlock = content().improvements[cmd.improvement].requires
				var block = improvement_site_reason(s,cmd.get("target"),town,cmd.improvement)
				if block != "": return block
			elif cmd.get("order") == "district":
				var kind = cmd.get("districtType","production")
				if not content().districts.has(kind): return "Unknown district."
				unlock = content().districts[kind].requires
				if s.districts.has(district_key(town,kind)): return "District already exists."
				if not eligible_site(s,cmd.get("target",""),town): return "Choose clear, unworked flat land within two hexes."
			else:
				if cmd.get("order","") not in buildable_buildings(): return "Unknown building."
				var d = content().buildings[cmd.order]
				unlock = d.requires
				var district = s.districts.get(cmd.get("districtId",""),{})
				if district.is_empty() or district.type != d.district or district.settlementId != town: return "Needs its completed local district."
				if s.buildings.has(building_key(town,cmd.order)): return "Building already exists."
			if unlock != "" and unlock not in s.completed: return "Requires "+nodes()[unlock].name+"."
			var cost = 1 if cmd.type == "improve" else 2 if cmd.order == "district" else 6
			return "Needs %d Industry." % cost if s.resources.industry < cost else ""
	return "Unknown command."
static func command(state: Dictionary,cmd: Dictionary) -> Dictionary:
	var blocked = reason(state,cmd)
	if blocked != "": return {"ok":false,"state":state,"message":blocked}
	var s = state.duplicate(true)
	var c = s.cohorts.get(cmd.get("cohortId",""),{})
	var person = c.id if not c.is_empty() else cmd.get("unitId","")
	if s.cohorts.has(person): mark_used(s,person)
	var message = "Order completed."
	match cmd.type:
		"focusPerson": return {"ok":true,"state":s,"message":"Selected "+c.name+"."}
		"endTurn":
			end_turn(s)
			return {"ok":true,"state":s,"message":s.log[0]}
		"develop":
			var n = nodes()[cmd.nodeId]
			s.resources[n.resource] -= n.cost
			s.completed.append(cmd.nodeId)
			message = "Developed "+n.name+"."
		"assign": c.state.job = cmd.get("job")
		"clearSpecialty":
			if "flamer" in c.equipment:
				c.equipment.erase("flamer")
				s.equipment[c.state.settlementId].flamer = s.equipment[c.state.settlementId].get("flamer",0)+1
			c.qualification = "Worker"
			message = "Specialty cleared; identity, equipment and job retained."
		"equip":
			var stocks = s.equipment[c.state.settlementId]
			if cmd.item in c.equipment:
				c.equipment.erase(cmd.item)
				stocks[cmd.item] = stocks.get(cmd.item,0)+1
			else:
				stocks[cmd.item] -= 1
				c.equipment.append(cmd.item)
		"cleanse":
			var t = s.tiles[cmd.target]
			match cmd.layer:
				"forest": t.feature = null
				"vegetation": t.vegetation = false
				"obstacle": t.obstacle = ""
				"xenomass": t.xenomass = false
				"pollution": t.pollution = maxi(0,int(t.pollution)-1)
			c.lastCleanse = int(s.turn)
			if c.state.kind == "mobile": c.state.movementRemaining -= 1
			message = "Cleansed %s at %s." % [cmd.layer,cmd.target]
		"manufacture":
			s.resources.industry -= content().equipment[cmd.item].cost
			var stocks = s.equipment[cmd.settlementId]
			stocks[cmd.item] = stocks.get(cmd.item,0)+1
			message = content().equipment[cmd.item].name+" manufactured into settlement stock."
		"upgrade":
			s.resources.industry -= 6
			s.buildings[cmd.buildingId].tier = 2
			message = "Workplace upgraded: two worker slots, increased output and power use."
		"mobilise":
			c.state = {"kind":"mobile","tileId":s.settlements[c.state.settlementId].tileId,"movementRemaining":0.0}
			message = c.name+" deployed; movement refreshes next turn."
		"board":
			s.movementQueues.erase(c.id)
			s.moveProgress.erase(c.id)
			c.state = {"kind":"cargo","transportId":cmd.transportId}
			message = c.name+" boarded Transport ("+str(passengers(s,cmd.transportId).size())+"/2)."
		"unload":
			var carrier = s.cohorts[c.state.transportId]
			c.state = {"kind":"mobile","tileId":carrier.state.tileId,"movementRemaining":0.0}
			c.facing = carrier.facing
			c.lastRoute = []
			message = c.name+" unloaded; movement refreshes next turn."
		"join":
			s.movementQueues.erase(c.id)
			s.moveProgress.erase(c.id)
			c.home = site_at(s,c.state.tileId).id
			c.state = {"kind":"resident","settlementId":c.home,"job":null}
		"visit":
			var site = s.neutralSites[c.state.tileId]
			var amount = site.amount*(2 if c.qualification == "Merchant" else 1)
			s.resources[site.resource] += amount
			site.visitors.append(c.id)
			message = "%s visits %s: +%d %s to shared supply (once per person/site)." % [c.name,site.name,amount,site.resource]
		"cancelMove":
			s.movementQueues.erase(cmd.unitId)
			s.moveProgress.erase(cmd.unitId)
		"move","queueMove":
			var u = mobile(s,cmd.unitId)
			var existing = s.movementQueues.get(u.id,[]).duplicate()
			if not cmd.get("append",false):
				existing = []
				s.moveProgress.erase(u.id)
			var start = existing.back() if not existing.is_empty() else u.tileId
			existing.append_array(path(s,start,cmd.target,u.classId).path.slice(1))
			s.movementQueues[u.id] = existing
			message = advance_queue(s,u.id)
		"train":
			s.resources.industry -= 2
			s.trainingProject = {"cohortId":c.id,"qualification":cmd.qualification,"turnsRemaining":2,"settlementId":c.state.settlementId}
			c.state = {"kind":"training","settlementId":c.state.settlementId}
		"build","improve":
			var order = cmd.improvement if cmd.type == "improve" else cmd.order
			s.resources.industry -= 1 if cmd.type == "improve" else 2 if order == "district" else 6
			var town = c.state.settlementId
			s.constructionProject = {"order":order,"cohortId":c.id,"settlementId":town,"targetTileId":cmd.get("target"),"districtId":cmd.get("districtId"),"districtType":cmd.get("districtType","production"),"turnsRemaining":project_duration(order)}
			c.state = {"kind":"building","settlementId":town}
			message = order_name(order,cmd.get("districtType","production"))+" construction started."
	s.log.push_front(message)
	s.log = s.log.slice(0,100)
	return {"ok":true,"state":s,"message":message}
static func advance_queue(s: Dictionary,key: String) -> String:
	var u = mobile(s,key)
	if u.is_empty(): return ""
	var entity = s.cohorts[key].state
	s.cohorts[key].lastRoute = [entity.tileId]
	var steps = s.movementQueues.get(key,[])
	while not steps.is_empty():
		var next = steps[0]
		if s.tiles[next].get("hostiles",0) > 0: return "Route paused: animals block next tile; attack or reroute."
		var cost = step_cost(s,entity.tileId,next)
		if next not in neighbours(s,entity.tileId) or is_inf(cost):
			s.movementQueues.erase(key)
			s.moveProgress.erase(key)
			return "Route stopped: step no longer passable."
		var paid = s.moveProgress.get(key,0.0)
		var payment = minf(entity.movementRemaining,maxf(0,cost-paid))
		entity.movementRemaining = maxf(0,entity.movementRemaining-payment)
		paid += payment
		if paid+EPSILON < cost:
			s.moveProgress[key] = paid
			return "Travelling toward %s: %.2f / %.2f move paid; continues next turn." % [next,paid,cost]
		s.moveProgress.erase(key)
		var from = s.tiles[entity.tileId]
		var to = s.tiles[next]
		s.cohorts[key].facing = atan2(sqrt(3.0)*(to.q-from.q+(to.r-from.r)*0.5),1.5*(to.r-from.r))
		entity.tileId = next
		s.cohorts[key].lastRoute.append(next)
		mark_used(s,key)
		steps.pop_front()
	if steps.is_empty(): s.movementQueues.erase(key)
	return u.name+" arrived at "+entity.tileId+"."
static func mark_used(s: Dictionary,key: String) -> void:
	s.visualCounter += 1
	s.cohorts[key].lastUsed = s.visualCounter
static func person_tile(s: Dictionary,c: Dictionary) -> String:
	if c.state.kind == "cargo": return s.cohorts[c.state.transportId].state.tileId
	if c.state.kind == "mobile": return c.state.tileId
	var job = c.state.get("job","")
	if job is String and job.begins_with("tile:"): return job.substr(5)
	if job is String and job.begins_with("building:"):
		var b = s.buildings[job_building(job)]
		if b.has("districtId"): return s.districts[b.districtId].tileId
	return s.settlements[c.home].tileId
static func visible_people(s: Dictionary) -> Dictionary:
	var top = {}
	for c in s.cohorts.values():
		if c.state.kind == "cargo": continue
		var tile = person_tile(s,c)
		if not top.has(tile) or c.lastUsed >= s.cohorts[top[tile]].lastUsed: top[tile] = c.id
	return top
static func new_person(s: Dictionary,town: String) -> void:
	var key = s.get("idPrefix", "")+"pop_%03d" % s.nextCohortNumber
	while s.cohorts.has(key):
		s.nextCohortNumber += 1
		key = s.get("idPrefix", "")+"pop_%03d" % s.nextCohortNumber
	s.nextCohortNumber += 1
	s.cohorts[key] = {"id":key,"name":"Settler "+str(s.nextCohortNumber-1),"qualification":"Worker","home":town,"equipment":[],"facing":0.0,"lastUsed":0,"lastRoute":[],"state":{"kind":"resident","settlementId":town,"job":null}}
static func end_turn(s: Dictionary) -> void:
	var ledger = economy(s)
	s.warnings = []
	for k in RESOURCES:
		if s.resources[k]+ledger.delta[k] < 0: s.warnings.append(k.capitalize()+" shortage.")
		s.resources[k] = maxi(0,s.resources[k]+ledger.delta[k])
	for key in ledger.status:
		if "No Energy" in ledger.status[key] or "no Energy" in ledger.status[key]: s.warnings.append(key+": "+ledger.status[key])
	for town in s.settlements:
		var growth = ledger.towns[town].growth
		if s.resources.food == 0: growth = mini(0,growth)
		s.settlements[town].growth = maxi(0,s.settlements[town].growth+growth)
		while s.settlements[town].growth >= 20:
			s.settlements[town].growth -= 20
			new_person(s,town)
			s.log.push_front(s.settlements[town].name+": population grew.")
	if s.trainingProject != null:
		s.trainingProject.turnsRemaining -= 1
		if s.trainingProject.turnsRemaining == 0:
			var t = s.trainingProject
			s.cohorts[t.cohortId].qualification = t.qualification
			s.cohorts[t.cohortId].state = {"kind":"resident","settlementId":t.settlementId,"job":null}
			s.trainingProject = null
	if s.constructionProject != null:
		s.constructionProject.turnsRemaining -= 1
		if s.constructionProject.turnsRemaining == 0:
			var t = s.constructionProject
			if content().improvements.has(t.order):
				if not s.improvements.has(t.targetTileId): s.improvements[t.targetTileId] = {}
				s.improvements[t.targetTileId][t.order] = true
			elif t.order == "district":
				var key = district_key(t.settlementId,t.districtType)
				s.districts[key] = {"id":key,"type":t.districtType,"settlementId":t.settlementId,"tileId":t.targetTileId}
			else:
				var key = building_key(t.settlementId,t.order)
				s.buildings[key] = {"id":key,"type":t.order,"settlementId":t.settlementId,"districtId":t.districtId,"tier":1}
			s.cohorts[t.cohortId].state = {"kind":"resident","settlementId":t.settlementId,"job":null}
			s.constructionProject = null
	s.turn += 1
	for c in s.cohorts.values():
		if c.state.kind == "mobile": c.state.movementRemaining = movement_budget(c)
	for key in s.movementQueues.keys(): advance_queue(s,key)
	s.log.push_front("Turn %d: %s" % [s.turn,yield_text(ledger.delta)])
	s.log = s.log.slice(0,100)

static func migrate_save(data):
	if not data is Dictionary: return data
	var s = data.duplicate(true)
	if s.get("schemaVersion") == 11: return s
	if s.get("schemaVersion") == 10:
		if s.get("rulesVersion") != 10: return s
		s.schemaVersion = 11; s.rulesVersion = 11
		Layers.initialise(s.tiles)
		return s
	if s.get("schemaVersion") == 9:
		if s.get("rulesVersion") != 9: return s
		s.schemaVersion = 10
		s.rulesVersion = 10
		return migrate_save(s)
	if s.get("schemaVersion") == 8:
		if s.get("rulesVersion") != 8: return s
		s.schemaVersion = 9
		s.rulesVersion = 9
		return migrate_save(s)
	if s.get("schemaVersion") == 7:
		if s.get("rulesVersion") != 7: return s
		s.schemaVersion = 8
		s.rulesVersion = 8
		return migrate_save(s)
	if s.get("schemaVersion") == 6:
		if s.get("rulesVersion") != 6: return s
		if not s.get("cohorts") is Dictionary: return s
		s.schemaVersion = 7
		s.rulesVersion = 7
		s.visualCounter = 0
		for c in s.cohorts.values():
			if not c is Dictionary: return data
			c.facing = 0.0
			c.lastUsed = 0
			c.lastRoute = []
		return migrate_save(s)
	if not whole(s.get("schemaVersion"),1,5) or s.get("rulesVersion") != s.schemaVersion: return s
	if not has_fields(s,["resources","tiles","settlements","cohorts","buildings","units","districts","completed"]): return s
	for k in ["resources","tiles","settlements","cohorts","buildings","units","districts"]:
		if not s[k] is Dictionary: return s
	var world = Generator.generate()
	# Expand legacy geography, retaining all old terrain and persistent people/orders.
	for key in s.tiles:
		if not s.tiles[key] is Dictionary or not world.tiles.has(key): return data
		var old = s.tiles[key]
		if not has_fields(old,["id","q","r","baseTerrain","relief","feature"]): return data
		world.tiles[key].merge(old,true)
		if key == "1,3": world.tiles[key].bonus = "edible_flora"
		if key == "2,2": world.tiles[key].bonus = "ore_seam"
	s.tiles = world.tiles
	s.map = {"seed":world.seed,"width":world.width,"height":world.height}
	s.rivers = world.rivers
	s.schemaVersion = 6
	s.rulesVersion = 6
	var old_resources = s.resources.duplicate()
	s.resources = {"food":old_resources.get("food",0),"minerals":0,"industry":old_resources.get("industry",0),"energy":old_resources.get("credits",0),"science":old_resources.get("research",0),"culture":old_resources.get("influence",0)}
	s.equipment = {}
	for town in s.settlements:
		s.settlements[town].growth = 0
		s.equipment[town] = {"work_suit":2,"small_arms":1,"rover":0,"survey_kit":0,"reinforced_suit":0} if town == "main" else {}
	for c in s.cohorts.values():
		if not c is Dictionary or not c.get("state") is Dictionary: return data
		c.home = c.state.get("settlementId","main")
		c.equipment = []
		c.qualification = {"Farmer":"Biologist","Specialist":"Scientist","Security":"Soldier"}.get(c.get("qualification"),c.get("qualification"))
		if c.state.get("job") is String and c.state.job.begins_with("building:"): c.state.job += "#0"
	if s.units.has("rover"):
		if s.cohorts.has("pop_rover"): return data
		var u = s.units.rover
		if not u is Dictionary or not has_fields(u,["tileId","movementRemaining"]): return data
		s.cohorts.pop_rover = {"id":"pop_rover","name":"Expedition Driver","qualification":"Worker","home":"main","equipment":["rover"],"state":{"kind":"mobile","tileId":u.tileId,"movementRemaining":u.movementRemaining}}
	s.units = {}
	s.improvements = s.get("improvements",{})
	s.movementQueues = s.get("movementQueues",{})
	if s.movementQueues.has("rover"):
		s.movementQueues.pop_rover = s.movementQueues.rover
		s.movementQueues.erase("rover")
	s.moveProgress = {}
	s.nextCohortNumber = s.get("nextCohortNumber",1)
	for d in s.districts.values():
		if not d is Dictionary: return data
		d.type = d.get("type","production")
	for b in s.buildings.values():
		if not b is Dictionary: return data
		b.tier = 1
	if s.get("trainingProject") is Dictionary:
		s.trainingProject.settlementId = s.cohorts[s.trainingProject.cohortId].home
		s.trainingProject.qualification = {"Farmer":"Biologist","Specialist":"Scientist","Security":"Soldier"}.get(s.trainingProject.qualification,s.trainingProject.qualification)
	if s.get("constructionProject") is Dictionary:
		var t = s.constructionProject
		t.districtType = t.get("districtType","production")
		if s.cohorts.has(t.cohortId): s.cohorts[t.cohortId].equipment.append("work_suit")
	# Earlier completed nodes keep their meaning after the prerequisite graph expands.
	var pending = s.completed.duplicate()
	while not pending.is_empty():
		var key = pending.pop_back()
		if nodes().has(key):
			for pre in nodes()[key].requires:
				if pre not in s.completed:
					s.completed.append(pre)
					pending.append(pre)
	s.neutralSites = {
		"8,3":{"name":"Storykeepers' Enclave","resource":"culture","amount":3,"visitors":[]},
		"15,7":{"name":"Independent Observatory","resource":"science","amount":3,"visitors":[]}}
	for key in s.neutralSites:
		s.tiles[key].baseTerrain = "plains"
		s.tiles[key].feature = null
	return migrate_save(s)

static func combat_profile(c: Dictionary) -> Dictionary:
	var armed = "small_arms" in c.equipment or "flamer" in c.equipment
	var strength = (1.0 if c.qualification == "Soldier" else 0.4) if armed else 0.2
	return {"attack":strength,"defence":strength,"ranged":1.0 if "flamer" in c.equipment and c.qualification == "Soldier" else strength*0.5 if "small_arms" in c.equipment and c.qualification == "Soldier" else 0.0}
static func military_capacity(s: Dictionary) -> int:
	var total = s.districts.values().filter(func(d):return d.type == "security").size()
	for b in s.buildings.values():
		if b.type == "guard_post": total += int(b.tier)
	return total
static func equipment_total(s: Dictionary,item: String) -> int:
	var count = 0
	for stock in s.equipment.values(): count += int(stock.get(item,0))
	for c in s.cohorts.values():
		if item in c.equipment: count += 1
	return count
static func whole(v,minimum: float,maximum: float) -> bool:
	return (v is int or v is float) and is_finite(float(v)) and v == floor(float(v)) and v >= minimum and v <= maximum
static func has_fields(d: Dictionary,fields: Array) -> bool: return fields.all(func(k): return d.has(k))
static func same_keys(a: Dictionary,b: Dictionary) -> bool: return a.size() == b.size() and a.keys().all(func(k): return b.has(k))
static func valid_movement(v,maximum: float) -> bool:
	return (v is int or v is float) and is_finite(float(v)) and v >= 0 and v <= maximum+EPSILON
static func validate(s) -> String:
	if not s is Dictionary or not has_fields(s,["schemaVersion","rulesVersion","visualCounter","turn","map","tiles","rivers","resources","settlements","cohorts","equipment","units","buildings","districts","improvements","completed","movementQueues","moveProgress","neutralSites","trainingProject","constructionProject","nextCohortNumber","log","warnings"]): return "Missing save fields."
	if s.schemaVersion != 11 or s.rulesVersion != 11: return "Unsupported save version."
	for k in ["map","tiles","resources","settlements","cohorts","equipment","units","buildings","districts","improvements","movementQueues","moveProgress","neutralSites"]:
		if not s[k] is Dictionary: return "Invalid "+k+"."
	for k in ["rivers","completed","log","warnings"]:
		if not s[k] is Array: return "Invalid "+k+"."
	if not whole(s.turn,1,100000000) or not whole(s.nextCohortNumber,1,100000000): return "Invalid turn/counter."
	if not has_fields(s.map,["seed","width","height"]) or not whole(s.map.seed,0,1000000) or not whole(s.map.width,9,48) or not whole(s.map.height,7,32): return "Invalid map dimensions."
	if s.tiles.size() != s.map.width*s.map.height: return "Incomplete map."
	for r in range(int(s.map.height)):
		for q in range(int(s.map.width)):
			var key = tile_id(q,r)
			var t = s.tiles.get(key,{})
			if not t is Dictionary or not has_fields(t,["id","q","r","baseTerrain","biome","relief","feature","bonus"]) or t.id != key or t.q != q or t.r != r: return "Invalid hex."
			if t.baseTerrain not in ["plains","grassland","desert","tundra","fungal","water"] or t.biome not in ["temperate","lush","dry","cold","fungal","coastal"] or t.relief not in ["flat","hills"] or t.feature not in [null,"forest"] or (t.bonus != "" and not content().bonuses.has(t.bonus)): return "Unknown terrain or deposit."
	for t in s.tiles.values():
		if not has_fields(t,Layers.FIELDS) or not whole(t.pollution,0,3) or t.obstacle not in ["","brambles","stones"] or not t.vegetation is bool or not t.xenomass is bool or not whole(t.biomass,0,1000) or not whole(t.hostiles,0,180): return "Invalid tile overlay."
		if t.baseTerrain == "desert" and t.feature == "forest": return "Deserts cannot have trees."
	for edge in s.rivers:
		if not edge is String: return "Invalid river."
		var ends = edge.split("|")
		if ends.size() != 2 or not s.tiles.has(ends[0]) or not s.tiles.has(ends[1]) or ends[1] not in neighbours(s,ends[0]): return "Invalid river edge."
	if not same_keys(s.resources,{"food":0,"minerals":0,"industry":0,"energy":0,"science":0,"culture":0}): return "Invalid resource types."
	for k in RESOURCES:
		if not whole(s.resources[k],0,9007199254740991): return "Invalid stock."
	if s.settlements.is_empty() or not s.units.is_empty(): return "Invalid settlements or detached vehicles."
	var town_tiles = []
	for key in s.settlements:
		var t = s.settlements[key]
		if not t is Dictionary or not has_fields(t,["id","name","tileId","growth"]) or t.id != key or not t.name is String or not s.tiles.has(t.tileId) or s.tiles[t.tileId].baseTerrain == "water" or t.tileId in town_tiles or not whole(t.growth,0,19): return "Invalid settlement."
		town_tiles.append(t.tileId)
		if not s.equipment.has(key) or not s.equipment[key] is Dictionary: return "Missing equipment stock."
		for item in s.equipment[key]:
			if not content().equipment.has(item) or not whole(s.equipment[key][item],0,1000000): return "Invalid equipment stock."
	var known = []
	for key in s.completed:
		if not key is String or not nodes().has(key) or key in known: return "Invalid completed technology."
		known.append(key)
	# Technology conditions are acquisition requirements, not ongoing operation locks.
	for key in known:
		for pre in nodes()[key].requires:
			if pre not in known: return "Missing prerequisite technology."
	var used = []
	for key in s.districts:
		var d = s.districts[key]
		if not d is Dictionary or not has_fields(d,["id","type","settlementId","tileId"]) or d.id != key or not content().districts.has(d.type) or not s.settlements.has(d.settlementId) or not s.tiles.has(d.tileId) or d.tileId in used or d.tileId in town_tiles: return "Invalid district."
		var tile = s.tiles[d.tileId]
		if content().districts[d.type].requires not in s.completed or tile.baseTerrain == "water" or tile.relief != "flat" or tile.feature != null or distance(tile,s.tiles[s.settlements[d.settlementId].tileId]) > preset().workRange: return "Invalid district site or technology."
		used.append(d.tileId)
	for key in s.buildings:
		var b = s.buildings[key]
		if not b is Dictionary or not has_fields(b,["id","type","settlementId","tier"]) or b.id != key or not content().buildings.has(b.type) or not s.settlements.has(b.settlementId) or not whole(b.tier,1,2): return "Invalid workplace."
		var definition = content().buildings[b.type]
		if b.type in buildable_buildings() and (not b.has("districtId") or definition.requires not in s.completed): return "Missing building district or technology."
		if b.tier == 2 and definition.get("upgrade","") not in s.completed: return "Missing tier 2 technology."
		if b.has("districtId") and (not s.districts.has(b.districtId) or s.districts[b.districtId].settlementId != b.settlementId or s.districts[b.districtId].type != content().buildings[b.type].get("district")): return "Invalid workplace district."
	for key in s.improvements:
		if not s.tiles.has(key) or s.tiles[key].baseTerrain == "water" or not s.improvements[key] is Dictionary: return "Invalid improvement site."
		var count = 0
		for imp in s.improvements[key]:
			if not content().improvements.has(imp) or not s.improvements[key][imp] is bool: return "Invalid improvement."
			if s.improvements[key][imp]:
				var definition = content().improvements[imp]
				if definition.requires != "" and definition.requires not in s.completed: return "Missing improvement technology."
				if imp != "road":
					count += 1
					if not site_at(s,key).is_empty() or not district_at(s,key).is_empty() or s.neutralSites.has(key): return "Overlapping improvement."
				if definition.site == "flat" and (s.tiles[key].relief != "flat" or s.tiles[key].feature != null): return "Invalid flat improvement."
				if definition.site == "hills" and s.tiles[key].relief != "hills": return "Invalid hill improvement."
				if definition.site == "fungal" and s.tiles[key].baseTerrain != "fungal": return "Invalid fungal improvement."
		if count > 1: return "Multiple site improvements."
	if s.cohorts.size() > 1000: return "Too many people."
	if not whole(s.visualCounter,0,9007199254740991): return "Invalid visual use counter."
	for key in s.cohorts:
		var c = s.cohorts[key]
		if not c is Dictionary or not has_fields(c,["id","name","qualification","home","equipment","state","facing","lastUsed","lastRoute"]) or c.id != key or not c.name is String or c.name.length() > 100 or not content().qualifications.has(c.qualification) or not s.settlements.has(c.home) or not c.equipment is Array or not c.state is Dictionary: return "Invalid person."
		if not (c.facing is float or c.facing is int) or not is_finite(float(c.facing)) or not whole(c.lastUsed,0,s.visualCounter) or not c.lastRoute is Array or c.lastRoute.size() > 1001: return "Invalid visual state."
		for key_tile in c.lastRoute:
			if not key_tile is String or not s.tiles.has(key_tile): return "Invalid movement trace."
		var gear = []
		for item in c.equipment:
			if not content().equipment.has(item) or item in gear: return "Invalid loadout."
			gear.append(item)
		if "flamer" in c.equipment and c.qualification != "Soldier": return "Untrained flamer operator."
		if c.has("lastCleanse") and not whole(c.lastCleanse,1,s.turn): return "Invalid cleansing cooldown."
		var st = c.state
		if st.get("kind") == "mobile":
			if not has_fields(st,["tileId","movementRemaining"]) or not s.tiles.has(st.tileId) or is_inf(movement_cost(s,st.tileId)) or not valid_movement(st.movementRemaining,movement_budget(c)): return "Invalid mobile person."
		elif st.get("kind") == "cargo":
			var carrier = s.cohorts.get(st.get("transportId", ""),{})
			if carrier.is_empty() or not carrier.get("state") is Dictionary or carrier.state.get("kind") != "mobile" or not carrier.get("equipment") is Array or "rover" not in carrier.equipment or passengers(s,st.transportId).size() > 2: return "Invalid Transport passenger."
		elif st.get("kind") in ["resident","training","building"]:
			if not s.settlements.has(st.get("settlementId","")) or st.settlementId != c.home or (st.kind == "resident" and not st.has("job")): return "Invalid resident."
		else: return "Unknown person state."
	var jobs = []
	for c in s.cohorts.values():
		if c.state.kind == "resident" and c.state.job != null:
			if not c.state.job is String or c.state.job in jobs or not reason(s,{"type":"assign","cohortId":c.id,"job":c.state.job}).is_empty(): return "Invalid or duplicate assignment."
			jobs.append(c.state.job)
	for key in s.neutralSites:
		var n = s.neutralSites[key]
		if not s.tiles.has(key) or not n is Dictionary or not has_fields(n,["name","resource","amount","visitors"]) or not n.name is String or n.resource not in RESOURCES or not whole(n.amount,1,100) or not n.visitors is Array: return "Invalid neutral site."
		for visitor in n.visitors:
			if not s.cohorts.has(visitor): return "Invalid site visitor."
	for key in s.movementQueues:
		var u = mobile(s,key)
		var steps = s.movementQueues[key]
		if u.is_empty() or not steps is Array or steps.is_empty() or steps.size() > 1000: return "Invalid queue."
		var prev = u.tileId
		for next in steps:
			if not next is String or not s.tiles.has(next) or next not in neighbours(s,prev) or is_inf(step_cost(s,prev,next)): return "Invalid path."
			prev = next
	for key in s.moveProgress:
		if not s.movementQueues.has(key) or not valid_movement(s.moveProgress[key],step_cost(s,mobile(s,key).tileId,s.movementQueues[key][0])): return "Invalid partial step."
	if s.trainingProject != null:
		var t = s.trainingProject
		if not t is Dictionary or not has_fields(t,["cohortId","qualification","turnsRemaining","settlementId"]) or not s.cohorts.has(t.cohortId) or not s.settlements.has(t.settlementId) or not content().qualifications.has(t.qualification) or t.qualification == "Worker" or not whole(t.turnsRemaining,1,2): return "Invalid training."
		if s.cohorts[t.cohortId].state.kind != "training" or s.cohorts[t.cohortId].qualification != "Worker": return "Invalid trainee."
	if s.constructionProject != null:
		var t = s.constructionProject
		if not t is Dictionary or not has_fields(t,["cohortId","order","settlementId","turnsRemaining","targetTileId","districtId","districtType"]) or not s.cohorts.has(t.cohortId) or not s.settlements.has(t.settlementId) or not t.order is String or (t.order != "district" and t.order not in buildable_buildings() and not content().improvements.has(t.order)) or not whole(t.turnsRemaining,1,project_duration(t.order)): return "Invalid construction."
		if not builder(s.cohorts[t.cohortId]) or s.cohorts[t.cohortId].state.kind != "building": return "Invalid builder."
		if t.order == "district":
			if not content().districts.has(t.districtType) or not t.targetTileId is String or not eligible_site(s,t.targetTileId,t.settlementId): return "Invalid district project."
		elif content().improvements.has(t.order):
			if not improvement_site_reason(s,t.targetTileId,t.settlementId,t.order).is_empty(): return "Invalid improvement project."
		elif not s.districts.has(t.districtId) or s.districts[t.districtId].type != content().buildings[t.order].district: return "Invalid building project."
	for c in s.cohorts.values():
		if c.state.kind == "training" and (s.trainingProject == null or s.trainingProject.cohortId != c.id): return "Orphan trainee."
		if c.state.kind == "building" and (s.constructionProject == null or s.constructionProject.cohortId != c.id): return "Orphan builder."
	if s.log.size() > 100 or s.warnings.size() > 100: return "Oversized report."
	for line in s.log+s.warnings:
		if not line is String or line.length() > 4000: return "Invalid report."
	return ""
