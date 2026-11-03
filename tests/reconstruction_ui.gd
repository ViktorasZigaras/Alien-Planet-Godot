extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1440,900)
 var app=load("res://main.tscn").instantiate();root.add_child(app)
 await process_frame
 var original=JSON.stringify(app.state)
 app.selected_tile=S.GREEN_TOWN;app.render()
 app.tabs.current_tab=3
 if DisplayServer.get_name()!="headless":
  for i in range(4):await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://reports/reconstruction/opening_testing.png")
 app.tabs.current_tab=4;app.selected_tile="4,3";app.render()
 app.set_map_mode(1)
 while not app.world_view.built:await process_frame
 for i in range(8):await process_frame
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://reports/reconstruction/opening_3d_survey.png")
 if JSON.stringify(app.state)!=original:printerr("UI inspection changed state");quit(1);return
 print("UI views, Green inspection, Testing and Survey/Atlas opened; state preserved")
 app.queue_free();await process_frame
 quit()
