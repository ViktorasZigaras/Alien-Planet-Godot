extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
func _initialize(): call_deferred("run")
func run():
 var s=S.initial_state()
 print("INITIAL ",S.validate(s))
 for i in range(10):
  s=S.advance_round(s)
  var e=S.validate(s)
  print("ROUND ",i+1," ",e," ",JSON.stringify(S.summary(s)))
  if e!="": quit(1);return
 quit()
