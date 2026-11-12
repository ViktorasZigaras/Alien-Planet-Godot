extends Control

const EDGE = Color("#76684e")
const SHADE = Color("#141c20")
const WIRES = [Color("#c79966"),Color("#75a2a1"),Color("#8a8069")]
var cable_run = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x < 40 or size.y < 24: return
	draw_rect(Rect2(Vector2(3,3),size-Vector2(6,6)),SHADE,false,2)
	for x in [6.0,size.x-6.0]:
		for y in [6.0,size.y-6.0]:
			draw_circle(Vector2(x,y),3,SHADE)
			draw_line(Vector2(x-1.5,y+1),Vector2(x+1.5,y-1),EDGE,1,true)
	if not cable_run: return
	var y = size.y-19
	for seam in [327.0,size.x-267.0]:
		draw_line(Vector2(seam,9),Vector2(seam,y-4),SHADE,3)
		draw_line(Vector2(seam+2,9),Vector2(seam+2,y-4),EDGE)
		for bolt in [13.0,y-9]:
			draw_circle(Vector2(seam+1,bolt),2.5,EDGE)
	draw_rect(Rect2(12,y-2,size.x-24,15),Color("#10181b"))
	draw_line(Vector2(12,y-2),Vector2(size.x-12,y-2),EDGE)
	for slot in [[30.0,313.0],[347.0,size.x-284.0],[size.x-247.0,size.x-27.0]]:
		if slot[1]-slot[0] < 60: continue
		for wire in range(3):
			var height = y+2+wire*3
			var points = PackedVector2Array([
				Vector2(slot[0],height),Vector2(slot[0]+22,height),
				Vector2(slot[0]+28,height+3),Vector2(slot[1]-34,height+3),
				Vector2(slot[1]-28,height),Vector2(slot[1],height),
			])
			draw_polyline(points,SHADE,3.5,true)
			draw_polyline(points,WIRES[wire],1.5,true)
		for x in [slot[0],slot[1]]:
			draw_rect(Rect2(x-4,y,8,12),EDGE)
			draw_line(Vector2(x-2,y+2),Vector2(x-2,y+10),Color("#b2a27e"))
