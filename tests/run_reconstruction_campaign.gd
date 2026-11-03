extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
func _initialize():call_deferred("run")
func run():
 DirAccess.make_dir_recursive_absolute("res://reports/reconstruction/final_campaign")
 var s=S.initial_state();var milestones=[]
 for i in range(200):
  s=S.advance_round(s)
  var error=S.validate(s)
  if error!="":printerr("INVALID ",i+1,": ",error);quit(1);return
  if (i+1)%20==0:
   var row={"round":i+1,"summary":S.summary(s),"operations":{}}
   for id in ["red","green"]:row.operations[id]=s.civilizations[id].ai.operation.duplicate(true)
   milestones.append(row);print(JSON.stringify(row))
   FileAccess.open("res://reports/reconstruction/final_campaign/campaign_checkpoint.json",FileAccess.WRITE).store_string(JSON.stringify(s))
 FileAccess.open("res://reports/reconstruction/final_campaign/campaign_summary.json",FileAccess.WRITE).store_string(JSON.stringify({"version":"0.910-reconstructed","seed":731,"rounds":200,"recording":false,"milestones":milestones,"final":S.summary(s)},"  "))
 print("CAMPAIGN COMPLETE; nest active = ",S.summary(s).xeno.activeNests)
 quit()
