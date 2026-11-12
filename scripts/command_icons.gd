extends RefCounted

# Each string is a pen stroke in a shared 16-unit grid.
const STROKES = {
	"Map":["2,4 6,2 10,4 14,2 14,12 10,14 6,12 2,14 2,4","6,2 6,12","10,4 10,14"],
	"Colony":["2,14 2,7 8,2 14,7 14,14 2,14","6,14 6,9 10,9 10,14"],
	"Research":["6,2 10,2","7,2 7,7 3,12 3,14 13,14 13,12 9,7 9,2","5,11 11,11"],
	"Ecology":["3,12 4,6 9,3 14,2 13,8 10,12 3,12","2,14 10,6"],
	"Orders":["4,2 13,2 13,14 4,14 4,2","6,6 11,6","6,9 11,9","6,12 9,12"],
	"Alienopedia":["2,3 6,3 8,5 10,3 14,3 14,12 10,12 8,14 6,12 2,12 2,3","8,5 8,14"],
	"Center":["8,1 8,5","8,11 8,15","1,8 5,8","11,8 15,8","5,5 11,5 11,11 5,11 5,5"],
	"Overlay":["2,6 8,2 14,6 8,10 2,6","2,10 8,14 14,10"],
	"Move here":["2,12 2,8 13,8","9,4 13,8 9,12"],
	"Retreat":["14,12 14,8 3,8","7,4 3,8 7,12"],
	"Take build kit":["2,6 14,6 14,13 2,13 2,6","5,6 5,3 11,3 11,6","2,9 14,9","8,8 8,11"],
	"Queue project":["2,4 8,4","2,8 8,8","2,12 8,12","10,8 15,8","12,5 12,11"],
	"Hold":["6,3 6,13","10,3 10,13"],
	"Resume":["5,3 13,8 5,13 5,3"],
	"Identify":["2,3 8,3 10,5 10,9 8,11 4,11 2,9 2,3","9,10 14,15"],
	"Fire":["2,8 9,8","5,4 9,4 13,8 9,12 5,12"],
	"Duel":["3,3 13,13","13,3 3,13","3,10 6,13","10,13 13,10"],
	"End Turn":["2,8 10,8","7,5 10,8 7,11","13,3 13,13"],
	"Save":["2,2 12,2 14,4 14,14 2,14 2,2","5,2 5,6 11,6 11,2","5,14 5,9 11,9 11,14"],
	"Load":["2,5 7,5 9,7 14,7 13,14 2,14 2,5","2,9 14,9"],
	"Investigate":["2,6 5,3 11,3 14,6 11,9 5,9 2,6","8,5 9,6 8,7 7,6 8,5","5,12 11,12"],
	"Next idle":["3,4 10,8 3,12 3,4","13,4 13,12"],
	"Exchange":["2,5 13,5","10,2 13,5 10,8","14,11 3,11","6,8 3,11 6,14"],
	"Fieldwork":["3,14 10,7","8,3 11,2 14,5 13,8 10,9 8,7 8,3"],
	"Stop work":["4,4 12,4 12,12 4,12 4,4"],
	"Model Lab":["8,2 14,5 14,11 8,14 2,11 2,5 8,2","2,5 8,8 14,5","8,8 8,14"],
}
const ALIASES = {
	"Center station":"Center", "End Turn  ↵":"End Turn", "Manage colony":"Colony",
	"Return kit":"Take build kit", "Terrain work":"Ecology",
	"Work selected hex":"Ecology", "Transfer 1 Food to growth":"Ecology",
	"Authorize expedition":"Orders", "Stand down expedition":"Hold",
}
static var cache: Dictionary = {}

static func for_label(label: String) -> Texture2D:
	var prefix = label.get_slice(" · ",0)
	var key = ALIASES.get(prefix,prefix)
	if not STROKES.has(key): return null
	if cache.has(key): return cache[key]
	var raster = Image.create_empty(64,64,false,Image.FORMAT_RGBA8)
	for stroke in STROKES[key]:
		var points = stroke.split(" ")
		for i in range(1,points.size()):
			var start = Vector2(points[i-1].get_slice(",",0).to_float(),points[i-1].get_slice(",",1).to_float())*4
			var finish = Vector2(points[i].get_slice(",",0).to_float(),points[i].get_slice(",",1).to_float())*4
			for y in range(maxi(0,int(minf(start.y,finish.y))-4),mini(64,int(maxf(start.y,finish.y))+5)):
				for x in range(maxi(0,int(minf(start.x,finish.x))-4),mini(64,int(maxf(start.x,finish.x))+5)):
					var point = Vector2(x,y)
					var distance = point.distance_to(Geometry2D.get_closest_point_to_segment(point,start,finish))
					var alpha = clampf(3.4-distance,0.0,1.0)
					if alpha > raster.get_pixel(x,y).a:
						raster.set_pixel(x,y,Color(0.92,0.83,0.63,alpha))
	raster.resize(20,20,Image.INTERPOLATE_LANCZOS)
	cache[key] = ImageTexture.create_from_image(raster)
	return cache[key]
