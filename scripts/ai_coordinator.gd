class_name AICoordinator
extends RefCounted
## Reconstructed 0.906–0.910 responsibility chain; saved, deterministic, ordinary orders.
const R = preload("res://scripts/game_rules.gd")
const A = preload("res://scripts/ai_assessment.gd")
const P = preload("res://scripts/ai_plan_actions.gd")
const L = preload("res://scripts/ai_lieutenant.gd")
const O = preload("res://scripts/ai_operation.gd")
static func initial(player: String) -> Dictionary:
	return {"version":1,"identity":player,"doctrine":"research_specialization" if player == "blue" else "nest_campaign","plans":{},"jobTerms":{},"loans":{},"governors":{},"proposals":[],"authorizations":[],"deferred":[],"history":[],"lastReview":0,"operation":{},"lieutenant":L.initial(),"decisionCount":0,"turnActors":[]}
static func ensure(p: Dictionary,player: String) -> void:
	if not p.has("ai"): p.ai = initial(player)
static func note(p: Dictionary,event: Dictionary) -> void:
	p.ai.history.append(event.duplicate(true))
	if p.ai.history.size()>128: p.ai.history.pop_front()
static func proposal(id: String,advisor: String,score: float,why: String) -> Dictionary:
	return {"id":id,"advisor":advisor,"score":score,"reason":why}
static func review(world: Dictionary,p: Dictionary,player: String) -> void:
	ensure(p,player)
	p.ai.lastReview = p.turn; p.ai.turnActors = []
	for id in p.ai.jobTerms.keys():
		if not p.cohorts.has(id) or p.ai.jobTerms[id]<=p.turn: p.ai.jobTerms.erase(id)
	for id in p.ai.loans.keys():
		if not p.cohorts.has(id): p.ai.loans.erase(id)
	for town in p.settlements:
		if not p.ai.governors.has(town): p.ai.governors[town] = {"role":"research" if player == "blue" else "production","since":p.turn}
	if player in ["red","green"] and p.ai.operation.is_empty() and O.target(world)!="": p.ai.operation = O.initial(p,O.target(world))
	if not p.ai.operation.is_empty():
		O.review(world,p)
		if O.can_commission(world,p): p.ai.operation.phase = "commission"
	var net = R.economy(p).delta
	var candidates = []
	for k in R.RESOURCES:
		var want = {"food":3,"minerals":2,"industry":3,"energy":2,"science":2,"culture":2}[k]
		if net[k]<want:
			var emergency = net[k]<0 and p.resources[k]+net[k]*5<5
			candidates.append(proposal("income:"+k,"governors",1000.0 if emergency else 160.0+(want-net[k])*10,"Actual net "+str(net[k])+" below desired "+str(want)))
	var op = p.ai.operation
	if not op.is_empty() and op.phase not in ["complete","cancelled"]:
		candidates.append(proposal("operation","general",260,"Binding nest force, civilian support and equipment prerequisites"))
		if p.cohorts.values().filter(func(c):return c.qualification!="Soldier").size()<op.required.civilians+maxi(0,7-p.cohorts.values().filter(func(c):return c.qualification=="Soldier").size()): candidates.append(proposal("growth","governors",270,"Population needed for military and civilian support"))
	if op.is_empty() or op.phase in ["complete","cancelled"]:
		candidates.append(proposal("research","scientist",120 if player=="blue" else 70,"Affordable useful capability"))
		candidates.append(proposal("specialists","governors",100,"Existing workplaces benefit from matching professions"))
		if p.cohorts.size()>=8: candidates.append(proposal("expand","planner",60,"Useful surveyed land and sufficient population"))
		candidates.append(proposal("roads","planner",45,"Connect inhabited settlements"))
		candidates.append(proposal("growth","governors",40,"Further growth and economic capacity"))
	candidates.sort_custom(func(a,b):return a.score>b.score or (a.score==b.score and a.id<b.id))
	p.ai.proposals = candidates
	p.ai.authorizations = candidates.slice(0,3).map(func(v):return v.id)
	p.ai.deferred = candidates.slice(3).map(func(v):return v.id)
	for c in candidates:
		if not p.ai.plans.has(c.id): p.ai.plans[c.id] = {"id":c.id,"created":p.turn,"lastProgress":p.turn,"status":"pending","budget":{},"actors":[]}
		p.ai.plans[c.id].priority = c.score
	# Planner records target and actor during the replayable council review.
	if p.ai.plans.has("expand"):
		var plan = p.ai.plans.expand
		if plan.has("target") and not R.site_at(p,plan.target).is_empty():
			plan.erase("target"); plan.erase("actor")
		if not plan.has("target"):
			var sites = preload("res://scripts/tile_survey.gd").sites(world,p)
			if not sites.is_empty(): plan.target = sites[0].tile
		if not p.cohorts.has(plan.get("actor", "")):
			for c in A.people(p):
				if c.state.kind=="resident" and c.qualification=="Worker" and not R.builder(c) and R.population(p,c.home)>=7 and not P.protected(p,c.id):
					plan.actor = c.id; break
	for id in p.ai.plans:
		if not candidates.any(func(c):return c.id==id): p.ai.plans[id].status = "satisfied_or_not_currently_needed"
