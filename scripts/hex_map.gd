class_name PlanetHexMap
extends Control
## One lightweight map view; picking uses real hex polygons, not sprite bounds.
signal tile_selected(key: String)
signal move_requested(key: String, append: bool)
signal hover_changed(key: String)
const X = preload("res://scripts/xeno_ecology.gd")
const Claims = preload("res://scripts/claim_map.gd")
const Style = preload("res://scripts/visual_style.gd")
const Rules = preload("res://scripts/game_rules.gd")
const Catalogue = preload("res://scripts/asset_catalogue.gd")
const Art = preload("res://scripts/starter_art.gd")
var fx: Control
var state: Dictionary = {}
var selected_tile = "2,3"
var selected_unit = ""
var overlay = "none"
var show_yields = false
var hovered = ""
var zoom = 1.0
var pan = Vector2.ZERO
var dragging = false
var press_position = Vector2.ZERO
var drag_distance = 0.0
var left_down = false
var supply: Dictionary = {}
var route: Dictionary = {}
var font: Font
var focus_key = ""
var missing_sprite_keys: Dictionary = {}

func _ready() -> void:
	fx = preload("res://scripts/combat_effects.gd").new()
	add_child(fx)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	font = ThemeDB.fallback_font
	resized.connect(func():
		if focus_key != "": focus_tile(focus_key)
		else: queue_redraw())
	mouse_exited.connect(func(): hovered = ""; hover_changed.emit(""); queue_redraw())

func update_view(s: Dictionary, tile: String, unit: String, support: String) -> void:
	state = s
	fx.receive(s.xenos,func(key):return centre(state.tiles[key])+Vector2(0,-13))
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
	focus_key = ""
	zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()

func map_dimensions() -> Vector2:
	if state.is_empty(): return Vector2(910,550)
	return Vector2(140+sqrt(3.0)*36*(state.map.width-1+(state.map.height-1)/2.0),150+54*(state.map.height-1))

func focus_tile(key: String) -> void:
	focus_key = key
	zoom = 2.8
	pan = Vector2.ZERO
	pan += size/2-map_origin()-centre(state.tiles[key])*map_scale()
	queue_redraw()

func map_scale() -> float:
	var dims = map_dimensions()
	return maxf(0.1,minf(size.x/dims.x,size.y/dims.y))*zoom

func map_origin() -> Vector2:
	return (size - map_dimensions() * map_scale()) / 2.0 + pan

func centre(t: Dictionary) -> Vector2:
	return Vector2(70 + sqrt(3.0)*36*(t.q+t.r/2.0), 75 + 54*t.r)

func polygon(t: Dictionary) -> PackedVector2Array:
	var points = PackedVector2Array()
	var c = centre(t)
	for i in range(6):
		var a = deg_to_rad(60*i-30)
		points.append(c+Vector2(cos(a), sin(a))*35.8)
	return points

