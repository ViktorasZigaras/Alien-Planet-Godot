class_name CivilizationSession
extends RefCounted
## Blue's compatible rule state plus isolated rival rule states and an optional recorder.
const Shell = preload("res://scripts/shell_fixture.gd")
const X = preload("res://scripts/xeno_ecology.gd")
const R = preload("res://scripts/game_rules.gd")
const Agent = preload("res://scripts/civilization_agent.gd")
const Claims = preload("res://scripts/claim_map.gd")
const RED_TOWN = "10,8"
const GREEN_TOWN = "16,2"
const Coordinator = preload("res://scripts/ai_coordinator.gd")
const Operation = preload("res://scripts/ai_operation.gd")
static func initial_state() -> Dictionary:
	var s = attach(R.initial_state())
	var green = s.civilizations.red.duplicate(true)
	green.idPrefix = "green_"; green.policyProfile = {"defence":"nest_campaign"}
	green.settlements = {"green_town":{"id":"green_town","name":"Green Reach","tileId":GREEN_TOWN,"growth":0}}
	green.cohorts = {}; green.buildings = {}; green.districts = {}; green.improvements = {}
	green.resources = R.preset().start.duplicate(true)
	green.equipment = {"green_town":{"work_suit":2,"small_arms":1,"flamer":0,"rover":0,"survey_kit":0,"reinforced_suit":0}}
	green.tileAccess = {"green_town":[]}
	for key in s.tiles:
		if R.distance(s.tiles[key],s.tiles[GREEN_TOWN])<=2: green.tileAccess.green_town.append(key)
	for i in range(5):
		R.new_person(green,"green_town")
	for kind in ["lab","civic","training"]:
		var key = "green_"+kind
		green.buildings[key] = {"id":key,"type":kind,"tier":1,"settlementId":"green_town"}
	green.ai = Coordinator.initial("green")
	s.civilizations.green = green; s.xenos.deaths.green = 0
	for player in ["red","green"]:
		var state = s.civilizations[player]
		var town = state.settlements.keys()[0]
		var center = state.settlements[town].tileId
		var positions = [center]+R.neighbours(state,center).filter(func(key):return state.tiles[key].baseTerrain!="water")
		for i in range(4):
			var key = player+"_field_"+str(i)
			state.cohorts[key] = {"id":key,"name":player.capitalize()+" field Soldier "+str(i+1),"qualification":"Soldier","home":town,"equipment":["flamer" if i==3 else "small_arms"],"facing":0.0,"lastUsed":0,"lastRoute":[],"state":{"kind":"mobile","tileId":positions[i/3],"movementRemaining":1.0}}
	X.sync_tiles(s)
	return s
static func own_state(s: Dictionary) -> Dictionary:
	var own = {}
	# Exclude recorder/rivals before copying; history must not be copied then discarded.
	for key in s:
		if key not in ["civilizations","testing","worldVersion","xenos"]:
			own[key] = s[key].duplicate(true) if s[key] is Dictionary or s[key] is Array else s[key]
	return own
static func players(s: Dictionary) -> Dictionary:
	var result = {"blue":s}
	for id in s.get("civilizations",{}): result[id] = s.civilizations[id]
	return result
