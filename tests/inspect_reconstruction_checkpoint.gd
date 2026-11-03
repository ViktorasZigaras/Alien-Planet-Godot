extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
const P=preload("res://scripts/ai_plan_actions.gd")
func _initialize():
 var s=S.migrate(JSON.parse_string(FileAccess.get_file_as_string("res://reports/reconstruction/campaign_checkpoint.json")))
 var p=s.civilizations.green
 print("GREEN FLOW ",JSON.stringify(S.R.economy(p)))
 print("GROW ",JSON.stringify(P.grow(p)))
 print("INFRA ",JSON.stringify(P.infrastructure(p,"food")))
 print("BUILDER ",JSON.stringify(P.builder(p,"green_town")))
 print("LOANS ",JSON.stringify(p.ai.loans)," terms ",JSON.stringify(p.ai.jobTerms))
 print("LAST ",JSON.stringify(p.ai.history.slice(-15)))
 print("CONSTRUCTION ",JSON.stringify(p.constructionProject))
 quit()
