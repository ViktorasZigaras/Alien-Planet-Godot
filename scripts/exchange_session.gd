extends RefCounted
const Diplomacy = preload("res://scripts/diplomacy_session.gd")
const E = Diplomacy.E
const R = Diplomacy.R
const BASE_SCIENCE = 3
const MERCHANT_BONUS = 2
const SCIENCE_COST = 2
const FOOD_YIELD = 2
const FOOD_STOCK = 8
const SCIENCE_STOCK = 12

static func attach(s: Dictionary) -> Dictionary:
	var sites = {}
	var home = s.settlements.main.tileId
	var routes = R.routes(s,home).costs
	var relay = ""
	var best = INF
	for key in routes:
		var tile = s.tiles[key]
		if key == home or key == s.expansion.contact: continue
		if R.distance(s.tiles[home],tile) < 2: continue
		if s.cohorts.values().any(func(person): return person.state.job == "tile:"+key): continue
		var score = float(routes[key])+(2 if not s.knowledge.visible.has(key) else 0)
		if tile.relief != "flat" or tile.obstacle != "" or tile.feature != null: score += 20
		if s.xenos.nests.values().any(func(n): return R.distance(tile,s.tiles[n.tile]) < 3): score += 40
		if score < best:
			best = score
			relay = key
	if relay != "": sites[relay] = inventory("Independent Relay")
	if s.expansion.contact != "": sites[s.expansion.contact] = inventory("Compact Exchange")
	s.exchange = {"sites":sites}
	return s

static func inventory(title: String) -> Dictionary:
	return {"name":title,"food":FOOD_STOCK,"science":SCIENCE_STOCK,"minerals":0,"last_turn":0,"visitor":"","service":""}

static func science_yield(person: Dictionary) -> int:
	return BASE_SCIENCE+(MERCHANT_BONUS if person.get("qualification") == "Merchant" else 0)

static func reason(s: Dictionary, cmd: Dictionary) -> String:
	if cmd.type != "visitService": return Diplomacy.reason(s,cmd)
	var key: String = cmd.get("tile","")
	if not s.exchange.sites.has(key) or not s.knowledge.visible.has(key): return "Choose an observed exchange site."
	var id: String = cmd.get("person","")
	var person = s.cohorts.get(id,{})
	if person.is_empty() or person.state.kind != "mobile" or person.state.tileId != key: return "Move a civilian onto the exchange site."
	if person.qualification == "Soldier" or s.tactics.down.has(id) or Diplomacy.Expansion.staffed(s,id) != "": return "A ready civilian visitor is required."
	if s.movementQueues.has(id) or s.moveProgress.has(id): return "Finish or cancel the travel order first."
	if s.tiles[key].hostiles > 0: return "Wildlife blocks the service."
	if key == s.expansion.contact and not Diplomacy.active(s): return "Compact exchange requires active civilian passage."
	var site = s.exchange.sites[key]
	if site.last_turn == s.turn: return "Your faction already used this site's service this turn."
	match cmd.get("service",""):
		"food":
			if site.food < FOOD_YIELD: return "The site has no rations left."
		"science":
			if site.science < science_yield(person): return "The site has too little survey data for this exchange."
			if Diplomacy.Planner.available(s,"minerals") < SCIENCE_COST: return "Needs 2 unreserved Minerals."
		_: return "Choose a site service."
	return ""

static func command(s: Dictionary, cmd: Dictionary) -> Dictionary:
	if cmd.type != "visitService": return Diplomacy.command(s,cmd)
	var error = reason(s,cmd)
	if error != "": return Diplomacy.Expansion.Tactical.rejected(s,error)
	var next = s.duplicate(true)
	var site = next.exchange.sites[cmd.tile]
	site.last_turn = next.turn
	site.visitor = cmd.person
	site.service = cmd.service
	var amount = FOOD_YIELD if cmd.service == "food" else science_yield(next.cohorts[cmd.person])
	if cmd.service == "science":
		E.change(next,"minerals",-SCIENCE_COST)
		site.minerals += SCIENCE_COST
	site[cmd.service] -= amount
	E.change(next,cmd.service,amount)
	return {"ok":true,"state":next,"message":"%s supplied %d %s." % [site.name,amount,cmd.service.capitalize()]}

static func validate(s) -> String:
	var error = Diplomacy.validate(s)
	if error != "": return error
	if not s.get("exchange") is Dictionary or not s.exchange.get("sites") is Dictionary or s.exchange.sites.size() > 2: return "Invalid exchange network."
	for key in s.exchange.sites:
		var site = s.exchange.sites[key]
		if not s.tiles.has(key) or s.tiles[key].baseTerrain == "water" or not site is Dictionary: return "Invalid site location."
		var name = "Compact Exchange" if key == s.expansion.contact else "Independent Relay"
		if site.get("name") != name or not R.whole(site.get("food"),0,FOOD_STOCK) or not R.whole(site.get("science"),0,SCIENCE_STOCK) or not R.whole(site.get("minerals"),0,SCIENCE_STOCK) or not R.whole(site.get("last_turn"),0,s.turn): return "Invalid site stocks."
		if not site.get("visitor") is String or not site.get("service") is String: return "Invalid visitor record."
		if site.last_turn > 0 and (not s.cohorts.has(site.visitor) or site.service not in ["food","science"]): return "Invalid visitor record."
	return ""
