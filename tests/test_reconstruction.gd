extends SceneTree
const S=preload("res://scripts/civilization_session.gd")
const R=preload("res://scripts/game_rules.gd")
const A=preload("res://scripts/ai_assessment.gd")
const P=preload("res://scripts/ai_plan_actions.gd")
const L=preload("res://scripts/ai_lieutenant.gd")
const O=preload("res://scripts/ai_operation.gd")
const C=preload("res://scripts/ai_coordinator.gd")
var checks=0
var failures=[]
func check(ok:bool,label:String):
 checks+=1
 if not ok: failures.append(label);printerr("FAIL ",label)
func _initialize():call_deferred("run")
func supplied() -> Dictionary:
 var s=S.initial_state();var p=s.civilizations.red
 C.review(s,p,"red")
 for i in range(3):
  R.new_person(p,"red_town")
  var id=p.cohorts.keys().back();p.cohorts[id].qualification="Soldier"
 R.new_person(p,"red_town")
 var g=O.slots(p);var positions=[S.RED_TOWN]+R.neighbours(p,S.RED_TOWN)
 for i in range(g.force.size()):
  var c=p.cohorts[g.force[i]]
  c.equipment=["small_arms" if i<4 else "flamer"]
  c.state={"kind":"mobile","tileId":positions[1+i/3],"movementRemaining":1.0}
 var guard=p.cohorts[g.guard];guard.equipment=["small_arms"];guard.state={"kind":"mobile","tileId":S.RED_TOWN,"movementRemaining":1.0}
 p.resources.food=2000;p.resources.industry=300;p.resources.energy=300;p.resources.minerals=300
 S.X.sync_tiles(s)
 return s
func replay(report:Dictionary) -> Dictionary:
 var s=report.initial.blue.duplicate(true)
 s.worldVersion=report.initial.worldVersion;s.civilizations={}
 for id in report.initial:
  if id not in ["blue","xenos","worldVersion"]:s.civilizations[id]=report.initial[id].duplicate(true)
 s.xenos=report.initial.xenos.duplicate(true)
 s.testing={"enabled":false,"events":[],"sequence":0,"dropped":0,"initial":{},"outcome":{"status":"in_progress"}}
 for e in report.events:
  var result=S.command_for(s,e.player,e.command,e.policyRule)
  check(result.ok==e.accepted,"Replay acceptance #"+str(e.sequence))
  s=result.state
 return s
