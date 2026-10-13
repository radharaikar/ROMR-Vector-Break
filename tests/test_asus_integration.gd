extends Node

# Comprehensive ASUS integration test suite for VECTOR//BREAK.
# Verifies interoperability between Dell physics/projectile/manager and ASUS enemy/reflector/VFX.

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK ASUS ENEMY & REFLECTOR INTEGRATION TEST ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 1. Load Main Scene
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Failed to load res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	print("[PASS] Main scene loaded with ASUS nodes integrated.")
	
	# 2. Verify ASUS EnemyDrone in Main scene
	var asus_drone = main_node.get_node_or_null("EnemyDrone")
	assert(asus_drone != null, "ASUS EnemyDrone node not found in Main scene")
	assert(asus_drone.is_in_group("enemies"), "ASUS EnemyDrone is not in 'enemies' group")
	assert(asus_drone.health == 50, "ASUS EnemyDrone initial health is not 50")
	print("[PASS] ASUS EnemyDrone verified in tree with health=%d and group 'enemies'." % asus_drone.health)
	
	# 3. Verify ASUS Reflector45 in Main scene
	var asus_refl = main_node.get_node_or_null("Reflector45")
	assert(asus_refl != null, "ASUS Reflector45 node not found in Main scene")
	assert(asus_refl.is_in_group("reflective"), "ASUS Reflector45 is not in 'reflective' group")
	print("[PASS] ASUS Reflector45 verified in tree with group 'reflective'.")
	
	# 4. Direct Projectile Collision & Damage Intake Test
	var proj_scene = load("res://scenes/energy_projectile.tscn")
	assert(proj_scene != null, "EnergyProjectile scene could not be loaded")
	
	var target_drone = load("res://scenes/enemy_drone.tscn").instantiate()
	target_drone.global_position = Vector2(500, 300)
	main_node.add_child(target_drone)
	
	var direct_proj = proj_scene.instantiate()
	direct_proj.global_position = Vector2(400, 300)
	direct_proj.direction = Vector2(1, 0)
	main_node.add_child(direct_proj)
	
	# Advance physics frames for direct hit
	for i in range(12):
		await get_tree().physics_frame
	
	assert(target_drone.health < 50, "ASUS EnemyDrone was not damaged by Dell projectile collision")
	print("[PASS] Dell EnergyProjectile directly collided with ASUS EnemyDrone. Remaining HP: %d" % target_drone.health)
	
	# 5. Destruction & Score/Combo Integration Test
	var gm = get_node_or_null("/root/GameManager")
	assert(gm != null, "GameManager singleton not found")
	var prev_score = gm.score
	var prev_combo = gm.combo
	
	# Deal fatal damage
	target_drone.take_damage(50, 2)
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	assert(!is_instance_valid(target_drone), "ASUS EnemyDrone was cleaned up from tree after fatal damage")
	assert(gm.score > prev_score, "Score was not incremented in GameManager on ASUS enemy death")
	assert(gm.combo >= prev_combo, "Combo was not updated in GameManager on ASUS enemy death")
	print("[PASS] ASUS EnemyDrone destruction registered with GameManager: Score=%d, Combo=%d" % [gm.score, gm.combo])
	
	# 6. Physical Ricochet on ASUS Reflector45
	var test_refl = load("res://scenes/reflector_45.tscn").instantiate()
	test_refl.global_position = Vector2(600, 400)
	main_node.add_child(test_refl)
	
	var bounce_proj = proj_scene.instantiate()
	bounce_proj.global_position = Vector2(520, 400)
	bounce_proj.direction = Vector2(1, 0) # Fire horizontally into reflector
	main_node.add_child(bounce_proj)
	
	# Wait until bounce occurs
	for i in range(12):
		await get_tree().physics_frame
		if bounce_proj.bounces >= 1:
			break
	
	assert(bounce_proj.bounces >= 1, "Projectile did not register bounce on ASUS Reflector45")
	assert(bounce_proj.ricochet_combo >= 2, "Projectile ricochet_combo did not increment on reflection")
	assert(bounce_proj.velocity.y < -100.0, "Reflected projectile velocity does not reflect upward: %s" % str(bounce_proj.velocity))
	print("[PASS] Projectile successfully reflected off ASUS Reflector45 with bounces=%d, ricochet_combo=%d, velocity=%s" % [
		bounce_proj.bounces, bounce_proj.ricochet_combo, str(bounce_proj.velocity)
	])
	bounce_proj.queue_free()
	
	# 7. Ricochet-to-Enemy Hit Integration Test
	# Setup: Reflector at (700, 300), Drone above it at (700, 160)
	var combo_refl = load("res://scenes/reflector_45.tscn").instantiate()
	combo_refl.global_position = Vector2(700, 300)
	main_node.add_child(combo_refl)
	
	var ricochet_victim = load("res://scenes/enemy_drone.tscn").instantiate()
	ricochet_victim.global_position = Vector2(700, 160)
	main_node.add_child(ricochet_victim)
	
	var ricochet_shot = proj_scene.instantiate()
	ricochet_shot.global_position = Vector2(620, 300)
	ricochet_shot.direction = Vector2(1, 0) # Fire toward reflector
	main_node.add_child(ricochet_shot)
	
	# Wait for bounce and upward hit on the drone
	for i in range(25):
		await get_tree().physics_frame
		if !is_instance_valid(ricochet_victim) or ricochet_victim.health < 50:
			break
	
	assert(!is_instance_valid(ricochet_victim) or ricochet_victim.health < 50, "ASUS EnemyDrone was not damaged by the ricocheted projectile")
	print("[PASS] Ricochet combat verified: Projectile bounced off Reflector45 and struck EnemyDrone!")
	
	# 8. Spawner Verification
	var spawner = main_node.get_node_or_null("EnemySpawner")
	assert(spawner != null, "EnemySpawner node not found")
	assert(spawner.drone_scenes.size() >= 2, "EnemySpawner does not include both drone variants")
	print("[PASS] EnemySpawner verified with multi-drone wave support: %d scene variants registered." % spawner.drone_scenes.size())
	
	print("\n============================================================")
	print(">>> ALL ASUS INTEGRATION RUNTIME TESTS PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)
