class_name AIPlanActions
extends RefCounted
## Prerequisite helpers return one ordinary engine command. Never grant stock or people.
const R = preload("res://scripts/game_rules.gd")
const A = preload("res://scripts/ai_assessment.gd")
const Survey = preload("res://scripts/tile_survey.gd")
static func intent(cmd: Dictionary,rule: String) -> Dictionary: return {"command":cmd,"rule":rule}
static func legal(p: Dictionary,cmd: Dictionary,rule: String) -> Dictionary:
	return intent(cmd,rule) if R.reason(p,cmd) == "" else {}
static func home(p: Dictionary) -> String:
	var ids = p.settlements.keys(); ids.sort()
	for id in ids:
		if R.population(p,id) > 0: return id
	return ids[0]
static func protected(p: Dictionary,id: String) -> bool:
	return p.get("ai",{}).get("jobTerms",{}).get(id,0) > p.turn
static func builder(p: Dictionary,town: String) -> Dictionary:
	for c in A.people(p):
		if c.home == town and c.state.kind == "resident" and R.builder(c):
			if c.state.job == null: return {"person":c.id}
			if not protected(p,c.id): return intent({"type":"assign","cohortId":c.id,"job":null},"loan_builder")
	for c in A.people(p):
		if c.home != town or c.state.kind != "resident" or c.qualification == "Soldier" or protected(p,c.id): continue
		if c.state.job != null: return intent({"type":"assign","cohortId":c.id,"job":null},"loan_builder")
		var gear = legal(p,{"type":"equip","cohortId":c.id,"item":"work_suit"},"equip_builder")
		if not gear.is_empty(): return gear
		var tech = technology(p,"standard_tooling")
		if not tech.is_empty(): return tech
		return legal(p,{"type":"manufacture","settlementId":town,"item":"work_suit"},"manufacture_builder_suit")
	return {}
static func technology(p: Dictionary,key: String,depth: int = 0) -> Dictionary:
	if key == "" or key in p.completed or depth > 20: return {}
	var cmd = {"type":"develop","nodeId":key}
	if R.reason(p,cmd) == "": return intent(cmd,"research_prerequisite:"+key)
	var n = R.nodes()[key]
	for pre in n.requires:
		if pre not in p.completed: return technology(p,pre,depth+1)
	for kind in n.buildings:
		if not p.buildings.values().any(func(b):return b.type == kind): return workplace(p,home(p),kind,depth+1)
	for role in n.specialists:
		if not p.cohorts.values().any(func(c):return c.qualification == role): return training(p,home(p),role,depth+1)
	return {}
static func training(p: Dictionary,town: String,role: String,depth: int = 0) -> Dictionary:
	if depth > 20 or p.trainingProject != null: return {}
	for tech in ["technical_education",R.content().qualifications[role].requires]:
		if tech != "" and tech not in p.completed: return technology(p,tech,depth+1)
	for c in A.people(p):
		if c.home != town or c.state.kind != "resident" or c.qualification != "Worker" or R.builder(c) or protected(p,c.id): continue
		# Preserve six operating civilians for the fixed operation; not a universal troop cap.
		if role == "Soldier" and p.cohorts.values().filter(func(x):return x.qualification != "Soldier").size() <= 6: continue
		return legal(p,{"type":"train","cohortId":c.id,"qualification":role},"train_for_plan:"+role)
	return {}
static func workplace(p: Dictionary,town: String,kind: String,depth: int = 0) -> Dictionary:
	if depth > 20 or p.buildings.has(R.building_key(town,kind)) or p.constructionProject != null: return {}
	var definition = R.content().buildings[kind]
	if definition.requires not in p.completed: return technology(p,definition.requires,depth+1)
	var district_exists = p.districts.has(R.district_key(town,definition.district))
	if p.resources.industry < (6 if district_exists else 2): return {}
	var b = builder(p,town)
	if b.has("command"): return b
	if b.is_empty(): return {}
	var district = R.district_key(town,definition.district)
	if not p.districts.has(district):
		var tech = R.content().districts[definition.district].requires
		if tech not in p.completed: return technology(p,tech,depth+1)
		for t in Survey.ordered(p):
			var cmd = {"type":"build","cohortId":b.person,"order":"district","districtType":definition.district,"target":t.id}
			if R.reason(p,cmd) == "": return intent(cmd,"district_for:"+kind)
		for t in Survey.ordered(p):
			if t.baseTerrain == "water" or t.relief != "flat" or R.distance(t,p.tiles[p.settlements[town].tileId]) > 2 or not R.site_at(p,t.id).is_empty() or not R.district_at(p,t.id).is_empty() or R.occupied(p,"tile:"+t.id) or R.has_site_improvement(p,t.id) or p.neutralSites.has(t.id): continue
			for layer in ["vegetation","forest","obstacle"]:
				var clean = legal(p,{"type":"cleanse","cohortId":b.person,"target":t.id,"layer":layer},"clear_workplace_plot")
				if not clean.is_empty(): return clean
		return {}
	return legal(p,{"type":"build","cohortId":b.person,"order":kind,"districtId":district},"construct:"+kind)
