extends RefCounted
const Expansion = preload("res://scripts/expansion_session.gd")
const E = Expansion.E
const R = Expansion.R
const Planner = Expansion.Planner
const COST = 2
const DURATION = 5
const FOOD = 3
const STOCK = 6
const TERMS = ["passage","rations"]

static func attach(s: Dictionary) -> Dictionary:
	var home = s.settlements.main.tileId
	var routes = R.routes(s,home).costs
	var contact = ""
	var best = INF
	for key in routes:
		var tile = s.tiles[key]
		if s.knowledge.visible.has(key): continue
		if R.distance(s.tiles[home],tile) < 3: continue
		var score = float(routes[key])
		if tile.obstacle != "" or tile.relief == "hills": score += 20
		if s.xenos.nests.values().any(func(n): return R.distance(tile,s.tiles[n.tile]) < 3): score += 40
		if score < best:
			best = score
			contact = key
	s.expansion.contact = contact
	s.diplomacy = {"passage_until":0,"minerals":0,"food":STOCK,"last_trade":0}
	return s

static func known(s: Dictionary) -> bool:
	return s.knowledge.memory.has(s.expansion.contact)

static func active(s: Dictionary) -> bool:
	return s.diplomacy.passage_until > s.turn

static func reason(s: Dictionary, cmd: Dictionary) -> String:
	if cmd.type in ["move","queueMove"] and cmd.get("target","") == s.expansion.contact and known(s):
		var unit = R.mobile(s,cmd.get("unitId",""))
		if not unit.is_empty() and not R.passage_allowed(s,cmd.target,unit.classId):
			return "Compact passage excludes soldiers." if unit.classId == "soldier" else "Negotiate civilian passage before entering Compact territory."
	if cmd.type != "compactOffer": return Expansion.reason(s,cmd)
	if not known(s): return "Locate the Survey Compact first."
	if cmd.get("term") not in TERMS: return "The Compact declines those terms."
	match cmd.term:
		"passage":
			if active(s): return "Civilian passage is already active."
		"rations":
			if s.diplomacy.last_trade == s.turn: return "The Compact trades rations once per turn."
			if s.diplomacy.food < FOOD: return "The Compact has no rations left to trade."
	if Planner.available(s,"minerals") < COST: return "Needs 2 unreserved Minerals."
	return ""

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	if cmd.type != "compactOffer":
		if cmd.type in ["move","queueMove"] and known(s) and cmd.get("target","") == s.expansion.contact:
			var blocked = reason(s,cmd)
			if blocked != "": return Expansion.Tactical.rejected(s,blocked)
		var result = Expansion.command(s,cmd)
		if result.ok and cmd.type == "endTurn" and active(s) and not active(result.state):
			result.message = "Compact passage expired. Visitors may leave, and entry requires a new agreement."
		return result
	var blocked = reason(s,cmd)
	if blocked != "": return Expansion.Tactical.rejected(s,blocked)
	var next = s.duplicate(true)
	E.change(next,"minerals",-COST)
	next.diplomacy.minerals += COST
	if cmd.term == "passage":
		next.diplomacy.passage_until = next.turn+DURATION
		return {"ok":true,"state":next,"message":"The Compact granted five turns of civilian passage."}
	next.diplomacy.food -= FOOD
	next.diplomacy.last_trade = next.turn
	E.change(next,"food",FOOD)
	return {"ok":true,"state":next,"message":"Received 3 Food from the Compact."}

static func validate(s) -> String:
	var error = Expansion.validate(s)
	if error != "": return error
	if not s.get("diplomacy") is Dictionary: return "Missing Compact agreement records."
	var data = s.diplomacy
	if not R.whole(data.get("passage_until"),0,s.turn+DURATION) or not R.whole(data.get("minerals"),0,9007199254740991) or not R.whole(data.get("food"),0,STOCK) or not R.whole(data.get("last_trade"),0,s.turn): return "Invalid Compact agreement records."
	return ""
