extends RefCounted
const R = preload("res://scripts/game_rules.gd")
# Trial recipes: one Industry per effort point; no Engineer bonus is assumed.
const RECIPES = {
	"farm":{"work":4,"kind":"improvement","label":"Farm (+1 Food)"},
	"farm_upgrade":{"work":4,"kind":"upgrade","label":"Farm upgrade (+1 more Food)"},
	"district":{"work":6,"kind":"district","label":"Agriculture district (replaces natural yield)"},
	"greenhouse":{"work":6,"kind":"building","label":"Greenhouse (staffed +3 Food)"}
}

static func attach(s: Dictionary) -> void:
	if not s.has("construction"):
		s.construction = {"next":1,"queue":[],"kits":1,"holders":[],"travelled":[],"farmTiers":{}}

static func available(s: Dictionary, owner: String = "") -> int:
	var reserved = int(s.obligations.get("industry",0))
	for id in s.get("commitments",{}).get("stocks",{}):
		if id != owner: reserved += int(s.commitments.stocks[id].get("industry",0))
	return maxi(0,int(s.resources.industry)-reserved)

static func target_reason(s: Dictionary, recipe: String, tile: String) -> String:
	if not RECIPES.has(recipe) or not s.tiles.has(tile) or s.tiles[tile].baseTerrain == "water" or not R.site_at(s,tile).is_empty(): return "Choose a land hex outside the settlement center."
	var has_farm = s.improvements.get(tile,{}).get("farm",false)
	var district = R.district_at(s,tile)
	match recipe:
		"farm":
			if has_farm or not district.is_empty() or s.tiles[tile].relief == "hills": return "Farm needs an unimproved flat land hex."
		"farm_upgrade":
			if not has_farm or s.construction.farmTiers.get(tile,1)>=2: return "Requires a completed tier-one Farm."
		"district":
			if not district.is_empty() or has_farm: return "Choose an undeveloped district site."
		"greenhouse":
			if district.is_empty(): return "Complete an Agriculture district first."
			for b in s.buildings.values():
				if b.get("districtId") == district.id: return "This district already has a building."
	return ""

static func reason(s: Dictionary, cmd: Dictionary) -> String:
	match cmd.get("type",""):
		"enqueue":
			var error = target_reason(s,cmd.get("recipe",""),cmd.get("tile",""))
			if error != "": return error
			for p in s.construction.queue:
				if p.tile == cmd.tile and p.status != "complete": return "This hex already has an unfinished project."
			return ""
		"hold":
			if not cmd.get("held") is bool: return "Choose hold or resume."
			for p in s.construction.queue:
				if p.id == cmd.get("id") and p.status != "complete": return ""
			return "No unfinished project with that identity."
		"deployBuilder":
			if not s.cohorts.has(cmd.get("person","")): return "Unknown person."
			var c = s.cohorts[cmd.person]
			if c.state.kind != "resident": return "Already outside the settlement."
			if not s.get("commitments",{}).get("people",{}).get(c.id,{}).is_empty(): return "Release this person's planning commitment first."
			if s.construction.holders.size() >= s.construction.kits: return "Reusable build kit is already equipped."
			return ""
		"returnBuilder":
			if not s.cohorts.has(cmd.get("person","")) or cmd.person not in s.construction.holders: return "Not an equipped builder."
			if s.cohorts[cmd.person].state.tileId != s.settlements.main.tileId: return "Travel back to the Landing Station first."
			return ""
	return "Unknown construction command."

static func apply(s: Dictionary, cmd: Dictionary) -> void:
	match cmd.type:
		"enqueue":
			var id = "project_"+str(s.construction.next); s.construction.next += 1
			s.construction.queue.append({"id":id,"recipe":cmd.recipe,"tile":cmd.tile,"work":0,"paid":0,"started":false,"held":false,"status":"queued","blocker":"","goal":""})
		"hold":
			for p in s.construction.queue:
				if p.id == cmd.id:
					p.held = cmd.held
					for goal in s.get("planning",{}).get("goals",[]):
						if goal.id == p.goal:
							goal.authorized = not p.held
							goal.status = "proposed" if p.held else "pending"
		"deployBuilder":
			s.construction.holders.append(cmd.person)
			var tile = R.person_tile(s,s.cohorts[cmd.person])
			s.cohorts[cmd.person].state = {"kind":"mobile","tileId":tile,"movementRemaining":1.0,"job":null}
		"returnBuilder":
			s.construction.holders.erase(cmd.person)
			s.cohorts[cmd.person].state = {"kind":"resident","settlementId":"main","job":null}
			s.movementQueues.erase(cmd.person); s.moveProgress.erase(cmd.person)

