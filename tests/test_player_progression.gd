extends Node

# ==============================================================================
# VECTOR//BREAK — PLAYER & PROGRESSION AUTOMATED TEST SUITE
# Verifies Player Health, Invulnerability, Healing, Pickups, Economy,
# Second Chance Revive, Store, Upgrades, Save/Load, and Story Presentation.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK: PLAYER & PROGRESSION SYSTEM TESTS ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	test_health_and_single_death()
	await test_damage_cooldown_and_invulnerability()
	test_healing_and_clamping()
	test_pickup_and_anti_duplicate()
	test_currency_and_transaction_guards()
	await test_revive_second_chance()
	test_store_purchase_and_skins()
	test_save_load_and_corrupt_fallback()
	test_story_transmissions_and_briefings()
	await test_hud_data_synchronization()
	
	print("\n============================================================")
	print(">>> ALL 10 PLAYER & PROGRESSION TESTS PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)

# --- 1. Health Clamping & Single Death Event ---
func test_health_and_single_death() -> void:
	var player_scene = load("res://scenes/player.tscn")
	assert(player_scene != null, "Player scene failed to load")
	var player: PlayerShip = player_scene.instantiate()
	add_child(player)
	
	var death_events = [0]
	player.player_died.connect(func(): death_events[0] += 1)
	
	assert(player.current_health == player.max_health, "Initial health not equal to max_health")
	
	# Deal non-lethal damage
	var hit1 = player.take_damage(30)
	assert(hit1 == true, "take_damage should succeed on first hit")
	assert(player.current_health == 70, "Health not reduced correctly (expected 70, got %d)" % player.current_health)
	assert(death_events[0] == 0, "Death triggered prematurely")
	
	# Bypass invulnerability for lethal test
	player.is_invulnerable = false
	var hit2 = player.take_damage(150) # Exceeds remaining 70 HP
	assert(hit2 == true, "take_damage should succeed")
	assert(player.current_health == 0, "Health did not clamp to 0 (got %d)" % player.current_health)
	assert(player.is_dead == true, "is_dead flag should be true")
	assert(death_events[0] == 1, "Death event was not emitted")
	
	# Attempt additional damage while dead
	var hit3 = player.take_damage(50)
	assert(hit3 == false, "Dead player should reject damage")
	assert(death_events[0] == 1, "Death event fired multiple times!")
	
	player.remove_from_group("player")
	player.queue_free()
	print("[PASS] Test 1: Health clamping and single death event verified.")

# --- 2. Damage Cooldown & Invulnerability ---
func test_damage_cooldown_and_invulnerability() -> void:
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	
	player.take_damage(20)
	assert(player.is_invulnerable == true, "Player should be invulnerable after taking damage")
	
	# Rapid second hit must be blocked
	var hit_blocked = player.take_damage(20)
	assert(hit_blocked == false, "Damage during invulnerability was not blocked")
	assert(player.current_health == 80, "Health decreased during invulnerability window")
	
	# Wait for invulnerability to expire
	player.invulnerability_timer = 0.05
	for i in range(5):
		await get_tree().physics_frame
	
	# Artificially trigger process frame completion
	player.invulnerability_timer = 0.0
	player._process(0.1)
	assert(player.is_invulnerable == false, "Invulnerability did not reset")
	
	player.remove_from_group("player")
	player.queue_free()
	print("[PASS] Test 2: Damage cooldown and invulnerability window verified.")

# --- 3. Healing & Clamping ---
func test_healing_and_clamping() -> void:
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	
	player.current_health = 40
	var healed = player.heal(35)
	assert(healed == 35, "Expected 35 HP healed, got %d" % healed)
	assert(player.current_health == 75, "Expected 75 HP, got %d" % player.current_health)
	
	# Over-healing clamps to max_health
	var over_healed = player.heal(50)
	assert(over_healed == 25, "Over-heal should return actual delta (expected 25, got %d)" % over_healed)
	assert(player.current_health == player.max_health, "Health exceeded max_health")
	
	# Dead player cannot be healed via ordinary heal()
	player.is_dead = true
	var dead_heal = player.heal(50)
	assert(dead_heal == 0, "Dead player should not receive healing")
	
	player.remove_from_group("player")
	player.queue_free()
	print("[PASS] Test 3: Healing and max-health clamping verified.")

# --- 4. Pickup Collection & Waste Prevention ---
func test_pickup_and_anti_duplicate() -> void:
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	
	var nanocell: PickupNanocell = load("res://scenes/pickup_nanocell.tscn").instantiate()
	add_child(nanocell)
	
	# Full health player should NOT consume nanocell
	player.current_health = player.max_health
	assert(nanocell.can_collect(player) == false, "Full-health player should not waste nanocell")
	
	# Damaged player can collect nanocell
	player.current_health = 60
	assert(nanocell.can_collect(player) == true, "Damaged player should be able to collect nanocell")
	
	nanocell._try_collect(player)
	assert(player.current_health == 85, "Nanocell did not heal player by 25 HP (got %d)" % player.current_health)
	assert(nanocell.is_collected == true, "Pickup is_collected flag not set")
	
	# Duplicate collection attempt must be blocked
	nanocell._try_collect(player)
	assert(player.current_health == 85, "Duplicate pickup collection occurred!")
	
	player.remove_from_group("player")
	player.queue_free()
	nanocell.queue_free()
	print("[PASS] Test 4: Pickup collection, full-health waste prevention, and duplicate lock verified.")

# --- 5. Currency Earning, Spending & Anti-Duplicate Transactions ---
func test_currency_and_transaction_guards() -> void:
	var gm = get_node_or_null("/root/GameManager")
	assert(gm != null, "GameManager not found")
	
	SaveManager.reset_data()
	assert(gm.get_currency() == 0, "Initial currency after reset is not 0")
	
	# Award currency with transaction ID
	var bal1 = gm.award_currency(60, "tx_wave_1")
	assert(bal1 == 60, "Currency did not increase to 60")
	
	# Duplicate transaction must be ignored
	var bal2 = gm.award_currency(60, "tx_wave_1")
	assert(bal2 == 60, "Duplicate transaction was awarded!")
	
	# Valid purchase
	var spend_success = gm.spend_currency(40)
	assert(spend_success == true, "Valid purchase of 40 was rejected")
	assert(gm.get_currency() == 20, "Balance after spend is not 20")
	
	# Over-budget purchase must be rejected
	var spend_fail = gm.spend_currency(100)
	assert(spend_fail == false, "Over-budget purchase of 100 was accepted!")
	assert(gm.get_currency() == 20, "Balance changed after failed purchase")
	
	print("[PASS] Test 5: Currency earning, spending, and anti-duplicate transaction guards verified.")

# --- 6. Revive / Second Chance System ---
func test_revive_second_chance() -> void:
	var gm = get_node_or_null("/root/GameManager")
	
	# Wait a frame for old queue_free nodes to leave tree
	await get_tree().physics_frame
	
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	
	SaveManager.reset_data()
	gm.has_used_revive_this_run = false
	
	# Deal lethal damage
	player.current_health = 0
	player.is_dead = true
	
	assert(gm.can_revive() == true, "Player should be eligible for revive with default core")
	var revive_ok = gm.execute_revive()
	assert(revive_ok == true, "execute_revive failed")
	assert(player.is_dead == false, "Player is still flagged as dead after revive")
	assert(player.current_health == 50, "Player health after revive is not 50 HP (got %d)" % player.current_health)
	assert(player.is_invulnerable == true, "Player not granted post-revive invulnerability")
	assert(SaveManager.get_reconstruction_cores() == 0, "Reconstruction core was not deducted")
	
	# Second revive in same run must be rejected
	assert(gm.can_revive() == false, "Second revive allowed in same run!")
	
	player.remove_from_group("player")
	player.queue_free()
	print("[PASS] Test 6: Second chance revive mechanics and single-use limit verified.")

# --- 7. Store Purchase, Skins & Upgrades ---
func test_store_purchase_and_skins() -> void:
	SaveManager.reset_data()
	SaveManager.add_currency(300)
	
	# Buy and equip Prototype skin
	assert(SaveManager.is_skin_unlocked("skin_prototype") == false, "Prototype skin already unlocked")
	var spend_ok = SaveManager.spend_currency(150)
	assert(spend_ok == true, "Failed to spend for skin")
	SaveManager.unlock_skin("skin_prototype")
	assert(SaveManager.is_skin_unlocked("skin_prototype") == true, "Prototype skin not marked unlocked")
	
	var equip_ok = SaveManager.equip_skin("skin_prototype")
	assert(equip_ok == true, "Failed to equip unlocked skin")
	assert(SaveManager.get_equipped_skin() == "skin_prototype", "Equipped skin mismatch")
	
	# Unlock Stabilized Frame upgrade (+25 Max HP)
	SaveManager.unlock_upgrade("upgrade_frame")
	assert(SaveManager.is_upgrade_unlocked("upgrade_frame") == true, "Upgrade not unlocked")
	
	# Instantiate player to verify stat modification
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	assert(player.max_health == 125, "Player max_health did not reflect Stabilized Frame upgrade (got %d)" % player.max_health)
	assert(player.current_skin_id == "skin_prototype", "Player did not equip prototype skin")
	
	player.remove_from_group("player")
	player.queue_free()
	print("[PASS] Test 7: Store purchase, skin equipping, and upgrade modifiers verified.")

# --- 8. Save / Load & Corrupted Fallback ---
func test_save_load_and_corrupt_fallback() -> void:
	var test_path = "user://test_audit_save.json"
	SaveManager.reset_data(test_path)
	SaveManager.add_currency(180)
	SaveManager.save_data(test_path)
	
	# Clean reload
	SaveManager.current_data.clear()
	var load_ok = SaveManager.load_data(test_path)
	assert(load_ok == true, "Failed to load valid save file")
	assert(SaveManager.get_currency() == 180, "Loaded currency does not match saved currency")
	
	# Corrupt file test
	var file = FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string("{MALFORMED_JSON_CORRUPTION_TEST:::")
	file.close()
	
	var corrupt_load = SaveManager.load_data(test_path)
	assert(corrupt_load == false, "Corrupted file reported successful load")
	assert(SaveManager.get_currency() == 0, "Corrupted file did not reset to safe defaults")
	
	# Missing file test
	var missing_load = SaveManager.load_data("user://non_existent_save_file.json")
	assert(missing_load == false, "Missing file reported successful load")
	assert(SaveManager.get_currency() == 0, "Missing file did not initialize defaults")
	
	# Cleanup test file
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)
	
	print("[PASS] Test 8: Save/Load persistence and corrupt/missing file fallback verified.")