static func attach(s: Dictionary) -> Dictionary:
	if s.get("worldVersion") == 4: return s
	if s.get("worldVersion") == 3:
		s = R.migrate_save(s)
		s.worldVersion = 4
		Coordinator.ensure(s,"blue")
		for id in s.civilizations:
			s.civilizations[id] = R.migrate_save(s.civilizations[id])
			Coordinator.ensure(s.civilizations[id],id)
		return s
	if s.get("worldVersion") == 2:
		s = s.duplicate(true)
		s.worldVersion = 3
		var x = s.xenos
		x.deaths = {"blue":0,"red":0,"animals":0}; x.lastAnimalAttack = {}; x.effects = []; x.effectSequence = 0
		for n in x.nests.values(): n.burned = false
		for u in x.units.values(): u.hp = clampi(roundi(100*float(u.hp)/{"larva":4,"predator":6,"armored":11}[u.kind]),1,100)
		for id in x.humanHealth: x.humanHealth[id] = clampi(int(x.humanHealth[id])*10,1,100)
		X.sync_tiles(s)
		return attach(s)
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
	red.tileAccess = {"red_town":[]}
	for tile in s.tiles.values():
		if R.distance(tile,s.tiles[RED_TOWN])<=2: red.tileAccess.red_town.append(tile.id)
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
	var initial = {"blue":own_state(s),"xenos":s.xenos.duplicate(true),"worldVersion":s.worldVersion}
	for id in s.civilizations: initial[id] = s.civilizations[id].duplicate(true)
	s.testing = {"enabled":true,"events":[],"sequence":0,"dropped":0,"initial":initial,"outcome":{"status":"in_progress"}}
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
	return {"format":"alien-planet-test-reconstruction-v1","gameVersion":"0.910-reconstructed","seed":s.map.seed,"initial":s.testing.initial,"events":s.testing.events,"droppedEvents":s.testing.dropped,"outcome":s.testing.outcome,"final":s.testing.outcome.get("summary",summary(s))}
static func reason_for(s: Dictionary,player: String,cmd: Dictionary) -> String:
	if not players(s).has(player): return "Unknown civilization."
	var p = players(s)[player]
	if cmd.get("type", "") == "focusPerson": return R.reason(p,cmd)
	if s.get("scenario", "") == Shell.ID: return Shell.reason(s,cmd)
	if cmd.get("type", "") == "aiReview": return ""
	if cmd.get("type", "") == "found":
		var founder = p.cohorts.get(cmd.get("cohortId", ""),{})
		if not founder.is_empty() and founder.state.kind=="mobile":
			for other in players(s).values():
				for town in other.settlements.values():
					if R.distance(s.tiles[founder.state.tileId],s.tiles[town.tileId])<3: return "Too near an existing settlement."
	if cmd.get("type", "") == "attackXeno": return X.attack_reason(s,p,cmd)
	var target = cmd.get("target", "")
	if cmd.get("type", "") == "assign" and cmd.get("job") is String and cmd.job.begins_with("tile:"): target = cmd.job.substr(5)
	if cmd.get("type", "") in ["build","improve"] and s.xenos.nests.values().any(func(n):return n.tile == target): return "A xeno nest occupies this tile."
	if cmd.get("type", "") in ["assign","build","improve","cleanse","buyTile"] and target != "":
		var owner = Claims.owners(players(s)).get(target,player)
		if owner != player: return "Tile claimed by another civilization."
	return R.reason(p,cmd)
