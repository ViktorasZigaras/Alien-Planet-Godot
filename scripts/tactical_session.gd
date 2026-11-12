extends RefCounted
const Previous = preload("res://scripts/ecology_session.gd")
const E = Previous.E
const R = E.R
const X = Previous.Wildlife
const K = Previous.K

static func initial() -> Dictionary:
	var s = Previous.initial()
	s.tactics = {"auto":true,"target":"","down":{},"evacuating":{},"orders":[]}
	var guard = s.cohorts.explorer.duplicate(true)
	guard.id = "guard"
	guard.name = "Rifle Soldier"
	guard.qualification = "Soldier"
	guard.equipment = ["small_arms"]
	s.cohorts.guard = guard
	K.observe(s)
	return s

static func visible_animals(s: Dictionary) -> Array:
	return s.xenos.units.values().filter(func(animal): return s.knowledge.visible.has(animal.tile))

static func threat(s: Dictionary, tile: String) -> bool:
	return visible_animals(s).any(func(animal): return animal.kind != "larva" and R.distance(s.tiles[tile],s.tiles[animal.tile]) <= 3)

static func retreat(s: Dictionary, id: String) -> Dictionary:
	if not s.cohorts.has(id): return rejected(s,"Select a cohort.")
	var home = s.settlements.main.tileId
	var person = s.cohorts[id]
	var tile = R.person_tile(s,person)
	if tile == home:
		person.state.job = null
		s.movementQueues.erase(id)
		s.moveProgress.erase(id)
		return {"ok":true,"state":s,"message":"Sheltering at Landing Station."}
	if R.path(s,tile,home,"").is_empty(): return rejected(s,"No observed land route to shelter.")
	if person.state.kind == "resident":
		person.state = {"kind":"mobile","tileId":tile,"movementRemaining":1.0,"job":null}
		s.tactics.evacuating[id] = true
		s.progression.training.erase(id)
		s.commitments.people.erase(id)
	var queued = s.movementQueues.get(id,[])
	if not queued.is_empty() and queued.back() == home:
		return {"ok":true,"state":s,"message":"Retreat already queued."}
	return Previous.command(s,{"type":"queueMove","unitId":id,"target":home})

static func rejected(s: Dictionary, message: String) -> Dictionary:
	return {"ok":false,"state":s,"message":message}

