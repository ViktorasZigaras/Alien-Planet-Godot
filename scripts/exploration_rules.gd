extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const EXPLORER = "explorer"

static func observe(s: Dictionary) -> void:
	var visible = {}
	for tile in s.tileAccess.main:
		visible[tile] = true
	for person in s.cohorts.values():
		if person.state.kind != "mobile": continue
		var position = s.tiles[person.state.tileId]
		for tile in s.tiles.values():
			if R.distance(position,tile) <= 1: visible[tile.id] = true
	s.knowledge.visible = visible
	for key in visible:
		var tile = s.tiles[key].duplicate(true)
		tile.hostiles = 0
		tile.xenomass = s.tiles[key].xenomass if s.has("ecology") else false
		if not s.knowledge.identified.has(key): tile.bonus = ""
		var district = R.district_at(s,key).duplicate(true)
		var buildings = {}
		if not district.is_empty():
			for building in s.buildings.values():
				if building.get("districtId") == district.id: buildings[building.id] = building.duplicate(true)
		s.knowledge.memory[key] = {"tile":tile,"signal":s.tiles[key].bonus != "","turn":s.turn,"district":district,"buildings":buildings,"improvements":s.improvements.get(key,{}).duplicate(true)}

static func view(s: Dictionary, projection: Dictionary) -> Dictionary:
	projection.districts = {}
	projection.improvements = {}
	projection.buildings = {}
	for key in projection.tiles:
		var record = s.knowledge.memory.get(key,{})
		var tile = projection.tiles[key]
		if record.is_empty():
			tile.feature = null
			tile.bonus = ""
			tile.vegetation = false
			tile.obstacle = ""
			tile.pollution = 0
			tile.biomass = 0
			tile.hostiles = 0
			tile.xenomass = false
		else:
			projection.tiles[key] = record.tile.duplicate(true)
			if not record.district.is_empty(): projection.districts[record.district.id] = record.district
			projection.buildings.merge(record.buildings)
			if not record.improvements.is_empty(): projection.improvements[key] = record.improvements
	for key in projection.neutralSites.keys():
		if not s.knowledge.visible.has(key): projection.neutralSites.erase(key)
	for id in projection.cohorts.keys():
		if projection.cohortOwners.get(id,"blue") != "blue" and not s.knowledge.visible.has(R.person_tile(s,projection.cohorts[id])):
			projection.cohorts.erase(id)
	for group in ["units","nests"]:
		var actors = projection.xenos.get(group,{})
		for id in actors.keys():
			var key = actors[id].get("tile","")
			if not s.knowledge.visible.has(key): actors.erase(id)
	for key in projection.xenos.get("mass",{}).keys():
		if not s.knowledge.visible.has(key): projection.xenos.mass.erase(key)
	return projection

static func work_reason(s: Dictionary, mode: String) -> String:
	var tile = s.cohorts[EXPLORER].state.tileId
	if not s.knowledge.identified.has(tile): return "Identify this site first."
	if EXPLORER in s.construction.travelled or s.movementQueues.has(EXPLORER): return "Wait for a stationary turn at the site."
	if mode == "investigate":
		if s.knowledge.investigated.has(tile): return "Investigation reward already collected."
		if s.tiles[tile].bonus == "alien_specimens" and "power_systems" not in s.progression.techs: return "Alien Specimens require Power Systems."
	elif not s.knowledge.investigated.has(tile):
		return "Investigate this site before fieldwork."
	for person in s.cohorts.values():
		if person.state.get("job") == "tile:"+tile: return "A settlement worker is assigned here."
	if not R.district_at(s,tile).is_empty(): return "A district occupies the site."
	return ""

static func produce(s: Dictionary, gross: Dictionary) -> void:
	if not s.has("knowledge") or s.knowledge.work == "": return
	if work_reason(s,s.knowledge.work) != "": return
	var key = s.cohorts[EXPLORER].state.tileId
	if s.knowledge.work == "investigate":
		s.knowledge.investigated[key] = true
		s.knowledge.work = ""
		gross.science += 2
	else:
		var special = R.content().bonuses[s.tiles[key].bonus].yields
		for resource in special:
			gross[resource] += special[resource]
		gross.science += 1
		gross.culture += 1
