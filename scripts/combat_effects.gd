extends Control
## View-only projected bursts. No particles, timers or rendering affect game state.
var seen = -1
var bursts: Array = []
var location: Callable
var motion = true
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
func receive(x: Dictionary,project: Callable):
	location = project
	if seen < 0 or int(x.effectSequence) < seen: seen = int(x.effectSequence); bursts.clear(); return
	for event in x.effects:
		if int(event.id) <= seen: continue
		seen = int(event.id)
		if is_visible_in_tree() and motion:
			var burst = event.duplicate(); burst.age = 0.0; bursts.append(burst)
	if bursts.size() > 24: bursts = bursts.slice(-24)
	queue_redraw()
func _process(delta: float):
	if not is_visible_in_tree() or not motion: bursts.clear(); return
	if bursts.is_empty(): return
	for burst in bursts: burst.age += delta
	bursts = bursts.filter(func(b):return b.age < 0.7)
	queue_redraw()
func _draw():
	if not location.is_valid(): return
	for burst in bursts:
		var a = location.call(burst.source); var b = location.call(burst.target)
		var t = float(burst.age)/0.7
		var color = Color({"rifle":"f8d887","flame":"ee843d","spit":"a1c357","claw":"d4c4a3"}[burst.kind])
		color.a = 1.0-t
		# Small source lunge / muzzle flash, tracer or travelling spit and impact sparks.
		draw_circle(a.lerp(b,minf(0.15,t)),4*(1-t),color)
		if burst.kind == "rifle" and t < 0.3: draw_line(a,b,color,2)
		elif burst.kind == "spit": draw_circle(a.lerp(b,minf(1,t*2)),5,color)
		elif burst.kind == "flame":
			for j in range(7):
				var at = a.lerp(b,float(j)/6)+Vector2(sin(j*2.7+t*10)*7,cos(j*1.5+t*8)*5)
				draw_circle(at,(3+j*0.5)*(1-t),color)
		for i in range(6):
			var angle = i*TAU/6+t*2
			draw_circle(b+Vector2(cos(angle),sin(angle))*t*17,2.5*(1-t),color)