static func choose(world: Dictionary,p: Dictionary,player: String) -> Dictionary:
	var op = p.ai.operation
	var force = [] if op.is_empty() else op.force
	var target = O.target(world) if op.is_empty() else op.target
	var released = not op.is_empty() and op.phase == "deployed"
	var tactical = L.pick(world,p,force,target,released)
	if not tactical.is_empty(): tactical.plan = "operation"; return tactical
	# Restore construction loans only when their old slot remains legal and useful.
	for id in p.ai.loans.keys():
		var c = p.cohorts.get(id,{})
		if c.is_empty() or c.state.kind!="resident" or c.state.job!=null: continue
		if not c.get("aiLoanBuilt",false) and p.turn-c.get("aiLoanSince",p.turn)<12: continue
		if p.ai.turnActors.has(id): continue
		if p.constructionProject!=null and p.constructionProject.cohortId==id: continue
		var loan = P.legal(p,{"type":"assign","cohortId":id,"job":p.ai.loans[id]},"restore_construction_loan")
		if not loan.is_empty(): return loan
	for candidate in p.ai.proposals:
		var result = {}
		var id = candidate.id
		if id.begins_with("income:"):
			var resource = id.substr(7)
			var net = R.economy(p).delta
			var want = {"food":3,"minerals":2,"industry":3,"energy":2,"science":2,"culture":2}[resource]
			if net[resource]>=want: continue
			result = P.income(p,resource,candidate.score>=1000)
			if result.is_empty(): result = P.infrastructure(p,resource)
		elif id == "operation": result = O.pick(world,p)
		elif id == "growth": result = P.grow(p)
		elif id == "research": result = P.research(p)
		elif id == "roads": result = P.road(p)
		elif id == "expand": result = P.expansion(world,p)
		elif id == "specialists":
			for b in p.buildings.values():
				for role in R.content().buildings[b.type].specialists:
					if p.cohorts.values().any(func(c):return c.home==b.settlementId and c.qualification==role): continue
					result = P.training(p,b.settlementId,role)
					if not result.is_empty(): break
				if not result.is_empty(): break
		if result.is_empty(): continue
		var actor = result.command.get("cohortId",result.command.get("unitId",""))
		if result.command.type=="assign" and actor in p.ai.turnActors: continue
		result.plan = id
		return result
	return {}
static func applied(p: Dictionary,cmd: Dictionary,rule: String,before: Dictionary,context: Dictionary = {}) -> void:
	p.ai.decisionCount += 1
	var actor = cmd.get("cohortId",cmd.get("unitId",""))
	if cmd.type == "assign":
		if actor not in p.ai.turnActors: p.ai.turnActors.append(actor)
		if rule == "loan_builder" and before.get("job") is String:
			p.ai.loans[actor] = before.job
			p.cohorts[actor].aiLoanSince = p.turn
			p.cohorts[actor].aiLoanBuilt = false
		elif cmd.get("job") != null:
			p.ai.jobTerms[actor] = p.turn+6; p.ai.loans.erase(actor)
			p.cohorts[actor].erase("aiLoanSince"); p.cohorts[actor].erase("aiLoanBuilt")
	if cmd.type in ["build","improve"] and p.ai.loans.has(actor): p.cohorts[actor].aiLoanBuilt = true
	if not p.ai.operation.is_empty():
		if O.can_commission(context.get("world",{}),p): p.ai.operation.phase = "commission"
	# No opaque world state is stored in the history.
	var plan = context.get("plan","")
	if p.ai.plans.has(plan):
		p.ai.plans[plan].lastProgress = p.turn; p.ai.plans[plan].status = "executing"
		p.ai.plans[plan].budget = {"lastCommand":cmd.type}
		p.ai.plans[plan].actors = [actor] if actor!="" else []
	note(p,{"turn":p.turn,"rule":rule,"command":cmd.duplicate(true),"plan":plan})
	if cmd.type in ["queueMove","attackXeno"]: L.append_event(p.ai.lieutenant,{"turn":p.turn,"rule":rule,"command":cmd.duplicate(true)})
static func validate(p: Dictionary) -> String:
	if not p.has("ai"): return ""
	var a = p.ai
	if not a is Dictionary or not R.has_fields(a,["version","identity","doctrine","plans","jobTerms","loans","governors","proposals","authorizations","deferred","history","lastReview","operation","lieutenant","decisionCount","turnActors"]): return "Invalid AI state."
	for key in ["plans","jobTerms","loans","governors"]:
		if not a[key] is Dictionary: return "Invalid AI dictionary."
	for key in ["proposals","authorizations","deferred","history","turnActors"]:
		if not a[key] is Array or a[key].size()>128: return "Invalid AI array."
	if not R.whole(a.lastReview,0,p.turn) or not R.whole(a.decisionCount,0,100000000): return "Invalid AI clocks."
	for id in a.jobTerms:
		if not R.whole(a.jobTerms[id],0,p.turn+6): return "Invalid operating term."
	var error = L.validate(a.lieutenant)
	if error!="": return error
	return O.validate(a.operation,p)
