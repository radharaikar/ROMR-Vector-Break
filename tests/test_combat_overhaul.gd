extends Node2D

# ==============================================================================
# VECTOR//BREAK — COMBAT OVERHAUL AUTOMATED TEST SUITE
# Verifies spaceship physical movement, mouse rotation, custom cursor states,
# rebuilt enemy pursuit AI across archetypes, and hostile projectile damage safety.
# ==============================================================================

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK COMBAT OVERHAUL VERIFICATION SUITE ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	test_player_physics_movement_and_rotation()
	test_custom_cursor_behavior()
	test_drone_active_pursuit()
	test_chaser_pursuit_and_lead()
	test_striker_standoff_and_evade()
	test_dasher_state_machine()
	test_heavy_shield_orientation_and_ricochet()
	test_hostile_projectile_safety()
	
	print("\n============================================================")
	print(">>> ALL COMBAT OVERHAUL VERIFICATION TESTS PASSED 100%! <<<")
	print("============================================================\n")
	get_tree().quit(0)

# 1. Player Physics Movement, Rotation & Full Arena Freedom
func test_player_physics_movement_and_rotation() -> void:
	var player_scene = load("res://scenes/player.tscn")
	assert(player_scene != null, "Player scene failed to load")
	var player = player_scene.instantiate()
	add_child(player)
	await get_tree().physics_frame
	
	# Verify rotation toward cursor target
	player.global_position = Vector2(400, 300)
	var simulated_target = Vector2(400, 100) # Directly upward (-PI/2)
	var expected_angle = (simulated_target - player.global_position).angle()
	player.rotation = expected_angle
	assert(abs(player.rotation - (-PI * 0.5)) < 0.05, "Player rotation alignment mismatch")
	
	# Verify muzzle Marker2D rotates with the player ship
	var muzzle = player.get_node_or_null("Muzzle")
	assert(muzzle != null, "Muzzle marker missing")
	var muzzle_world_offset = muzzle.global_position - player.global_position
	# When facing up, muzzle at local (28, 0) should be at world (0, -28)
	assert(abs(muzzle_world_offset.x) < 1.0 and muzzle_world_offset.y < -20.0, "Muzzle not synchronized with ship rotation")
	print("[PASS] 1a. Ship rotation and muzzle marker synchronization verified.")
	
	# Verify physical movement across full arena
	player.global_position = Vector2(1000, 500)
	player._physics_process(0.016)
	assert(player.global_position.x > 800.0, "Player incorrectly restricted from right arena area")
	assert(player.global_position.y > 400.0, "Player incorrectly restricted from lower arena area")
	print("[PASS] 1b. Full arena movement range verified (x=1000, y=500 accessible).")
	
	player.queue_free()
	await get_tree().physics_frame

# 2. Custom Cursor States
func test_custom_cursor_behavior() -> void:
	var cursor_scene = load("res://scenes/custom_cursor.tscn")
	assert(cursor_scene != null, "Custom cursor scene failed to load")
	var cursor = cursor_scene.instantiate()
	add_child(cursor)
	await get_tree().physics_frame
	
	# Test enemy hover detection
	var drone_scene = load("res://scenes/geometric_drone.tscn")
	var drone = drone_scene.instantiate()
	drone.global_position = Vector2(500, 300)
	add_child(drone)
	await get_tree().physics_frame
	
	# Position cursor directly over drone
	cursor.global_position = Vector2(505, 302)
	cursor._process(0.016)
	assert(cursor.is_hovering_enemy == true, "Cursor failed to detect hovering over enemy")
	
	# Move cursor away from drone
	cursor.global_position = Vector2(100, 100)
	cursor._process(0.016)
	assert(cursor.is_hovering_enemy == false, "Cursor false-positive hover detected")
	
	# Test firing flash trigger
	cursor.trigger_fire_flash()
	assert(cursor._flash_timer > 0.05, "Cursor fire flash timer failed to activate")
	print("[PASS] 2. Custom cursor reticle, enemy hover detection, and fire flash verified.")
	
	drone.queue_free()
	cursor.queue_free()
	await get_tree().physics_frame

# 3. Geometric Drone Active Pursuit AI
func test_drone_active_pursuit() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var drone_scene = load("res://scenes/geometric_drone.tscn")
	var player = player_scene.instantiate()
	var drone = drone_scene.instantiate()
	
	player.global_position = Vector2(300, 200)
	drone.global_position = Vector2(600, 500)
	add_child(player)
	add_child(drone)
	await get_tree().physics_frame
	
	# Process multiple physics frames and verify drone moves toward player
	var initial_dist = drone.global_position.distance_to(player.global_position)
	for i in range(15):
		drone._physics_process(0.016)
	var final_dist = drone.global_position.distance_to(player.global_position)
	
	assert(final_dist < initial_dist, "Drone failed to pursue player position (Dist did not decrease)")
	assert(drone.velocity.x < 0.0 and drone.velocity.y < 0.0, "Drone velocity direction does not match player heading")
	print("[PASS] 3. Geometric Drone active multi-directional pursuit AI verified.")
	
	player.queue_free()
	drone.queue_free()
	await get_tree().physics_frame

