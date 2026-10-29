class_name PlanetHexMap
extends Control
## One lightweight map view; picking uses real hex polygons, not sprite bounds.
signal tile_selected(key: String)
signal move_requested(key: String)
signal hover_changed(key: String)
const Rules = preload("res://scripts/game_rules.gd")
const Art = preload("res://scripts/starter_art.gd")
var state: Dictionary = {}
var selected_tile = "2,3"
var selected_unit = ""
var overlay = "cohort"
var hovered = ""
var zoom = 1.0
var pan = Vector2.ZERO
var dragging = false
var supply: Dictionary = {}
var route: Dictionary = {}
var font: Font

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	font = ThemeDB.fallback_font
	resized.connect(queue_redraw)
	mouse_exited.connect(func(): hovered = ""; hover_changed.emit(""); queue_redraw())

func update_view(s: Dictionary, tile: String, unit: String, support: String) -> void:
	state = s
	selected_tile = tile
	selected_unit = unit
	overlay = support
	supply = Rules.supply_field(s)
	route = {}
	var u = Rules.mobile(s, unit)
	if not u.is_empty():
		route = Rules.path(s, u.tileId, tile, u.classId)
	queue_redraw()

func fit_map() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()

func map_scale() -> float:
	return maxf(0.1, minf(size.x / 910.0, size.y / 550.0)) * zoom

func map_origin() -> Vector2:
	return (size - Vector2(910, 550) * map_scale()) / 2.0 + pan

func centre(t: Dictionary) -> Vector2:
	return Vector2(70 + sqrt(3.0)*36*(t.q+t.r/2.0), 75 + 54*t.r)

func polygon(t: Dictionary) -> PackedVector2Array:
	var points = PackedVector2Array()
	var c = centre(t)
	for i in range(6):
		var a = deg_to_rad(60*i-30)
		points.append(c+Vector2(cos(a), sin(a))*34)
	return points

func pick(local_point: Vector2) -> String:
	var point = (local_point - map_origin()) / map_scale()
	for t in state.get("tiles", {}).values():
		if Geometry2D.is_point_in_polygon(point, polygon(t)):
			return t.id
	return ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			accept_event()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var before = (event.position-map_origin()) / map_scale()
			zoom = clampf(zoom * (1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0/1.12), 0.7, 2.8)
			pan += event.position - (map_origin() + before * map_scale())
			queue_redraw()
			accept_event()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			var key = pick(event.position)
			if not key.is_empty():
				if event.button_index == MOUSE_BUTTON_RIGHT:
					move_requested.emit(key)
				else:
					tile_selected.emit(key)
				grab_focus()
			accept_event()
	elif event is InputEventMouseMotion:
		if dragging:
			pan += event.relative
			queue_redraw()
		else:
			var key = pick(event.position)
			if key != hovered:
				hovered = key
				hover_changed.emit(key)
				queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101c24"))
	if state.is_empty() or font == null:
		return
	draw_set_transform(map_origin(), 0, Vector2.ONE * map_scale())
	for t in state.tiles.values():
		var c = centre(t)
		var poly = polygon(t)
		var colour = Color("506951")
		if t.baseTerrain == "water": colour = Color("234d69")
		elif t.feature == "forest": colour = Color("304e3b")
		elif t.relief == "hills": colour = Color("6b5d4b")
		if hovered == t.id: colour = colour.lightened(0.12)
		draw_colored_polygon(poly, colour)
		var edge = Color("263c3f")
		if overlay != "none" and supply.get(t.id, INF) <= Rules.reach(state, overlay): edge = Color("88ae98")
		if selected_tile == t.id: edge = Color("f5cd82")
		var outline = poly.duplicate()
		outline.append(poly[0])
		draw_polyline(outline, edge, 3 if selected_tile == t.id else 1.0, true)
		if t.feature == "forest":
			for dx in [-12, 0, 12]:
				draw_colored_polygon(PackedVector2Array([c+Vector2(dx-8, 9), c+Vector2(dx, -16), c+Vector2(dx+8, 9)]), Color("73926a"))
		elif t.relief == "hills":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-20, 11), c+Vector2(-3, -14), c+Vector2(7, 0), c+Vector2(15, -7), c+Vector2(25, 11)]), Color("b4a085"))
		elif t.baseTerrain == "water":
			for dy in [-8, 0, 8]: draw_line(c+Vector2(-15, dy), c+Vector2(15, dy), Color("426d86"), 1)
		text_at(t.id, c+Vector2(0, 25), 10, Color("d5dfd0"))
		var site = Rules.site_at(state, t.id)
		var district = Rules.district_at(state, t.id)
		if not site.is_empty() or not district.is_empty():
			var key = site.id if not site.is_empty() else "district"
			draw_icon(key, Rect2(c-Vector2(25, 28), Vector2(50, 44)))
		if state.constructionProject != null and state.constructionProject.targetTileId == t.id:
			text_at("BUILD", c+Vector2(0, 1), 12, Color("ffdb96"))
	if not route.is_empty() and route.path.size() > 1:
		for i in range(route.path.size()-1):
			draw_dashed_line(centre(state.tiles[route.path[i]]), centre(state.tiles[route.path[i+1]]), Color("f6d697"), 2, 6, true)
	var units = []
	for key in state.units: units.append(Rules.mobile(state, key))
	for key in state.cohorts:
		if state.cohorts[key].state.kind == "mobile": units.append(Rules.mobile(state, key))
	for u in units:
		var same = units.filter(func(v): return v.tileId == u.tileId)
		var offset = (same.find(u) - (same.size()-1)/2.0)*23.0
		var c = centre(state.tiles[u.tileId]) + Vector2(offset, -3)
		draw_circle(c, 20, Color("142b34"))
		draw_arc(c, 20, 0, TAU, 32, Color("f5cc82") if selected_unit == u.id else Color("a2ccd6"), 2, true)
		var key = "rover" if u.classId == "rover" else state.cohorts[u.id].qualification
		draw_icon(key, Rect2(c-Vector2(17, 19), Vector2(34, 36)))
	for site in state.settlements.values():
		text_at(site.name, centre(state.tiles[site.tileId])+Vector2(0, -40), 13, Color("ffe7b6"))
	draw_set_transform(Vector2.ZERO)
	draw_string(font, Vector2(18, size.y-32), "LEFT: inspect    RIGHT: move selected unit    WHEEL: zoom    MIDDLE: pan", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9db1b8"))
	draw_string(font, Vector2(18, size.y-13), "Main Base is the only supply source · Field Station supply cost 4", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("738d98"))

func text_at(text: String, pos: Vector2, font_size: int, colour: Color) -> void:
	draw_string(font, pos-Vector2(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x/2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, colour)

func draw_icon(key: String, rect: Rect2) -> void:
	var tex = Art.roster()
	if tex != null:
		draw_texture_rect_region(tex, rect, Art.CROPS[key])
	else:
		draw_circle(rect.get_center(), 12, Color("dbc190"))
