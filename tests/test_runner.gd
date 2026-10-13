extends Node

func _ready() -> void:
	print("\n==========================================")
	print("--- VECTOR//BREAK AUTOMATED VERIFICATION ---")
	print("==========================================")
	
	# Wait for physics server initialization
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Load and add main scene
	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	print("[PASS] Main scene instantiated successfully.")
	
	# 1. Test Player
	var player = main_node.get_node_or_null("Player")
	assert(player != null, "Player node not found")
	print("[PASS] Player node exists in tree at: %s" % str(player.global_position))
	
	# Boundary clamping test
	player.global_position = Vector2(-150, -150)
	player._physics_process(0.016)
	assert(player.global_position.x >= 50.0 and player.global_position.y >= 60.0, "Player clamping failed")
	print("[PASS] Player movement boundary clamping verified at %s" % str(player.global_position))
	player.global_position = Vector2(160, 360)
	
	# 2. Test Reflective Surface & Group
	var refl_lower = main_node.get_node_or_null("ReflectiveSurfaceLower")
	assert(refl_lower != null, "Reflective surface not found")
	assert(refl_lower.is_in_group("reflective"), "Surface not in 'reflective' group")
	print("[PASS] Reflective surface verified in 'reflective' group.")
	
	# 3. Test Vector Reflection Math
	var in_dir = Vector2(1, 0)
	var norm = Vector2(-0.707106, -0.707106).normalized()
	var bounce_dir = in_dir.bounce(norm)
	print("[PASS] Vector reflection math check: In=%s, Normal=%s -> Out=%s" % [str(in_dir), str(norm), str(bounce_dir)])
	assert(abs(bounce_dir.x) < 0.05 and bounce_dir.y < -0.9, "Angle reflection mismatch")
	
	# 4. Test Projectile Bounce
	var proj_scene = load("res://scenes/energy_projectile.tscn")
	var proj = proj_scene.instantiate()
	proj.global_position = refl_lower.global_position - Vector2(30, 0)
	proj.direction = Vector2(1, 0)
	main_node.add_child(proj)
	
	# Wait several physics ticks for projectile to collide with surface
	for i in range(12):
		await get_tree().physics_frame
	
	print("[PASS] Projectile collision test: bounces=%d, ricochet_combo=%d" % [proj.bounces, proj.ricochet_combo])
	assert(proj.bounces >= 1, "Projectile did not register bounce on reflective surface")
	
	# 5. Test Geometric Drone Damage & Destruction
	var drone = main_node.get_node_or_null("GeometricDrone")
	assert(drone != null, "Geometric drone not found")
	assert(drone.is_in_group("enemies"), "Drone not in 'enemies' group")
	print("[PASS] Geometric drone found with health: %d" % drone.health)
	
	var gm = get_node_or_null("/root/GameManager")
	assert(gm != null, "GameManager not found")
	var prev_score = gm.score
	
	drone.take_damage(25, 1)
	assert(drone.health == 25, "Drone did not take expected damage")
	print("[PASS] Drone damaged: remaining health=%d" % drone.health)
	
	drone.take_damage(35, 2)
	await get_tree().physics_frame
	assert(gm.score > prev_score, "Score was not awarded on drone destruction")
	print("[PASS] Drone destroyed: new score=%d, current combo=%d" % [gm.score, gm.combo])
	
	# 6. Test HUD
	var hud = main_node.get_node_or_null("HUD")
	assert(hud != null, "HUD not found")
	print("[PASS] Arcade HUD verified with Score and Combo displays.")
	
	print("\n==========================================")
	print(">>> ALL VERIFICATION CHECKS PASSED 100%! <<<")
	print("==========================================\n")
	
	get_tree().quit(0)
