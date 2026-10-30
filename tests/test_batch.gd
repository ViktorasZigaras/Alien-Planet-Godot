extends SceneTree
const R = preload("res://scripts/game_rules.gd")
const G = preload("res://scripts/map_generator.gd")
var checks = 0
var failures = []
func check(ok: bool,what: String) -> void:
	checks += 1
	if not ok:
		failures.append(what)
		printerr("FAIL: ",what)
func run_cmd(s: Dictionary,c: Dictionary) -> Dictionary:
	var before = JSON.stringify(s)
	var result = R.command(s,c)
	check(result.ok,"Command "+str(c)+": "+result.message)
	check(JSON.stringify(s) == before,"Commands preserve input")
	if result.ok: check(R.validate(result.state) == "","Valid result: "+R.validate(result.state))
	return result.state
func reject(s: Dictionary,c: Dictionary) -> void:
	var before = JSON.stringify(s)
	var result = R.command(s,c)
	check(not result.ok and JSON.stringify(result.state) == before,"Rejected atomically: "+str(c))
func rich() -> Dictionary:
	var s = R.initial_state()
	for k in R.RESOURCES: s.resources[k] = 1000
	return s
func _initialize() -> void:
	var s = R.initial_state()
	check(R.validate(s) == "","Initial save valid")
	check(s.tiles.size() == 384,"Expanded map")
	check(G.generate() == G.generate(),"Generator deterministic")
	check(G.generate(732).tiles != G.generate().tiles,"Seed varies geography")
	var counts = {}
	var biomes = {}
	var terrains = {}
	var wooded_hill = false
	for t in s.tiles.values():
		biomes[t.biome] = biomes.get(t.biome,0)+1
		terrains[t.baseTerrain] = true
		if t.bonus != "":
			var res = R.content().bonuses[t.bonus].yields.keys()[0]
			counts[res] = counts.get(res,0)+1
		if t.feature == "forest" and t.relief == "hills": wooded_hill = true
	check(biomes.size() == 6 and terrains.size() == 6,"Six biomes/terrains represented")
	check(wooded_hill,"Forest + hill coexists")
	for resource in ["food","minerals","energy","science","culture"]: check(counts.get(resource,0) > 0,"Map deposit: "+resource)
	check(counts.food > counts.science and counts.minerals > counts.energy,"Basic deposits more plentiful")
	for b in ["lush","dry","cold","fungal","temperate"]:
		var adjacency = 0
		for t in s.tiles.values():
			if t.biome == b and R.neighbours(s,t.id).any(func(k): return s.tiles[k].biome == b): adjacency += 1
		check(adjacency >= biomes[b]-2,"Biome blob adjacency: "+b)
	var key = "4,3"
	s.rivers = []
	s.tiles[key].bonus = ""
	s.tiles[key].baseTerrain = "plains"
	s.tiles[key].feature = "forest"
	s.tiles[key].relief = "hills"
	check(R.tile_yield(s,key) == {"minerals":3},"Stacked hill/forest -2 Food +2 Minerals, zero floor")
	s.rivers = [G.edge_key(key,"4,2"),G.edge_key(key,"3,3")]
	check(R.tile_yield(s,key).food == 1,"River adjacency adds once")
	check(R.tile_yield(s,"4,2").food == 3,"Other river bank receives Food")
	check(R.step_cost(s,"3,3",key) == 4,"Stacked terrain + river crossing")
	s.improvements[key] = {"road":true}
	check(R.step_cost(s,"3,3",key) == 4,"Entering isolated road pays terrain and river")
	s.improvements["3,3"] = {"road":true}
	check(is_equal_approx(R.step_cost(s,"3,3",key),4.0/3),"Connected roads + river")
	s.rivers = []
	check(is_equal_approx(R.step_cost(s,"3,3",key),1.0/3),"Connected road thirds")
	check(R.step_cost(s,key,"4,2") == 1,"Leaving road pays entered terrain")
	# A one-MP person traverses a three-MP step over three turns.
	s = rich()
	s = run_cmd(s,{"type":"assign","cohortId":"pop_a","job":null})
	s = run_cmd(s,{"type":"equip","cohortId":"pop_a","item":"work_suit"})
	check(s.equipment.main.work_suit == 1 and R.builder(s.cohorts.pop_a),"Stock withdrawn and builder capability")
	s = run_cmd(s,{"type":"mobilise","cohortId":"pop_a"})
	s.cohorts.pop_a.state.tileId = "3,3"
	s.cohorts.pop_a.state.movementRemaining = 1
	s.tiles["4,3"].feature = "forest"
	s.tiles["4,3"].relief = "hills"
	s.rivers = []
	s = run_cmd(s,{"type":"queueMove","unitId":"pop_a","target":"4,3"})
	check(s.cohorts.pop_a.state.tileId == "3,3" and s.moveProgress.pop_a == 1,"Partial step stays on origin")
	s = run_cmd(s,{"type":"queueMove","unitId":"pop_a","target":"5,3","append":true})
	check(s.moveProgress.pop_a == 1,"Append preserves partial movement")
	s = run_cmd(s,{"type":"endTurn"})
	check(s.moveProgress.pop_a == 2,"Progress persists across turn")
	s = JSON.parse_string(JSON.stringify(s))
	check(R.validate(s) == "","Mid-step save roundtrip")
	s = run_cmd(s,{"type":"endTurn"})
	check(s.cohorts.pop_a.state.tileId == "4,3","Expensive step completed")
	reject(s,{"type":"queueMove","unitId":"pop_a","target":"0,0"})
	s = run_cmd(s,{"type":"cancelMove","unitId":"pop_a"})
	check(not s.moveProgress.has("pop_a"),"Cancel discards step credit")
	s = run_cmd(s,{"type":"queueMove","unitId":"pop_a","target":"5,3"})
	s = run_cmd(s,{"type":"queueMove","unitId":"pop_a","target":"3,3"})
	check(s.movementQueues.pop_a.back() == "3,3","Plain order replaces destination")
	# Prerequisites, manufacture, persistent identity, training and construction.
	s = rich()
	reject(s,{"type":"develop","nodeId":"precision_assembly"})
	s = run_cmd(s,{"type":"develop","nodeId":"technical_education"})
	s = run_cmd(s,{"type":"develop","nodeId":"standard_tooling"})
	s = run_cmd(s,{"type":"develop","nodeId":"extraction"})
	check("building" in R.tech_reason(s,"precision_assembly"),"Advanced tech requires preceding building")
	s = run_cmd(s,{"type":"manufacture","settlementId":"main","item":"work_suit"})
	s = run_cmd(s,{"type":"assign","cohortId":"pop_a","job":null})
	reject(s,{"type":"build","order":"district","cohortId":"pop_a","target":"3,3"})
	s = run_cmd(s,{"type":"equip","cohortId":"pop_a","item":"work_suit"})
	s = run_cmd(s,{"type":"build","order":"district","cohortId":"pop_a","target":"3,3"})
	s = run_cmd(s,{"type":"endTurn"})
	s = run_cmd(s,{"type":"build","order":"workshop","cohortId":"pop_a","districtId":"district_main"})
	s = run_cmd(s,{"type":"endTurn"})
	s = run_cmd(s,{"type":"endTurn"})
	check("specialist" in R.tech_reason(s,"precision_assembly"),"Advanced tech needs specialist")
	s = run_cmd(s,{"type":"train","cohortId":"pop_c","qualification":"Engineer"})
	s = run_cmd(s,{"type":"endTurn"})
	s = run_cmd(s,{"type":"endTurn"})
	check(s.cohorts.pop_c.qualification == "Engineer","Specific profession trained")
	s.resources.minerals = 0
	check("stock" in R.tech_reason(s,"precision_assembly"),"Advanced tech needs retained resource stock")
	s.resources.minerals = 30
	s = run_cmd(s,{"type":"develop","nodeId":"precision_assembly"})
	check(s.resources.minerals == 30,"Prerequisite stock not consumed")
	s = run_cmd(s,{"type":"upgrade","buildingId":"workshop_main"})
	check(R.slots(s.buildings.workshop_main) == 2,"Tier 2 opens two real slots")
	s = run_cmd(s,{"type":"assign","cohortId":"pop_c","job":"building:workshop_main#0"})
	s = run_cmd(s,{"type":"assign","cohortId":"pop_b","job":"building:workshop_main#1"})
	reject(s,{"type":"assign","cohortId":"pop_a","job":"building:workshop_main#1"})
	var worked = R.forecast(s)
	s = run_cmd(s,{"type":"assign","cohortId":"pop_c","job":null})
	s = run_cmd(s,{"type":"assign","cohortId":"pop_b","job":null})
	var passive = R.forecast(s)
	check(worked.industry > passive.industry and passive.industry+R.economy(s).militaryUpkeep.industry > 1,"Worked and passive Industry output")
	check(worked.minerals < passive.minerals,"Conversion consumes actual Minerals")
	s.resources.minerals = 0
	check(R.forecast(s).industry+R.economy(s).militaryUpkeep.industry == 1,"No input-free workshop conversion; only starter Industry remains")
	var identity = s.cohorts.pop_c.id
	s = run_cmd(s,{"type":"clearSpecialty","cohortId":"pop_c"})
	check(s.cohorts.pop_c.id == identity and s.cohorts.pop_c.qualification == "Worker","Clear specialty preserves person")
	s = run_cmd(s,{"type":"equip","cohortId":"pop_a","item":"rover"}) if s.equipment.main.get("rover",0) else s
	# Build a generator, then exhaust stored Energy: it restarts from basic town supply.
	s.resources.minerals = 100
	s = run_cmd(s,{"type":"develop","nodeId":"power_systems"})
	s = run_cmd(s,{"type":"build","order":"generator","cohortId":"pop_a","districtId":"district_main"})
	s = run_cmd(s,{"type":"endTurn"})
	s = run_cmd(s,{"type":"endTurn"})
	s.resources.energy = 0
	check(R.economy(s).status.generator_main == "Powered","Generator starts from baseline power")
	# Medical reduction is uncapped and population grows at 20 accumulated growth.
	var g = rich()
	g.cohorts.pop_c.qualification = "Medic"
	g.completed = ["cultivation","closed_ecology","clinical_practice","regenerative_care"]
	g.districts.district_main_agriculture = {"id":"district_main_agriculture","type":"agriculture","settlementId":"main","tileId":"3,3"}
	g.buildings.clinic_main = {"id":"clinic_main","type":"clinic","settlementId":"main","districtId":"district_main_agriculture","tier":2}
	g.cohorts.pop_c.state.job = "building:clinic_main#0"
	g.cohorts.pop_d.qualification = "Medic"
	g.cohorts.pop_d.state.job = "building:clinic_main#1"
	var ledger = R.economy(g)
	check(ledger.towns.main.medicine > ledger.towns.main.penalty,"Medical surplus exceeds size penalty")
	check(ledger.towns.main.growth == ledger.towns.main.food-5-5+ledger.towns.main.medicine,"Growth formula")
	g.settlements.main.growth = 19
	var old_count = g.cohorts.size()
	g = run_cmd(g,{"type":"endTurn"})
	check(g.cohorts.size() == old_count+1,"Growth creates persistent Worker")
	var e = R.forecast(g)
	g = run_cmd(g,{"type":"endTurn"})
	check(e.energy < 0,"Powered facilities consume Energy")
	# Neutral sites accept everyone, with a larger Merchant reward, once per visitor.
	var n = rich()
	n.cohorts.pop_rover.state.tileId = "8,3"
	var amount = n.resources.culture
	n = run_cmd(n,{"type":"visit","cohortId":"pop_rover"})
	check(n.resources.culture == amount+3,"Ordinary person visits")
	reject(n,{"type":"visit","cohortId":"pop_rover"})
	n.cohorts.pop_rover.state.tileId = "15,7"
	n.cohorts.pop_rover.qualification = "Merchant"
	amount = n.resources.science
	n = run_cmd(n,{"type":"visit","cohortId":"pop_rover"})
	check(n.resources.science == amount+6,"Merchant Science visit bonus")
	n = run_cmd(n,{"type":"queueMove","unitId":"pop_rover","target":"6,3"})
	for i in range(15):
		if not n.movementQueues.has("pop_rover"): break
		n = run_cmd(n,{"type":"endTurn"})
	n = run_cmd(n,{"type":"join","cohortId":"pop_rover"})
	check(n.cohorts.pop_rover.home == "field" and "rover" in n.cohorts.pop_rover.equipment,"Joining transfers home without losing gear")
	# All professions accept transport, arms, suit combinations; no separate vehicle.
	for role in R.content().qualifications:
		var t = rich()
		t.cohorts.pop_a.qualification = role
		t.equipment.main.rover = 1
		t = run_cmd(t,{"type":"equip","cohortId":"pop_a","item":"rover"})
		t = run_cmd(t,{"type":"equip","cohortId":"pop_a","item":"small_arms"})
		t = run_cmd(t,{"type":"equip","cohortId":"pop_a","item":"work_suit"})
		check(t.cohorts.pop_a.equipment.size() == 3 and t.units.is_empty(),"Combined gear: "+role)
		t = run_cmd(t,{"type":"equip","cohortId":"pop_a","item":"rover"})
		check(t.equipment.main.rover == 1,"Gear returned to stock")
	# Legacy saves retain identity and convert the existing Rover into an equipped person.
	for version in range(1,6):
		var old = R.read_json("res://data/initial_state_v5.json")
		old.schemaVersion = version
		old.rulesVersion = version
		var migrated = R.migrate_save(old)
		check(R.validate(migrated) == "","Migration v"+str(version)+": "+R.validate(migrated))
		check(migrated.cohorts.pop_a.id == "pop_a" and "rover" in migrated.cohorts.pop_rover.equipment,"Migration identity/equipment")
	# Exercise every advanced node's complete condition set, not only research prices.
	var all = rich()
	all.cohorts.pop_a.equipment = ["work_suit"]
	all.cohorts.pop_a.state.job = null
	all.completed = []
	for role in R.content().qualifications:
		if role == "Worker": continue
		R.new_person(all,"main")
		var id = "pop_%03d" % (all.nextCohortNumber-1)
		all.cohorts[id].qualification = role
	var district_sites = {"production":"3,3","agriculture":"4,2","research":"3,2","civic":"2,4","security":"1,4"}
	for kind in district_sites:
		var id = R.district_key("main",kind)
		all.districts[id] = {"id":id,"type":kind,"settlementId":"main","tileId":district_sites[kind]}
	for kind in R.buildable_buildings():
		var id = R.building_key("main",kind)
		all.buildings[id] = {"id":id,"type":kind,"settlementId":"main","tier":1,"districtId":R.district_key("main",R.content().buildings[kind].district)}
	var pending = R.nodes().keys()
	for pass_index in range(10):
		for node in pending.duplicate():
			if R.tech_reason(all,node) == "":
				var result = R.command(all,{"type":"develop","nodeId":node})
				check(result.ok,"Technology reachable: "+node)
				all = result.state
				pending.erase(node)
	check(pending.is_empty() and all.completed.size() == 20,"All twenty techs reachable without cycles")
	check(R.validate(all) == "","Complete technology/workplace example valid")
	for kind in R.buildable_buildings():
		var id = R.building_key("main",kind)
		all = run_cmd(all,{"type":"upgrade","buildingId":id})
		check(R.slots(all.buildings[id]) == 2,"Tier 2: "+kind)
	# Growth may cross multiple thresholds in a single rich-food turn.
	all.settlements.main.growth = 19
	check(R.economy(all).towns.main.medicine >= 0,"Medical ledger present")
	var bio = rich()
	bio.cohorts.pop_a.qualification = "Biologist"
	bio.tiles["1,3"].feature = "forest"
	bio.tiles["1,3"].baseTerrain = "fungal"
	var out = R.job_output(bio,bio.cohorts.pop_a)
	var raw = R.tile_yield(bio,"1,3")
	check(out.food == raw.food+1 and out.minerals == raw.minerals+1 and out.science == raw.science+1,"Biologist covers biological Food, timber and specimens")
	var invalid = R.initial_state()
	invalid.cohorts.pop_a.state.job = "building:lab_main#2"
	check(R.validate(invalid) != "","Invalid slot rejected")
	invalid = R.initial_state()
	invalid.resources.food = -1
	check(R.validate(invalid) != "","Negative stock rejected")
	invalid = R.initial_state()
	invalid.movementQueues.pop_rover = ["23,15"]
	check(R.validate(invalid) != "","Nonadjacent queue rejected")
	check(R.validate(null) != "","Non-object rejected")
	print("BATCH CHECKS: ",checks,"; FAILURES: ",failures.size())
	quit(0 if failures.is_empty() else 1)
