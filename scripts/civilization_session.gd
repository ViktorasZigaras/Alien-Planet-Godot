class_name CivilizationSession
extends RefCounted
## Blue's compatible rule state plus isolated rival rule states and an optional recorder.
const X = preload("res://scripts/xeno_ecology.gd")
const R = preload("res://scripts/game_rules.gd")
const Agent = preload("res://scripts/civilization_agent.gd")
const Claims = preload("res://scripts/claim_map.gd")
const RED_TOWN = "10,8"
static func initial_state() -> Dictionary: return attach(R.initial_state())
static func own_state(s: Dictionary) -> Dictionary:
	var own = s.duplicate(true)
	own.erase("civilizations")
	own.erase("testing")
	own.erase("worldVersion")
	own.erase("xenos")
	return own
static func players(s: Dictionary) -> Dictionary:
	var result = {"blue":s}
	for id in s.get("civilizations",{}): result[id] = s.civilizations[id]
	return result
static func attach(s: Dictionary) -> Dictionary:
	if s.get("worldVersion") == 3: return s
	if s.get("worldVersion") == 2:
		s = s.duplicate(true)
		s.worldVersion = 3
		var x = s.xenos
		x.deaths = {"blue":0,"red":0,"animals":0}; x.lastAnimalAttack = {}; x.effects = []; x.effectSequence = 0
		for n in x.nests.values(): n.burned = false
		for u in x.units.values(): u.hp = clampi(roundi(100*float(u.hp)/{"larva":4,"predator":6,"armored":11}[u.kind]),1,100)
		for id in x.humanHealth: x.humanHealth[id] = clampi(int(x.humanHealth[id])*10,1,100)
		X.sync_tiles(s)
		return s
	if s.get("worldVersion") == 1:
		s = s.duplicate(true)
		s.worldVersion = 3
		s.xenos = X.initial(s)
		X.sync_tiles(s)
		return attach(s)
	if s.has("worldVersion"): return s
	s = s.duplicate(true)
	# A clear green landing area, isolated from both blue settlements.
	for t in s.tiles.values():
		if R.distance(s.tiles[RED_TOWN],t) <= 2:
			t.baseTerrain = "grassland"; t.biome = "lush"; t.feature = null; t.relief = "flat"
			if t.id != "8,9": t.bonus = ""
	s.tiles["8,9"].relief = "hills"; s.tiles["8,9"].bonus = "ore_seam"
	var red = R.initial_state()
	red.map = s.map.duplicate(true)
	red.tiles = s.tiles.duplicate(true)
	red.rivers = s.rivers.duplicate(true)
	red.turn = s.turn
	red.resources = R.preset().start.duplicate(true)
	red.settlements = {"red_town":{"id":"red_town","name":"Red Haven","tileId":RED_TOWN,"growth":0}}
	red.cohorts = {}
	for i in range(5):
		var id = "red_person_"+str(i)
		red.cohorts[id] = {"id":id,"name":"Red Settler "+str(i+1),"qualification":"Worker","home":"red_town","equipment":[],"facing":0.0,"lastUsed":0,"lastRoute":[],"state":{"kind":"resident","settlementId":"red_town","job":null}}
	red.buildings = {}
	for kind in ["lab","civic","training"]:
		var id = "red_"+kind
		red.buildings[id] = {"id":id,"type":kind,"tier":1,"settlementId":"red_town"}
	red.equipment = {"red_town":{"work_suit":2,"small_arms":1,"rover":0,"survey_kit":0,"reinforced_suit":0}}
	red.completed = []; red.improvements = {}; red.districts = {}; red.units = {}
	red.trainingProject = null; red.constructionProject = null; red.movementQueues = {}; red.moveProgress = {}
	red.log = ["Red Haven founded. Policy: population, land development and research."]
	red.policyProfile = {"priorities":["population","tile_development","research"],"defence":"hunt_animals_and_disable_nest"}
	red.idPrefix = "red_"
	red.warnings = []; red.visualCounter = 0; red.nextCohortNumber = 1
	s.worldVersion = 3
	s.civilizations = {"red":red}
	s.xenos = X.initial(s)
	X.sync_tiles(s)
	s.testing = {"enabled":false,"events":[],"sequence":0,"dropped":0,"initial":{},"outcome":{"status":"in_progress"}}
	return attach(s)
