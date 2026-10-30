class_name TerrainLayers
extends RefCounted
const FIELDS = ["pollution","obstacle","vegetation","biomass","xenomass","hostiles"]
static func initialise(tiles: Dictionary, scatter: bool = false) -> void:
	for t in tiles.values():
		var land = t.baseTerrain != "water"
		var n = posmod(int(t.q)*43+int(t.r)*79,149)
		if t.baseTerrain == "desert" and t.feature == "forest": t.feature = null
		if not t.has("pollution"): t.pollution = (1+n%3) if scatter and land and n < 8 else 0
		if not t.has("obstacle"): t.obstacle = ("brambles" if n%2 == 0 else "stones") if scatter and land and n >= 8 and n < 21 else ""
		if not t.has("vegetation"): t.vegetation = scatter and land and t.feature == null and n%3 == 0
		if not t.has("biomass"): t.biomass = (2+n%4) if scatter and land and n > 132 else 0
		if not t.has("xenomass"): t.xenomass = false
		if not t.has("hostiles"): t.hostiles = 0
static func blocked(t: Dictionary) -> bool:
	return t.feature == "forest" or t.get("vegetation",false) or t.get("obstacle", "") != ""
static func penalty(t: Dictionary) -> int:
	return int(t.get("pollution",0))+(1 if t.get("xenomass",false) else 0)
static func apply(t: Dictionary, yields: Dictionary) -> Dictionary:
	if t.get("pollution",0) == 3: return {}
	var out = yields.duplicate()
	for k in out.keys():
		out[k] = maxi(0,int(out[k])-penalty(t)-(1 if t.get("obstacle", "") == "brambles" and k == "minerals" else 2 if t.get("obstacle", "") == "stones" and k == "minerals" else 0))
		if out[k] == 0: out.erase(k)
	return out
static func description(t: Dictionary) -> String:
	var parts = []
	if t.get("pollution",0): parts.append("Pollution %d/3" % t.pollution)
	if t.get("obstacle", "") != "": parts.append(t.obstacle.capitalize())
	if t.get("vegetation",false): parts.append(t.biome.capitalize()+" light vegetation")
	if t.get("biomass",0): parts.append("Biomass patch (%d)" % t.biomass)
	if t.get("xenomass",false): parts.append("Xenomass: human yields −1")
	return " · ".join(parts)
