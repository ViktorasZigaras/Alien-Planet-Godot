extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
const R = preload("res://scripts/game_rules.gd")
const C = preload("res://scripts/combat_rules.gd")
var checks = 0
var failures = []
func check(value: bool,label: String):
	checks += 1
	if not value: failures.append(label); printerr("FAIL: ",label)
func _initialize(): call_deferred("run")
func clear_tile(s: Dictionary,id: String):
	var t = s.tiles[id]
	t.baseTerrain = "plains"; t.feature = null; t.relief = "flat"; t.bonus = ""
	t.pollution = 0; t.xenomass = false; t.obstacle = ""; t.vegetation = false
	# A non-river fixture allows exact base-yield assertions.
	s.rivers = s.rivers.filter(func(e):return id not in e.split("|"))
func run():
	var s = S.initial_state()
	check(S.validate(s) == "","Fresh world valid: "+S.validate(s))
	check(s.schemaVersion == 11 and s.worldVersion == 3,"Save versions advanced")
	check(is_equal_approx(C.odds(1,1),0.5),"Equal healthy strength exactly 50%")
	check(C.odds(2,1)>0.9 and C.odds(0.5,1)<0.1,"Repeated rounds amplify strength advantage")
	check(is_equal_approx(C.odds(1,2),1-C.odds(2,1)),"Duel symmetry")
	check(C.odds(1,1,30,100)<0.5,"Wounds lower survival")
	check(C.odds(1,1.25)<0.5,"Defensive terrain matters")
	var rng = {"rng":157}
	for i in range(30):
		var outcome = C.duel(rng,1,1,100,100)
		check((outcome.attackerHP == 0) != (outcome.defenderHP == 0),"Exactly one duel survivor")
	clear_tile(s,"4,3")
	var t = s.tiles["4,3"]
	check(R.tile_yield(s,t.id) == {"food":2,"minerals":1},"Clear plains yields")
	t.xenomass = true
	check(R.tile_yield(s,t.id) == {"food":1},"Xenomass penalises humans")
	t.xenomass = false; t.pollution = 1
	check(R.tile_yield(s,t.id) == {"food":1},"Light pollution minus one each")
	t.pollution = 2
	check(R.tile_yield(s,t.id).is_empty(),"Middle pollution minus two each")
	t.pollution = 3; t.bonus = "edible_flora"
	check(R.tile_yield(s,t.id).is_empty(),"Toxic pollution zero even bonus output")
	t.pollution = 0; t.bonus = "ore_seam"; t.obstacle = "brambles"
	check(R.tile_yield(s,t.id).minerals == 2,"Brambles minus one minerals")
	t.obstacle = "stones"
	check(R.tile_yield(s,t.id).minerals == 1,"Stones minus two minerals")
	t.obstacle = ""; t.vegetation = true
	check(R.tile_yield(s,t.id).minerals == 3,"Light vegetation neutral yields")
	s.cohorts.pop_a.state.job = null; s.cohorts.pop_a.equipment = ["work_suit"]
	var clean = {"type":"cleanse","cohortId":"pop_a","target":t.id,"layer":"vegetation"}
	check(R.reason(s,clean) == "","Resident suit can clear nearby vegetation")
	s = R.command(s,clean).state
	check(not s.tiles[t.id].vegetation,"Clear action persists")
	check(R.reason(s,clean) != "","Clean action cooldown / absent overlay rejected")
	var troop = {"qualification":"Soldier","equipment":["small_arms"]}
	check(R.combat_profile(troop).attack == 1 and R.combat_profile(troop).ranged == 0.5,"Rifle baseline and half strength range")
	troop.equipment = ["flamer"]
	check(R.combat_profile(troop).defence == 1,"Flamer no extra toughness")
	check(S.X.human_power(s,troop) == 2,"Flamer offense animal bonus")
	check(S.X.DATA.larva.attack == 0.25 and S.X.DATA.predator.attack == 1 and S.X.DATA.armored.attack > 1,"Animal baseline strengths")
	var fresh = S.initial_state()
	check(not fresh.tiles.values().any(func(tile):return tile.baseTerrain == "desert" and tile.feature == "forest"),"No desert trees")
	var make = {"type":"manufacture","settlementId":"main","item":"rover"}
	fresh.completed = ["field_methods","surveying"]
	check(R.reason(fresh,make).contains("capacity"),"Transport needs military capacity")
	var old = S.initial_state(); old.schemaVersion = 10; old.rulesVersion = 10; old.worldVersion = 2
	for u in old.xenos.units.values(): u.hp = {"larva":4,"predator":6,"armored":11}[u.kind]
	old.xenos.humanHealth.pop_a = 7
	var migrated = S.migrate(JSON.parse_string(JSON.stringify(old)))
	check(S.validate(migrated) == "","Schema ten migrates: "+S.validate(migrated))
	check(migrated.xenos.humanHealth.pop_a == 70,"Wounds scaled on migration")
	# Movement route no longer has expedition-range exclusion.
	check(not R.path(fresh,"2,3","18,12","cohort").is_empty(),"Long map route available")
	# Step on cleared nest, then disabled nest never harvests/spreads/breeds.
	var burn = S.initial_state(); burn.xenos.units = {}; S.X.sync_tiles(burn)
	var c = burn.cohorts.pop_a; c.qualification = "Soldier"; c.equipment = ["small_arms"]
	c.state = {"kind":"mobile","tileId":S.X.NEST_TILE,"movementRemaining":1.0}
	S.X.burn_occupied(burn)
	check(burn.xenos.nests.nest_1.burned,"Soldier occupation disables nest")
	var stocks = burn.xenos.nests.nest_1.biomass; var mass = burn.xenos.mass.size()
	S.X.tick(burn,S.players(burn)); S.X.sync_tiles(burn)
	check(burn.xenos.units.is_empty() and burn.xenos.nests.nest_1.biomass == stocks and burn.xenos.mass.size() == mass,"Burned nest dormant")
	# Round-trip deterministic combat and counts.
	var one = S.initial_state(); var two = S.migrate(JSON.parse_string(JSON.stringify(one)))
	var a = C.duel(one.xenos,1,1.5,100,75); var b = C.duel(two.xenos,1,1.5,100,75)
	check(a == b and one.xenos.rng == two.xenos.rng,"Combat random stream persists")
	var cost = S.initial_state()
	var before_cost = R.economy(cost).militaryUpkeep.duplicate()
	cost.cohorts.pop_rover.qualification = "Soldier"; cost.cohorts.pop_rover.equipment.append("flamer")
	var after_cost = R.economy(cost).militaryUpkeep
	check(after_cost.food == before_cost.food+1 and after_cost.industry == before_cost.industry+1,"Mobilised Soldier food and Flamer Industry upkeep")
	var shot = S.initial_state()
	shot.xenos.units = {"xeno_0003":shot.xenos.units.xeno_0003}
	var gunner = shot.cohorts.pop_rover
	gunner.qualification = "Soldier"; gunner.equipment = ["small_arms"]
	gunner.state.movementRemaining = 1.0
	shot.xenos.units.xeno_0003.tile = "4,3"
	var fire = {"type":"attackXeno","cohortId":gunner.id,"targetId":"xeno_0003","mode":"ranged"}
	check(S.reason_for(shot,"blue",fire) == "","Rifle reaches two hexes")
	var fired = S.command_for(shot,"blue",fire)
	check(fired.ok and fired.state.xenos.units.xeno_0003.hp < 100 and not fired.state.xenos.humanHealth.has(gunner.id),"Ranged damage without retaliation")
	check(S.reason_for(fired.state,"blue",fire) != "","One attack per turn")
	check(fired.state.xenos.effects.back().kind == "rifle","Rifle burst event emitted")
	gunner.equipment = ["flamer"]
	check(S.reason_for(shot,"blue",fire) != "","Flamer has adjacent range only")
	shot.xenos.units.xeno_0003.tile = "3,3"
	check(S.reason_for(shot,"blue",fire) == "","Flamer reaches adjacent animal")
	var wound = S.initial_state(); wound.xenos.units = {}; wound.xenos.nests.nest_1.burned = true
	wound.xenos.humanHealth.pop_rover = 50
	wound.cohorts.pop_rover.state.tileId = "4,3"
	S.X.tick(wound,S.players(wound))
	check(wound.xenos.humanHealth.pop_rover == 55,"Field heals five HP in quiet round")
	wound.cohorts.pop_rover.state.tileId = wound.settlements.main.tileId
	S.X.tick(wound,S.players(wound))
	check(wound.xenos.humanHealth.pop_rover == 75,"Town heals twenty HP in quiet round")
	var dirty = S.initial_state(); dirty.cohorts.pop_a.state.job = null; dirty.cohorts.pop_a.equipment = ["work_suit"]
	dirty.tiles["3,3"].pollution = 3; S.X.sync_tiles(dirty)
	for level in [2,1,0]:
		var result = S.command_for(dirty,"blue",{"type":"cleanse","cohortId":"pop_a","target":"3,3","layer":"pollution"})
		check(result.ok and result.state.tiles["3,3"].pollution == level,"Cleaning lowers pollution one level")
		check(result.state.tiles == result.state.civilizations.red.tiles,"Cleansing shared by both civilizations")
		dirty = result.state; dirty.turn += 1; dirty.civilizations.red.turn += 1
	var blocked = S.initial_state()
	blocked.cohorts.pop_rover.state.tileId = "2,3"
	blocked.tiles["3,3"].hostiles = 1
	var move = R.command(blocked,{"type":"queueMove","unitId":"pop_rover","target":"3,3"})
	check(move.ok and move.state.cohorts.pop_rover.state.tileId == "2,3" and move.state.movementQueues.has("pop_rover"),"Animals block entry and preserve movement queue")
	var toxic = S.initial_state()
	for tile in toxic.tiles.values(): tile.pollution = 3
	toxic.xenos.tick = 1
	var animal = toxic.xenos.units.xeno_0001
	var nest_before = toxic.xenos.nests.nest_1.duplicate()
	S.X.worker_turn(toxic,toxic.xenos,animal,0)
	check(toxic.xenos.nests.nest_1.biomass == nest_before.biomass and toxic.xenos.nests.nest_1.minerals == nest_before.minerals,"Toxic pollution suppresses animal harvest too")
	var capacity = S.initial_state()
	capacity.districts.example = {"type":"security"}
	check(R.military_capacity(capacity) == 1,"Security District adds one equipment slot each")
	capacity.buildings.guard = {"type":"guard_post","tier":2}
	check(R.military_capacity(capacity) == 3,"Tier two Guard Post adds two slots each")
	var mass_clean = S.initial_state()
	mass_clean.xenos.mass["3,3"] = "nest_1"; S.X.sync_tiles(mass_clean)
	mass_clean.cohorts.pop_a.state.job = null; mass_clean.cohorts.pop_a.equipment = ["work_suit"]
	var cleansed = S.command_for(mass_clean,"blue",{"type":"cleanse","cohortId":"pop_a","target":"3,3","layer":"xenomass"})
	check(cleansed.ok and not cleansed.state.xenos.mass.has("3,3") and not cleansed.state.tiles["3,3"].xenomass,"Cleansing clears authoritative animal mat and human penalty")
	print("0.904 CHECKS ",checks," FAILURES ",failures.size())
	quit(0 if failures.is_empty() else 1)
