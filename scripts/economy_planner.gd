extends RefCounted
## B03 bounded planner for the two-civilian economy trial, not legacy military AI.
const E = preload("res://scripts/economy_fixture.gd")

static func attach(state: Dictionary) -> Dictionary:
	var s = state.duplicate(true)
	if not s.has("planning"):
		s.planning = {"enabled":false,"next":1,"goals":[],"trace":[],"review":{}}
		s.commitments = {"people":{},"stocks":{},"prerequisites":[]}
	return s

static func available(s: Dictionary, resource: String) -> int:
	var used = 0
	for stock in s.commitments.stocks.values(): used += int(stock.get(resource,0))
	return maxi(0,int(s.resources[resource])-used-int(s.obligations.get(resource,0)))

static func allocate(s: Dictionary) -> void:
	s.commitments = {"people":{},"stocks":{},"prerequisites":[]}
	for goal in s.planning.goals:
		if not goal.authorized or goal.status == "cancelled": continue
		var amount = mini(int(goal.amount),available(s,"industry"))
		s.commitments.stocks[goal.id] = {"industry":amount}
		goal.status = "fulfilled" if amount == goal.amount else "pending"
		goal.blocker = "" if goal.status == "fulfilled" else "Needs %d more Industry" % (goal.amount-amount)

static func candidates(s: Dictionary) -> Array:
	# Prune by useful Food and material yield, not by hex identity. Preserve
	# current work as an equal-score alternative to avoid assignment churn.
	var food = []; var minerals = []
	for job in E.jobs(s):
		if job.id.begins_with("tile:"):
			food.append(job); minerals.append(job)
	food.sort_custom(func(a,b): return a.yield.get("food",0)>b.yield.get("food",0) if a.yield.get("food",0)!=b.yield.get("food",0) else a.id<b.id)
	minerals.sort_custom(func(a,b): return a.yield.get("minerals",0)>b.yield.get("minerals",0) if a.yield.get("minerals",0)!=b.yield.get("minerals",0) else a.id<b.id)
	var ids = ["idle","manufacture"]
	if s.has("construction"): ids.append_array(["construct","mixed","builder"])
	if s.has("progression"): ids.append_array(["study","generate","training"])
	if s.has("ecology"): ids.append_array(["waste","medical"])
	for list in [food.slice(0,3),minerals.slice(0,3)]:
		for job in list:
			if job.id not in ids: ids.append(job.id)
	for c in s.cohorts.values():
		if c.state.job != null and c.state.job not in ids: ids.append(c.state.job)
	return ids

static func score(s: Dictionary, trial: Dictionary, missing: int) -> float:
	var ledger = E.resolve(trial,false).ledger
	var value = -10000.0*maxi(0,-int(ledger.closing.food))+120.0*ledger.get("work",0)
	if missing>0:
		value += 100.0*mini(missing,int(ledger.gross.industry))
		value -= 10.0*maxi(0,missing-int(ledger.closing.minerals))
	else: value -= float(ledger.gross.industry+ledger.gross.minerals)
	if ledger.net.food<0: value += 5.0*ledger.net.food
	if ledger.has("ecology"):
		value -= 12.0*ledger.ecology.spilled
		value += 2.0*ledger.ecology.treated
	for id in trial.cohorts:
		if trial.cohorts[id].state.job == s.cohorts[id].state.job: value += 0.1
	return value

static func joint_allocations(s: Dictionary, options: Array, missing: int) -> Dictionary:
	var seed = s.duplicate(true); seed.commitments.people = {}
	for c in seed.cohorts.values(): c.state.job = null
	var beam = [{"state":seed,"score":0.0}]; var rejected = 0; var evaluated = 0
	var ids = s.cohorts.keys(); ids.sort()
	for id in ids:
		var expanded = []
		for partial in beam:
			for job in options:
				var result = E.command(partial.state,{"type":"assign","person":id,"job":job})
				if not result.ok: rejected += 1; continue
				evaluated += 1
				var value = score(s,result.state,missing)
				expanded.append({"state":result.state,"score":value})
		expanded.sort_custom(func(a,b):return a.score>b.score)
		# Preserve the exhaustive original two-person case; bound growth cases.
		beam = expanded.slice(0,16) if s.cohorts.size()>2 else expanded
	return {"beam":beam,"rejected":rejected,"evaluated":evaluated}

