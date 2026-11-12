extends RefCounted
const Tactical = preload("res://scripts/tactical_session.gd")
const E = Tactical.E
const R = Tactical.R
const Planner = preload("res://scripts/economy_planner.gd")
const COST = {"food":4,"minerals":3,"industry":2}
const ORDERS = ["foundOutpost","workOutpost","layRoad","leaveOutpost"]

static func attach(s: Dictionary) -> Dictionary:
	var contact = ""
	for tile in s.tiles.values():
		if R.distance(s.tiles[s.settlements.main.tileId],tile) == 5 and tile.baseTerrain != "water" and tile.obstacle == "" and not s.knowledge.visible.has(tile.id):
			contact = tile.id
			break
	s.expansion = {"outposts":{},"roads":{},"fieldCrews":{},"lost":0,"contact":contact}
	return s

static func staffed(s: Dictionary, id: String) -> String:
	for site in s.expansion.outposts:
		if s.expansion.outposts[site].crew == id: return site
	return ""

static func unsafe(s: Dictionary, site: String) -> bool:
	if not Tactical.visible_animals(s).any(func(a): return a.kind != "larva" and R.distance(s.tiles[site],s.tiles[a.tile]) <= 1): return false
	for person in s.cohorts.values():
		if person.qualification == "Soldier" and Tactical.X.hp(s.xenos,person.id) >= 35:
			if R.distance(s.tiles[site],s.tiles[R.person_tile(s,person)]) <= 1: return false
	return true

static func reason(s: Dictionary, cmd: Dictionary) -> String:
	var id: String = cmd.get("person",cmd.get("unitId",""))
	var stationed = staffed(s,id)
	if cmd.type in ["move","queueMove","retreat","returnBuilder"] and stationed != "": return "Evacuate the outpost before moving its crew."
	if cmd.type == "enqueue" and occupied(s,cmd.get("tile","")): return "An occupied site cannot be developed."
	if cmd.type not in ORDERS: return E.reason(s,cmd)
	var person: Dictionary = s.cohorts.get(id,{})
	if person.is_empty() or person.state.kind != "mobile": return "Select a mobile civilian."
	var site: String = person.state.tileId
	if cmd.type in ["foundOutpost","layRoad"] and (s.movementQueues.has(id) or s.moveProgress.has(id)): return "Finish or cancel travel first."
	match cmd.type:
		"foundOutpost":
			if stationed != "" or (id not in s.construction.holders and not s.expansion.fieldCrews.has(id)): return "Deploy a builder or select a surviving outpost crew."
			if s.tiles[site].obstacle != "": return "Clear the obstruction before founding."
			if site == s.expansion.contact: return "The Survey Compact already occupies this site."
			var terrain = R.founding_reason(s,site)
			if terrain != "": return terrain
			for other in s.expansion.outposts:
				if R.distance(s.tiles[site],s.tiles[other]) < 3: return "Needs two hexes between settlement centers."
			if unsafe(s,site): return "Needs protection from nearby predators."
			for project in s.construction.queue:
				if project.tile == site and project.status != "complete": return "An unfinished project occupies this hex."
			for resource in COST:
				if Planner.available(s,resource) < COST[resource]: return "Needs 4 Food, 3 Minerals and 2 unreserved Industry."
		"layRoad":
			if id not in s.construction.holders: return "Needs a builder with the reusable kit."
			if s.expansion.roads.has(site): return "A road is already here."
			if s.tiles[site].baseTerrain == "water" or s.tiles[site].obstacle != "": return "Choose clear land."
			if Planner.available(s,"industry") < 1: return "Needs 1 unreserved Industry."
		"workOutpost":
			if stationed == "": return "Select the outpost crew."
			var target: String = cmd.get("tile","")
			if target == "": return ""
			if not s.knowledge.visible.has(target) or target == s.settlements.main.tileId or s.expansion.outposts.has(target) or target == s.expansion.contact: return "Select an observed hex outside a settlement center."
			if R.distance(s.tiles[stationed],s.tiles[target]) != 1: return "Select an adjacent hex."
			if s.tiles[target].obstacle != "" or R.tile_yield(s,target).get("food",0) == 0: return "Choose clear land with a Food yield."
			for other in s.expansion.outposts:
				if other != stationed and s.expansion.outposts[other].work == target: return "Another outpost works this hex."
		"leaveOutpost":
			if stationed == "": return "Landing Station cannot be abandoned."
	return ""

static func occupied(s: Dictionary, tile: String) -> bool:
	return s.expansion.outposts.has(tile) or (tile != "" and tile == s.expansion.contact and s.knowledge.memory.has(tile))

static func prepare(s: Dictionary) -> Dictionary:
	var next = s.duplicate(true)
	for site in next.expansion.outposts.keys():
		var camp = next.expansion.outposts[site]
		var exposed = unsafe(next,site)
		camp.pressure = camp.pressure+1 if exposed else 0
		if camp.pressure >= 2:
			next.expansion.outposts.erase(site)
			next.expansion.lost += 1
		elif not exposed and camp.work != "" and next.tiles[camp.work].obstacle == "":
			E.change(next,"food",R.tile_yield(next,camp.work).get("food",0))
	return next

