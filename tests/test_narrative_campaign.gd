extends Node

# ==============================================================================
# VECTOR//BREAK — NARRATIVE & CAMPAIGN AUTOMATED TEST SUITE
# Verifies Campaign Act Progression, Save/Reset State, Story Dialogue,
# Prologue Scene, Campaign Mission Selection, Pause & Victory HUD Overlays.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK: NARRATIVE & CAMPAIGN SYSTEM TESTS ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	test_story_acts_and_dialogue()
	test_save_manager_campaign_progression()
	test_campaign_menu_scene()
	test_prologue_scene()
	test_hangar_navigation_and_modal()
	test_hud_pause_and_victory_overlays()
	test_revive_projectile_clear()
	
	print("\n============================================================")
	print(">>> ALL 7 NARRATIVE & CAMPAIGN TESTS PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)

# --- 1. Story Acts Structure & Dialogue Sequences ---
func test_story_acts_and_dialogue() -> void:
	var acts = StoryData.get_campaign_acts()
	assert(acts.size() == 5, "Campaign must have exactly 5 acts (got %d)" % acts.size())
	
	for act in acts:
		assert(act.has("act"), "Act missing 'act' index")
		assert(act.has("title"), "Act missing 'title'")
		assert(act.has("location"), "Act missing 'location'")
		assert(act.has("boss"), "Act missing 'boss'")
		assert(act.has("reward"), "Act missing 'reward'")
		assert(act.has("description"), "Act missing 'description'")
	
	assert(acts[0].act == 1, "First act must be Act 1")
	assert(acts[4].act == 5, "Fifth act must be Act 5")
	
	# Verify dialogue sequences
	var prologue_intro = StoryData.get_dialogue("prologue_intro")
	assert(prologue_intro.size() > 0, "prologue_intro sequence is empty")
	assert(prologue_intro[0].has("speaker"), "Dialogue line missing speaker")
	assert(prologue_intro[0].has("text"), "Dialogue line missing text")
	
	var prologue_mira = StoryData.get_dialogue("prologue_mira_plea")
	assert(prologue_mira.size() > 0, "prologue_mira_plea sequence is empty")
	
	var act1_brief = StoryData.get_dialogue("act1_briefing")
	assert(act1_brief.size() > 0, "act1_briefing sequence is empty")
	
	var act1_vic = StoryData.get_dialogue("act1_victory")
	assert(act1_vic.size() > 0, "act1_victory sequence is empty")
	
	# Character colors
	assert(StoryData.COLOR_KAEL != null, "COLOR_KAEL missing")
	assert(StoryData.COLOR_MIRA != null, "COLOR_MIRA missing")
	assert(StoryData.COLOR_ORACLE != null, "COLOR_ORACLE missing")
	
	print("[PASS] Test 1: Story acts structure and dialogue sequences verified.")

# --- 2. SaveManager Campaign Progression & Reset ---
func test_save_manager_campaign_progression() -> void:
	# Ensure clean state
	SaveManager.reset_campaign_only()
	assert(SaveManager.is_act_unlocked(1) == true, "Act 1 must be unlocked by default")
	assert(SaveManager.is_act_unlocked(2) == false, "Act 2 must be locked initially")
	assert(SaveManager.is_act_completed(1) == false, "Act 1 must not be completed initially")
	
	# Complete Act 1
	SaveManager.complete_act(1)
	assert(SaveManager.is_act_completed(1) == true, "Act 1 must be recorded as completed")
	assert(SaveManager.is_act_unlocked(2) == true, "Act 2 must unlock upon Act 1 completion")
	assert(SaveManager.has_active_save() == true, "has_active_save must return true after progress")
	
	# Simulate upgrades/currency preservation during campaign reset
	var data = SaveManager.get_data()
	data["currency"] = 250
	data["reconstruction_cores"] = 5
	SaveManager.save_data()
	SaveManager.reset_campaign_only()
	
	assert(SaveManager.is_act_completed(1) == false, "Campaign reset must clear completed acts")
	assert(SaveManager.is_act_unlocked(1) == true, "Act 1 must remain unlocked after reset")
	assert(SaveManager.is_act_unlocked(2) == false, "Act 2 must re-lock after reset")
	assert(SaveManager.get_data()["currency"] == 250, "Campaign reset must NOT erase currency")
	assert(SaveManager.get_data()["reconstruction_cores"] == 5, "Campaign reset must NOT erase cores")
	
	print("[PASS] Test 2: SaveManager campaign progression and safe reset verified.")

# --- 3. Campaign Menu Scene & Population ---
func test_campaign_menu_scene() -> void:
	var camp_scene = load("res://scenes/campaign_menu.tscn")
	assert(camp_scene != null, "campaign_menu.tscn failed to load")
	var menu = camp_scene.instantiate()
	add_child(menu)
	
	var act_list = menu.get_node_or_null("Margin/VBox/Body/ActScroll/ActListVBox")
	assert(act_list != null, "ActListVBox container not found in campaign menu")
	assert(act_list.get_child_count() == 5, "ActListVBox should contain 5 act card buttons (got %d)" % act_list.get_child_count())
	
	var mission_title = menu.get_node_or_null("Margin/VBox/Body/DetailPanel/VBox/DetailTitle")
	assert(mission_title != null, "DetailTitle label missing")
	
	var launch_btn = menu.get_node_or_null("Margin/VBox/Body/DetailPanel/VBox/LaunchButton")
	assert(launch_btn != null, "LaunchButton button missing")
	assert(launch_btn.disabled == false, "LaunchButton should be enabled for Act 1")
	
	menu.queue_free()
	print("[PASS] Test 3: Campaign menu hierarchy and act list population verified.")

# --- 4. Prologue Scene Hierarchy ---
func test_prologue_scene() -> void:
	var pro_scene = load("res://scenes/prologue.tscn")
	assert(pro_scene != null, "prologue.tscn failed to load")
	var prologue = pro_scene.instantiate()
	add_child(prologue)
	
	var player = prologue.get_node_or_null("Player")
	assert(player != null, "Player node missing from prologue")
	
	var dialogue_box = prologue.get_node_or_null("StoryDialogue")
	assert(dialogue_box != null, "StoryDialogue missing from prologue")
	
	var target1 = prologue.get_node_or_null("Targets/TargetDrone1")
	assert(target1 != null, "TargetDrone1 missing from prologue targets")
	
	var reflector1 = prologue.get_node_or_null("Reflector45")
	assert(reflector1 != null, "Reflector45 missing from prologue reflectors")
	
	# Clean up player group
	if player.is_in_group("player"):
		player.remove_from_group("player")
	
	prologue.queue_free()
	print("[PASS] Test 4: Prologue scene structure, player, and targets verified.")

# --- 5. Hangar Navigation & New Game Modal ---
func test_hangar_navigation_and_modal() -> void:
	var hangar_scene = load("res://scenes/hangar_menu.tscn")
	assert(hangar_scene != null, "hangar_menu.tscn failed to load")
	var hangar = hangar_scene.instantiate()
	add_child(hangar)
	
	var camp_btn = hangar.get_node_or_null("Margin/HBox/NavVBox/CampaignBtn")
	assert(camp_btn != null, "CampaignBtn button missing in hangar")
	
	var cont_btn = hangar.get_node_or_null("Margin/HBox/NavVBox/ContinueBtn")
	assert(cont_btn != null, "ContinueBtn button missing in hangar")
	
	var new_btn = hangar.get_node_or_null("Margin/HBox/NavVBox/NewGameBtn")
	assert(new_btn != null, "NewGameBtn button missing in hangar")
	
	var modal = hangar.get_node_or_null("NewGameModal")
	assert(modal != null, "NewGameModal node missing in hangar")
	assert(modal.visible == false, "NewGameModal should start hidden")
	
	# Trigger modal
	hangar._on_new_game_pressed()
	assert(modal.visible == true, "NewGameModal should be visible after NewGameBtn pressed")
	
	hangar._on_cancel_new_game()
	assert(modal.visible == false, "NewGameModal should hide on cancel")
	
	hangar.queue_free()
	print("[PASS] Test 5: Hangar campaign button, continue guard, and new game modal verified.")

# --- 6. HUD Pause & Victory Overlays ---
func test_hud_pause_and_victory_overlays() -> void:
	var hud_scene = load("res://scenes/hud.tscn")
	assert(hud_scene != null, "hud.tscn failed to load")
	var hud = hud_scene.instantiate()
	add_child(hud)
	
	assert(hud.process_mode == Node.PROCESS_MODE_ALWAYS, "HUD process_mode must be PROCESS_MODE_ALWAYS for pause menu")
	
	var pause_overlay = hud.get_node_or_null("Control/PauseOverlay")
	assert(pause_overlay != null, "PauseOverlay missing in HUD")
	assert(pause_overlay.visible == false, "PauseOverlay should start hidden")
	assert(pause_overlay.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseOverlay must have process_mode ALWAYS")
	
	var victory_overlay = hud.get_node_or_null("Control/VictoryOverlay")
	assert(victory_overlay != null, "VictoryOverlay missing in HUD")
	assert(victory_overlay.visible == false, "VictoryOverlay should start hidden")
	
	# Test manual pause trigger
	hud._toggle_pause()
	assert(pause_overlay.visible == true, "Pause overlay did not open on pause toggle")
	assert(get_tree().paused == true, "Tree was not paused on pause toggle")
	
	hud._on_resume_pressed()
	assert(pause_overlay.visible == false, "Pause overlay did not close on resume")
	assert(get_tree().paused == false, "Tree remained paused after resume")
	
	# Test victory overlay trigger
	hud._on_victory_requested("act1")
	assert(victory_overlay.visible == true, "Victory overlay did not display on victory request")
	assert(get_tree().paused == true, "Tree was not paused during victory debrief")
	
	# Unpause for subsequent tests
	get_tree().paused = false
	hud.queue_free()
	print("[PASS] Test 6: HUD Pause and Victory overlays verified.")

# --- 7. Projectile Clearing on Revive ---
func test_revive_projectile_clear() -> void:
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	player.current_health = 0
	player.is_dead = true
	
	# Spawn dummy enemy projectiles
	var p1 = Node2D.new()
	p1.name = "EnemyProj1"
	p1.add_to_group("enemy_projectiles")
	add_child(p1)
	
	var p2 = Area2D.new()
	p2.name = "EnemyProj2"
	p2.add_to_group("enemy_projectiles")
	add_child(p2)
	
	var initial_bullets = get_tree().get_nodes_in_group("enemy_projectiles")
	assert(initial_bullets.size() == 2, "Failed to spawn enemy test projectiles")
	
	# Setup GameManager state for revive
	SaveManager.add_reconstruction_core(1)
	GameManager.has_used_revive_this_run = false
	
	var revive_ok = GameManager.execute_revive()
	assert(revive_ok == true, "execute_revive should succeed")
	assert(player.is_dead == false, "Player should be revived")
	assert(player.current_health > 0, "Player should have health restored")
	assert(player.is_invulnerable == true, "Player should have invulnerability window after revive")
	
	# Verify bullet cleanup was queued
	assert(p1.is_queued_for_deletion() == true, "Enemy bullet 1 was not queued for deletion on revive")
	assert(p2.is_queued_for_deletion() == true, "Enemy bullet 2 was not queued for deletion on revive")
	
	player.remove_from_group("player")
	player.queue_free()
	p1.queue_free()
	p2.queue_free()
	print("[PASS] Test 7: Enemy projectile clear on revive verified.")
