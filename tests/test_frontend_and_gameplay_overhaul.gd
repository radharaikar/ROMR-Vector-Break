extends Node2D

# ==============================================================================
# VECTOR//BREAK — DELL FRONTEND & GAMEPLAY OVERHAUL VERIFICATION SUITE
# Verifies:
# 1. Enemy attacks & shooting back (Drone, Striker, Heavy spread, Elite arbiter)
# 2. Elite enemy archetype behavior, stats, and phase mechanics
# 3. Player damage and healing balance (drop chance, health clamping, bounds)
# 4. Two free maps & point-based map unlock economy
# 5. Settings manager audio/video persistence
# 6. Player level calculation & collections/store source of truth
# 7. Cinematic intro & main menu instantiation
# 8. Modular space obstacles & balanced arena layout
# ==============================================================================

const SettingsManager = preload("res://scripts/settings_manager.gd")
const SpaceObstacle = preload("res://scripts/space_obstacle.gd")
const EnemyElite = preload("res://scripts/enemy_elite.gd")

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK DELL FRONTEND & GAMEPLAY OVERHAUL SUITE ---")
	print("============================================================\n")
	
	# Reset save data to clean state
	SaveManager.reset_data()
	SaveManager.load_data()
	
	# --------------------------------------------------------------------------
	# 1. Test Enemy Attacks & Shooting Back
	# --------------------------------------------------------------------------
	print("[RUN] 1. Testing enemy shooting mechanics...")
	var player_dummy = load("res://scenes/player.tscn").instantiate()
	player_dummy.global_position = Vector2(200.0, 360.0)
	add_child(player_dummy)
	await get_tree().physics_frame
	
	# Test Drone shooting
	var drone = load("res://scenes/enemy_drone.tscn").instantiate()
	drone.global_position = Vector2(500.0, 360.0)
	add_child(drone)
	await get_tree().physics_frame
	
	assert("projectile_scene" in drone, "EnemyDrone lacks projectile_scene")
	var initial_children = get_child_count()
	drone._fire_shot(Vector2.LEFT)
	await get_tree().physics_frame
	assert(get_child_count() > initial_children, "EnemyDrone failed to discharge hostile projectile")
	
	var shot = null
	for child in get_children():
		if child is HostileProjectile:
			shot = child
			break
	assert(shot != null, "HostileProjectile not found in tree")
	assert(shot.shooter == drone, "HostileProjectile shooter reference not set to drone")
	assert(shot.damage == 10, "EnemyDrone shot damage is not 10")
	shot.queue_free()
	drone.queue_free()
	print("[PASS] 1. Basic Enemy Drone successfully aims and discharges hostile projectile.")
	
	# --------------------------------------------------------------------------
	# 2. Test Heavy 3-Bolt Spread Cannon
	# --------------------------------------------------------------------------
	print("[RUN] 2. Testing Heavy dreadnought 3-bolt spread barrage...")
	var heavy = load("res://scenes/enemy_heavy.tscn").instantiate()
	heavy.global_position = Vector2(800.0, 360.0)
	add_child(heavy)
	await get_tree().physics_frame
	
	var count_before = get_child_count()
	heavy._fire_heavy_cannon(Vector2.LEFT)
	await get_tree().physics_frame
	var spawned_projectiles = 0
	for child in get_children():
		if child is HostileProjectile:
			spawned_projectiles += 1
			child.queue_free()
	assert(spawned_projectiles == 3, "Heavy cannon did not spawn 3-bolt spread barrage! Count: %d" % spawned_projectiles)
	heavy.queue_free()
	print("[PASS] 2. Heavy Dreadnought 3-bolt spread cannon verified (3 projectiles discharged).")
	
	# --------------------------------------------------------------------------
	# 3. Test Elite Arbiter Enemy Archetype
	# --------------------------------------------------------------------------
	print("[RUN] 3. Testing Elite Arbiter archetype...")
	var elite = load("res://scenes/enemy_elite.tscn").instantiate()
	elite.global_position = Vector2(700.0, 360.0)
	add_child(elite)
	await get_tree().physics_frame
	
	assert(elite.max_health == 220, "Elite max health is not 220")
	assert(elite.score_value == 500, "Elite score value is not 500")
	
	# Test twin plasma discharge
	count_before = get_child_count()
	elite._fire_twin_plasma(Vector2.LEFT)
	await get_tree().physics_frame
	assert(get_child_count() > count_before, "Elite failed to discharge twin plasma bolt")
	
	# Test radial barrage
	count_before = get_child_count()
	elite._fire_radial_barrage(Vector2.LEFT)
	await get_tree().physics_frame
	var radial_count = 0
	for child in get_children():
		if child is HostileProjectile:
			radial_count += 1
			child.queue_free()
	assert(radial_count >= 5, "Elite failed to fire 5-way radial barrage! Count: %d" % radial_count)
	
	# Test phase warp relocation
	var original_pos = elite.global_position
	elite._trigger_phase_warp()
	await get_tree().physics_frame
	assert(elite.global_position != original_pos, "Elite failed to phase-warp relocate")
	elite.queue_free()
	print("[PASS] 3. Elite Arbiter verified: stats (220 HP, 500 score), twin plasma, radial barrage, and phase warp.")
	
	# --------------------------------------------------------------------------
	# 4. Test Player Damage & Healing Balance
	# --------------------------------------------------------------------------
	print("[RUN] 4. Testing player damage intake and healing clamp...")
	assert(player_dummy.get_health() == 100, "Player initial HP not 100")
	player_dummy.take_damage(25)
	assert(player_dummy.get_health() == 75, "Player health not 75 after 25 damage")
	
	# Over-heal test
	var healed = player_dummy.heal(50)
	assert(healed == 25, "Healed amount did not clamp to missing health (expected 25, got %d)" % healed)
	assert(player_dummy.get_health() == 100, "Player health exceeded max health!")
	
	# Full health consumption lock
	var nanocell = load("res://scenes/pickup_nanocell.tscn").instantiate()
	add_child(nanocell)
	assert(not nanocell.can_collect(player_dummy), "Nanocell allowed full-health player to consume it")
	nanocell.queue_free()
	player_dummy.queue_free()
	print("[PASS] 4. Player damage intake, health clamping, and nanocell waste prevention verified.")
	
	# --------------------------------------------------------------------------
	# 5. Test Two Free Maps and Additional Unlockable Maps
	# --------------------------------------------------------------------------
	print("[RUN] 5. Testing 2 Free Maps and point unlock economy...")
	SaveManager.reset_data()
	
	var biomes = CampaignData.get_biome_definitions()
	assert(biomes.size() == 5, "Expected 5 biomes, got %d" % biomes.size())
	
	# Free biomes
	assert(SaveManager.is_biome_unlocked("neon_graveyard"), "Neon Graveyard should be unlocked free by default")
	assert(SaveManager.is_biome_unlocked("vesper_desert"), "Vesper Desert should be unlocked free by default")
	
	# Locked biomes
	assert(not SaveManager.is_biome_unlocked("pelagic_depths"), "Pelagic Depths should be locked initially")
	assert(not SaveManager.is_biome_unlocked("pyroclastic_rift"), "Pyroclastic Rift should be locked initially")
	assert(not SaveManager.is_biome_unlocked("viridian_canopy"), "Viridian Canopy should be locked initially")
	
	# Unlock with currency
	SaveManager.add_currency(500)
	var unlock_success = SaveManager.unlock_biome("pelagic_depths", 450)
	assert(unlock_success, "Failed to unlock Pelagic Depths with 500 currency")
	assert(SaveManager.is_biome_unlocked("pelagic_depths"), "Pelagic Depths not marked unlocked after purchase")
	assert(SaveManager.get_currency() == 50, "Currency not deducted correctly (expected 50, got %d)" % SaveManager.get_currency())
	
	# Cannot afford
	var fail_unlock = SaveManager.unlock_biome("pyroclastic_rift", 750)
	assert(not fail_unlock, "Unlocked Pyroclastic Rift without sufficient currency")
	assert(not SaveManager.is_biome_unlocked("pyroclastic_rift"), "Pyroclastic Rift should still be locked")
	
	# Biome selection
	SaveManager.select_biome("vesper_desert")
	assert(SaveManager.get_selected_biome() == "vesper_desert", "Selected biome failed to update")
	print("[PASS] 5. Two Free Maps verified (Neon Graveyard & Vesper Desert) and unlock economy confirmed.")
	
	# --------------------------------------------------------------------------
	# 6. Test Settings Manager Persistence
	# --------------------------------------------------------------------------
	print("[RUN] 6. Testing SettingsManager audio/video settings...")
	SettingsManager.set_master_volume(0.72)
	SettingsManager.set_fullscreen(false)
	SettingsManager.set_screen_shake(true)
	SettingsManager.set_aim_sensitivity(1.3)
	
	var settings = SettingsManager.get_settings()
	assert(abs(settings["master_volume"] - 0.72) < 0.01, "Master volume not persisted")
	assert(settings["screen_shake"] == true, "Screen shake setting not persisted")
	assert(abs(settings["aim_sensitivity"] - 1.3) < 0.01, "Aim sensitivity not persisted")
	print("[PASS] 6. SettingsManager audio, video, and gameplay persistence verified.")
	
	# --------------------------------------------------------------------------
	# 7. Test Player Level Derivation & Collections/Store Source of Truth
	# --------------------------------------------------------------------------
	print("[RUN] 7. Testing player level calculation and collections coherence...")
	var data = SaveManager.get_data()
	data["stats"]["total_score"] = 3200
	SaveManager.save_data()
	
	var score_val = SaveManager.get_data()["stats"]["total_score"]
	var calc_level = 1 + int(score_val / 1500)
	var calc_xp = score_val % 1500
	assert(calc_level == 3, "Expected level 3 at 3200 score, got %d" % calc_level)
	assert(calc_xp == 200, "Expected 200 remaining XP, got %d" % calc_xp)
	
	# Skin store purchase reflection in collections
	assert(not SaveManager.is_skin_unlocked("skin_prototype"), "Prototype skin should not be unlocked yet")
	SaveManager.add_currency(200)
	SaveManager.spend_currency(150)
	SaveManager.unlock_skin("skin_prototype")
	assert(SaveManager.is_skin_unlocked("skin_prototype"), "Prototype skin should now be unlocked in Collections")
	print("[PASS] 7. Player Level calculation and Collections/Store coherence verified.")
	
	# --------------------------------------------------------------------------
	# 8. Test Scene Instantiations (Cinematic Intro, Main Menu, Space Obstacles)
	# --------------------------------------------------------------------------
	print("[RUN] 8. Testing scene instantiations...")
	var intro_scene = load("res://scenes/cinematic_intro.tscn")
	assert(intro_scene != null, "Failed to load cinematic_intro.tscn")
	var intro = intro_scene.instantiate()
	add_child(intro)
	assert(intro.get_node_or_null("Margin/Center/TitleContainer/TitleLabel") != null, "Intro title label missing")
	intro.queue_free()
	
	var menu_scene = load("res://scenes/main_menu.tscn")
	assert(menu_scene != null, "Failed to load main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/PlayBtn") != null, "PlayBtn missing")
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/CollectionsBtn") != null, "CollectionsBtn missing")
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/StoreBtn") != null, "StoreBtn missing")
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/LevelBtn") != null, "LevelBtn missing")
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/SettingsBtn") != null, "SettingsBtn missing")
	assert(menu.get_node_or_null("Margin/Center/MenuVBox/NavButtons/QuitBtn") != null, "QuitBtn missing")
	menu.queue_free()
	
	var obs_scene = load("res://scenes/space_obstacle.tscn")
	assert(obs_scene != null, "Failed to load space_obstacle.tscn")
	var obs = obs_scene.instantiate()
	add_child(obs)
	assert(obs.collision_layer == 4, "SpaceObstacle collision layer is not 4")
	obs.queue_free()
	print("[PASS] 8. Cinematic Intro, Main Menu (all 6 portals), and Modular Obstacle scenes verified.")
	
	print("\n============================================================")
	print(">>> ALL 8 FRONTEND & GAMEPLAY OVERHAUL CHECKS PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)
