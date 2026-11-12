extends SceneTree
const Opening = preload("res://scripts/opening_ui.gd")
var failures = []
var checks = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		push_error(description)

func button(parent: Node, text: String) -> Button:
	for node in parent.find_children("*","Button",true,false):
		if node.accessibility_name == text or node.text == text: return node
	return null

func press(parent: Node, text: String) -> bool:
	var control = button(parent,text)
	if not control or control.disabled: return false
	control.pressed.emit()
	return true

func run() -> void:
	root.size = Vector2i(1920,1080)
	var app = load("res://b09.tscn").instantiate()
	root.add_child(app)
	for i in range(12): await process_frame
	check(app.state.cohorts.size()==4 and app.state.cohorts.pop_a.qualification=="Worker" and app.state.cohorts.pop_b.qualification=="Worker" and app.state.cohorts.guard.qualification=="Soldier" and app.state.cohorts.explorer.qualification=="Explorer","Four intended starting cohorts")
	check(app.state.construction.kits == 1 and app.state.buildings.is_empty() and app.stocks.size()==6,"One reusable kit, minimal settlement and six-resource strip")
	check(app.world.size.x>1500 and app.world.size.y>600,"Map dominates normal 1080p view")
	var colony_key = button(app,"Colony")
	check(colony_key != null and colony_key.text.is_empty() and colony_key.icon != null and button(app,"End Turn  ↵").icon != null,"Map navigation and turn action have command icons")
	var base = app.state.duplicate(true)
	Opening.E.change(app.state,"food",-25)
	app.refresh()
	check(app.stocks.food.text.contains("-"),"Stock strip exposes Food deficit")
	app.request_turn()
	check(app.warn_turn.visible and app.state.turn==base.turn,"End Turn warns and allows proceeding")
	app.warn_turn.hide()
	app.state = base.duplicate(true)
	app.refresh()
	check(press(app,"Colony") and app.contributors.visible and app.details.visible,"Dedicated colony view opens")
	app.choose_person("pop_b",false)
	var work = ""
	for job in Opening.E.jobs(app.state):
		if job.id.begins_with("tile:") and job.id != app.state.cohorts.pop_b.state.job and Opening.E.reason(app.state,{"type":"assign","person":"pop_b","job":job.id})=="":
			work = job.id.substr(5)
			break
	app.select_tile(work)
	check(press(app.right_content,"Work selected hex · "+work) and app.state.cohorts.pop_b.state.job=="tile:"+work,"Reassign worker using selected hex")
	var site = ""
	for key in app.state.knowledge.visible:
		if Opening.E.reason(app.state,{"type":"enqueue","recipe":"farm","tile":key})=="":
			site = key
			break
	app.select_tile(site)
	var choices = app.right_content.find_children("*","Button",true,false).filter(func(item): return item.has_meta("build_recipe"))
	check(choices.size() == 4 and choices.all(func(item): return item.text == "" and item.icon != null),"Colony presents four illustrated build choices")
	var greenhouse = choices.filter(func(item): return item.get_meta("build_recipe") == "greenhouse")
	if not greenhouse.is_empty(): greenhouse[0].pressed.emit()
	var blocked_queue = button(app.right_content,"Queue project")
	check(blocked_queue.disabled and blocked_queue.tooltip_text.contains("Agriculture district"),"Build tray explains blocked choices without queuing them")
	for choice in app.right_content.find_children("*","Button",true,false):
		if choice.get_meta("build_recipe","") == "farm":
			choice.pressed.emit()
			break
	check(button(app.right_content,"Queue project").text.is_empty() and button(app.right_content,"Queue project").icon != null,"Queue command uses its icon and action name")
	check(press(app.right_content,"Queue project"),"Queue project from colony")
	check(press(app.right_content,"Hold") and app.state.construction.queue[0].held,"Hold work in project list")
	check(press(app.right_content,"Resume") and not app.state.construction.queue[0].held,"Resume work in project list")
	app.show_mode("Map")
	app.choose_person("explorer")
	app.select_tile("1,3")
	var identify = button(app.commands,"Identify")
	check(identify.text.is_empty() and identify.icon != null and identify.tooltip_text.begins_with("Identify"),"Explorer actions keep names in hover help")
	check(app.tile_info.text.contains("Unidentified signal"),"Inspect signal without revealing its identity")
	var before = JSON.stringify(app.state)
	app.world.move_preview.emit("1,3")
	check(app.preview_info.text.begins_with("Move to") and app.world.preview_route.size()>1 and JSON.stringify(app.state)==before,"Safe movement preview draws route without spending")
	var escape = InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	app._unhandled_key_input(escape)
	check(app.pending_move=="" and app.world.preview_route.is_empty(),"Escape cancels pending order")
	app.world.move_requested.emit("1,3",false)
	check(app.state.cohorts.explorer.state.tileId=="1,3" or app.state.movementQueues.has("explorer"),"Release orders normal movement")
	check(press(app,"Research") and app.right_content.find_children("*","Button",true,false).size()==2,"Research cards show both technologies")
	check(press(app,"Alienopedia") and app.right_content.get_child_count()>1,"Alienopedia opens with guidance")
	app.archive_page = "Wildlife"
	app.refresh_selection()
	check(app.right_content.get_child(1).text.contains("after a sighting"),"Unseen wildlife remains undisclosed")
	check(Opening.Tactical.validate(JSON.parse_string(JSON.stringify(app.state)))=="","Integrated opening roundtrips through save validation")
	app.state = base.duplicate(true)
	app.refresh()
	for i in range(4): app.send({"type":"endTurn"})
	check(app.state.resources.food>=0,"Default opening can sustain four quiet turns")
	var automated = base.duplicate(true)
	automated = Opening.Tactical.command(automated,{"type":"enqueue","recipe":"farm","tile":site}).state
	automated = Opening.Tactical.command(automated,{"type":"planning","enabled":true}).state
	for i in range(7):
		if automated.construction.queue[0].status == "complete": break
		automated = Opening.Tactical.command(automated,{"type":"endTurn"}).state
	check(automated.improvements.get(site,{}).get("farm",false) and automated.resources.food>=0,"Normal opening automates a Farm while maintaining Food")
	var before_lab = JSON.stringify(app.state)
	check(press(app,"Model Lab"),"Field kit opens from the game")
	for i in range(120):
		if app.model_lab.built: break
		await process_frame
	if app.model_lab.built:
		var lab = app.model_lab
		var fitted = lab.catalogue_actor.get_child_count()
		lab.irrigation_choice.button_pressed = false
		check(lab.irrigation_choice.visible and lab.catalogue_actor.get_child_count() < fitted,"Farm kit toggles the pump and pipes in the catalogue")
		var advance = InputEventKey.new()
		advance.keycode = KEY_ENTER
		advance.pressed = true
		app._unhandled_key_input(advance)
		app._unhandled_key_input(escape)
		check(not app.world.suspended and JSON.stringify(app.state)==before_lab,"Model Lab keeps game shortcuts isolated and Escape resumes the map")
	else:
		check(false,"Field kit builds in Model Lab")
	app.free()
	print(JSON.stringify({"suite":"B09","checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
