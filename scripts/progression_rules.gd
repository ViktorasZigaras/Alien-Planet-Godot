extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const GROWTH_COST = 10
const TRAINING_COST = 2
const TECHS = {
	"cultivation":{"cost":4,"evidence":"biologist","label":"Cultivation · unlock Farm upgrades"},
	"power_systems":{"cost":6,"evidence":"energy","label":"Power systems · generators produce 4 instead of 2 Energy"}
}
static func attach(s: Dictionary) -> void:
	s.progression = {"growthEnabled":true,"training":{},"techs":[],"evidence":{},"events":[],"bornTurn":0}

static func support(s: Dictionary, person: String = "", assignment: String = "") -> int:
	var capacity = 2
	var energy = int(s.resources.energy)
	for c in s.cohorts.values():
		var job = assignment if c.id == person else c.state.get("job")
		if job is String and job.begins_with("building:") and c.id not in s.get("construction",{}).get("travelled",[]):
			if s.buildings.get(R.job_building(job),{}).get("type") == "greenhouse" and energy>0:
				capacity += 2; energy -= 1
	return capacity

static func working(s: Dictionary) -> int:
	var n = 0
	for c in s.cohorts.values():
		if c.state.kind == "resident" and c.state.get("job") != null: n += 1
	return n

static func output(s: Dictionary, c: Dictionary) -> Dictionary:
	if c.id in s.get("construction",{}).get("travelled",[]): return {}
	var job = c.state.get("job")
	var out = {}
	if job is String and job.begins_with("tile:"): out = R.tile_yield(s,job.substr(5))
	elif job is String and job.begins_with("building:") and s.resources.energy>0: out = {"food":3}
	elif job == "study": out = {"science":1}
	elif job == "generate": out = {"energy":4 if "power_systems" in s.progression.techs else 2}
	var specialty = {"Biologist":"food","Scientist":"science"}.get(c.qualification,"")
	if specialty != "" and out.get(specialty,0)>0: out[specialty] += 2
	return out

static func prepare(s: Dictionary) -> void:
	if not s.has("progression"): return
	# Ordinary support loss idles excess workers. No unapproved Food exception.
	var active = s.cohorts.values().filter(func(c):return c.state.kind=="resident" and c.state.get("job") != null)
	active.sort_custom(func(a,b):
		var a_provider = a.state.job.begins_with("building:") and output(s,a).get("food",0)>0
		var b_provider = b.state.job.begins_with("building:") and output(s,b).get("food",0)>0
		if a_provider != b_provider: return a_provider
		var af = output(s,a).get("food",0); var bf = output(s,b).get("food",0)
		return af>bf if af!=bf else a.id<b.id)
	var capacity = support(s)
	var kept = 0
	for c in active:
		if kept<capacity: kept += 1
		else:
			s.progression.events.append({"turn":s.turn,"event":"support_loss","person":c.id,"formerJob":c.state.job,"potentialFood":output(s,c).get("food",0)})
			c.state.job = null
			if s.get("commitments",{}).get("people",{}).has(c.id): s.commitments.people.erase(c.id)

static func finish_turn(s: Dictionary, ledger: Dictionary) -> void:
	if not s.has("progression"): return
	var evidence = {"turn":s.turn,"food":int(ledger.gross.food),"energy":int(ledger.gross.energy),"biologist":false,"scientist":false}
	for work in ledger.activity.values():
		if work.qualification == "Biologist" and work.output.get("food",0)>0: evidence.biologist = true
		if work.qualification == "Scientist" and work.output.get("science",0)>0: evidence.scientist = true
	s.progression.evidence = evidence
	# Paused trainees keep progress but do not train while idled by support loss.
	for id in s.progression.training.keys():
		if s.cohorts[id].state.get("job") != "training": continue
		var course = s.progression.training[id]; course.remaining -= 1
		if course.remaining == 0:
			s.cohorts[id].qualification = course.qualification
			s.cohorts[id].state.job = null
			s.progression.training.erase(id)
			s.progression.events.append({"turn":s.turn,"event":"trained","person":id})
	var room = working(s)<support(s)
	var surplus = maxi(0,int(ledger.gross.food)-int(ledger.upkeep.food)-int(ledger.spending.food))
	var transfer = 1 if s.progression.growthEnabled and room and surplus>0 and s.resources.food>0 else 0
	s.storage.main.food -= transfer; s.resources.food -= transfer; s.settlements.main.growth += transfer
	ledger.growth_food = transfer
	if s.progression.growthEnabled and room and s.settlements.main.growth>=GROWTH_COST and s.progression.bornTurn != s.turn:
		var id = "grown_"+str(s.nextCohortNumber); s.nextCohortNumber += 1
		while s.cohorts.has(id): id = "grown_"+str(s.nextCohortNumber); s.nextCohortNumber += 1
		s.cohorts[id] = {"id":id,"name":"Civilian "+id,"qualification":"Worker","home":"main","equipment":[],"lastUsed":0,"facing":0.0,"lastRoute":[],"state":{"kind":"resident","settlementId":"main","job":null}}
		s.settlements.main.growth -= GROWTH_COST; s.progression.bornTurn = s.turn
		s.progression.events.append({"turn":s.turn,"event":"grown","person":id})
	prepare(s)
	ledger.net.food = s.resources.food-ledger.opening.food
	ledger.closing = s.resources.duplicate(true)
