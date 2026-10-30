extends RefCounted
const A = preload("res://scripts/world_assets.gd")
const R = preload("res://scripts/game_rules.gd")
static func entries() -> Array:
	var list = []
	for role in R.content().qualifications:
		for suit in range(3):
			for arms in range(2): list.append({"key":"person_%s_%d_%d" % [role,suit,arms],"kind":"person","role":role,"suit":suit,"arms":arms,"label":role+(" · Work Suit" if suit == 1 else " · Reinforced Suit" if suit == 2 else "")+(" · Small Arms" if arms else "")})
	list.append({"key":"vehicle_rover","kind":"rover","label":"Rover · five-joint wheel rig"})
	for type in R.content().buildings:
		for tier in [1,2]: list.append({"key":"building_%s_%d" % [type,tier],"kind":"building","type":type,"tier":tier,"label":R.content().buildings[type].name+" · T"+str(tier)})
	for type in R.content().improvements: list.append({"key":"improvement_"+type,"kind":"improvement","type":type,"label":R.content().improvements[type].name})
	for type in R.content().districts: list.append({"key":"district_"+type,"kind":"district","type":type,"label":R.content().districts[type].name})
	for type in R.content().bonuses: list.append({"key":"bonus_"+type,"kind":"bonus","type":type,"label":R.content().bonuses[type].name})
	for main in [true,false]: list.append({"key":"settlement_main" if main else "settlement_field","kind":"settlement","main":main,"label":"Main Base" if main else "Field Station"})
	for feature in ["forest","hills"]: list.append({"key":"overlay_"+feature,"kind":"overlay","type":feature,"label":feature.capitalize()+" layer"})
	return list
static func create(entry: Dictionary) -> Node3D:
	match entry.kind:
		"person": return A.person({"qualification":entry.role,"equipment":(["work_suit"] if entry.suit == 1 else ["reinforced_suit"] if entry.suit == 2 else [])+(["small_arms"] if entry.arms else [])})
		"rover": return A.Rover.new()
		"building": return A.building(entry.type,entry.tier)
		"district": return A.district(entry.type)
		"bonus": return A.bonus(entry.type)
		"settlement": return A.settlement(entry.main)
		"improvement": return A.improvement(entry.type)
		"overlay":
			var model = A.terrain({"baseTerrain":"plains","feature":"forest" if entry.type == "forest" else null,"relief":"hills" if entry.type == "hills" else "flat"})
			model.get_child(0).free()
			return model
	return Node3D.new()
static func person_key(c: Dictionary) -> String:
	if "rover" in c.equipment: return "vehicle_rover"
	return "person_%s_%d_%d" % [c.qualification,2 if "reinforced_suit" in c.equipment else 1 if "work_suit" in c.equipment else 0,1 if "small_arms" in c.equipment else 0]