static func summary(s: Dictionary) -> Dictionary:
	var result = {}
	for id in players(s):
		var p = players(s)[id]
		result[id] = {"turn":p.turn,"resources":p.resources.duplicate(),"population":p.cohorts.size(),"techs":p.completed.duplicate(),"buildings":p.buildings.size(),"districts":p.districts.size(),"improvedTiles":p.improvements.size(),"growth":p.settlements.values().map(func(t): return {"id":t.id,"growth":t.growth})}
	result.xeno = X.summary(s.xenos)
	return result
static func start_recording(s: Dictionary) -> Dictionary:
	s = s.duplicate(true)
	s.testing = {"enabled":true,"events":[],"sequence":0,"dropped":0,"initial":{"blue":own_state(s),"red":s.civilizations.red.duplicate(true),"xenos":s.xenos.duplicate(true)},"outcome":{"status":"in_progress"}}
	return s
static func record(s: Dictionary,player: String,cmd: Dictionary,rule: String,before: Dictionary,ok: bool,message: String) -> void:
	if not s.testing.enabled: return
	s.testing.sequence += 1
	cmd = cmd.duplicate(true)
	cmd.type = str(cmd.get("type", "invalid"))
	s.testing.events.append({"sequence":s.testing.sequence,"turn":s.turn,"player":player,"command":cmd.duplicate(true),"policyRule":rule,"accepted":ok,"message":message,"before":before,"after":summary(s)})
	if s.testing.events.size() > 10000: s.testing.events.pop_front(); s.testing.dropped += 1
static func finish_recording(s: Dictionary,status: String = "stopped",detail: String = "Manual stop") -> Dictionary:
	s = s.duplicate(true)
	s.testing.outcome = {"status":status,"detail":detail,"turn":s.turn,"summary":summary(s)}
	s.testing.enabled = false
	return s
static func report(s: Dictionary) -> Dictionary:
	return {"format":"alien-planet-test-v4","gameVersion":"0.904","seed":s.map.seed,"initial":s.testing.initial,"events":s.testing.events,"droppedEvents":s.testing.dropped,"outcome":s.testing.outcome,"final":s.testing.outcome.get("summary",summary(s))}
static func reason_for(s: Dictionary,player: String,cmd: Dictionary) -> String:
	if not players(s).has(player): return "Unknown civilization."
	var p = players(s)[player]
	if cmd.get("type", "") == "attackXeno": return X.attack_reason(s,p,cmd)
	var target = cmd.get("target", "")
	if cmd.get("type", "") == "assign" and cmd.get("job") is String and cmd.job.begins_with("tile:"): target = cmd.job.substr(5)
	if cmd.get("type", "") in ["build","improve"] and s.xenos.nests.values().any(func(n):return n.tile == target): return "A xeno nest occupies this tile."
	if cmd.get("type", "") in ["assign","build","improve","cleanse"] and target != "":
		var owner = Claims.owners(players(s)).get(target,player)
		if owner != player: return "Tile claimed by another civilization."
	return R.reason(p,cmd)
static func command_for(state: Dictionary,player: String,cmd: Dictionary,policy_rule: String = "human_command") -> Dictionary:
	if player == "xeno" and cmd.get("type", "") == "xenoTick":
		var s = state.duplicate(true)
		var before = summary(s) if s.testing.enabled else {}
		X.tick(s,players(s))
		X.burn_occupied(s)
		X.sync_tiles(s)
		record(s,"xeno",cmd,policy_rule,before,true,"Xeno ecology: "+str(s.xenos.lastEvents.size())+" events")
		if s.testing.enabled: s.testing.events.back().environmentEvents = s.xenos.lastEvents.duplicate(true)
		return {"ok":true,"state":s,"message":"Xeno ecology advanced."}
	var block = reason_for(state,player,cmd)
	if block != "":
		var failed = state.duplicate(true)
		record(failed,player,cmd,policy_rule,summary(state),false,block)
		return {"ok":false,"state":failed,"message":block}
	var before = summary(state) if state.testing.enabled else {}
	var s = state.duplicate(true)
	if cmd.get("type", "") == "attackXeno":
		var message = X.attack(s,players(s)[player],cmd)
		X.sync_tiles(s)
		record(s,player,cmd,policy_rule,before,true,message)
		if s.testing.enabled: s.testing.events.back().environmentEvents = s.xenos.lastEvents.duplicate(true)
		return {"ok":true,"state":s,"message":message}
	s.xenos.lastEvents = []
	var result = R.command(s if player == "blue" else s.civilizations[player],cmd)
	if player == "blue": s = result.state
	else: s.civilizations[player] = result.state
	# Cleansing edits shared geography; the animal mat is the authoritative layer.
	if cmd.type == "cleanse":
		var p = players(s)[player]
		s.tiles[cmd.target] = p.tiles[cmd.target].duplicate(true)
		if cmd.layer == "xenomass": s.xenos.mass.erase(cmd.target)
	X.burn_occupied(s,cmd.type in ["endTurn","move","queueMove"],player,cmd.get("unitId", ""))
	X.sync_tiles(s)
	if cmd.type != "focusPerson":
		record(s,player,cmd,policy_rule,before,result.ok,result.message)
		if s.testing.enabled: s.testing.events.back().environmentEvents = s.xenos.lastEvents.duplicate(true)
	return {"ok":result.ok,"state":s,"message":result.message}
