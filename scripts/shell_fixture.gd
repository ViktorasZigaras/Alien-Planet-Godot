extends RefCounted
## Approved B01 development fixture. Not the four-cohort opening or an economy trial.
const R = preload("res://scripts/game_rules.gd")
const ID = "b01-shell-v1"
const COMMANDS = ["move", "queueMove", "cancelMove", "endTurn"]

static func initial() -> Dictionary:
	var s = R.initial_state()
	s.scenario = ID
	s.map = {"seed":731,"width":9,"height":7}
	for key in s.tiles.keys():
		if s.tiles[key].q >= 9 or s.tiles[key].r >= 7: s.tiles.erase(key)
	s.rivers = s.rivers.filter(func(edge):
		var ends = edge.split("|")
		return s.tiles.has(ends[0]) and s.tiles.has(ends[1]))
	s.settlements = {"main":{"id":"main","name":"Landing Station","tileId":"2,3","growth":0}}
	s.cohorts = {"pop_a":{"id":"pop_a","name":"Survey party","qualification":"Worker","home":"main","equipment":[],"facing":0.0,"lastUsed":0,"lastRoute":[],"state":{"kind":"mobile","tileId":"2,3","movementRemaining":1.0}}}
	s.tileAccess = {"main":[]}
	for key in s.tiles:
		if R.distance(s.tiles[key],s.tiles["2,3"]) <= 2: s.tileAccess.main.append(key)
	s.resources = {}
	for key in R.RESOURCES: s.resources[key] = 0
	s.equipment = {"main":{}}
	for group in ["buildings","districts","improvements","units","movementQueues","moveProgress","neutralSites"]: s[group] = {}
	s.completed = []; s.trainingProject = null; s.constructionProject = null
	s.warnings = []; s.turn = 1; s.visualCounter = 0; s.nextCohortNumber = 1
	s.log = ["B01 fixture: movement and inspection only. Economy, growth, AI and fauna are inactive."]
	s.worldVersion = 4
	s.civilizations = {}
	s.xenos = {"tick":0,"rng":9868,"nextUnit":1,"nests":{},"units":{},"mass":{},"humanHealth":{},"lastHumanAttack":{},"lastEvents":[],"deaths":{"blue":0,"animals":0},"lastAnimalAttack":{},"effects":[],"effectSequence":0}
	s.testing = {"enabled":false,"events":[],"sequence":0,"dropped":0,"initial":{},"outcome":{"status":"in_progress"}}
	for t in s.tiles.values():
		t.xenomass = false; t.hostiles = 0
	return s

static func reason(s: Dictionary,cmd: Dictionary) -> String:
	if cmd.get("type", "") not in COMMANDS: return "Unavailable in B01: movement, route cancellation and End Turn only."
	return R.reason(s,cmd)

static func command(state: Dictionary,cmd: Dictionary) -> Dictionary:
	var blocked = reason(state,cmd)
	if blocked != "": return {"ok":false,"state":state,"message":blocked}
	if cmd.type != "endTurn": return R.command(state,cmd)
	var s = state.duplicate(true)
	# B01 isolates movement; it must not silently execute obsolete economy/growth rules.
	s.turn += 1
	for c in s.cohorts.values():
		c.lastRoute = []
		if c.state.kind == "mobile": c.state.movementRemaining = R.movement_budget(c)
	for key in s.movementQueues.keys(): R.advance_queue(s,key)
	var message = "Turn %d · movement refreshed; queued travel advanced." % s.turn
	s.log.push_front(message)
	s.log = s.log.slice(0,100)
	return {"ok":true,"state":s,"message":message}
