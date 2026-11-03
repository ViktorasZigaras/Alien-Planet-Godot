extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
func _initialize(): call_deferred("run")
func run():
 DirAccess.make_dir_recursive_absolute("res://builds")
 var s=S.initial_state()
 print("VALID ",S.validate(s))
 print("ACCESS ",JSON.stringify(s.civilizations.red.tileAccess))
 for i in range(60):
  s=S.advance_round(s)
  var error=S.validate(s)
  if error!="": printerr("INVALID ",i+1," ",error);quit(1);return
  if (i+1)%10==0:
   print("ROUND ",i+1," ",JSON.stringify(S.summary(s)))
   for id in ["red","green"]:
    var p=S.players(s)[id]
    print(id," ",JSON.stringify(p.ai.operation)," FLOW ",JSON.stringify(S.R.economy(p).delta)," LAST ",JSON.stringify(p.ai.history.slice(-4)))
 FileAccess.open("res://builds/reconstruction_diagnostic.json",FileAccess.WRITE).store_string(JSON.stringify(s))
 quit()
