extends RefCounted
const XActor = preload("res://scripts/xeno_actor.gd")
const XModels = preload("res://scripts/xeno_models.gd")
const A = preload("res://scripts/world_assets.gd")
const R = preload("res://scripts/game_rules.gd")
static func entries() -> Array:
	var list = []
	for role in R.content().qualifications:
		for suit in range(3):
			for arms in range(2): list.append({"key":"person_%s_%d_%d" % [role,suit,arms],"kind":"person","role":role,"suit":suit,"arms":arms,"label":role+(" · Work Suit" if suit == 1 else " · Reinforced Suit" if suit == 2 else "")+(" · Small Arms" if arms else "")})
	list.append({"key":"vehicle_rover","kind":"rover","label":"Transport · two passenger slots"})
	for type in R.content().buildings:
		for tier in [1,2]: list.append({"key":"building_%s_%d" % [type,tier],"kind":"building","type":type,"tier":tier,"label":R.content().buildings[type].name+" · T"+str(tier)})
	for type in R.content().improvements: list.append({"key":"improvement_"+type,"kind":"improvement","type":type,"label":R.content().improvements[type].name})
	for type in R.content().districts: list.append({"key":"district_"+type,"kind":"district","type":type,"label":R.content().districts[type].name})
	for type in R.content().bonuses: list.append({"key":"bonus_"+type,"kind":"bonus","type":type,"label":R.content().bonuses[type].name})
	for main in [true,false]: list.append({"key":"settlement_main" if main else "settlement_field","kind":"settlement","main":main,"label":"Main Base" if main else "Field Station"})
	for feature in ["forest","hills"]: list.append({"key":"overlay_"+feature,"kind":"overlay","type":feature,"label":feature.capitalize()+" layer"})
	for terrain in ["plains","grassland","desert","tundra","fungal"]: list.append({"key":"hill_"+terrain,"kind":"hill","type":terrain,"label":terrain.capitalize()+" rounded hill"})
	for kind in ["nest","larva","predator","armored","mass","mass_hills"]: list.append({"key":"xeno_"+kind,"kind":"xeno","type":kind,"label":"Xeno · "+kind.capitalize()})
	for biome in ["temperate","lush","cold","fungal","dry","coastal"]:
		list.append({"key":"forest_"+biome,"kind":"forest","type":biome,"label":biome.capitalize()+" forest"})
		list.append({"key":"layer_vegetation_"+biome,"kind":"layer","type":"vegetation_"+biome,"label":biome.capitalize()+" light vegetation"})
	for layer in ["pollution1","pollution2","pollution3","brambles","stones","biomass"]:
		list.append({"key":"layer_"+layer,"kind":"layer","type":layer,"label":layer.capitalize()})
	list.append({"key":"person_flamer","kind":"flamer","label":"Soldier · Flamer Exoskeleton"})
	list.append({"key":"xeno_burned","kind":"burned","label":"Disabled nest"})
	return list
static func create(entry: Dictionary) -> Node3D:
	match entry.kind:
		"flamer": return A.person({"qualification":"Soldier","equipment":["flamer"]})
		"burned":
			var nest = XModels.create("nest"); nest.scale.y = 0.4; nest.scale.x = 0.9
			A.P.oval(nest,Vector3(0,0.25,0),Vector3(0.9,0.12,0.9),Color("252b26"))
			return nest
		"layer": return A.layer(entry.type,{"baseTerrain":"plains","relief":"flat"})
		"forest":
			var terrain = A.terrain({"baseTerrain":"fungal" if entry.type == "fungal" else "plains","biome":entry.type,"feature":"forest","relief":"flat"})
			terrain.get_child(0).free()
			return terrain
		"xeno":
			if entry.type in ["nest","mass","mass_hills"]: return XModels.create(entry.type)
			var actor = XActor.new(); actor.kind = entry.type; return actor
		"person": return A.person({"qualification":entry.role,"equipment":(["work_suit"] if entry.suit == 1 else ["reinforced_suit"] if entry.suit == 2 else [])+(["small_arms"] if entry.arms else [])})
		"rover": return A.Rover.new()
		"building": return A.building(entry.type,entry.tier)
		"district": return A.district(entry.type)
		"bonus": return A.bonus(entry.type)
		"settlement": return A.settlement(entry.main)
		"improvement": return A.improvement(entry.type)
		"hill": return A.hill_sprite(entry.type)
		"overlay":
			var model = A.terrain({"baseTerrain":"plains","feature":"forest" if entry.type == "forest" else null,"relief":"hills" if entry.type == "hills" else "flat"})
			if entry.type == "forest": model.get_child(0).free()
			return model
	return Node3D.new()
static func person_key(c: Dictionary) -> String:
	if "rover" in c.equipment: return "vehicle_rover"
	if "flamer" in c.equipment: return "person_flamer"
	return "person_%s_%d_%d" % [c.qualification,2 if "reinforced_suit" in c.equipment else 1 if "work_suit" in c.equipment else 0,1 if "small_arms" in c.equipment else 0]

static func library_entries() -> Array:
	return entries().filter(func(e): return e.kind != "person" or (e.suit == 0 and e.arms == 0))
