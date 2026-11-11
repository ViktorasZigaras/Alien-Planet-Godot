extends RefCounted
const S = preload("res://scripts/construction_session.gd")
const E = S.E
const P = S.P
const G = preload("res://scripts/progression_rules.gd")
static func initial() -> Dictionary:
	var s = S.initial(); G.attach(s)
	return s
static func reason(s: Dictionary, cmd: Dictionary) -> String:
	match cmd.get("type",""):
		"growthPolicy": return "" if cmd.get("enabled") is bool else "Choose growth on/off."
		"boostGrowth":
			if not s.progression.growthEnabled or G.working(s)>=G.support(s): return "Growth needs permission and spare working support."
			if not E.R.whole(cmd.get("amount"),1,10): return "Transfer 1–10 Food."
			if P.available(s,"food")<cmd.amount: return "Insufficient unreserved Food."
			return ""
		"train":
			if not s.cohorts.has(cmd.get("person","")) or cmd.get("qualification","") not in ["Biologist","Scientist"]: return "Choose a person and supported specialty."
			var c = s.cohorts[cmd.person]
			if c.state.kind != "resident" or s.progression.training.has(c.id): return "Return to town or finish existing training."
			if c.qualification == cmd.qualification: return "Already qualified."
			if not s.commitments.people.get(c.id,{}).is_empty(): return "Release this person's planning commitment first."
			if c.state.job == null and G.working(s)>=G.support(s): return "Training needs a supported working place."
			if P.available(s,"industry")<G.TRAINING_COST: return "Needs 2 unreserved Industry."
			return ""
		"research":
			if not G.TECHS.has(cmd.get("tech","")): return "Unknown technology."
			if cmd.tech in s.progression.techs: return "Already researched."
			var tech = G.TECHS[cmd.tech]; var proof = s.progression.evidence
			if proof.get("turn",0) != s.turn-1 or not proof.get(tech.evidence,false): return "Required capability did not operate in the immediately preceding turn."
			if P.available(s,"science")<tech.cost: return "Insufficient unreserved Science."
			return ""
	return E.reason(s,cmd)
static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	if cmd.get("type","") not in ["growthPolicy","boostGrowth","train","research"]: return S.command(state,cmd)
	var error = reason(state,cmd)
	if error != "": return {"ok":false,"state":state,"message":error}
	var s = state.duplicate(true)
	match cmd.type:
		"growthPolicy": s.progression.growthEnabled = cmd.enabled
		"boostGrowth":
			E.change(s,"food",-int(cmd.amount)); s.settlements.main.growth += int(cmd.amount)
		"train":
			E.change(s,"industry",-G.TRAINING_COST)
			s.progression.training[cmd.person] = {"qualification":cmd.qualification,"remaining":2}
			s.cohorts[cmd.person].state.job = "training"
		"research":
			E.change(s,"science",-G.TECHS[cmd.tech].cost); s.progression.techs.append(cmd.tech)
	s.lastCommands.append(cmd.duplicate(true))
	return {"ok":true,"state":s,"message":"Progression order applied; explicit costs charged once."}

static func validate(s) -> String:
	if not s is Dictionary or not s.get("progression") is Dictionary: return "Missing progression state."
	var p = s.progression
	if not p.get("growthEnabled") is bool or not p.get("training") is Dictionary or not p.get("techs") is Array or not p.get("evidence") is Dictionary or not p.get("events") is Array or not E.R.whole(p.get("bornTurn"),0,9007199254740991): return "Invalid progression state."
	if not s.get("settlements") is Dictionary or not s.settlements.get("main") is Dictionary or not E.R.whole(s.settlements.main.get("growth"),0,9007199254740991): return "Invalid local growth."
	if not s.get("cohorts") is Dictionary: return "Missing people."
	for id in p.training:
		var course = p.training[id]
		if not s.cohorts.has(id) or not course is Dictionary or course.get("qualification") not in ["Biologist","Scientist"] or not E.R.whole(course.get("remaining"),1,2): return "Invalid training."
	var seen = []
	for tech in p.techs:
		if tech not in G.TECHS or tech in seen: return "Invalid research."
		seen.append(tech)
	return S.validate(s)
