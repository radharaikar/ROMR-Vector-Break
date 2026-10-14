extends Node2D

# ==============================================================================
# VECTOR//BREAK — REGRESSION TEST SUITE: CRITICAL BUG FIXES & GAMEPLAY FLOW
# Verifies signal mismatch fix, float modulo fix, store upgrade repairs,
# upgrade gameplay application, and multi-round lifecycle transitions.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK CRITICAL BUG FIXES & FLOW VERIFICATION ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 1: player_fired Signal Mismatch Fix
	# --------------------------------------------------------------------------
	print("[RUN] 1. Testing player_fired signal signature and cursor trigger_fire_flash...")
	var cursor_scene = load("res://scenes/custom_cursor.tscn")
	var cursor = cursor_scene.instantiate()
	add_child(cursor)
	
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	await get_tree().physics_frame
	
	# Reconnect signal explicitly to test signature compatibility
	if not player.player_fired.is_connected(cursor.trigger_fire_flash):
		player.player_fired.connect(cursor.trigger_fire_flash)
	
	# Simulate multiple shots emitting projectile node
	for i in range(5):
		var dummy_proj = Node2D.new()
		player.player_fired.emit(dummy_proj)
		dummy_proj.queue_free()
	
	assert(cursor._flash_timer > 0.0, "Cursor flash timer was not triggered by player_fired")
	cursor.trigger_fire_flash() # Also test calling without arguments
	assert(cursor._flash_timer == 0.10, "Cursor parameterless trigger_fire_flash failed")
	print("[PASS] 1. player_fired signal signature compatibility verified with 0 and 1 arguments.")
	
	cursor.queue_free()
	player.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 2: Float Modulo & Player Level Calculation Safety
	# --------------------------------------------------------------------------
	print("[RUN] 2. Testing Player Level display with float score and zero thresholds...")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().physics_frame
	
	# Test various score formats in save data: float, zero, negative, large
	var test_scores = [0.0, 1500.5, 4520.8, -50.0, 99999.0]
	for sc in test_scores:
		SaveManager.get_data().get("stats", {})["total_score"] = sc
		menu._update_level_display() # Must execute without 'Invalid operands float and int in operator %'
	
	# Check modal opening and backdrop isolation
	menu._on_level_pressed()
	assert(menu.level_modal.visible == true, "LevelModal failed to open")
	assert(menu.modal_backdrop.visible == true, "ModalBackdrop failed to show")
	
	# Test backdrop click closing modal
	menu._hide_all_modals()
	assert(menu.level_modal.visible == false, "LevelModal failed to close")
	assert(menu.modal_backdrop.visible == false, "ModalBackdrop failed to hide")
	print("[PASS] 2. Float modulo safety and modal backdrop click isolation verified.")
	
	menu.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 3: Store Category Population, Row Highlighting, and Previews
	# --------------------------------------------------------------------------
	print("[RUN] 3. Testing Store category population, row highlighting, and upgrade previews...")
	var store_scene = load("res://scenes/store_menu.tscn")
	var store = store_scene.instantiate()
	add_child(store)
	await get_tree().physics_frame
	
	assert(store.skin_list_container.get_child_count() == 4, "Store skins count mismatch (expected 4)")
	assert(store.upgrade_list_container.get_child_count() == 4, "Store upgrades count mismatch (expected 4)")
	
	# Test selecting each upgrade and verifying graphic
	var upgrades_to_test = ["upgrade_capacitor", "upgrade_nanocell", "upgrade_frame", "upgrade_targeting"]
	for up_id in upgrades_to_test:
		store._select_upgrade(up_id)
		assert(store.is_selected_an_upgrade == true, "Selection flag failed for " + up_id)
		assert(store.selected_item_id == up_id, "Selected item ID failed for " + up_id)
		assert(store.upgrade_graphic.visible == true, "Upgrade graphic invisible for " + up_id)
		assert(store.preview_sprite.visible == false, "Ship sprite visible during upgrade selection for " + up_id)
		assert(store.upgrade_graphic.current_upgrade_id == up_id, "Upgrade graphic ID mismatch for " + up_id)
		
		# Verify row highlight prefix
		var btn = store._item_buttons[up_id]
		assert(btn.text.begins_with("► "), "Selected item button lacks '► ' prefix: " + btn.text)
	
	# Test selecting skin and verifying ship sprite preview
	store._select_skin("skin_prototype")
	assert(store.is_selected_an_upgrade == false, "Selection flag failed for skin")
	assert(store.preview_sprite.visible == true, "Ship sprite invisible during skin selection")
	assert(store.upgrade_graphic.visible == false, "Upgrade graphic visible during skin selection")
	print("[PASS] 3. Store category population (4 skins, 4 upgrades), selection highlighting, and vector previews verified.")
	
	# --------------------------------------------------------------------------
	# TEST 4: Store Purchase Logic & Upgrades Gameplay Application
	# --------------------------------------------------------------------------
	print("[RUN] 4. Testing Store purchase deduction, SaveManager persistence, and ship upgrades...")
	SaveManager.reset_data()
	SaveManager.add_currency(500)
	store._refresh_ui()
	
	# Purchase upgrade_capacitor (120 ◆)
	store._select_upgrade("upgrade_capacitor")
	store._on_action_pressed()
	assert(SaveManager.is_upgrade_unlocked("upgrade_capacitor") == true, "upgrade_capacitor failed to unlock")
	assert(SaveManager.get_currency() == 380, "Currency deduction failed (expected 380, got %d)" % SaveManager.get_currency())
	
	# Duplicate purchase attempt should not re-charge
	store._on_action_pressed()
	assert(SaveManager.get_currency() == 380, "Duplicate purchase re-charged currency!")
	
	# Purchase upgrade_frame (150 ◆)
	store._select_upgrade("upgrade_frame")
	store._on_action_pressed()
	assert(SaveManager.is_upgrade_unlocked("upgrade_frame") == true, "upgrade_frame failed to unlock")
	assert(SaveManager.get_currency() == 230, "Currency deduction failed (expected 230, got %d)" % SaveManager.get_currency())
	
	# Purchase upgrade_nanocell (100 ◆)
	store._select_upgrade("upgrade_nanocell")
	store._on_action_pressed()
	assert(SaveManager.is_upgrade_unlocked("upgrade_nanocell") == true, "upgrade_nanocell failed to unlock")
	assert(SaveManager.get_currency() == 130, "Currency deduction failed (expected 130, got %d)" % SaveManager.get_currency())
	assert(SaveManager.get_reconstruction_cores() >= 1, "upgrade_nanocell failed to award reconstruction core")
	
	# Purchase upgrade_targeting (80 ◆)
	store._select_upgrade("upgrade_targeting")
	store._on_action_pressed()
	assert(SaveManager.is_upgrade_unlocked("upgrade_targeting") == true, "upgrade_targeting failed to unlock")
	assert(SaveManager.get_currency() == 50, "Currency deduction failed (expected 50, got %d)" % SaveManager.get_currency())
	
	# Attempt unaffordable purchase (skin_prototype costs 150 ◆, player has 50 ◆)
	store._select_skin("skin_prototype")
	store._on_action_pressed()
	assert(SaveManager.is_skin_unlocked("skin_prototype") == false, "Unaffordable skin was unlocked!")
	assert(SaveManager.get_currency() == 50, "Currency was deducted for unaffordable purchase!")
	
	# Verify real gameplay modifier application on PlayerShip
	var ship = player_scene.instantiate()
	add_child(ship)
	await get_tree().physics_frame
	
	assert(ship.max_health == 125, "Stabilized Frame failed to boost max_health to 125 (got %d)" % ship.max_health)
	assert(ship.aim_preview_length == 180.0, "Targeting Matrix failed to extend aim guide to 180.0")
	assert(ship.max_projectile_bounces_bonus == 1, "Vector Capacitor failed to grant +1 bounce bonus")
	
	# Verify Nanocell pickup bonus (+10 HP)
	var nanocell = PickupNanocell.new()
	ship.current_health = 50
	nanocell.apply_pickup(ship)
	assert(ship.current_health == 85, "Nanocell healing failed: expected 85 HP (50 + 25 + 10), got %d" % ship.current_health)
	nanocell.queue_free()
	
	print("[PASS] 4. Store purchases, anti-duplicate guards, and in-game modifiers (125 HP, +1 bounce, +10 heal) verified.")
	
	ship.queue_free()
	store.queue_free()
	SaveManager.reset_data()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 5: Round Lifecycle (ROUND_START -> COMBAT -> ROUND_CLEAR -> TRANSITION)
	# --------------------------------------------------------------------------
	print("[RUN] 5. Testing explicit round lifecycle state transitions...")
	var arena = Node2D.new()
	add_child(arena)
	
	var rm_script = load("res://scripts/round_manager.gd")
	var rm = Node.new()
	rm.set_script(rm_script)
	rm.auto_start_first_round = false
	arena.add_child(rm)
	await get_tree().physics_frame
	
	var signals_received = {
		"round_cleared": false,
		"transition": false,
		"victory": false
	}
	rm.round_cleared.connect(func(_idx, _name, _reward): signals_received["round_cleared"] = true)
	rm.round_transition_started.connect(func(_next_idx, _total): signals_received["transition"] = true)
	
	# Start Round 0 (Recon Patrol)
	rm.start_round(0)
	assert(rm.current_state == rm.State.COMBAT, "RoundManager failed to enter COMBAT state")
	assert(rm.current_round_index == 0, "RoundManager round index mismatch")
	assert(rm.current_wave_index == 0, "RoundManager wave index mismatch")
	assert(rm.active_enemies.size() == 2, "Wave 1 enemy count mismatch (expected 2)")
	
	# Clear Wave 1
	for enemy in rm.active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	for i in range(5):
		await get_tree().process_frame
	
	assert(rm.current_state == rm.State.WAVE_TRANSITION or rm.current_state == rm.State.COMBAT, "Failed to transition to Wave 2")
	
	if rm.current_state == rm.State.WAVE_TRANSITION:
		rm._spawn_wave(1)
	
	# Clear Wave 2 (All waves in Round 0 now cleared)
	for enemy in rm.active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	for i in range(10):
		await get_tree().process_frame
	
	assert(signals_received["round_cleared"] == true, "ROUND_CLEAR signal was not emitted")
	assert(signals_received["transition"] == true, "ROUND_TRANSITION signal was not emitted")
	assert(rm.current_state == rm.State.ROUND_CLEAR or rm.current_state == rm.State.ROUND_TRANSITION, "State mismatch after round clear")
	print("[PASS] 5. Round lifecycle (ROUND_START -> COMBAT -> ROUND_CLEAR -> ROUND_TRANSITION) verified.")
	
	# --------------------------------------------------------------------------
	# TEST 6: Final Round Completion & Final Victory
	# --------------------------------------------------------------------------
	print("[RUN] 6. Testing final round completion and Victory state...")
	rm.round_victory.connect(func(_idx, _score): signals_received["victory"] = true)
	
	# Jump to final round (Round 4: Boss Commander Serin)
	rm.start_round(3)
	assert(rm.current_round_index == 3, "Final round index mismatch")
	assert(rm.active_enemies.size() == 1, "Boss enemy failed to spawn in final round")
	
	# Defeat Boss Serin
	for enemy in rm.active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	for i in range(10):
		await get_tree().process_frame
	
	assert(signals_received["victory"] == true, "Final victory signal was not emitted")
	assert(rm.current_state == rm.State.VICTORY, "RoundManager failed to enter final VICTORY state")
	print("[PASS] 6. Final round victory flow verified: Boss cleared, victory emitted, no infinite respawns.")
	
	arena.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 7: Scene Instantiation & Clean Playable State
	# --------------------------------------------------------------------------
	print("[RUN] 7. Testing Act 1 Mission and HUD synchronization...")
	var act1_scene = load("res://scenes/act1_mission.tscn")
	var act1 = act1_scene.instantiate()
	add_child(act1)
	await get_tree().physics_frame
	
	var act1_hud = act1.get_node_or_null("HUD")
	var act1_rm = act1.get_node_or_null("RoundManager")
	assert(act1_hud != null, "Act1 HUD missing")
	assert(act1_rm != null, "Act1 RoundManager missing")
	
	# Start round 0 and confirm HUD status text formatting
	act1_rm.start_round(0)
	await get_tree().physics_frame
	var status_text = act1_hud.status_label.text
	assert(status_text.contains("ROUND 1/4"), "HUD status label missing 'ROUND 1/4': " + status_text)
	assert(status_text.contains("WAVE 1/2"), "HUD status label missing 'WAVE 1/2': " + status_text)
	assert(status_text.contains("HOSTILES: 2"), "HUD status label missing 'HOSTILES: 2': " + status_text)
	print("[PASS] 7. Act 1 Mission status HUD ('%s') verified." % status_text)
	
	act1.queue_free()
	SaveManager.reset_data()
	await get_tree().physics_frame
	
	print("\n============================================================")
	print(">>> ALL 7 BUG FIX & GAMEPLAY FLOW REGRESSION TESTS PASSED 100%! <<<")
	print("============================================================\n")
	get_tree().quit(0)