static func finish(s: Dictionary, p: Dictionary) -> void:
	match p.recipe:
		"farm":
			if not s.improvements.has(p.tile): s.improvements[p.tile] = {}
			s.improvements[p.tile].farm = true; s.construction.farmTiers[p.tile] = 1
		"farm_upgrade": s.construction.farmTiers[p.tile] = 2
		"district": s.districts[p.id] = {"id":p.id,"type":"agriculture","tileId":p.tile,"settlementId":"main","tier":1}
		"greenhouse": s.buildings[p.id] = {"id":p.id,"type":"greenhouse","settlementId":"main","districtId":R.district_at(s,p.tile).id,"tier":1}
	p.status = "complete"; p.blocker = ""

static func resolve(s: Dictionary, ledger: Dictionary) -> void:
	if not s.has("construction"): return
	var labor = {}; var total = 0
	for c in s.cohorts.values():
		var job = c.state.get("job")
		var points = 2 if job in ["construct","builder"] else (1 if job == "mixed" else 0)
		if c.id in s.construction.travelled: points = 0
		if job == "builder" and c.id not in s.construction.holders: points = 0
		labor[c.id] = points; total += points
	ledger.work = 0; ledger.unused_effort = total
	for p in s.construction.queue:
		if p.status == "complete": continue
		p.blocker = ""
		if p.held: p.blocker = "Held"; continue
		var authorized = false
		for goal in s.get("planning",{}).get("goals",[]):
			if goal.id == p.goal and goal.authorized: authorized = true
		if not authorized: p.blocker = "Funding purpose is not authorized"; continue
		var legal = target_reason(s,p.recipe,p.tile)
		if legal != "": p.blocker = legal; continue
		if not s.construction.holders.is_empty() and not s.construction.holders.any(func(id):return s.cohorts[id].state.tileId==p.tile):
			p.blocker = "Reusable kit is away; bring it to this site or return it to storage"; continue
		if p.recipe == "district" and not p.started and s.cohorts.values().any(func(c): return c.state.get("job") == "tile:"+p.tile):
			p.blocker = "Reassign the hex worker before district construction starts"; continue
		var eligible = []
		for id in labor:
			var c = s.cohorts[id]
			if labor[id]>0 and ((c.state.kind == "resident" and p.tile in s.tileAccess.main) or (c.state.kind == "mobile" and c.state.tileId == p.tile)): eligible.append(id)
		if eligible.is_empty(): p.blocker = "Needs settlement effort or an equipped builder at the site"; continue
		var affordable = available(s,p.goal)
		if affordable == 0: p.blocker = "Needs unreserved Industry"; continue
		for id in eligible:
			var work = mini(labor[id],mini(RECIPES[p.recipe].work-int(p.work),affordable))
			if work <= 0: continue
			p.started = true; p.status = "active"; p.work += work; p.paid += work
			s.storage.main.industry -= work; s.resources.industry -= work
			ledger.spending.industry += work; ledger.work += work
			labor[id] -= work; affordable -= work
			if p.goal != "" and s.has("planning"):
				for g in s.planning.goals:
					if g.id == p.goal:
						g.amount = maxi(1,RECIPES[p.recipe].work-int(p.work))
						if p.work == RECIPES[p.recipe].work: g.authorized = false; g.status = "cancelled"; g.blocker = "Project completed"
			if s.get("commitments",{}).get("stocks",{}).has(p.goal): s.commitments.stocks[p.goal].industry = maxi(0,int(s.commitments.stocks[p.goal].industry)-work)
			if p.work == RECIPES[p.recipe].work: finish(s,p); break
		if p.status != "complete": p.blocker = "Needs more labor" if affordable>0 else "Needs more Industry"
	ledger.unused_effort = 0
	for n in labor.values(): ledger.unused_effort += n
