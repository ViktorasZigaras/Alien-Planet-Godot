class_name AIOperation
extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const X = preload("res://scripts/xeno_ecology.gd")
const A = preload("res://scripts/ai_assessment.gd")
const P = preload("res://scripts/ai_plan_actions.gd")
const L = preload("res://scripts/ai_lieutenant.gd")
static func initial(p: Dictionary,target: String) -> Dictionary:
	return {"target":target,"hub":P.home(p),"phase":"prepare","required":{"rifles":4,"flamers":2,"homeGuard":1,"civilians":6},"force":[],"guard":"","approvedTurn":p.turn,"releaseTurn":0,"releases":0,"blockers":[],"history":[]}
static func target(world: Dictionary) -> String:
	var ids = world.xenos.nests.keys(); ids.sort()
	for id in ids:
		if not world.xenos.nests[id].burned: return world.xenos.nests[id].tile
	return ""
static func slots(p: Dictionary) -> Dictionary:
	var soldiers = A.people(p).filter(func(c):return c.qualification == "Soldier")
	var guard = ""; var force = []
	for c in soldiers:
		if "flamer" not in c.equipment: guard = c.id; break
	for c in soldiers:
		if c.id != guard and force.size()<6: force.append(c.id)
	return {"guard":guard,"force":force}
static func supply(p: Dictionary,force: Array,horizon: int) -> Dictionary:
	var copy = p.duplicate(false); copy.cohorts = p.cohorts.duplicate(true)
	for id in force:
		if not copy.cohorts.has(id): continue
		var c = copy.cohorts[id]
		if c.state.kind == "resident": c.state = {"kind":"mobile","tileId":p.settlements[c.home].tileId,"movementRemaining":0.0}
	var net = R.economy(copy).delta
	var missing = []
	for k in ["food","industry"]:
		if p.resources[k]+mini(0,net[k])*horizon < 4: missing.append(k)
	return {"ready":missing.is_empty(),"missing":missing,"net":net,"horizon":horizon}
static func readiness(world: Dictionary,p: Dictionary) -> Dictionary:
	var op = p.ai.operation
	var group = slots(p); var blockers = []
	var rifles = 0; var flamers = 0
	if group.guard == "": blockers.append("home guard")
	else:
		var guard = p.cohorts[group.guard]
		if guard.state.kind!="mobile" or "small_arms" not in guard.equipment or X.hp(world.xenos,guard.id)<75: blockers.append("armed commissioned home guard")
	if group.force.size()!=6: blockers.append("six offensive Soldiers")
	if p.cohorts.values().filter(func(c):return c.qualification != "Soldier").size()<op.required.civilians: blockers.append("civilian support")
	var hub = p.settlements[op.hub].tileId
	for id in group.force:
		var c = p.cohorts[id]
		if "flamer" in c.equipment: flamers += 1
		elif "small_arms" in c.equipment: rifles += 1
		if c.state.kind != "mobile": blockers.append(id+": not commissioned")
		elif R.distance(p.tiles[c.state.tileId],p.tiles[hub])>2: blockers.append(id+": not staged")
		if X.hp(world.xenos,id)<75: blockers.append(id+": wounded")
	if rifles!=4 or flamers!=2: blockers.append("four rifles and two flamers")
	var provision = supply(p,group.force,24)
	for k in provision.missing: blockers.append("provision "+k)
	return {"ready":blockers.is_empty(),"blockers":blockers,"force":group.force,"guard":group.guard,"supply":provision}
static func review(world: Dictionary,p: Dictionary) -> void:
	var op = p.ai.operation
	if target(world)=="": op.phase = "complete"; op.blockers = []; return
	if not p.settlements.has(op.hub): op.phase = "cancelled"; op.blockers = ["assembly hub lost"]; return
	var group = slots(p)
	if op.phase == "deployed":
		var horizon = maxi(4,24-(p.turn-int(op.releaseTurn)))
		var surviving = op.force.filter(func(id):return p.cohorts.has(id))
		if surviving.size()<4 or not supply(p,surviving,horizon).ready:
			op.phase = "recovery"; op.blockers = ["attrition or insufficient operating support"]
		return
	op.force = group.force; op.guard = group.guard
	var ready = readiness(world,p)
	op.blockers = ready.blockers
	if ready.ready:
		op.phase = "deployed"; op.releaseTurn = p.turn; op.releases += 1
		op.history.append({"type":"release","turn":p.turn,"force":op.force.duplicate(),"horizon":24})
		if op.history.size()>64: op.history.pop_front()