func equivalent(a,b) -> bool:
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for k in a:
   if not b.has(k) or not equivalent(a[k],b[k]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in range(a.size()):
   if not equivalent(a[i],b[i]): return false
  return true
 if (a is float or a is int) and (b is float or b is int): return abs(float(a)-float(b))<0.000000001
 return a==b
func run():
 var s=S.initial_state()
 check(S.validate(s)=="","Fresh three-player world valid: "+S.validate(s))
 check(s.schemaVersion==14 and s.worldVersion==4,"Reconstructed versions")
 var focused=S.command_for(s,"blue",{"type":"focusPerson","cohortId":"pop_a"}).state
 check(focused.ai==s.ai,"Unrecorded visual focus does not mutate private AI")
 check(S.players(s).size()==3 and s.civilizations.green.settlements.green_town.tileId=="16,2","Green scenario")
 for id in ["red","green"]:
  var p=S.players(s)[id]
  check(p.cohorts.size()==9,"Five civilians and four disclosed starting troops "+id)
  check(p.cohorts.values().filter(func(c):return "flamer" in c.equipment).size()==1,"One supplied flamer "+id)
 var before=s.civilizations.green.resources.food;s.civilizations.red.resources.food+=5
 check(s.civilizations.green.resources.food==before,"Private resource pools")
 # Old world import must retain its factions, not inject new scenario troops.
 var old=S.initial_state();old.civilizations.erase("green");old.xenos.deaths.erase("green");old.worldVersion=3
 var migrated=S.migrate(JSON.parse_string(JSON.stringify(old)))
 check(S.validate(migrated)=="" and not migrated.civilizations.has("green"),"Old two-player save retained: "+S.validate(migrated))
 var p=s.civilizations.red
 var snapshot=p.duplicate(true)
 var forecast=A.forecast(p)
 check(p==snapshot and forecast.horizon==5,"Read-only forecast")
 var review=S.command_for(s,"red",{"type":"aiReview"},"test_review");s=review.state;p=s.civilizations.red
 snapshot=p.duplicate(true)
 C.choose(s,p,"red")
 check(snapshot==p,"Choosing an intent is read-only")
 check(not p.ai.operation.is_empty() and p.ai.operation.required.rifles==4,"Persistent fixed charter")
 check(p.ai.operation.phase!="deployed","Incomplete force held")
 var supplied_world=supplied();var supplied_player=supplied_world.civilizations.red
 check(S.validate(supplied_world)=="","Explicit supplied fixture valid")
 check(O.readiness(supplied_world,supplied_player).ready,"Whole supplied force ready")
 O.review(supplied_world,supplied_player)
 check(supplied_player.ai.operation.phase=="deployed" and supplied_player.ai.operation.releases==1,"Ready force released")
 var group=supplied_player.ai.operation.force.duplicate()
 var budget_before=O.supply(supplied_player,group,24)
 supplied_player.turn+=8
 var cost=R.economy(supplied_player).delta
 supplied_player.resources.food+=mini(0,cost.food)*8;supplied_player.resources.industry+=mini(0,cost.industry)*8
 check(budget_before.ready and O.supply(supplied_player,group,16).ready,"Approved budget consumption retains decreasing horizon")
 supplied_world=supplied();supplied_player=supplied_world.civilizations.red
 var missing=O.slots(supplied_player).force[0]
 supplied_player.cohorts[missing].equipment=[]
 supplied_player.ai.operation.phase="commission"
 O.review(supplied_world,supplied_player)
 check(supplied_player.ai.operation.phase!="deployed","Forged phase cannot bypass loadout readiness")
 supplied_world=supplied();supplied_player=supplied_world.civilizations.red
 O.review(supplied_world,supplied_player)
 for id in supplied_player.ai.operation.force.slice(0,3):
  S.X.remove_person(supplied_world,S.players(supplied_world),{"id":id,"player":"red","tile":R.person_tile(supplied_player,supplied_player.cohorts[id])})
 O.review(supplied_world,supplied_player)
 check(supplied_player.ai.operation.phase=="recovery","Attrition triggers recovery")
 # Real incoming terrain events update only the owning civilization.
 var learn=S.initial_state();var rp=learn.civilizations.red;var gp=learn.civilizations.green
 var events=[]
 for i in range(3):events.append({"type":"attack","player":"red","soldier":true,"victim":"test","tile":"10,8","damage":25,"health":0 if i==2 else 75,"support":1})
 L.observe(learn,rp,"red",events)
 var key=L.terrain_class(learn.tiles["10,8"])
 check(rp.ai.lieutenant.terrain[key].band==2 and gp.ai.lieutenant.terrain.is_empty(),"Private actual-location terrain memory")
 check(L.validate(rp.ai.lieutenant)=="","Learned state validates")
 var damaged=rp.ai.lieutenant.duplicate(true);damaged.terrain[key].band=0
 check(L.validate(damaged)!="","Inconsistent caution rejected")
 L.observe(learn,rp,"red",events)
 check(rp.ai.lieutenant.retreatHP==70,"Two field deaths increase retreat threshold")
 # Engine commands really spend resources; founding does not create free people.
 var found=S.initial_state();var founder=found.cohorts.pop_rover
 founder.qualification="Worker";founder.state.tileId="6,6";founder.equipment=["work_suit"];founder.state.movementRemaining=1.0
 found.tiles["6,6"].baseTerrain="plains";found.tiles["6,6"].hostiles=0;S.X.sync_tiles(found)
 found.resources.industry=10
 var command={"type":"found","cohortId":founder.id}
 check(S.reason_for(found,"blue",command)=="","Founder has legal separated location")
 var count=found.cohorts.size();var result=S.command_for(found,"blue",command,"test_found")
 check(result.ok and result.state.cohorts.size()==count and result.state.resources.industry==6,"Founding pays and retains same population")
 check(S.validate(result.state)=="","Founded state validates: "+S.validate(result.state))
 # Serialization and replay through actual economic/controller/ecology transitions.
 var game=S.start_recording(S.initial_state())
 for i in range(12):
  game=S.advance_round(game)
  check(S.validate(game)=="","Ordinary round valid "+str(i+1)+": "+S.validate(game))
 var saved=S.migrate(JSON.parse_string(JSON.stringify(game)))
 check(S.validate(saved)=="","JSON round trip validates: "+S.validate(saved))
 var continuation=S.advance_round(game);var restored_continuation=S.advance_round(saved)
 check(equivalent(continuation,restored_continuation),"JSON continuation preserves entire state and private plans")
 var report=S.report(game);var replayed=replay(report)
 check(S.summary(replayed)==S.summary(game),"Replay physical outcome matches")
 for player in S.players(game):check(S.players(replayed)[player].ai==S.players(game)[player].ai,"Replay full private AI matches "+player)
 check(report.droppedEvents==0,"No trace truncation")
 DirAccess.make_dir_recursive_absolute("res://reports/reconstruction")
 FileAccess.open("res://reports/reconstruction/replay_12_rounds.json",FileAccess.WRITE).store_string(JSON.stringify(report))
 FileAccess.open("res://reports/reconstruction/replay_final_state.json",FileAccess.WRITE).store_string(JSON.stringify(game))
 FileAccess.open("res://reports/reconstruction/checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"rounds":12,"commands":report.events.size()},"  "))
 print("RECONSTRUCTION CHECKS ",checks," FAILURES ",failures.size())
 quit(0 if failures.is_empty() else 1)
