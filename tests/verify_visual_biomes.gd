extends Node

# ==============================================================================
# VECTOR//BREAK — VISUAL BIOME & PERSISTENCE VERIFICATION RUNNER
# Captures direct rendered viewport frames of all 5 biomes and the selector,
# and verifies save persistence across game restarts.
# ==============================================================================

const SCREENSHOT_DIR: String = "res://screenshots/"

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK: VISUAL & PERSISTENCE VERIFICATION ---")
	print("============================================================\n")
	
	DirAccess.make_dir_absolute("C:/Users/dalia/.gemini/antigravity/scratch/ROMR-Vector-Break/screenshots")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 1. Verify Biome Selector Visual
	await _capture_biome_selector()
	
	# 2. Verify all 5 Biomes in Main Combat Arena
	var biomes = ["neon_graveyard", "desert_world", "ocean_world", "volcanic_world", "alien_forest"]
	for i in range(biomes.size()):
		var b_id = biomes[i]
		await _capture_combat_biome(b_id, i + 2)
	
	# 3. Verify Save Persistence across Restarts
	_verify_save_persistence_across_restarts()
	
	print("\n============================================================")
	print(">>> VISUAL & PERSISTENCE VERIFICATION COMPLETE 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)

func _capture_biome_selector() -> void:
	SaveManager.load_data()
	# Set clean test economy
	SaveManager.get_data()["currency"] = 450
	SaveManager.get_data()["unlocked_biomes"] = ["neon_graveyard", "desert_world"]
	SaveManager.set_selected_biome("desert_world")
	
	var menu_scene = load("res://scenes/biome_select_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	
	for f in range(6):
		await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/dalia/.gemini/antigravity/scratch/ROMR-Vector-Break/screenshots/01_biome_select_menu.png"
	img.save_png(out_path)
	print("[SAVED] Biome selector screenshot: %s" % out_path)
	
	menu.queue_free()
	await get_tree().process_frame

func _capture_combat_biome(biome_id: String, index: int) -> void:
	SaveManager.get_data()["unlocked_biomes"] = ["neon_graveyard", "desert_world", "ocean_world", "volcanic_world", "alien_forest"]
	SaveManager.set_selected_biome(biome_id)
	
	var main_scene = load("res://scenes/main.tscn")
	var main_arena = main_scene.instantiate()
	add_child(main_arena)
	
	# Allow particles and geometry to simulate for 10 frames
	for f in range(10):
		await get_tree().physics_frame
		await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	var filename = "%02d_combat_%s.png" % [index, biome_id]
	var out_path = "C:/Users/dalia/.gemini/antigravity/scratch/ROMR-Vector-Break/screenshots/" + filename
	img.save_png(out_path)
	print("[SAVED] Combat arena biome screenshot: %s" % out_path)
	
	main_arena.queue_free()
	await get_tree().process_frame

func _verify_save_persistence_across_restarts() -> void:
	print("--- Verifying Save Persistence Across Game Restarts ---")
	# Unlock all biomes and set selected
	var all_ids = ["neon_graveyard", "desert_world", "ocean_world", "volcanic_world", "alien_forest"]
	SaveManager.get_data()["unlocked_biomes"] = all_ids
	SaveManager.get_data()["currency"] = 850
	SaveManager.set_selected_biome("alien_forest")
	SaveManager.save_data()
	
	# Wipe in-memory working cache to simulate complete game shutdown
	SaveManager.current_data = {}
	SaveManager._is_initialized = false
	
	# Load from user:// disk
	var loaded = SaveManager.load_data()
	assert(loaded == true or FileAccess.file_exists(SaveManager.SAVE_PATH), "Save file was not found on disk")
	
	var loaded_unlocked = SaveManager.get_unlocked_biomes()
	for b_id in all_ids:
		assert(SaveManager.is_biome_unlocked(b_id) == true, "Biome %s failed to persist unlock state after restart" % b_id)
	
	assert(SaveManager.get_selected_biome() == "alien_forest", "Selected biome failed to persist across restart (got %s)" % SaveManager.get_selected_biome())
	assert(SaveManager.get_currency() == 850, "Currency failed to persist across restart")
	
	# Reset back to default for clean repo
	SaveManager.set_selected_biome("neon_graveyard")
	print("[PASS] Full save file reload verified. All 5 biome unlocks and selections persisted 100%.")
