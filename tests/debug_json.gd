extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
var diffs=[]
func diff(a,b,path):
 if a is Dictionary and b is Dictionary:
  for k in a:
   if not b.has(k):diffs.append(path+" missing "+str(k))
   else:diff(a[k],b[k],path+"/"+str(k))
  return
 if a is Array and b is Array:
  if a.size()!=b.size():diffs.append(path+" sizes "+str(a.size())+" "+str(b.size()));return
  for i in range(a.size()):diff(a[i],b[i],path+"/"+str(i))
  return
 if a!=b:diffs.append(path+": "+str(a)+" vs "+str(b))
func _initialize():call_deferred("run")
func run():
 var s=S.start_recording(S.initial_state())
 for i in range(12):s=S.advance_round(s)
 var saved=S.migrate(JSON.parse_string(JSON.stringify(s)))
 print("VALID ",S.validate(saved))
 var a=S.advance_round(s);var b=S.advance_round(saved)
 diff(a,b,"")
 print("DIFF ",JSON.stringify(diffs.slice(0,40)))
 quit()
