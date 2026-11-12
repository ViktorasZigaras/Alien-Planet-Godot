extends Control
signal focus_requested(key: String)
var tiles = {}
var visible_hexes = {}
var memory = {}
var station = ""
var focus = Vector3.ZERO
var selected = ""
var footprint = Vector2(8,5)
var grid = Vector2i(9,7)

func hex_scale() -> float:
	return minf((size.x-28)/maxf(11,grid.x+0.5*(grid.y-1)),(size.y-26)/maxf(5.3,0.866*(grid.y-1)))

func point(tile: Dictionary) -> Vector2:
	return Vector2(14,13)+Vector2(float(tile.q)+float(tile.r)*0.5,float(tile.r)*0.866)*hex_scale()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#111d26"))
	for tile in tiles.values():
		var color: Color = {"water":Color("#315367"),"plains":Color("#88815a"),"grassland":Color("#60805a"),"desert":Color("#a89161"),"tundra":Color("#8b9690"),"fungal":Color("#746581")}.get(tile.baseTerrain,Color("#667064"))
		if not visible_hexes.has(tile.id): color = color.darkened(0.23 if memory.has(tile.id) else 0.46)
		var p = point(tile)
		var radius = hex_scale()*0.54
		var polygon = PackedVector2Array()
		for i in range(6):
			var angle = deg_to_rad(30+i*60)
			polygon.append(p+Vector2(cos(angle),sin(angle))*radius)
		draw_colored_polygon(polygon,color)
		if tile.id == station: draw_circle(p,4,Color("#f6d486"))
		if tile.id == selected: draw_arc(p,radius+2,0,TAU,20,Color("#f8d98f"),1.6,true)
	if not tiles.is_empty():
		var scale_factor = hex_scale()/sqrt(3.0)
		var center = Vector2(14,13)+Vector2(focus.x,focus.z)*scale_factor
		var extent = footprint*scale_factor
		var bounds = Rect2(center-extent*0.5,extent).intersection(Rect2(Vector2(2,2),size-Vector2(4,4)))
		draw_rect(bounds,Color(1,0.93,0.75,0.78),false,1)
	draw_rect(Rect2(Vector2.ONE,size-Vector2(2,2)),Color("#a48956"),false,1)

func _gui_input(event: InputEvent) -> void:
	var click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var drag = event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if not click and not drag: return
	var best = ""
	var distance = INF
	for tile in tiles.values():
		var next = point(tile).distance_squared_to(event.position)
		if next < distance:
			distance = next
			best = tile.id
	if best != "": focus_requested.emit(best)
	accept_event()