static func credit_harvest(ledger: Dictionary, food: int) -> void:
	ledger.opening.food -= food
	ledger.gross.food += food
	ledger.net.food += food

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	if cmd.type == "endTurn":
		var next = prepare(s)
		# Tactical retreat applies to unstationed crews. A staffed site holds until evacuated or lost.
		var result = Tactical.command(next,cmd)
		if result.ok:
			credit_harvest(result.state.lastLedger,next.resources.food-s.resources.food)
			for site in result.state.expansion.outposts.keys():
				var id = result.state.expansion.outposts[site].crew
				if result.state.movementQueues.has(id) or result.state.cohorts[id].state.get("tileId","") != site:
					result.state.expansion.outposts.erase(site)
			if next.expansion.lost > s.expansion.lost: result.message = "An outpost was overrun. Its surviving crew can refound."
		return result
	if cmd.type not in ORDERS:
		if cmd.type in ["move","queueMove","retreat","returnBuilder"] and staffed(s,cmd.get("person",cmd.get("unitId",""))) != "":
			return Tactical.rejected(s,"Evacuate the outpost before moving its crew.")
		if cmd.type == "enqueue" and occupied(s,cmd.get("tile","")): return Tactical.rejected(s,"An occupied site cannot be developed.")
		return Tactical.command(s,cmd)
	var issue = reason(s,cmd)
	if issue != "": return Tactical.rejected(s,issue)
	var next = s.duplicate(true)
	var id: String = cmd.person
	var site: String = next.cohorts[id].state.tileId
	var message = ""
	match cmd.type:
		"foundOutpost":
			for resource in COST: E.change(next,resource,-COST[resource])
			next.expansion.outposts[site] = {"crew":id,"work":"","pressure":0}
			next.expansion.fieldCrews[id] = true
			next.construction.holders.erase(id)
			next.ecology.terrainWork.erase(id)
			message = "Outpost founded. Assign an adjacent Food hex."
		"layRoad":
			E.change(next,"industry",-1)
			next.expansion.roads[site] = true
			if not next.improvements.has(site): next.improvements[site] = {}
			next.improvements[site].road = true
			message = "Road laid. Connected road hexes reduce travel effort."
		"workOutpost":
			next.expansion.outposts[site].work = cmd.tile
			for person in next.cohorts.values():
				if cmd.tile != "" and person.state.job == "tile:"+cmd.tile: person.state.job = null
			message = "Outpost work assignment updated."
		"leaveOutpost":
			next.expansion.outposts.erase(site)
			message = "Outpost evacuated. Landing Station remains operational."
	Tactical.K.observe(next)
	return {"ok":true,"state":next,"message":message}

static func validate(s) -> String:
	if not s is Dictionary or not s.get("expansion") is Dictionary: return "Missing expansion state."
	var x: Dictionary = s.expansion
	if not x.get("contact") is String: return "Invalid faction contact."
	for key in ["outposts","roads","fieldCrews"]:
		if not x.get(key) is Dictionary: return "Invalid expansion records."
	if not R.whole(x.get("lost"),0,9007199254740991): return "Invalid outpost losses."
	if not s.get("tiles") is Dictionary or not s.get("cohorts") is Dictionary: return "Missing geography or cohorts."
	if x.contact != "" and not s.tiles.has(x.contact): return "Unknown faction site."
	for id in x.fieldCrews:
		if x.fieldCrews[id] != true or not s.cohorts.get(id) is Dictionary or s.cohorts[id].get("qualification") in ["Soldier","Explorer"]: return "Invalid frontier crew."
	for site in x.roads:
		if x.roads[site] != true or not s.tiles.get(site) is Dictionary or s.tiles[site].get("baseTerrain") == "water": return "Invalid road location."
	var work_sites = {}
	var crews = {}
	for site in x.outposts:
		var camp = x.outposts[site]
		if not camp is Dictionary or not camp.get("crew") is String or not camp.get("work") is String: return "Invalid outpost."
		if not s.tiles.get(site) is Dictionary or not x.fieldCrews.has(camp.crew) or crews.has(camp.crew): return "Invalid outpost site or crew."
		var person = s.cohorts[camp.crew].get("state",{})
		if not person is Dictionary or person.get("kind") != "mobile" or person.get("tileId") != site or not R.whole(camp.get("pressure"),0,1): return "Invalid outpost garrison."
		if camp.work != "" and (not s.tiles.get(camp.work) is Dictionary or work_sites.has(camp.work) or R.distance(s.tiles[site],s.tiles[camp.work]) != 1): return "Invalid frontier work area."
		if camp.work != "": work_sites[camp.work] = true
		crews[camp.crew] = true
	return Tactical.validate(s)