static func attack(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var error = X.attack_reason(s,s,cmd)
	if error != "": return rejected(s,error)
	var message = X.attack(s,s,cmd)
	X.sync_tiles(s)
	K.observe(s)
	return {"ok":true,"state":s,"message":message}

static func preview(s: Dictionary, id: String, target: String, mode: String) -> String:
	var cmd = {"cohortId":id,"targetId":target,"mode":mode}
	var error = X.attack_reason(s,s,cmd)
	if error != "": return error
	var animal = s.xenos.units[target]
	var person = s.cohorts[id]
	if mode == "melee": return "Duel win chance %d%%" % roundi(100*X.preview(s,s,person,animal))
	var defence = float(X.DATA[animal.kind].attack)*X.C.defence(s.tiles[animal.tile])
	var damage = X.C.ranged_damage(X.human_power(s,person,true),defence,X.hp(s.xenos,id),int(animal.hp))
	return "Fire deals %d damage" % mini(damage,int(animal.hp))

static func automate(s: Dictionary) -> Dictionary:
	if not s.tactics.auto: return s
	var home = s.settlements.main.tileId
	var orders: Array[String] = []
	if s.resources.energy <= 0:
		for id in s.cohorts:
			if s.cohorts[id].state.kind != "resident": continue
			var candidate = E.command(s,{"type":"assign","person":id,"job":"generate"})
			if candidate.ok and E.resolve(candidate.state,false).ledger.closing.food >= 0:
				s = candidate.state
				orders.append("%s assigned to emergency generation" % id)
				break
	var home_threat = threat(s,home)
	var soldiers = []
	for id in s.cohorts.keys():
		var person = s.cohorts[id]
		var tile = R.person_tile(s,person)
		if person.qualification == "Soldier" and person.state.kind == "mobile":
			soldiers.append(id)
		elif tile != home and threat(s,tile) and not s.get("expansion",{}).get("outposts",{}).values().any(func(site): return site.crew == id):
			var result = retreat(s,id)
			if result.ok:
				s = result.state
				orders.append("%s retreats toward shelter" % id)
	var reserve = ""
	for id in soldiers:
		if s.cohorts[id].state.tileId == home and X.hp(s.xenos,id)>=35:
			reserve = id
			break
	if reserve == "" and not soldiers.is_empty(): reserve = soldiers[0]
	var target = s.xenos.units.get(s.tactics.target,{})
	if not target.is_empty() and not s.knowledge.visible.has(target.tile): target = {}
	var power = 0.0
	for id in soldiers:
		if id != reserve and X.hp(s.xenos,id)>=45:
			power += X.C.effective(X.human_power(s,s.cohorts[id]),X.hp(s.xenos,id))
	var opposition = 0.0
	if not target.is_empty():
		for animal in visible_animals(s):
			if R.distance(s.tiles[animal.tile],s.tiles[target.tile]) <= 1:
				opposition += X.C.effective(float(X.DATA[animal.kind].attack)*X.C.defence(s.tiles[animal.tile]),int(animal.hp))
	var expedition = not target.is_empty() and not home_threat and power >= 1.25*opposition
	if not target.is_empty() and not expedition: orders.append("Expedition holds for garrison, health or strength")
	for id in soldiers:
		var person = s.cohorts[id]
		var tile = person.state.tileId
		if X.hp(s.xenos,id)<45 or (id == reserve and tile != home) or (home_threat and tile != home):
			var result = retreat(s,id)
			if result.ok: s = result.state
			orders.append("%s returns to the station" % id)
			continue
		var fired = false
		for animal in visible_animals(s):
			if id == reserve and R.distance(s.tiles[home],s.tiles[animal.tile])>2: continue
			if id != reserve and not expedition and not home_threat: continue
			var cmd = {"cohortId":id,"targetId":animal.id,"mode":"ranged"}
			if X.attack_reason(s,s,cmd) == "":
				s = attack(s,cmd).state
				orders.append("%s fires at %s" % [id,X.DATA[animal.kind].name])
				fired = true
				break
		if fired or id == reserve: continue
		if not expedition:
			if tile != home:
				var result = retreat(s,id)
				if result.ok: s = result.state
			continue
		if not s.movementQueues.get(id,[]).is_empty(): continue
		var destination = ""
		var best = INF
		for next in R.neighbours(s,target.tile):
			if not s.knowledge.visible.has(next) or s.tiles[next].hostiles>0 or next == tile: continue
			var route = R.path(s,tile,next,"")
			if not route.is_empty() and route.cost < best:
				destination = next
				best = route.cost
		if destination != "":
			var result = Previous.command(s,{"type":"queueMove","unitId":id,"target":destination})
			if result.ok:
				s = result.state
				orders.append("%s advances on the observed target" % id)
	s.tactics.orders = orders
	return s

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	var kind = cmd.get("type","")
	var id = cmd.get("person","")
	if kind in ["attackXeno","retreat","tacticalAuto","expedition","standDown","equipSoldier","endTurn"]:
		var next = s.duplicate(true)
		match kind:
			"attackXeno": return attack(next,cmd)
			"retreat": return retreat(next,id)
			"tacticalAuto": next.tactics.auto = cmd.get("enabled",false) == true
			"expedition":
				var target = next.xenos.units.get(cmd.get("targetId",""),{})
				if target.is_empty() or not next.knowledge.visible.has(target.tile): return rejected(s,"Choose an observed animal.")
				next.tactics.target = target.id
			"standDown": next.tactics.target = ""
			"equipSoldier":
				var weapon = cmd.get("weapon","")
				var person = next.cohorts.get(id,{})
				var home = next.settlements.main.tileId
				if weapon not in ["small_arms","flamer"] or person.get("qualification") != "Soldier" or R.person_tile(next,person) != home or next.tactics.down.has(id) or id in next.construction.holders:
					return rejected(s,"A ready Soldier at the station can equip a rifle or flamer.")
				if weapon in person.equipment: return rejected(s,"That weapon is already equipped.")
				var cost = 2 if weapon == "flamer" else 1
				if Previous.Previous.Previous.P.available(next,"industry") < cost: return rejected(s,"Needs %d unreserved Industry." % cost)
				E.change(next,"industry",-cost)
				person.equipment = [weapon]
				person.state = {"kind":"mobile","tileId":home,"movementRemaining":0.0,"job":null}
				next.movementQueues.erase(id)
				next.moveProgress.erase(id)
			"endTurn":
				next = automate(next)
				var result = Previous.command(next,cmd)
				if not result.ok: return result
				next = result.state
				var home = next.settlements.main.tileId
				for person_id in next.tactics.evacuating.keys():
					if next.cohorts[person_id].state.tileId == home:
						next.cohorts[person_id].state = {"kind":"resident","settlementId":"main","job":null}
						next.tactics.evacuating.erase(person_id)
				for person_id in next.tactics.down.keys():
					if X.hp(next.xenos,person_id)>=35: next.tactics.down.erase(person_id)
				K.observe(next)
		return {"ok":true,"state":next,"message":"Tactical order recorded."}
	return Previous.command(s,cmd)

static func validate(s) -> String:
	if not s is Dictionary or not s.get("tactics") is Dictionary: return "Missing tactics state."
	var tactics = s.tactics
	if not tactics.get("auto") is bool or not tactics.get("target") is String or not tactics.get("down") is Dictionary or not tactics.get("evacuating") is Dictionary or not tactics.get("orders") is Array: return "Invalid tactical orders."
	for id in tactics.down.keys()+tactics.evacuating.keys():
		if not s.cohorts.has(id): return "Missing tactical cohort."
	return Previous.validate(s)
