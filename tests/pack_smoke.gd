extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var app=load("res://b01.tscn").instantiate()
 root.add_child(app)
 while not app.world_view.built: await process_frame
 if app.state.get("scenario","")!="b01-shell-v1" or app.state.tiles.size()!=63: quit(1);return
 if not app.issue({"type":"queueMove","unitId":"pop_a","target":"2,2"}): quit(2);return
 if not app.issue({"type":"endTurn"}) or app.state.turn!=2: quit(3);return
 if not app.save_to("user://b01-pack-check.json"):quit(4);return
 if not app.load_from("user://b01-pack-check.json"):quit(5);return
 for i in range(4):await process_frame
 while app.world_view.building:await process_frame
 app.free()
 for i in range(3):await process_frame
 print("PACK SMOKE PASS: isolated PCK loads B01, moves, advances once, saves and loads")
 quit()
