extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func run():
 var old=S.initial_state();old.civilizations.erase("green");old.xenos.deaths.erase("green");old.worldVersion=3
 var n=S.migrate(JSON.parse_string(JSON.stringify(old)))
 print("OLD ",S.validate(n)," rules ",n.schemaVersion," world ",n.worldVersion)
 var s=S.initial_state()
 for i in range(3):s=S.advance_round(s)
 var raw=JSON.parse_string(JSON.stringify(s));print("RAW ",S.validate(raw));var saved=S.migrate(raw)
 print("SAVE ",S.validate(saved)," rules ",saved.schemaVersion," world ",saved.worldVersion)
 quit()
