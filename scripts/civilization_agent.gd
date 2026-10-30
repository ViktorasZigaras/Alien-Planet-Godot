class_name CivilizationAgent
extends RefCounted
## Deterministic policy function: state in, one ordinary command + rule label out.
const R = preload("res://scripts/game_rules.gd")
static func choice(command: Dictionary,rule: String) -> Dictionary: return {"command":command,"rule":rule}
static func ordered_tiles(s: Dictionary) -> Array:
	var tiles = s.tiles.values()
	tiles.sort_custom(func(a,b): return a.r < b.r or (a.r == b.r and a.q < b.q))
	return tiles
static func reserved_plots(s: Dictionary) -> Array:
	var town = s.settlements.values()[0]
	var plots = []
	for tile in ordered_tiles(s):
		if tile.id != town.tileId and R.distance(tile,s.tiles[town.tileId]) <= 2 and tile.baseTerrain != "water" and tile.relief == "flat" and tile.feature == null and tile.bonus == "":
			plots.append(tile.id)
			if plots.size() == 5: break
	return plots
static func pick(s: Dictionary) -> Dictionary:
	var people = s.cohorts.values()
	people.sort_custom(func(a,b): return a.id < b.id)
	var protected = reserved_plots(s)
	var town = s.settlements.values()[0]
	var builder = {}
	for c in people:
		if R.builder(c): builder = c; break
	for c in people:
		if c.state.kind == "mobile" and c.state.tileId == town.tileId and c.qualification != "Soldier" and R.passengers(s,c.id).is_empty(): return choice({"type":"join","cohortId":c.id},"settle_arrived_person")
	if builder.is_empty():
		for c in people:
			if c.state.kind != "resident": continue
			if c.state.job != null: return choice({"type":"assign","cohortId":c.id,"job":null},"reserve_builder")
			var gear = {"type":"equip","cohortId":c.id,"item":"work_suit"}
			if R.reason(s,gear) == "": return choice(gear,"equip_builder")
	for key in R.nodes():
		var cmd = {"type":"develop","nodeId":key}
		if R.reason(s,cmd) == "": return choice(cmd,"research_available_capability")
	var ledger = R.economy(s)
	var growth = ledger.towns[town.id].growth
	var idle = people.filter(func(c): return c.state.kind == "resident" and c.state.job == null and c.id != builder.get("id", ""))
	# During shortage, move one non-food worker back to food. No best-strategy search.
	if idle.is_empty() and growth < 0:
		for c in people:
			if c.state.kind == "resident" and c.id != builder.get("id", "") and c.state.job is String and not c.state.job.begins_with("tile:"):
				return choice({"type":"assign","cohortId":c.id,"job":null},"release_staff_for_food")
	for c in idle:
		var jobs = R.list_jobs(s,town.id)
		jobs.sort_custom(func(a,b): return a.id < b.id)
		var selected = {}
		var score = -INF
		for job in jobs:
			var cmd = {"type":"assign","cohortId":c.id,"job":job.id}
			if R.reason(s,cmd) != "": continue
			if job.id.begins_with("tile:") and job.id.substr(5) in protected: continue
			var value = 0.0
			if job.id.begins_with("tile:"):
				var yields = R.tile_yield(s,job.id.substr(5))
				value = yields.get("food",0)*4 if growth < 2 else yields.get("minerals",0)*3 if s.resources.minerals < 5 else yields.get("science",0)*2+yields.get("food",0)
			else:
				var b = s.buildings[R.job_building(job.id)]
				var d = R.content().buildings[b.type]
				value = 2.0 if growth >= 2 else 0.0
				if c.qualification == "Medic" and b.type == "clinic": value = 18
				elif R.content().qualifications[c.qualification].resource == d.resource: value += 5
				if b.type == "workshop" and s.resources.minerals < 2: value = -1
			if value > score: score = value; selected = cmd
		if not selected.is_empty(): return choice(selected,"assign_food_or_workplace")
	if s.trainingProject == null:
		for role in ["Biologist","Engineer","Scientist","Soldier","Merchant","Medic","Extractor","Artist","Explorer","Administrator"]:
			if people.any(func(c): return c.qualification == role): continue
			for c in people:
				if c.qualification != "Worker" or c.id == builder.get("id", "") or c.state.kind != "resident": continue
				var cmd = {"type":"train","cohortId":c.id,"qualification":role}
				if R.reason(s,cmd) == "": return choice(cmd,"train_missing_profession")
	if not builder.is_empty() and builder.state.kind == "resident":
		if builder.state.job != null: return choice({"type":"assign","cohortId":builder.id,"job":null},"keep_builder_available")
		if s.constructionProject == null:
			for kind in ["workshop","generator","clinic","greenhouse","research_lab","exchange","guard_post","atelier"]:
				if s.buildings.values().any(func(b): return b.type == kind): continue
				var d = R.content().buildings[kind]
				if d.requires not in s.completed: continue
				var district = R.district_key(town.id,d.district)
				if not s.districts.has(district):
					for tile in ordered_tiles(s):
						var cmd = {"type":"build","cohortId":builder.id,"order":"district","districtType":d.district,"target":tile.id}
						if R.reason(s,cmd) == "": return choice(cmd,"develop_required_district")
						if tile.baseTerrain != "water" and tile.relief == "flat" and R.distance(tile,s.tiles[town.tileId]) <= 2 and R.site_at(s,tile.id).is_empty() and R.district_at(s,tile.id).is_empty() and not R.has_site_improvement(s,tile.id) and not R.occupied(s,"tile:"+tile.id):
							for layer in ["vegetation","forest","obstacle"]:
								var clean = {"type":"cleanse","cohortId":builder.id,"target":tile.id,"layer":layer}
								if R.reason(s,clean) == "": return choice(clean,"clear_construction_plot")
				else:
					var cmd = {"type":"build","cohortId":builder.id,"order":kind,"districtId":district}
					if R.reason(s,cmd) == "": return choice(cmd,"build_profession_workplace")
			if s.resources.industry < 6: return {}
			for c in people:
				if c.state.kind != "resident" or not c.state.get("job") is String or not c.state.job.begins_with("tile:"): continue
				var cmd = {"type":"improve","cohortId":builder.id,"improvement":"farm","target":c.state.job.substr(5)}
				if R.reason(s,cmd) == "": return choice(cmd,"improve_worked_food_tile")
	return {}