static func command_for(state: Dictionary,player: String,cmd: Dictionary,policy_rule: String = "human_command") -> Dictionary:
	# Selection is presentation state, even for callers using the legacy command API.
	if cmd.get("type", "") == "focusPerson":
		var block = "Unknown person."
		if players(state).has(player): block = R.reason(players(state)[player],cmd)
		return {"ok":block == "","state":state,"message":"Selection updated." if block == "" else block}
	if state.get("scenario", "") == Shell.ID:
		if player != "blue": return {"ok":false,"state":state,"message":"Only Blue exists in B01."}
		var before = summary(state) if state.testing.enabled else {}
		var result = Shell.command(state,cmd)
		if not result.ok: result.state = state.duplicate(true)
		record(result.state,player,cmd,policy_rule,before,result.ok,result.message)
		return result
	if cmd.get("type", "") == "aiReview":
		if not players(state).has(player): return {"ok":false,"state":state,"message":"Unknown civilization."}
		var s = state.duplicate(true)
		var before = summary(s) if s.testing.enabled else {}
		Coordinator.review(s,players(s)[player],player)
		record(s,player,cmd,policy_rule,before,true,"Council reviewed objectives and authorizations.")
		return {"ok":true,"state":s,"message":"Council reviewed."}

	if player == "xeno" and cmd.get("type", "") == "xenoTick":
		var s = state.duplicate(true)
		var before = summary(s) if s.testing.enabled else {}
		X.tick(s,players(s))
		for id in players(s):
			Coordinator.ensure(players(s)[id],id)
			Coordinator.L.observe(s,players(s)[id],id,s.xenos.lastEvents)
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
		var acting = players(s)[player]
		Coordinator.ensure(acting,player)
		var message = X.attack(s,acting,cmd)
		Coordinator.L.observe(s,acting,player,s.xenos.lastEvents)
		Coordinator.applied(acting,cmd,policy_rule,{}, {"plan":cmd.get("_aiPlan", ""),"world":s})
		X.sync_tiles(s)
		record(s,player,cmd,policy_rule,before,true,message)
		if s.testing.enabled: s.testing.events.back().environmentEvents = s.xenos.lastEvents.duplicate(true)
		return {"ok":true,"state":s,"message":message}
	s.xenos.lastEvents = []
	var acting_before = players(s)[player].cohorts.get(cmd.get("cohortId", ""),{}).get("state",{}).duplicate(true)
	var result = R.command(s if player == "blue" else s.civilizations[player],cmd)
	if player == "blue": s = result.state
	else: s.civilizations[player] = result.state
	var acting = players(s)[player]
	Coordinator.ensure(acting,player)
	if cmd.type != "focusPerson":
		Coordinator.applied(acting,cmd,policy_rule,acting_before,{"plan":cmd.get("_aiPlan", ""),"world":s})
		if not acting.ai.operation.is_empty():
			Operation.review(s,acting)
			if Operation.can_commission(s,acting): acting.ai.operation.phase = "commission"
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
static func ai_turn(state: Dictionary,player: String) -> Dictionary:
	var s = command_for(state,player,{"type":"aiReview"},"council_review").state
	for step in range(12):
		var intent = Coordinator.choose(s,players(s)[player],player)
		if intent.is_empty(): break
		var cmd = intent.command.duplicate(true)
		cmd._aiPlan = intent.get("plan", "")
		var result = command_for(s,player,cmd,intent.rule)
		s = result.state
		if not result.ok: break
	return command_for(s,player,{"type":"endTurn"},"finish_civilization_turn").state
static func advance_round(state: Dictionary,all_ai: bool = true) -> Dictionary:
	if state.get("scenario", "") == Shell.ID: return command_for(state,"blue",{"type":"endTurn"})
	var s = ai_turn(state,"blue") if all_ai else command_for(state,"blue",{"type":"endTurn"}).state
	var ids = s.civilizations.keys().map(func(id):return str(id)); ids.sort()
	for player in ids: s = ai_turn(s,player)
	return command_for(s,"xeno",{"type":"xenoTick"},"local_ecology").state