static func command(state: Dictionary,cmd: Dictionary) -> Dictionary:
	var result = command_for(state,"blue",cmd)
	if not result.ok or cmd.type != "endTurn": return result
	var s = result.state
	for step in range(8):
		var intent = military_intent(s)
		if intent.is_empty(): intent = Agent.pick(s.civilizations.red)
		if intent.is_empty(): break
		var action = command_for(s,"red",intent.command,intent.rule)
		s = action.state
		if not action.ok: break
	var red_turn = command_for(s,"red",{"type":"endTurn"},"finish_civilization_turn")
	result.state = command_for(red_turn.state,"xeno",{"type":"xenoTick"},"local_ecology").state
	return result
static func projection(s: Dictionary) -> Dictionary:
	var view = own_state(s)
	view.xenos = s.xenos.duplicate(true)
	view.claimOwners = Claims.owners(players(s))
	view.settlementOwners = {}; view.cohortOwners = {}
	for id in players(s):
		var p = players(s)[id]
		for group in ["settlements","cohorts","buildings","districts","improvements"]:
			if id != "blue": view[group].merge(p[group].duplicate(true))
		for key in p.settlements: view.settlementOwners[key] = id
		for key in p.cohorts: view.cohortOwners[key] = id
	return view
static func validate(s) -> String:
	var base = R.validate(s)
	if base != "": return base
	if not s.tiles.has(RED_TOWN): return "Map too small for the two-civilization test scenario."
	if s.get("worldVersion") != 3 or not s.get("civilizations") is Dictionary or not s.civilizations.has("red") or s.civilizations.size() != 1: return "Invalid civilizations."
	var red = s.civilizations.red
	var error = R.validate(red)
	if error != "": return "Red: "+error
	if red.map != s.map or red.turn != s.turn or red.tiles != s.tiles or red.rivers != s.rivers: return "Civilizations must share geography and world turn."
	var xeno_error = X.validate(s.get("xenos"),s,players(s))
	if xeno_error != "": return xeno_error
	for group in ["cohorts","settlements","buildings","districts"]:
		for key in red[group]:
			if s[group].has(key): return "Duplicate civilization object identity."
	if not s.get("testing") is Dictionary or not s.testing.get("enabled") is bool or not s.testing.get("events") is Array or s.testing.events.size() > 10000 or not s.testing.get("initial") is Dictionary or not s.testing.get("outcome") is Dictionary: return "Invalid test recorder."
	if not R.whole(s.testing.get("sequence"),0,9007199254740991) or not R.whole(s.testing.get("dropped"),0,9007199254740991) or not s.testing.outcome.get("status") is String: return "Invalid recorder counters/outcome."
	var previous = 0
	for event in s.testing.events:
		if not event is Dictionary or not R.has_fields(event,["sequence","turn","player","command","policyRule","accepted","message","before","after"]): return "Invalid test event."
		if not R.whole(event.sequence,previous+1,s.testing.sequence) or not R.whole(event.turn,1,s.turn) or event.player not in ["blue","red","xeno"] or not event.command is Dictionary or not event.command.get("type") is String or not event.policyRule is String or not event.accepted is bool or not event.before is Dictionary or not event.after is Dictionary: return "Invalid test event fields."
		previous = event.sequence
	if not s.testing.initial.is_empty():
		if not s.testing.initial.has("blue") or not s.testing.initial.has("red") or R.validate(s.testing.initial.blue) != "" or R.validate(s.testing.initial.red) != "": return "Invalid test starting snapshot."
	return ""