static func plan(state: Dictionary) -> Dictionary:
	var s = attach(state)
	allocate(s)
	if not s.planning.enabled: return s
	var purposes = []; var missing = 0
	for goal in s.planning.goals:
		if goal.authorized and goal.status == "pending":
			purposes.append(goal.id); missing += int(goal.amount)-int(s.commitments.stocks[goal.id].industry)
	var options = candidates(s)
	var best = {}; var best_score = -INF; var examined = 0; var rejected = 0
	var baseline = E.resolve(s,false).ledger
	var choices = joint_allocations(s,options,missing)
	rejected = choices.rejected; examined = choices.evaluated
	for choice in choices.beam:
		if choice.score>best_score: best_score = choice.score; best = choice.state
	if best.is_empty():
		s.planning.review = {"blocked":"No legal joint allocation","candidates":examined,"rejected":rejected}
		return s
	# One shared work package serves all active goals, rather than duplicating
	# the same Food/mineral prerequisite and worker for each goal.
	for id in best.cohorts:
		var job = best.cohorts[id].state.job
		if job != null:
			s.commitments.people[id] = {"job":job,"purposes":purposes.duplicate(),"emergency":purposes.is_empty()}
		if job == "manufacture":
			var inputs = mini(2,available(s,"minerals"))
			if inputs>0: s.commitments.stocks["input:"+id] = {"minerals":inputs}
	# Apply the exact allocated jobs through shared legality/effect commands.
	for c in s.cohorts.values(): c.state.job = null
	for id in best.cohorts:
		var job = best.cohorts[id].state.job
		var result = E.command(s,{"type":"assign","person":id,"job":"idle" if job == null else job})
		if result.ok: s = result.state
	if not purposes.is_empty():
		s.commitments.prerequisites = [{"id":"shared-material-work","purposes":purposes,"inputs":"Minerals → Industry; real Food jobs sustain workers"}]
	s.planning.review = {"candidates":examined,"rejected":rejected,"score":best_score,"prior_food_net":baseline.net.food,"reason":"Food safety, then useful goal progress and prerequisites; stable work breaks ties"}
	return s

static func command(state: Dictionary, cmd: Dictionary) -> Dictionary:
	var s = attach(state)
	match cmd.get("type",""):
		"planning":
			if not cmd.get("enabled") is bool: return {"ok":false,"state":state,"message":"Expected planning on/off."}
			s.planning.enabled = cmd.enabled
		"goal":
			if not E.R.whole(cmd.get("amount"),1,100): return {"ok":false,"state":state,"message":"Choose 1–100 Industry to reserve."}
			var id = "goal_"+str(s.planning.next); s.planning.next += 1
			s.planning.goals.append({"id":id,"amount":int(cmd.amount),"authorized":false,"status":"proposed","blocker":"Awaiting authorization"})
		"authorize", "cancel":
			var found = false
			for goal in s.planning.goals:
				if goal.id == cmd.get("id") and goal.status != "cancelled":
					found = true
					goal.authorized = cmd.type == "authorize"
					goal.status = "pending" if goal.authorized else "cancelled"
					goal.blocker = "" if goal.authorized else "Purpose cancelled; reservations released"
					if cmd.type == "cancel":
						for project in s.get("construction",{}).get("queue",[]):
							if project.goal == goal.id and project.status != "complete": project.held = true
			if not found: return {"ok":false,"state":state,"message":"Unknown or cancelled goal."}
		"endTurn":
			s = plan(s)
			var before = s.resources.duplicate(true)
			var result = E.command(s,cmd)
			s = result.state
			s.planning.trace.append({"turn":s.turn-1,"before":before,"after":s.resources.duplicate(true),"work":s.commitments.people.duplicate(true)})
		_: return E.command(s,cmd)
	s = plan(s)
	return {"ok":true,"state":s,"message":"Plan reconciled with actual stocks and legal work."}

static func validate(s) -> String:
	# Ignore untrusted saved claims even while validating ordinary assignments.
	if not s is Dictionary: return "Not a planning save."
	var clean = s.duplicate(true)
	clean.commitments = {"people":{},"stocks":{},"prerequisites":[]}
	var error = E.validate(clean)
	if error != "": return error
	if not s.get("planning") is Dictionary or not s.get("commitments") is Dictionary: return "Missing planning state."
	var p = s.planning
	if not p.get("enabled") is bool or not p.get("goals") is Array or not p.get("trace") is Array or not p.get("review") is Dictionary or not E.R.whole(p.get("next"),1,9007199254740991): return "Invalid planning state."
	var ids = []
	for g in p.goals:
		if not g is Dictionary or not g.get("id") is String or g.id in ids or not E.R.whole(g.get("amount"),1,100) or not g.get("authorized") is bool or g.get("status") not in ["proposed","pending","fulfilled","cancelled"] or not g.get("blocker") is String: return "Invalid goal."
		if not g.id.begins_with("goal_") or not g.id.substr(5).is_valid_int() or int(g.id.substr(5))<1 or int(g.id.substr(5))>=p.next: return "Invalid goal identity."
		ids.append(g.id)
	# Commitments are derived, never trusted from a save. Caller rebuilds them.
	return ""
