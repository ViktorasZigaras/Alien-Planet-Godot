extends RefCounted
const Previous = preload("res://scripts/progression_session.gd")
const K = preload("res://scripts/exploration_rules.gd")

static func initial() -> Dictionary:
	var s = Previous.initial()
	var explorer = s.cohorts.pop_a.duplicate(true)
	explorer.id = K.EXPLORER
	explorer.name = "Explorer"
	explorer.qualification = "Explorer"
	explorer.state = {"kind":"mobile","tileId":s.settlements.main.tileId,"movementRemaining":1.0,"job":null}
	s.cohorts[K.EXPLORER] = explorer
	s.knowledge = {"visible":{},"memory":{},"identified":{},"investigated":{},"work":""}
	K.observe(s)
	return s

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var kind = cmd.get("type","")
	if kind not in ["identify","investigate","fieldwork","stopFieldwork"]:
		var result = Previous.command(s,cmd)
		if result.ok:
			if cmd.get("unitId") == K.EXPLORER and kind in ["move","queueMove"]: result.state.knowledge.work = ""
			K.observe(result.state)
		return result
	var tile = s.cohorts[K.EXPLORER].state.tileId
	var error = ""
	if kind == "identify":
		if s.tiles[tile].bonus == "": error = "There is no special site here."
		elif s.knowledge.identified.has(tile): error = "Site already identified."
	elif kind != "stopFieldwork":
		error = K.work_reason(s,kind)
	if error != "": return {"ok":false,"state":s,"message":error}
	var next = s.duplicate(true)
	if kind == "identify": next.knowledge.identified[tile] = true
	else: next.knowledge.work = "" if kind == "stopFieldwork" else kind
	K.observe(next)
	return {"ok":true,"state":next,"message":"Explorer order recorded."}

static func validate(s) -> String:
	if not s is Dictionary or not s.get("knowledge") is Dictionary: return "Missing exploration state."
	var error = Previous.validate(s)
	if error != "": return error
	if not s.cohorts.has(K.EXPLORER) or s.cohorts[K.EXPLORER].state.kind != "mobile" or s.cohorts[K.EXPLORER].qualification != "Explorer": return "Missing field Explorer."
	for field in ["visible","memory","identified","investigated"]:
		if not s.knowledge.get(field) is Dictionary: return "Invalid map knowledge."
		for key in s.knowledge[field]:
			if not s.tiles.has(key): return "Invalid observed hex."
	for key in s.knowledge.memory:
		var record = s.knowledge.memory[key]
		if not record is Dictionary or not record.get("tile") is Dictionary or not record.get("district") is Dictionary or not record.get("buildings") is Dictionary or not record.get("improvements") is Dictionary or not record.get("turn") is float and not record.get("turn") is int: return "Invalid observation record."
		for field in s.tiles[key]:
			if not record.tile.has(field): return "Incomplete observation record."
	for key in s.knowledge.identified:
		if s.tiles[key].bonus == "" or not s.knowledge.memory.has(key): return "Invalid identified site."
	for key in s.knowledge.investigated:
		if not s.knowledge.identified.has(key): return "Invalid investigation."
	if s.knowledge.get("work") not in ["","investigate","fieldwork"]: return "Invalid field assignment."
	return ""
