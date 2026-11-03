extends SceneTree
const R=preload("res://scripts/game_rules.gd")
func _initialize():
 var s=R.initial_state()
 print("RULES INITIAL ",R.validate(s)," ",s.schemaVersion)
 quit()