# --- 9. Story Transmissions & Briefings ---
func test_story_transmissions_and_briefings() -> void:
	var prologue = StoryData.get_dialogue("prologue")
	assert(prologue.size() >= 3, "Prologue dialogue missing expected sequence")
	assert(prologue[1]["speaker"].begins_with("MIRA"), "Prologue missing Mira transmission")
	
	var briefing = StoryData.get_dialogue("act1_briefing")
	assert(briefing.size() >= 2, "Act 1 briefing missing sequence")
	
	var ending = StoryData.get_dialogue("act1_victory")
	assert(ending.size() >= 2, "Act 1 victory debrief missing sequence")
	
	print("[PASS] Test 9: Story transmissions, briefings, and narrative dialogues verified.")

# --- 10. HUD Real-Time Data Synchronization ---
func test_hud_data_synchronization() -> void:
	SaveManager.reset_data() # Reset defaults so max_health is 100
	await get_tree().physics_frame
	
	var hud_scene = load("res://scenes/hud.tscn")
	assert(hud_scene != null, "HUD scene failed to load")
	var hud: ArcadeHUD = hud_scene.instantiate()
	add_child(hud)
	
	var player: PlayerShip = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	
	hud._connect_player()
	
	# Simulate health changes: 100 - 60 = 40
	player.take_damage(60)
	assert(hud.health_bar.value == 40, "HUD health bar not synchronized (expected 40, got %f)" % hud.health_bar.value)
	assert(hud.critical_warning.visible == false, "Critical warning active prematurely at 40%")
	
	player.is_invulnerable = false
	player.take_damage(25) # 40 - 25 = 15 (15% <= 25%)
	assert(hud.health_bar.value == 15, "HUD health bar not updated to 15 (got %f)" % hud.health_bar.value)
	assert(hud.critical_warning.visible == true, "Critical warning did not activate at <= 25% HP")
	
	player.remove_from_group("player")
	player.queue_free()
	hud.queue_free()
	print("[PASS] Test 10: HUD real-time health and warning synchronization verified.")