static func migrate(data):
	var base = R.migrate_save(data)
	if R.validate(base) != "" or not base.tiles.has(RED_TOWN): return base
	if base.get("civilizations") is Dictionary:
		for id in base.civilizations: base.civilizations[id] = R.migrate_save(base.civilizations[id])
	if base.get("testing") is Dictionary and base.testing.get("initial") is Dictionary:
		for id in ["blue","red"]:
			if base.testing.initial.has(id): base.testing.initial[id] = R.migrate_save(base.testing.initial[id])
	return attach(base)

static func military_intent(s: Dictionary) -> Dictionary:
	# A finite rule list, ordinary commands only; no search or language-model policy.
	var p = s.civilizations.red
	var army = p.cohorts.values().filter(func(c):return c.qualification == "Soldier")
	army.sort_custom(func(a,b):return a.id < b.id)
	var town = p.settlements.values()[0]
	if s.turn < 12 or R.military_capacity(p) == 0: return {}
	for c in army:
		if c.state.kind != "resident": continue
		if c.state.job != null: return Agent.choice({"type":"assign","cohortId":c.id,"job":null},"free_soldier_for_mobilisation")
		var want_flame = not army.any(func(other):return "flamer" in other.equipment)
		var item = "flamer" if want_flame and "protective_equipment" in p.completed else "small_arms"
		if "small_arms" not in c.equipment and "flamer" not in c.equipment:
			var equip = {"type":"equip","cohortId":c.id,"item":item}
			if R.reason(p,equip) == "": return Agent.choice(equip,"equip_army")
			var make = {"type":"manufacture","settlementId":town.id,"item":item}
			if R.reason(p,make) == "": return Agent.choice(make,"manufacture_army_equipment")
			continue
		if not army.any(func(other):return "rover" in other.equipment):
			var equip = {"type":"equip","cohortId":c.id,"item":"rover"}
			if R.reason(p,equip) == "": return Agent.choice(equip,"equip_army_transport")
			var make = {"type":"manufacture","settlementId":town.id,"item":"rover"}
			if R.reason(p,make) == "": return Agent.choice(make,"manufacture_army_transport")
		var deploy = {"type":"mobilise","cohortId":c.id}
		if R.reason(p,deploy) == "": return Agent.choice(deploy,"mobilise_hunting_party")
	if army.size() < 3 and p.cohorts.size() >= 7 and p.trainingProject == null:
		var recruits = p.cohorts.values().filter(func(c):return c.qualification == "Worker" and c.state.kind == "resident" and not R.builder(c))
		recruits.sort_custom(func(a,b):return a.id < b.id)
		for c in recruits:
			var train = {"type":"train","cohortId":c.id,"qualification":"Soldier"}
			if R.reason(p,train) == "": return Agent.choice(train,"train_hunting_party")
	var deployed = army.filter(func(c):return c.state.kind == "mobile")
	if deployed.size() < 2: return {}
	for c in deployed:
		if c.state.movementRemaining < 1 or s.xenos.lastHumanAttack.get(c.id,-1) == s.turn: continue
		var animals = s.xenos.units.values()
		animals.sort_custom(func(a,b):
			var da = R.distance(s.tiles[c.state.tileId],s.tiles[a.tile]); var db = R.distance(s.tiles[c.state.tileId],s.tiles[b.tile])
			return da < db or (da == db and a.id < b.id))
		for animal in animals:
			for mode in ["ranged","melee"]:
				var cmd = {"type":"attackXeno","cohortId":c.id,"targetId":animal.id,"mode":mode}
				if reason_for(s,"red",cmd) == "": return Agent.choice(cmd,"ranged_hunt" if mode == "ranged" else "contact_hunt")
		if s.xenos.humanHealth.get(c.id,100) < 60:
			if c.state.tileId == town.tileId: continue
			var retreat = {"type":"queueMove","unitId":c.id,"target":town.tileId}
			if not p.movementQueues.has(c.id) and R.reason(p,retreat) == "": return Agent.choice(retreat,"retreat_to_heal")
			continue
		var target = ""
		if not animals.is_empty() and R.distance(s.tiles[c.state.tileId],s.tiles[animals[0].tile]) <= 5: target = animals[0].tile
		else:
			for nest in s.xenos.nests.values():
				if not nest.burned: target = nest.tile; break
		if target == "" or target == c.state.tileId or p.movementQueues.has(c.id): continue
		var move = {"type":"queueMove","unitId":c.id,"target":target}
		if R.reason(p,move) == "": return Agent.choice(move,"hunt_animals_or_occupy_nest")
	return {}