static func command(state: Dictionary,cmd: Dictionary) -> Dictionary:
	if state.get("scenario", "") == Shell.ID: return command_for(state,"blue",cmd)
	if cmd.type == "endTurn": return {"ok":true,"state":advance_round(state,false),"message":"Round complete."}
	return command_for(state,"blue",cmd)
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
	var shell = s.get("scenario", "") == Shell.ID
	if s.has("scenario") and not shell: return "Unknown development fixture."
	if not shell and not s.tiles.has(RED_TOWN): return "Map too small for the two-civilization test scenario."
	if s.get("worldVersion") != 4 or not s.get("civilizations") is Dictionary: return "Invalid civilizations."
	if shell:
		if not s.civilizations.is_empty() or s.map.width != 9 or s.map.height != 7 or s.settlements.size() != 1 or s.cohorts.size() != 1: return "Invalid B01 fixture population/map."
		if not s.settlements.has("main") or not s.cohorts.has("pop_a") or s.settlements.main.tileId != "2,3": return "Invalid B01 fixture identities."
		var person = s.cohorts.pop_a
		if person.state.kind != "mobile" or person.qualification != "Worker" or not person.equipment.is_empty(): return "Invalid B01 survey party."
		for group in ["buildings","districts","improvements","neutralSites"]:
			if not s[group].is_empty(): return "B01 development is inactive."
		if s.trainingProject != null or s.constructionProject != null or not s.completed.is_empty() or s.settlements.main.growth != 0: return "B01 projects/growth are inactive."
		for stock in s.resources.values():
			if stock != 0: return "B01 resource accounting is inactive."
		if not s.get("xenos") is Dictionary: return "Missing B01 environment."
		for group in ["nests","units","mass","humanHealth","lastHumanAttack","lastAnimalAttack"]:
			if not s.xenos.get(group) is Dictionary or not s.xenos[group].is_empty(): return "B01 ecology is inactive."

	elif not s.civilizations.has("red") or s.civilizations.size() > 2 or s.civilizations.keys().any(func(k):return k not in ["red","green"]): return "Invalid civilizations."
	var all_ids = {}
	for id in players(s):
		var state = players(s)[id]
		var error = R.validate(state)
		if error != "": return id+": "+error
		error = "" if shell else Coordinator.validate(state)
		if error != "": return id+": "+error
		if state.map != s.map or state.turn != s.turn or state.tiles != s.tiles or state.rivers != s.rivers: return "Civilizations must share geography and world turn."
		for group in ["cohorts","settlements","buildings","districts"]:
			for key in state[group]:
				if all_ids.has(key): return "Duplicate civilization object identity."
				all_ids[key] = true
	var xeno_error = X.validate(s.get("xenos"),s,players(s))
	if xeno_error != "": return xeno_error
	if not s.get("testing") is Dictionary or not s.testing.get("enabled") is bool or not s.testing.get("events") is Array or s.testing.events.size() > 10000 or not s.testing.get("initial") is Dictionary or not s.testing.get("outcome") is Dictionary: return "Invalid test recorder."
	if not R.whole(s.testing.get("sequence"),0,9007199254740991) or not R.whole(s.testing.get("dropped"),0,9007199254740991) or not s.testing.outcome.get("status") is String: return "Invalid recorder counters/outcome."
	var previous = 0
	for event in s.testing.events:
		if not event is Dictionary or not R.has_fields(event,["sequence","turn","player","command","policyRule","accepted","message","before","after"]): return "Invalid test event."
		if not R.whole(event.sequence,previous+1,s.testing.sequence) or not R.whole(event.turn,1,s.turn) or event.player not in ["blue","red","green","xeno"] or not event.command is Dictionary or not event.command.get("type") is String or not event.policyRule is String or not event.accepted is bool or not event.before is Dictionary or not event.after is Dictionary: return "Invalid test event fields."
		previous = event.sequence
	if not s.testing.initial.is_empty():
		if not s.testing.initial.has("blue") or R.validate(s.testing.initial.blue) != "": return "Invalid test starting snapshot."
		for id in s.civilizations:
			if not s.testing.initial.has(id) or R.validate(s.testing.initial[id]) != "": return "Invalid test starting snapshot."
	return ""
static func migrate(data):
	var base = R.migrate_save(data)
	if R.validate(base) != "": return base
	if base.get("scenario", "") == Shell.ID: return base
	if not base.tiles.has(RED_TOWN): return base
	if base.get("civilizations") is Dictionary:
		for id in base.civilizations: base.civilizations[id] = R.migrate_save(base.civilizations[id])
	if base.get("testing") is Dictionary and base.testing.get("initial") is Dictionary:
		for id in ["blue"]+base.get("civilizations",{}).keys():
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

static func from_recording(initial: Dictionary) -> Dictionary:
	var s = initial.blue.duplicate(true)
	s.worldVersion = int(initial.get("worldVersion",4))
	s.civilizations = {}
	for id in initial:
		if id not in ["blue","xenos","worldVersion"]: s.civilizations[id] = initial[id].duplicate(true)
	s.xenos = initial.xenos.duplicate(true)
	s.testing = {"enabled":false,"events":[],"sequence":0,"dropped":0,"initial":{},"outcome":{"status":"in_progress"}}
	return migrate(s)