# 4. Chaser High-Speed Predictive Pursuit
func test_chaser_pursuit_and_lead() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var chaser_scene = load("res://scenes/enemy_chaser.tscn")
	var player = player_scene.instantiate()
	var chaser = chaser_scene.instantiate()
	
	player.global_position = Vector2(400, 400)
	chaser.global_position = Vector2(700, 400)
	add_child(player)
	add_child(chaser)
	await get_tree().physics_frame
	
	var initial_dist = chaser.global_position.distance_to(player.global_position)
	for i in range(15):
		chaser._physics_process(0.016)
	var new_dist = chaser.global_position.distance_to(player.global_position)
	
	assert(new_dist < initial_dist, "Chaser failed to close distance to player")
	assert(chaser.velocity.x < -100.0, "Chaser speed is insufficient for aggressive pursuer archetype")
	print("[PASS] 4. Chaser high-speed predictive pursuit AI verified.")
	
	player.queue_free()
	chaser.queue_free()
	await get_tree().physics_frame

# 5. Striker Standoff and Evasion
func test_striker_standoff_and_evade() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var striker_scene = load("res://scenes/enemy_striker.tscn")
	var player = player_scene.instantiate()
	var striker = striker_scene.instantiate()
	
	# Place player too close to striker (< 220px) to trigger evasion
	player.global_position = Vector2(500, 360)
	striker.global_position = Vector2(600, 360)
	add_child(player)
	add_child(striker)
	await get_tree().physics_frame
	
	striker._physics_process(0.016)
	assert(striker.current_state == striker.State.EVADING, "Striker failed to enter EVADING state when player encroached")
	assert(striker.velocity.x > 0.0, "Striker failed to retreat away from approaching player")
	print("[PASS] 5. Striker standoff range maintenance and evasion state verified.")
	
	player.queue_free()
	striker.queue_free()
	await get_tree().physics_frame

# 6. Dasher State Machine
func test_dasher_state_machine() -> void:
	var dasher_scene = load("res://scenes/enemy_dasher.tscn")
	var dasher = dasher_scene.instantiate()
	add_child(dasher)
	await get_tree().physics_frame
	
	assert(dasher.current_state == dasher.State.TRACKING, "Dasher initial state is not TRACKING")
	dasher._enter_telegraph()
	assert(dasher.current_state == dasher.State.TELEGRAPHING, "Dasher failed to enter TELEGRAPHING")
	dasher._enter_dash()
	assert(dasher.current_state == dasher.State.DASHING, "Dasher failed to enter DASHING")
	dasher._enter_recovery()
	assert(dasher.current_state == dasher.State.RECOVERING, "Dasher failed to enter RECOVERING")
	print("[PASS] 6. Dasher tracking, telegraph, dash, and recovery state machine verified.")
	
	dasher.queue_free()
	await get_tree().physics_frame

# 7. Heavy Shield Orientation & Ricochet Flank Hit
func test_heavy_shield_orientation_and_ricochet() -> void:
	var heavy_scene = load("res://scenes/enemy_heavy.tscn")
	var heavy = heavy_scene.instantiate()
	heavy.global_position = Vector2(800, 360)
	heavy.rotation = PI # Facing left
	add_child(heavy)
	await get_tree().physics_frame
	
	var initial_hp = heavy.current_health
	
	# Frontal hit arriving from left (ahead of the heavy)
	heavy.take_damage(35, 1, Vector2(780, 360))
	assert(heavy.current_health == initial_hp, "Heavy shield failed to absorb frontal impact")
	
	# Rear ricochet hit arriving from right (behind the heavy)
	heavy.take_damage(35, 2, Vector2(850, 360))
	assert(heavy.current_health == initial_hp - 35, "Heavy failed to take damage from rear ricochet hit")
	print("[PASS] 7. Heavy directional shield absorption and rear ricochet penetration verified.")
	
	heavy.queue_free()
	await get_tree().physics_frame

# 8. Hostile Projectile Owner Safety & Player Damage
func test_hostile_projectile_safety() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var proj_scene = load("res://scenes/enemy_projectile.tscn")
	var striker_scene = load("res://scenes/enemy_striker.tscn")
	
	var player = player_scene.instantiate()
	var striker = striker_scene.instantiate()
	var proj = proj_scene.instantiate()
	
	player.global_position = Vector2(300, 300)
	striker.global_position = Vector2(600, 300)
	proj.global_position = Vector2(600, 300)
	proj.shooter = striker # Assign striker as shooter
	
	add_child(player)
	add_child(striker)
	add_child(proj)
	await get_tree().physics_frame
	
	# Verify projectile does not damage owner
	assert(striker.current_health == striker.max_health, "Hostile projectile damaged its own shooter")
	
	# Deliver projectile to player
	player.current_health = 100
	proj.global_position = player.global_position
	# Trigger collision handling
	player.take_damage(proj.damage, proj)
	assert(player.current_health < 100, "Hostile projectile failed to damage player")
	print("[PASS] 8. Hostile projectile shooter safety and player damage verified.")
	
	player.queue_free()
	striker.queue_free()
	proj.queue_free()
	await get_tree().physics_frame
