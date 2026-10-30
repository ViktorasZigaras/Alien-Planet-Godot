class_name ClaimMap
extends RefCounted
const R = preload("res://scripts/game_rules.gd")
const COLORS = {"blue":Color("70b8ee"),"red":Color("df786b")}
static func center(t: Dictionary) -> Vector2: return Vector2(sqrt(3.0)*(t.q+t.r*0.5),1.5*t.r)
static func owners(players: Dictionary) -> Dictionary:
	var result = {}
	var distances = {}
	for player in players:
		var state = players[player]
		for town in state.settlements.values():
			for tile in state.tiles.values():
				var d = R.distance(state.tiles[town.tileId],tile)
				if d <= 2 and d < distances.get(tile.id,INF): result[tile.id] = player; distances[tile.id] = d
	return result
static func boundary(tiles: Dictionary,claimed: Dictionary) -> Array:
	var result = []
	for key in claimed:
		var t = tiles[key]
		for offset in R.OFFSETS:
			var next = R.tile_id(t.q+offset.x,t.r+offset.y)
			if claimed.get(next, "") == claimed[key]: continue
			var delta = Vector2(sqrt(3.0)*(offset.x+offset.y*0.5),1.5*offset.y)
			var mid = center(t)+delta/2
			var side = delta.normalized().orthogonal()*0.5
			result.append({"player":claimed[key],"a":mid-side,"b":mid+side})
	return result
