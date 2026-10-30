class_name CombatRules
extends RefCounted
## Small Civ-style repeated-round duel, not an exact Civ IV implementation.
const MAX_HP = 100
static func effective(base: float,hp: int) -> float:
	return maxf(0.01,base*(0.5+0.5*float(hp)/MAX_HP))
static func round_chance(a: float,d: float) -> float: return a/(a+d)
static func damage(a: float,d: float) -> int: return clampi(roundi(20*(3*a+d)/(3*d+a)),5,60)
static func odds(a: float,d: float,ahp: int = 100,dhp: int = 100) -> float:
	# Exact outcome probability for fixed starting strengths/damage, no sampling.
	var ap = effective(a,ahp); var dp = effective(d,dhp)
	var wins = int(ceil(float(dhp)/damage(ap,dp)))
	var losses = int(ceil(float(ahp)/damage(dp,ap)))
	var p = round_chance(ap,dp)
	var grid = []
	for i in range(wins+1):
		var row = []
		for j in range(losses+1): row.append(1.0 if i == 0 else 0.0)
		grid.append(row)
	for i in range(1,wins+1):
		for j in range(1,losses+1): grid[i][j] = p*grid[i-1][j]+(1-p)*grid[i][j-1]
	return grid[wins][losses]
static func defence(tile: Dictionary,town: bool = false) -> float:
	return 1.0+(0.25 if tile.relief == "hills" else 0.0)+(0.25 if tile.feature == "forest" else 0.0)+(0.1 if tile.get("vegetation",false) else 0.0)+(0.15 if tile.get("obstacle", "") != "" else 0.0)+(0.1 if tile.baseTerrain == "fungal" else 0.0)+(0.25 if town else 0.0)
static func roll(x: Dictionary) -> float:
	x.rng = (int(x.rng)*1103515245+12345)%2147483648
	return float(x.rng)/2147483648.0
static func duel(x: Dictionary,a: float,d: float,ahp: int,dhp: int) -> Dictionary:
	var ap = effective(a,ahp); var dp = effective(d,dhp)
	var chance = round_chance(ap,dp)
	var hits = 0
	while ahp > 0 and dhp > 0:
		if roll(x) < chance: dhp -= damage(ap,dp)
		else: ahp -= damage(dp,ap)
		hits += 1
	return {"attackerHP":maxi(0,ahp),"defenderHP":maxi(0,dhp),"rounds":hits}
static func ranged_damage(a: float,d: float,ahp: int,dhp: int) -> int:
	return clampi(roundi(25*effective(a,ahp)/effective(d,dhp)),3,45)
