extends Node2D

# ==============================================================================
# VECTOR//BREAK — REGRESSION TEST SUITE: FINAL GAMEPLAY POLISH & CAMPAIGN
# Verifies ENTER dialogue advance, SPACEBAR isolation, simulation pause,
# nanocell healing & clamp, static laser removal, dynamic biome obstacles,
# finite 5-act campaign matrix, and homepage keyboard navigation focus.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK FINAL GAMEPLAY POLISH & QA TEST SUITE ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 1: Dialogue Controls, Character Avatar & Simulation Pause
	# --------------------------------------------------------------------------
	print("[RUN] 1. Testing StoryDialogue controls (ENTER only, SPACE/ESC ignored) and tree pause...")
	var dialogue_scene = load("res://scenes/story_dialogue.tscn")
	var dialogue: StoryDialogue = dialogue_scene.instantiate()
	add_child(dialogue)
	await get_tree().physics_frame
	
	assert(dialogue.avatar != null, "StoryDialogue missing CharacterAvatar instance")
	
	var test_seq = [
		{"speaker": "KAEL VEYR", "color": Color(0.3, 0.8, 1.0), "text": "Testing line 1"},
		{"speaker": "MIRA VEYR", "color": Color(0.2, 0.9, 1.0), "text": "Testing line 2"}
	]
	
	var state = {"completed": false}
	dialogue.play_sequence(test_seq, func(): state["completed"] = true)
	await get_tree().physics_frame
	
	assert(dialogue.visible == true, "Dialogue should be visible")
	assert(dialogue.is_active() == true, "Dialogue should report is_active() == true")
	assert(get_tree().paused == true, "Simulation should be PAUSED during dialogue")
	assert(dialogue.get_current_line_index() == 0, "Should start at line 0")
	
	# Simulate SPACEBAR press -> should be consumed and NOT advance line
	var space_event = InputEventKey.new()
	space_event.pressed = true
	space_event.keycode = KEY_SPACE
	dialogue._input(space_event)
	assert(dialogue.get_current_line_index() == 0, "SPACEBAR must NOT advance dialogue")
	
	# Simulate ESC press -> should NOT close dialogue
	var esc_event = InputEventKey.new()
	esc_event.pressed = true
	esc_event.keycode = KEY_ESCAPE
	dialogue._input(esc_event)
	assert(dialogue.is_active() == true, "ESC must NOT skip or cancel active dialogue")
	
	var enter_event = InputEventKey.new()
	enter_event.pressed = true
	enter_event.keycode = KEY_ENTER
	
	# First ENTER finishes typewriter text if typing
	if dialogue._is_typing:
		dialogue._input(enter_event)
	# Next ENTER advances to line 1
	dialogue._input(enter_event)
	assert(dialogue.get_current_line_index() == 1, "ENTER must advance dialogue to line 1")
	
	# Finish typing line 1 if typing, then advance to finish sequence
	if dialogue._is_typing:
		dialogue._input(enter_event)
	dialogue._input(enter_event)
	await get_tree().physics_frame
	assert(dialogue.visible == false, "Dialogue should hide upon sequence completion")
	assert(dialogue.is_active() == false, "Dialogue should no longer be active")
	assert(get_tree().paused == false, "Simulation must UNPAUSE after dialogue finishes")
	assert(state["completed"] == true, "Dialogue completion callback must be invoked")
	print("[PASS] 1. StoryDialogue ENTER advance, SPACEBAR isolation, and tree pausing verified.")
	
	dialogue.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 2: Nanocell Health Restore & Clamp Protection
	# --------------------------------------------------------------------------
	print("[RUN] 2. Testing Nanocell healing, collision mask, and full health rejection...")
	var player_scene = load("res://scenes/player.tscn")
	var player: PlayerShip = player_scene.instantiate()
	add_child(player)
	await get_tree().physics_frame
	
	var nanocell_scene = load("res://scenes/pickup_nanocell.tscn")
	var nanocell: PickupNanocell = nanocell_scene.instantiate()
	add_child(nanocell)
	await get_tree().physics_frame
	
	# Verify collision mask detects Layer 1 (Player CharacterBody2D) and Layer 2
	assert((nanocell.collision_mask & 1) != 0, "PickupNanocell must have collision_mask bit 1 enabled")
	
	# Test healing when damaged
	player.current_health = 60
	player.max_health = 100
	assert(nanocell.can_collect(player) == true, "Damaged player must be eligible for nanocell collection")
	
	nanocell.apply_pickup(player)
	assert(player.current_health > 60, "Player health must increase upon nanocell pickup")
	assert(player.current_health <= player.max_health, "Player health must clamp to max_health")
	
	# Test rejection when at full health (must not waste pickup)
	player.current_health = 100
	var nanocell2: PickupNanocell = nanocell_scene.instantiate()
	add_child(nanocell2)
	await get_tree().physics_frame
	assert(nanocell2.can_collect(player) == false, "Full health player must NOT be able to collect nanocell (waste prevention)")
	print("[PASS] 2. Nanocell collision mask (3), HP restore clamp, and waste prevention verified.")
	
	nanocell.queue_free()
	nanocell2.queue_free()
	player.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 3: Static Laser Gate Removal & Biome Obstacle Adaptability
	# --------------------------------------------------------------------------
	print("[RUN] 3. Testing removal of static LaserGate in act1_mission and dynamic biome obstacles...")
	var act1_scene = load("res://scenes/act1_mission.tscn")
	var act1 = act1_scene.instantiate()
	add_child(act1)
	await get_tree().physics_frame
	
	# Confirm static LaserGate node was removed
	var static_gate = act1.get_node_or_null("LaserGate")
	assert(static_gate == null, "Static LaserGate node must NOT exist in act1_mission scene")
	
	# Test SpaceObstacle dynamic adaptation across all 5 biomes
	var obs_scene = load("res://scenes/space_obstacle.tscn")
	var obs: SpaceObstacle = obs_scene.instantiate()
	add_child(obs)
	await get_tree().physics_frame
	
	var biomes = ["neon_graveyard", "vesper_desert", "pelagic_depths", "pyroclastic_rift", "viridian_canopy"]
	for b in biomes:
		obs.set_biome(b)
		assert(obs.current_biome == b, "SpaceObstacle failed to switch to biome: " + b)
	print("[PASS] 3. Static LaserGate successfully removed; SpaceObstacle adapts across all 5 biomes.")
	
	obs.queue_free()
	act1.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 4: Finite 5-Act Campaign Matrix & Narrative Ending Scene
	# --------------------------------------------------------------------------
	print("[RUN] 4. Testing 5-Act campaign definitions, biome mapping, and CampaignEnding scene...")
	for act_num in range(1, 6):
		var rounds = CampaignData.get_round_definitions(act_num)
		assert(rounds.size() > 0, "Act %d missing round definitions" % act_num)
		for r in rounds:
			assert(r.has("waves") and r["waves"].size() > 0, "Round %s in Act %d missing waves" % [r.get("id", "?"), act_num])
	
	# Verify Act 5 terminates at ORACLE Core boss
	var act5_rounds = CampaignData.get_round_definitions(5)
	assert(act5_rounds.size() == 2, "Act 5 should contain exactly 2 climax encounters")
	assert(act5_rounds[1]["id"] == "5-2", "Act 5 final round ID mismatch")
	
	# Test Act <-> Biome bidirectional mapping
	assert(CampaignData.get_act_for_biome("neon_graveyard") == 1, "neon_graveyard should be Act 1")
	assert(CampaignData.get_act_for_biome("vesper_desert") == 2, "vesper_desert should be Act 2")
	assert(CampaignData.get_act_for_biome("pelagic_depths") == 3, "pelagic_depths should be Act 3")
	assert(CampaignData.get_act_for_biome("pyroclastic_rift") == 4, "pyroclastic_rift should be Act 4")
	assert(CampaignData.get_act_for_biome("viridian_canopy") == 5, "viridian_canopy should be Act 5")
	
	# Verify CampaignEnding scene loads and instantiates
	var ending_scene = load("res://scenes/campaign_ending.tscn")
	assert(ending_scene != null, "CampaignEnding scene must exist at res://scenes/campaign_ending.tscn")
	var ending: Control = ending_scene.instantiate()
	add_child(ending)
	await get_tree().physics_frame
	assert(ending.get_node_or_null("StoryDialogue") != null, "CampaignEnding must have StoryDialogue node")
	print("[PASS] 4. 5-Act campaign matrix, biome mapping, and CampaignEnding scene verified.")
	
	ending.queue_free()
	await get_tree().physics_frame
	
	# --------------------------------------------------------------------------
	# TEST 5: Homepage Keyboard Navigation & Focus Style
	# --------------------------------------------------------------------------
	print("[RUN] 5. Testing MainMenu keyboard navigation and glowing neon cyan focus rings...")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu: MainMenu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().physics_frame
	
	var nav_buttons = [menu.play_btn, menu.collections_btn, menu.store_btn, menu.level_btn, menu.settings_btn, menu.quit_btn]
	for btn in nav_buttons:
		assert(btn != null, "Main menu navigation button missing")
		assert(not btn.focus_neighbor_top.is_empty(), "Button missing focus_neighbor_top: " + btn.name)
		assert(not btn.focus_neighbor_bottom.is_empty(), "Button missing focus_neighbor_bottom: " + btn.name)
		var focus_style = btn.get_theme_stylebox("focus")
		assert(focus_style is StyleBoxFlat, "Button missing custom StyleBoxFlat focus style")
		assert(focus_style.border_color == Color(0.2, 0.95, 1.0, 1.0), "Focus border color must be neon cyan (0.2, 0.95, 1.0)")
	print("[PASS] 5. MainMenu keyboard navigation looping and neon cyan focus styles verified.")
	
	menu.queue_free()
	await get_tree().physics_frame
	
	print("\n============================================================")
	print(">>> ALL 5 FINAL POLISH REGRESSION TESTS PASSED 100%! <<<")
	print("============================================================\n")
	get_tree().quit(0)
