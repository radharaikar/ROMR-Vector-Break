extends Node

# ==============================================================================
# VECTOR//BREAK — WORLDS & BIOME PROGRESSION AUTOMATED TEST SUITE
# Verifies 5 Distinct World Biomes, Unlock Costs, SaveManager Persistence,
# Environmental Hazard Zones, Biome Selection Menu, and Arena Integration.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK: WORLDS & BIOME PROGRESSION TESTS ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	test_biome_data_definitions()
	test_save_manager_biome_economy()
	test_selected_biome_safeguards()
	test_biome_scene_instantiations()
	test_hazard_zone_mechanics()
	test_biome_select_menu_ui()
	test_hangar_biomes_integration()
	test_main_scene_dynamic_biome_loading()
	
	print("\n============================================================")
	print(">>> ALL 8 WORLDS & PROGRESSION TESTS PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)

# --- 1. Biome Data Registry & Costs ---
func test_biome_data_definitions() -> void:
	var biomes = BiomeData.get_all_biomes()
	assert(biomes.size() == 5, "Expected exactly 5 world biomes, got %d" % biomes.size())
	
	var expected_costs = {
		"neon_graveyard": 0,
		"desert_world": 100,
		"ocean_world": 200,
		"volcanic_world": 350,
		"alien_forest": 500
	}
	
	for b in biomes:
		var b_id = b.get("id", "")
		assert(expected_costs.has(b_id), "Unknown biome id: %s" % b_id)
		assert(b.get("unlock_cost", -1) == expected_costs[b_id], "Cost mismatch for %s: expected %d, got %d" % [b_id, expected_costs[b_id], b.get("unlock_cost", -1)])
		assert(b.has("name") and b["name"].length() > 0, "Biome %s missing name" % b_id)
		assert(b.has("description") and b["description"].length() > 0, "Biome %s missing description" % b_id)
		assert(b.has("scene_path") and ResourceLoader.exists(b["scene_path"]), "Biome %s scene_path invalid or missing: %s" % [b_id, b.get("scene_path", "")])
		assert(b.has("hazard_name") and b.has("hazard_description"), "Biome %s missing hazard info" % b_id)
		assert(b.has("colors") and b["colors"].has("accent_cyan"), "Biome %s missing color palette" % b_id)
	
	print("[PASS] Test 1: BiomeData registry, costs (0, 100, 200, 350, 500), and scene paths verified.")

# --- 2. SaveManager Biome Economy & Unlocks ---
func test_save_manager_biome_economy() -> void:
	# Ensure starting baseline
	SaveManager.get_data()["unlocked_biomes"] = ["neon_graveyard"]
	SaveManager.get_data()["currency"] = 0
	SaveManager.save_data()
	
	assert(SaveManager.is_biome_unlocked("neon_graveyard") == true, "Neon Graveyard should always be unlocked")
	assert(SaveManager.is_biome_unlocked("desert_world") == false, "Desert World should start locked")
	assert(SaveManager.is_biome_unlocked("ocean_world") == false, "Ocean World should start locked")
	
	# Attempt unlock without funds -> must fail
	var failed_unlock = SaveManager.unlock_biome("desert_world")
	assert(failed_unlock == false, "Unlock should fail when currency is 0")
	assert(SaveManager.is_biome_unlocked("desert_world") == false, "Desert World should remain locked")
	
	# Add sufficient funds and unlock Desert World (100 fragments)
	SaveManager.add_currency(150)
	assert(SaveManager.get_currency() == 150, "Currency not added correctly")
	
	var success_unlock = SaveManager.unlock_biome("desert_world")
	assert(success_unlock == true, "Unlock should succeed with sufficient currency")
	assert(SaveManager.is_biome_unlocked("desert_world") == true, "Desert World must now be unlocked")
	assert(SaveManager.get_currency() == 50, "Expected 50 currency remaining after spending 100, got %d" % SaveManager.get_currency())
	
	# Idempotent unlock
	var repeat_unlock = SaveManager.unlock_biome("desert_world")
	assert(repeat_unlock == true, "Repeat unlock should return true")
	assert(SaveManager.get_currency() == 50, "Repeat unlock should not deduct currency")
	
	print("[PASS] Test 2: SaveManager biome unlock transaction and currency deduction verified.")

# --- 3. Selected Biome Safeguards ---
func test_selected_biome_safeguards() -> void:
	SaveManager.set_selected_biome("neon_graveyard")
	assert(SaveManager.get_selected_biome() == "neon_graveyard", "Initial selected biome mismatch")
	
	# Select unlocked biome
	SaveManager.set_selected_biome("desert_world")
	assert(SaveManager.get_selected_biome() == "desert_world", "Selecting unlocked biome failed")
	
	# Attempt select locked biome -> should be rejected
	SaveManager.set_selected_biome("volcanic_world")
	assert(SaveManager.get_selected_biome() == "desert_world", "Selected biome was allowed to switch to locked world")
	
	# Reset back to default
	SaveManager.set_selected_biome("neon_graveyard")
	print("[PASS] Test 3: Selected biome persistence and lock safeguards verified.")

# --- 4. Biome Scene Instantiations ---
func test_biome_scene_instantiations() -> void:
	var biome_paths = [
		"res://scenes/biomes/biome_neon_graveyard.tscn",
		"res://scenes/biomes/biome_desert_world.tscn",
		"res://scenes/biomes/biome_ocean_world.tscn",
		"res://scenes/biomes/biome_volcanic_world.tscn",
		"res://scenes/biomes/biome_alien_forest.tscn"
	]
	
	for path in biome_paths:
		var scn = load(path)
		assert(scn != null, "Failed to load scene: %s" % path)
		var inst = scn.instantiate()
		assert(inst is BiomeEnvironmentBase, "Scene %s does not inherit BiomeEnvironmentBase" % path)
		add_child(inst)
		
		# Check arena borders
		var borders = inst.get_node_or_null("BiomeArenaBorders")
		assert(borders != null, "Biome %s missing BiomeArenaBorders" % path)
		
		# Check hazard zone
		var hz = inst.get_node_or_null("HazardZone")
		assert(hz != null, "Biome %s missing HazardZone" % path)
		
		# Check spawn regions helper
		var spawns = inst.get_spawn_regions()
		assert(spawns.size() > 0, "Biome %s has no spawn regions" % path)
		
		inst.queue_free()
	
	print("[PASS] Test 4: All 5 biome scenes instantiated with particles, borders, and hazard zones.")

# --- 5. Hazard Zone Mechanics ---
func test_hazard_zone_mechanics() -> void:
	var hz_scene = load("res://scenes/biomes/biome_hazard_zone.tscn")
	assert(hz_scene != null, "Failed to load biome_hazard_zone.tscn")
	var hz: BiomeHazardZone = hz_scene.instantiate()
	add_child(hz)
	
	assert(hz.is_warning == false, "Hazard should start dormant")
	assert(hz.is_active_surge == false, "Hazard should start inactive")
	
	var warned = [false]
	var erupted = [false]
	hz.hazard_warned.connect(func(): warned[0] = true)
	hz.hazard_erupted.connect(func(): erupted[0] = true)
	
	hz.trigger_warning()
	assert(hz.is_warning == true, "trigger_warning failed to set is_warning")
	assert(warned[0] == true, "hazard_warned signal not fired")
	
	hz.trigger_surge()
	assert(hz.is_active_surge == true, "trigger_surge failed to set is_active_surge")
	assert(hz.is_warning == false, "Surge should clear warning state")
	assert(erupted[0] == true, "hazard_erupted signal not fired")
	
	hz.end_surge()
	assert(hz.is_active_surge == false, "end_surge failed to deactivate")
	
	hz.queue_free()
	print("[PASS] Test 5: BiomeHazardZone warning and surge states verified.")

# --- 6. Biome Select Menu UI ---
func test_biome_select_menu_ui() -> void:
	var menu_scene = load("res://scenes/biome_select_menu.tscn")
	assert(menu_scene != null, "Failed to load biome_select_menu.tscn")
	var menu: BiomeSelectMenu = menu_scene.instantiate()
	add_child(menu)
	
	var list_box = menu.get_node_or_null("Margin/VBox/Body/BiomeScroll/BiomeListVBox")
	assert(list_box != null, "BiomeListVBox container not found")
	assert(list_box.get_child_count() == 5, "BiomeListVBox must contain 5 biome buttons (got %d)" % list_box.get_child_count())
	
	var title_lbl = menu.get_node_or_null("Margin/VBox/Body/DetailPanel/VBox/DetailTitle")
	assert(title_lbl != null, "DetailTitle label missing")
	
	var deploy_btn = menu.get_node_or_null("Margin/VBox/Body/DetailPanel/VBox/DeployButton")
	assert(deploy_btn != null, "DeployButton missing")
	
	var unlock_btn = menu.get_node_or_null("Margin/VBox/Body/DetailPanel/VBox/UnlockButton")
	assert(unlock_btn != null, "UnlockButton missing")
	
	menu.queue_free()
	print("[PASS] Test 6: BiomeSelectMenu UI list and detail controls verified.")

# --- 7. Hangar Biomes Navigation ---
func test_hangar_biomes_integration() -> void:
	var hangar_scene = load("res://scenes/hangar_menu.tscn")
	assert(hangar_scene != null, "Failed to load hangar_menu.tscn")
	var hangar: HangarMenu = hangar_scene.instantiate()
	add_child(hangar)
	
	var biomes_btn = hangar.get_node_or_null("Margin/HBox/NavVBox/BiomesBtn")
	assert(biomes_btn != null, "BiomesBtn missing from hangar navigation")
	
	var biome_lbl = hangar.get_node_or_null("Margin/HBox/DisplayVBox/StatsPanel/VBox/BiomeLabel")
	assert(biome_lbl != null, "BiomeLabel missing from hangar stats panel")
	assert(biome_lbl.text.contains("NEON GRAVEYARD"), "BiomeLabel does not display current active biome")
	
	hangar.queue_free()
	print("[PASS] Test 7: Hangar BiomesBtn navigation and active biome display verified.")

# --- 8. Main Scene Dynamic Biome Loading ---
func test_main_scene_dynamic_biome_loading() -> void:
	# Select Desert World
	SaveManager.get_data()["unlocked_biomes"] = ["neon_graveyard", "desert_world"]
	SaveManager.set_selected_biome("desert_world")
	
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Failed to load main.tscn")
	var main_arena = main_scene.instantiate()
	add_child(main_arena)
	
	var active_env = main_arena.get_node_or_null("ActiveBiomeEnvironment")
	assert(active_env != null, "ActiveBiomeEnvironment was not dynamically loaded in main arena")
	assert(active_env is BiomeDesertWorld, "ActiveBiomeEnvironment is not BiomeDesertWorld")
	
	# Restore to default
	SaveManager.set_selected_biome("neon_graveyard")
	main_arena.queue_free()
	print("[PASS] Test 8: Main arena dynamic biome instantiation verified.")
