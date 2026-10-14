extends Node2D

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK: VERTICAL SLICE FLOW VERIFICATION ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	
	# 1. Verify Hangar Menu Scene
	var hangar_scene = load("res://scenes/hangar_menu.tscn")
	assert(hangar_scene != null, "Failed to load hangar_menu.tscn")
	var hangar = hangar_scene.instantiate()
	add_child(hangar)
	await get_tree().physics_frame
	
	assert(hangar.get_node_or_null("Margin/HBox/NavVBox/NewGameBtn") != null, "NewGameBtn missing")
	assert(hangar.get_node_or_null("Margin/HBox/NavVBox/StoreBtn") != null, "StoreBtn missing")
	assert(hangar.get_node_or_null("Margin/HBox/NavVBox/BriefingBtn") != null, "BriefingBtn missing")
	assert(hangar.get_node_or_null("CampaignModal") != null, "CampaignModal missing")
	print("[PASS] 1. Hangar menu instantiated with all navigation buttons & Campaign Matrix.")
	hangar.queue_free()
	await get_tree().physics_frame
	
	# 2. Verify Prologue Scene
	var prologue_scene = load("res://scenes/prologue.tscn")
	assert(prologue_scene != null, "Failed to load prologue.tscn")
	var prologue = prologue_scene.instantiate()
	add_child(prologue)
	await get_tree().physics_frame
	
	assert(prologue.get_node_or_null("Player") != null, "Player missing from prologue")
	assert(prologue.get_node_or_null("TutorialCanvas/ObjectivePanel") != null, "ObjectivePanel missing")
	assert(prologue.get_node_or_null("CutsceneCanvas/Overlay") != null, "Cutscene overlay missing")
	print("[PASS] 2. Prologue tutorial instantiated with player, objectives, and cataclysm overlay.")
	prologue.queue_free()
	await get_tree().physics_frame
	
	# 3. Verify Act 1 Mission Scene
	var act1_scene = load("res://scenes/act1_mission.tscn")
	assert(act1_scene != null, "Failed to load act1_mission.tscn")
	var act1 = act1_scene.instantiate()
	add_child(act1)
	await get_tree().physics_frame
	
	assert(act1.get_node_or_null("Player") != null, "Player missing from Act 1")
	assert(act1.get_node_or_null("RoundManager") != null, "RoundManager missing from Act 1")
	assert(act1.get_node_or_null("HUD") != null, "HUD missing from Act 1")
	assert(act1.get_node_or_null("StoryDialogue") != null, "StoryDialogue missing from Act 1")
	assert(act1.get_node_or_null("MovingReflector") != null, "MovingReflector hazard missing")
	assert(ResourceLoader.exists("res://scenes/laser_gate.tscn"), "LaserGate scene resource missing")
	assert(act1.get_node_or_null("VictoryCanvas/VictoryOverlay") != null, "VictoryOverlay missing")
	print("[PASS] 3. Act 1 Mission instantiated with RoundManager, hazards, HUD, and victory screen.")
	
	# 4. Verify HUD Pause & Boss Bar features
	var hud = act1.get_node_or_null("HUD")
	assert(hud != null, "HUD node not found")
	assert(hud.get_node_or_null("Control/BossHealthMargin") != null, "BossHealthMargin missing in HUD")
	assert(hud.get_node_or_null("Control/PauseOverlay") != null, "PauseOverlay missing in HUD")
	
	hud.show_boss_health("COMMANDER SERIN", 500)
	assert(hud.get_node_or_null("Control/BossHealthMargin").visible == true, "Boss health margin failed to show")
	hud.update_boss_health(350, 500)
	assert(hud.get_node_or_null("Control/BossHealthMargin/BossPanel/VBox/BossProgressBar").value == 350.0, "Boss progress update failed")
	hud.hide_boss_health()
	assert(hud.get_node_or_null("Control/BossHealthMargin").visible == false, "Boss health margin failed to hide")
	print("[PASS] 4. Boss health bar display, update, and hide cycle verified.")
	
	# 5. Verify Pause Toggle
	hud._toggle_pause()
	assert(hud.get_node_or_null("Control/PauseOverlay").visible == true, "Pause overlay failed to display")
	assert(get_tree().paused == true, "Engine tree failed to pause")
	hud._resume_game()
	assert(hud.get_node_or_null("Control/PauseOverlay").visible == false, "Pause overlay failed to hide on resume")
	assert(get_tree().paused == false, "Engine tree failed to unpause")
	print("[PASS] 5. Pause menu toggle, freeze tree, and resume cycle verified.")
	
	act1.queue_free()
	await get_tree().physics_frame
	
	print("\n============================================================")
	print(">>> ALL VERTICAL SLICE FLOW VERIFICATION CHECKS PASSED 100%! <<<")
	print("============================================================\n")
	get_tree().quit(0)
