extends RefCounted
const E = preload("res://scripts/economy_fixture.gd")
const P = preload("res://scripts/economy_planner.gd")
const C = preload("res://scripts/construction_rules.gd")
static func initial() -> Dictionary:
	var s = P.attach(E.initial()); C.attach(s)
	return s
static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	var result = P.command(state,cmd)
	if not result.ok: return result
	var s = result.state
	if cmd.type == "enqueue":
		# A player queue order is authorization for its actual remaining inputs.
		var project = s.construction.queue.back()
		s = P.command(s,{"type":"goal","amount":C.RECIPES[project.recipe].work}).state
		var goal = s.planning.goals.back().id
		s.construction.queue.back().goal = goal
		s = P.command(s,{"type":"authorize","id":goal}).state
	else: s = P.plan(s)
	return {"ok":true,"state":s,"message":result.message}

static func validate(s) -> String:
	if not s is Dictionary or not s.get("construction") is Dictionary: return "Missing construction state."
	var c = s.construction
	if not c.get("queue") is Array or not c.get("holders") is Array or not c.get("travelled") is Array or not c.get("farmTiers") is Dictionary or c.get("kits") != 1 or not E.R.whole(c.get("next"),1,9007199254740991): return "Invalid construction state."
	if not s.get("tiles") is Dictionary or not s.get("cohorts") is Dictionary: return "Missing geography/people."
	if s.has("survey") and not preload("res://scripts/survey_generator.gd").valid(s.survey): return "Invalid survey settings."
	var baseline = E.baseline(s)
	var towns = s.get("settlements",{}).duplicate(true)
	if s.has("progression") and towns.has("main"): towns.main.growth = 0
	var geography_ok = E.TerrainEcology.same_geography(s.tiles,baseline.tiles) if s.has("ecology") else E.same(s.tiles,baseline.tiles)
	if not geography_ok or not E.same(s.get("tileAccess"),baseline.tileAccess) or not E.same(towns,baseline.settlements): return "Changed construction fixture geography."
	var ids = []; var goals = []; var pending = []; var expected = s.duplicate(true)
	expected.improvements = {}; expected.districts = {}; expected.buildings = {}; expected.construction.farmTiers = {}
	for project in c.queue:
		if not project is Dictionary: return "Invalid queue entry."
		for key in ["id","recipe","tile","status","blocker","goal"]:
			if not project.get(key) is String: return "Invalid project field."
		if not C.RECIPES.has(project.recipe) or not s.tiles.has(project.tile) or project.id in ids: return "Invalid recipe/site/identity."
		if not project.id.begins_with("project_") or not project.id.substr(8).is_valid_int() or int(project.id.substr(8))<1 or int(project.id.substr(8))>=c.next: return "Invalid project counter."
		if not E.R.whole(project.get("work"),0,C.RECIPES[project.recipe].work) or project.get("paid") != project.work or not project.get("started") is bool or not project.get("held") is bool: return "Invalid project accounting."
		if project.started != (project.work>0) or (project.status == "complete") != (project.work == C.RECIPES[project.recipe].work) or project.status not in ["queued","active","complete"]: return "Inconsistent progress."
		if project.goal == "" or project.goal in goals: return "Missing or shared project funding identity."
		ids.append(project.id); goals.append(project.goal)
		if project.status == "complete":
			if C.target_reason(expected,project.recipe,project.tile) != "": return "Invalid completed development chain."
			C.finish(expected,project.duplicate(true))
		else:
			if project.tile in pending: return "Duplicate unfinished site."
			pending.append(project.tile)
	for key in s.get("expansion",{}).get("roads",{}):
		if not expected.improvements.has(key): expected.improvements[key] = {}
		expected.improvements[key].road = true
	if not E.same(s.get("buildings"),expected.buildings) or not E.same(s.get("districts"),expected.districts) or not E.same(s.get("improvements"),expected.improvements) or not E.same(c.farmTiers,expected.construction.farmTiers): return "Completed assets disagree with paid projects."
	var seen = []
	for id in c.holders:
		if not id is String or id in seen or not s.cohorts.has(id) or not s.cohorts[id].get("state") is Dictionary or s.cohorts[id].state.get("kind") != "mobile": return "Invalid kit holder."
		seen.append(id)
	if seen.size()>1: return "Build kit duplicated."
	for id in s.cohorts:
		if not s.cohorts[id] is Dictionary or not s.cohorts[id].get("state") is Dictionary: return "Invalid person."
		if s.cohorts[id].state.get("kind") == "mobile" and id not in seen and not (s.has("knowledge") and id == "explorer") and not (s.has("tactics") and (s.cohorts[id].qualification == "Soldier" or s.tactics.evacuating.has(id))) and not s.get("expansion",{}).get("fieldCrews",{}).has(id): return "Mobile builder has no kit."
	for id in c.travelled:
		if not id is String or not s.cohorts.has(id): return "Invalid travel activity."
	var error = P.validate(s)
	if error != "": return error
	for project in c.queue:
		var found = false
		for goal in s.planning.goals:
			if goal.id == project.goal:
				found = true
				if project.status != "complete" and goal.amount != C.RECIPES[project.recipe].work-project.work: return "Project funding disagrees with remaining cost."
		if not found: return "Unknown project funding goal."
	return ""