func pick(local_point: Vector2) -> String:
	var point = (local_point - map_origin()) / map_scale()
	for t in state.get("tiles", {}).values():
		if Geometry2D.is_point_in_polygon(point, polygon(t)):
			return t.id
	return ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				left_down = true
				press_position = event.position
				drag_distance = 0
			else:
				if left_down and drag_distance < 5:
					var key = pick(event.position)
					if key != "": tile_selected.emit(key)
				left_down = false
			grab_focus()
			accept_event()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			accept_event()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			focus_key = ""
			var before = (event.position-map_origin())/map_scale()
			zoom = clampf(zoom*(1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0/1.12),0.7,6.0)
			pan += event.position-(map_origin()+before*map_scale())
			queue_redraw()
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var key = pick(event.position)
			if key != "": move_requested.emit(key,event.shift_pressed)
			accept_event()
	elif event is InputEventMouseMotion:
		if left_down and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			left_down = false
		if dragging or left_down:
			drag_distance += event.relative.length()
			if dragging or drag_distance >= 5:
				focus_key = ""
				pan += Vector2(event.relative.x,-event.relative.y)
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
		draw_terrain(t,poly)
		var edge = Color(Style.SPRITE_GRID,0.58)
		if overlay != "none" and supply.get(t.id, INF) <= Rules.reach(state, overlay): edge = Color("748a70")
		if selected_tile == t.id: edge = Style.SELECTION
		var outline = poly.duplicate()
		outline.append(poly[0])
		draw_polyline(outline, edge, 3 if selected_tile == t.id else 0.65, true)
		if t.baseTerrain == "water":
			for neighbour in Rules.neighbours(state,t.id):
				if state.tiles[neighbour].baseTerrain == "water": continue
				var direction = (centre(state.tiles[neighbour])-c).normalized()
				var mid = (centre(state.tiles[neighbour])+c)/2-direction*1.3
				var along = direction.orthogonal()*17.5
				draw_line(mid-along,mid+along,Color("667f79"),3.0,true)
				draw_line(mid-along,mid+along,Color("b2c9b6"),0.9,true)
		if t.id == selected_tile or t.id == hovered: text_at(t.id,c+Vector2(0,27),10,Color("fff1c9"))
	# Second pass: objects can overlap neighbouring tiles without being erased.
	for t in state.tiles.values():
		var c = centre(t)
		if t.relief == "hills": draw_world_sprite("hill_"+t.baseTerrain,c+Vector2(0,-4),Vector2(82,86))
		if state.has("xenos") and state.xenos.mass.has(t.id): draw_world_sprite("xeno_mass_hills" if t.relief == "hills" else "xeno_mass",c+Vector2(0,-4),Vector2(82,86))
		if t.pollution > 0: draw_world_sprite("layer_pollution"+str(int(t.pollution)),c+Vector2(0,-5),Vector2(82,75))
		if t.obstacle != "": draw_world_sprite("layer_"+t.obstacle,c+Vector2(0,-7),Vector2(76,70))
		if t.vegetation: draw_world_sprite("layer_vegetation_"+t.biome,c+Vector2(0,-6),Vector2(78,70))
		if t.biomass > 0: draw_world_sprite("layer_biomass",c+Vector2(0,-5),Vector2(74,64))
		if t.feature == "forest" and not state.get("xenos",{}).get("nests",{}).values().any(func(n):return n.tile == t.id): draw_world_sprite("forest_"+t.biome,c+Vector2(0,-16 if t.relief == "hills" else -9),Vector2(78,78))
		var site = Rules.site_at(state, t.id)
		var district = Rules.district_at(state, t.id)
		if not site.is_empty(): draw_world_sprite("settlement_main" if site.id == "main" else "settlement_field",c+Vector2(0,-3),Vector2(85,85))
		if not district.is_empty():
			draw_world_sprite("district_"+district.type,c,Vector2(85,85))
			var buildings = state.buildings.values().filter(func(b): return b.get("districtId","") == district.id)
			for i in range(buildings.size()): draw_world_sprite("building_%s_%d" % [buildings[i].type,buildings[i].tier],c+Vector2(-10+i*20,-9),Vector2(50,50))
		if state.constructionProject != null and state.constructionProject.targetTileId == t.id:
			text_at("BUILD", c+Vector2(0, 1), 12, Color("ffdb96"))
	for edge_key in state.rivers:
		var ends = edge_key.split("|")
		var a = centre(state.tiles[ends[0]])
		var b = centre(state.tiles[ends[1]])
		var mid = (a+b)/2
		var side = (b-a).normalized().orthogonal()*18
		draw_line(mid-side,mid+side,Color("163c58"),6,true)
		draw_line(mid-side,mid+side,Color("65bdd9"),3,true)
	for t in state.tiles.values():
		if t.bonus != "":
			var resource = Rules.content().bonuses[t.bonus].yields.keys()[0]
			draw_world_sprite("bonus_"+t.bonus,centre(t)+Vector2(-20,-13 if t.relief != "hills" else -21),Vector2(82,82))
	for key in state.neutralSites:
		var c = centre(state.tiles[key])
		draw_world_sprite("building_exchange_1" if state.neutralSites[key].resource == "culture" else "building_research_lab_1",c,Vector2(85,85))
		text_at(state.neutralSites[key].name,c+Vector2(0,-35),11,Color("e3c5e9"))
	draw_improvements()
	draw_claims()
	draw_xenos()
	for tile in state.tiles.values():
		draw_worker(tile)
	if show_yields:
		for tile in state.tiles.values():
			draw_yield(tile)
	var people = Rules.visible_people(state)
	for tile in people:
		var c = state.cohorts[people[tile]]
		if c.state.kind == "mobile" or (c.state.get("job") is String and c.state.job.begins_with("tile:")): continue
		draw_world_sprite(Catalogue.person_key(c),centre(state.tiles[tile])+Vector2(10,8 if state.tiles[tile].relief == "hills" else 15),Vector2(56,56))
	draw_queued_route()
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
		var occupied = not Rules.site_at(state,u.tileId).is_empty() or not Rules.district_at(state,u.tileId).is_empty() or state.neutralSites.has(u.tileId)
		var c = centre(state.tiles[u.tileId]) + Vector2(offset+18 if occupied else offset, 20 if occupied else -13 if state.tiles[u.tileId].relief == "hills" else -3)

		draw_arc(c, 20, 0, TAU, 32, Color("f5cc82") if selected_unit == u.id else Color("a2ccd6"), 2, true)
		var key = "rover" if u.classId == "rover" else state.cohorts[u.id].qualification
		draw_world_sprite(Catalogue.person_key(state.cohorts[u.id]),c+Vector2(0,-9),Vector2(60,60))
	for site in state.settlements.values():
		var at = centre(state.tiles[site.tileId])
		var owner = state.get("settlementOwners",{}).get(site.id,"blue")
		var colour = Claims.COLORS[owner]
		text_at(site.name, at+Vector2(0,-40),13,colour)
		draw_line(at+Vector2(-23,-24),at+Vector2(-23,-9),Color("c9c1a6"),1.5)
		draw_rect(Rect2(at+Vector2(-23,-24),Vector2(8,5)),colour)
	draw_set_transform(Vector2.ZERO)
	draw_string(font, Vector2(18, size.y-32), "CLICK: inspect   DRAG: pan   RIGHT: move (Shift: append)   WHEEL: zoom", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9db1b8"))
	draw_string(font, Vector2(18, size.y-13), "Climate regions guide terrain and deposits · Fit map for the whole test world", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("738d98"))

func text_at(text: String, pos: Vector2, font_size: int, colour: Color) -> void:
	draw_string(font, pos-Vector2(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x/2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, colour)

func draw_icon(key: String, rect: Rect2) -> void:
	var tex = Art.icon(key)
	if tex != null:
		var factor = minf(rect.size.x/tex.get_width(),rect.size.y/tex.get_height())
		var dimensions = tex.get_size()*factor
		draw_texture_rect(tex,Rect2(rect.get_center()-dimensions/2,dimensions),false)
	else:
		draw_circle(rect.get_center(),12,Color("dbc190"))

func draw_yield(tile: Dictionary) -> void:
	var output = Rules.map_yield(state, tile.id)
	if output.is_empty():
		return
	var c = centre(tile) + Vector2(0, 8)
	var columns = mini(2,output.size())
	var width = columns*27.0
	var rows = ceili(output.size()/2.0)
	draw_style_box(yield_backplate(),Rect2(c-Vector2(width/2+3,12),Vector2(width+6,rows*17+3)))
	var i = 0
	for key in output:
		var pos = c+Vector2(-width/2+(i%2)*27,-10+floori(i/2.0)*17)
		draw_texture_rect(Art.resource_icon(key),Rect2(pos,Vector2(13,14)),false)
		draw_string(font,pos+Vector2(14,12),str(int(output[key])),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("fff2cd"))
		i += 1

func yield_backplate() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.07, 0.1, 0.85)
	style.set_corner_radius_all(3)
	return style

func draw_worker(tile: Dictionary) -> void:
	var worker = Rules.worker_at(state, tile.id)
	if worker.is_empty():
		return
	var c = centre(tile)
	var ring = PackedVector2Array()
	for p in polygon(tile): ring.append(c+(p-c)*0.87)
	ring.append(ring[0])
	var colour = Claims.COLORS[state.get("cohortOwners",{}).get(worker.id,"blue")]
	draw_polyline(ring, colour, 1.8, true)
	draw_style_box(yield_backplate(), Rect2(c+Vector2(-31,-28), Vector2(62,16)))
	text_at(worker.name, c+Vector2(0,-16), 9, colour)
	draw_world_sprite(Catalogue.person_key(worker),c+Vector2(10,-14 if tile.relief == "hills" else -4),Vector2(56,56))

func draw_improvements() -> void:
	for key in state.get("improvements", {}):
		var flags = state.improvements[key]
		var c = centre(state.tiles[key])
		for improvement in flags:
			if improvement != "road" and flags[improvement]: draw_world_sprite("improvement_"+improvement,c+Vector2(0,-3),Vector2(80,80))
		if flags.get("road", false):
			var linked = false
			for neighbour in Rules.neighbours(state,key):
				if state.improvements.get(neighbour,{}).get("road",false):
					var end = (c+centre(state.tiles[neighbour]))/2
					draw_line(c,end,Color("3d3025"),7,true)
					draw_line(c,end,Color("c7b088"),3,true)
					linked = true
			if not linked:
				draw_line(c+Vector2(-15,0),c+Vector2(15,0),Color("c7b088"),3,true)

func draw_queued_route() -> void:
	var u = Rules.mobile(state,selected_unit)
	if u.is_empty(): return
	var steps = state.movementQueues.get(selected_unit,[])
	var previous = u.tileId
	for i in range(steps.size()):
		var a = centre(state.tiles[previous])
		var b = centre(state.tiles[steps[i]])
		draw_line(a,b,Color("88e3e7"),2.5,true)
		draw_circle(b,4,Color("88e3e7"))
		text_at(str(i+1),b+Vector2(8,-8),9,Color("e8ffff"))
		previous = steps[i]

func draw_terrain(tile: Dictionary, points: PackedVector2Array) -> bool:
	var texture = Style.ground_texture(tile.baseTerrain,int(tile.q)*3+int(tile.r)*5)
	var c = centre(tile)
	var uv = PackedVector2Array()
	var half_width = sqrt(3.0)*35.8/2.0
	for point in points: uv.append(Vector2((point.x-c.x+half_width)/(half_width*2.0),(point.y-c.y+35.8)/71.6))
	var tint = Color(1.12,1.12,1.12) if hovered == tile.id else Color.WHITE
	draw_polygon(points,PackedColorArray([tint]),uv,texture)
	return true

func draw_world_sprite(key: String,at: Vector2,dimensions: Vector2) -> void:
	var texture = Art.world_icon(key)
	if texture == null:
		if not missing_sprite_keys.has(key):
			missing_sprite_keys[key] = true
			push_warning("Missing map sprite: "+key)
		draw_circle(at,8,Color("dd6d91"))
		return
	if key.begins_with("hill_") or key in ["xeno_mass","xeno_mass_hills"]:
		draw_texture_rect(texture,Rect2(at-dimensions/2,dimensions),false)
		return
	texture = Art.tight_icon(key)
	var fraction = 0.76
	if key.begins_with("bonus_"): fraction = 0.46
	elif key.begins_with("district_"): fraction = 0.57
	elif key == "overlay_forest" or key.begins_with("forest_"): fraction = 0.88
	elif key.begins_with("layer_"): fraction = 0.92
	elif key.begins_with("person_"): fraction = 0.85
	var limit = dimensions*fraction
	var scale_factor = minf(limit.x/texture.get_width(),limit.y/texture.get_height())
	var drawn = texture.get_size()*scale_factor
	draw_texture_rect(texture,Rect2(at-drawn/2,drawn),false)

func draw_claims() -> void:
	var stones = {}
	for edge in Claims.boundary(state.tiles,state.get("claimOwners",{})):
		var a = Vector2(70,75)+edge.a*36
		var b = Vector2(70,75)+edge.b*36
		var colour = Claims.COLORS[edge.player]
		draw_line(a,b,Color(colour,0.50),0.9,true)
		for point in [a,b]:
			var key = str(point.snapped(Vector2.ONE*0.01))+edge.player
			if stones.has(key): continue
			stones[key] = true
			draw_circle(point+Vector2(0,1.5),2.8,Color("293b40"))
			draw_rect(Rect2(point-Vector2(1.7,3.0),Vector2(3.4,4.2)),Color("b9b8a0"))
			draw_rect(Rect2(point-Vector2(1.7,3.0),Vector2(3.4,1.6)),colour)

func draw_xenos() -> void:
	if not state.has("xenos"): return
	for nest in state.xenos.nests.values():
		var at = centre(state.tiles[nest.tile])
		draw_world_sprite("xeno_burned" if nest.get("burned",false) else "xeno_nest",at+Vector2(0,-5),Vector2(78,72))
		text_at("Brood nest",at+Vector2(0,-34),11,Color("99be7c"))
	var visible = X.visible_units(state.xenos)
	for tile in visible:
		var unit = state.xenos.units[visible[tile]]
		var at = centre(state.tiles[tile])+Vector2(0,-6 if state.tiles[tile].relief == "hills" else 0)
		if state.xenos.nests.values().any(func(n):return n.tile == tile): at += Vector2(12,14)
		draw_world_sprite("xeno_"+unit.kind,at,Vector2(54,43) if unit.kind == "armored" else Vector2(46,35))
		if unit.hp < X.DATA[unit.kind].hp:
			draw_line(at+Vector2(-10,14),at+Vector2(10,14),Color("26372e"),3)
			draw_line(at+Vector2(-10,14),at+Vector2(-10+20.0*unit.hp/X.DATA[unit.kind].hp,14),Color("b9ca72"),2)
