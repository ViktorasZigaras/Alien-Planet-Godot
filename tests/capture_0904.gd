extends SceneTree
const S = preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func capture(path: String):
	for i in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func run():
	root.size=Vector2i(1440,900)
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	for i in range(12):await process_frame
	DirAccess.make_dir_recursive_absolute("res://builds/combat-0904")
	var before=JSON.stringify(app.state)
	await capture("res://builds/combat-0904/Alien_Planet_Opening_Sprites_0904.png")
	app.set_map_mode(1)
	while not app.world_view.built:await process_frame
	await capture("res://builds/combat-0904/Alien_Planet_Opening_3D_0904.png")
	if JSON.stringify(app.state)!=before:push_error("Default capture changed simulation");quit(1);return
	# Labelled UI/art fixture only. This is not the seeded policy experiment.
	var s = S.initial_state()
	var c = s.cohorts.pop_rover
	c.state = {"kind":"mobile","tileId":"17,12","movementRemaining":1.0}
	c.qualification = "Soldier";c.equipment=["flamer"]
	s.tiles["17,12"].feature=null;s.tiles["17,12"].vegetation=false
	s.xenos.units = {"xeno_0003":s.xenos.units.xeno_0003,"xeno_0001":s.xenos.units.xeno_0001}
	s.xenos.units.xeno_0003.tile="18,12";s.xenos.units.xeno_0003.hp=75
	s.xenos.units.xeno_0001.tile="19,12"
	s.tiles["18,11"].pollution=3;s.tiles["17,11"].pollution=2;s.tiles["16,12"].pollution=1
	s.tiles["16,13"].obstacle="stones";s.tiles["17,13"].obstacle="brambles";s.tiles["19,11"].biomass=4
	S.X.sync_tiles(s)
	app.state=s;app.selected_unit=c.id;app.selected_tile="18,12"
	app.status("STAGED ART / COMBAT PREVIEW — not the 200-turn test")
	app.render();app.world_view.focus_tile("18,12")
	while not app.world_view.built:await process_frame
	await capture("res://builds/combat-0904/Alien_Planet_Combat_Fixture_3D_0904.png")
	app.set_map_mode(0);app.pixel_view.focus_tile("18,12")
	await capture("res://builds/combat-0904/Alien_Planet_Combat_Fixture_Sprites_0904.png")
	# Real ranged command supplies the effect, frozen mid-animation for legibility.
	app.issue({"type":"attackXeno","cohortId":c.id,"targetId":"xeno_0003","mode":"ranged"})
	app.pixel_view.fx.set_process(false)
	for burst in app.pixel_view.fx.bursts:burst.age=0.18
	await capture("res://builds/combat-0904/Alien_Planet_Flame_Burst_Fixture_0904.png")
	print("0.904 opening captures unchanged; combat/overlays and flame images explicitly staged")
	quit()