static func gear(p: Dictionary,c: Dictionary,item: String) -> Dictionary:
	if item in c.equipment: return {}
	var equip = P.legal(p,{"type":"equip","cohortId":c.id,"item":item},"operation_equip:"+item)
	if not equip.is_empty(): return equip
	var tech = R.content().equipment[item].requires
	if tech not in p.completed: return P.technology(p,tech)
	if item == "flamer" and R.equipment_total(p,item)>=R.military_capacity(p): return P.workplace(p,c.home,"guard_post")
	return P.legal(p,{"type":"manufacture","settlementId":c.home,"item":item},"operation_manufacture:"+item)
static func pick(world: Dictionary,p: Dictionary) -> Dictionary:
	var op = p.ai.operation
	if op.phase in ["complete","cancelled","deployed"]: return {}
	var hub = p.settlements[op.hub].tileId
	var soldiers = A.people(p).filter(func(c):return c.qualification == "Soldier")
	# Recovery or pre-commission: return named troops and use ordinary join orders.
	if op.phase != "commission":
		for c in soldiers:
			if c.state.kind != "mobile": continue
			if c.state.tileId == hub: return P.legal(p,{"type":"join","cohortId":c.id},"operation_dock")
			if p.movementQueues.has(c.id): continue
			return P.legal(p,{"type":"queueMove","unitId":c.id,"target":hub},"operation_return_to_hub")
	if soldiers.size()<7:
		var train = P.training(p,op.hub,"Soldier")
		if not train.is_empty(): return train
		return P.grow(p)
	# Correct explicit composition before commissioning. Guard is kept separate.
	var group = slots(p)
	var desired = {}; var count = 0
	for id in group.force:
		desired[id] = "flamer" if count>=4 else "small_arms"; count += 1
	desired[group.guard] = "small_arms"
	for id in desired:
		var c = p.cohorts[id]
		if c.state.kind != "resident": continue
		var item = desired[id]
		for old in ["flamer","small_arms"]:
			if old != item and old in c.equipment: return P.legal(p,{"type":"equip","cohortId":id,"item":old},"operation_remove_wrong_weapon")
		var equip = gear(p,c,item)
		if not equip.is_empty(): return equip
	var equipped = desired.keys().all(func(id):return desired[id] in p.cohorts[id].equipment)
	if not equipped: return {}
	# Commission is recorded by coordinator after its next review, not by a forged ready flag.
	if op.phase != "commission": return {}
	for id in group.force+[group.guard]:
		var c = p.cohorts[id]
		if c.state.kind == "resident":
			if c.state.job != null: return P.intent({"type":"assign","cohortId":id,"job":null},"operation_clear_domestic_job")
			if L.occupancy(p,hub)>=3:
				for other in L.combatants(p):
					if other.state.tileId != hub or other.id == group.guard: continue
					var options = R.neighbours(p,hub); options.sort()
					for key in options:
						if L.occupancy(p,key)<3 and p.tiles[key].baseTerrain!="water":
							var move = P.legal(p,{"type":"queueMove","unitId":other.id,"target":key},"operation_stage")
							if not move.is_empty() and not p.movementQueues.has(other.id): return move
				return {}
			return P.legal(p,{"type":"mobilise","cohortId":id},"operation_commission")
	return {}
static func can_commission(world: Dictionary,p: Dictionary) -> bool:
	var op = p.ai.operation
	if op.phase not in ["prepare","recovery"]: return false
	var group = slots(p)
	if group.force.size()!=6 or group.guard=="": return false
	var rifles = 0; var flamers = 0
	for id in group.force:
		var c = p.cohorts[id]
		if c.state.kind != "resident" or c.home!=op.hub or X.hp(world.xenos,id)<75: return false
		if "flamer" in c.equipment: flamers += 1
		elif "small_arms" in c.equipment: rifles += 1
	return rifles==4 and flamers==2 and supply(p,group.force,24).ready
static func validate(op,p: Dictionary) -> String:
	if not op is Dictionary or op.is_empty(): return ""
	if not R.has_fields(op,["target","hub","phase","required","force","guard","approvedTurn","releaseTurn","releases","blockers","history"]): return "Missing operation fields."
	if op.phase not in ["prepare","commission","deployed","recovery","complete","cancelled"] or not p.tiles.has(op.target) or not op.hub is String: return "Invalid operation."
	if not op.required is Dictionary or not R.same_keys(op.required,{"rifles":4,"flamers":2,"homeGuard":1,"civilians":6}) or not op.required.keys().all(func(k):return R.whole(op.required[k],{"rifles":4,"flamers":2,"homeGuard":1,"civilians":6}[k],{"rifles":4,"flamers":2,"homeGuard":1,"civilians":6}[k])) or not op.force is Array or op.force.size()>6 or not op.blockers is Array or not op.history is Array or op.history.size()>64: return "Invalid charter."
	var ids = []
	for id in op.force:
		if not id is String or id in ids or id==op.guard: return "Invalid operation membership."
		ids.append(id)
	for key in ["approvedTurn","releaseTurn","releases"]:
		if not R.whole(op[key],0,100000000): return "Invalid operation clock."
	return ""