static func income(p: Dictionary,resource: String,emergency: bool = false) -> Dictionary:
	var before = R.economy(p).delta
	var best = {}; var gain = 0.0
	for c in A.people(p):
		if c.state.kind != "resident" or (not emergency and protected(p,c.id)): continue
		if c.id in p.get("ai",{}).get("turnActors",[]): continue
		if not emergency and c.state.job==null and p.get("ai",{}).get("loans",{}).has(c.id): continue
		if p.get("ai",{}).get("operation",{}).get("phase","") == "commission" and c.qualification == "Soldier": continue
		for job in R.list_jobs(p,c.home):
			if c.state.job == job.id or R.reason(p,{"type":"assign","cohortId":c.id,"job":job.id}) != "": continue
			var copy = p.duplicate(false); copy.cohorts = p.cohorts.duplicate(true)
			copy.cohorts[c.id].state.job = job.id
			var after = R.economy(copy).delta
			var value = float(after[resource]-before[resource])*5.0
			# Reject improvements that cure one deficit by creating an immediate survival deficit.
			if resource != "food" and after.food < mini(0,before.food): continue
			for k in ["food","energy","minerals","industry"]:
				if k != resource and after[k] < before[k]: value -= (before[k]-after[k])*(4.0 if before[k] <= 0 else 0.5)
			if value > gain+0.01:
				gain = value; best = intent({"type":"assign","cohortId":c.id,"job":job.id},"staff_income:"+resource)
	if not best.is_empty(): return best
	return {}
static func infrastructure(p: Dictionary,resource: String) -> Dictionary:
	var kind = {"food":"greenhouse","minerals":"workshop","industry":"workshop","energy":"generator","science":"research_lab","culture":"exchange"}.get(resource,"workshop")
	if resource == "minerals": return improvement(p,"mine")
	var towns = p.settlements.keys(); towns.sort()
	for town in towns:
		if R.population(p,town) == 0: continue
		var result = workplace(p,town,kind)
		if not result.is_empty(): return result
	return improvement(p,"farm" if resource == "food" else "energy_tap" if resource == "energy" else "field_camp")
static func improvement(p: Dictionary,kind: String) -> Dictionary:
	# Do not spend the last Industry on opportunistic terrain work while larger prerequisites wait.
	if p.resources.industry < 6: return {}
	var tech = R.content().improvements[kind].requires
	if tech != "" and tech not in p.completed: return technology(p,tech)
	var towns = p.settlements.keys(); towns.sort()
	for town in towns:
		if R.population(p,town) == 0: continue
		var b = builder(p,town)
		if b.has("command"): return b
		if b.is_empty(): continue
		for t in Survey.ordered(p):
			if R.worker_at(p,t.id).is_empty() or R.distance(t,p.tiles[p.settlements[town].tileId]) > 2: continue
			var cmd = {"type":"improve","cohortId":b.person,"improvement":kind,"target":t.id}
			if R.reason(p,cmd) == "": return intent(cmd,"improve_worked:"+kind)
	return {}
static func research(p: Dictionary) -> Dictionary:
	var keys = R.nodes().keys()
	keys.sort_custom(func(a,b):return R.nodes()[a].cost < R.nodes()[b].cost or (R.nodes()[a].cost == R.nodes()[b].cost and a < b))
	for key in keys:
		var result = legal(p,{"type":"develop","nodeId":key},"research_affordable:"+key)
		if not result.is_empty(): return result
	return {}
static func grow(p: Dictionary) -> Dictionary:
	var result = income(p,"food")
	if not result.is_empty(): return result
	result = infrastructure(p,"food")
	if not result.is_empty(): return result
	return workplace(p,home(p),"clinic")
static func expansion(world: Dictionary,p: Dictionary) -> Dictionary:
	var plan = p.ai.plans.get("expand",{}).duplicate(true)
	if not plan.has("target"):
		var sites = Survey.sites(world,p)
		if sites.is_empty(): return {}
		plan.target = sites[0].tile
	var target = plan.target
	if not R.site_at(p,target).is_empty(): return {}
	var founder = p.cohorts.get(plan.get("actor",""),{})
	if founder.is_empty():
		for c in A.people(p):
			if c.state.kind == "resident" and c.qualification == "Worker" and not R.builder(c) and not protected(p,c.id) and R.population(p,c.home) >= 7:
				plan.actor = c.id; founder = c; break
	if founder.is_empty(): return {}
	if founder.state.kind == "resident":
		if founder.state.job != null: return intent({"type":"assign","cohortId":founder.id,"job":null},"release_founder")
		if founder.equipment.is_empty():
			var eq = legal(p,{"type":"equip","cohortId":founder.id,"item":"work_suit"},"equip_founder")
			if not eq.is_empty(): return eq
			return legal(p,{"type":"manufacture","settlementId":founder.home,"item":"work_suit"},"make_founder_suit")
		return legal(p,{"type":"mobilise","cohortId":founder.id},"mobilise_founder")
	if founder.state.kind != "mobile": return {}
	if founder.state.tileId == target: return legal(p,{"type":"found","cohortId":founder.id},"found_planned_settlement")
	if p.movementQueues.has(founder.id): return {}
	return legal(p,{"type":"queueMove","unitId":founder.id,"target":target},"travel_to_found_site")
static func road(p: Dictionary) -> Dictionary:
	var towns = p.settlements.keys(); towns.sort()
	if towns.size() < 2: return {}
	var from = p.settlements[towns[0]].tileId
	for town in towns.slice(1):
		var route = R.path(p,from,p.settlements[town].tileId,"")
		for key in route.get("path",[]):
			if p.improvements.get(key,{}).get("road",false): continue
			for local in towns:
				if R.distance(p.tiles[key],p.tiles[p.settlements[local].tileId]) > 2: continue
				var b = builder(p,local)
				if b.has("command"): return b
				if b.is_empty(): continue
				var cmd = {"type":"improve","cohortId":b.person,"improvement":"road","target":key}
				if R.reason(p,cmd) == "": return intent(cmd,"road_corridor")
				for layer in ["vegetation","forest","obstacle"]:
					var clean = legal(p,{"type":"cleanse","cohortId":b.person,"target":key,"layer":layer},"clear_road_corridor")
					if not clean.is_empty(): return clean
	return {}
