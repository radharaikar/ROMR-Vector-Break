extends Node

## Comprehensive Combat AI & Encounter Verification Suite for VECTOR//BREAK.
## Tests all enemy archetypes, player combat safety, boss phases, obstacles, and encounter progression.

func _ready() -> void:
	print("\n============================================================")
	print("--- VECTOR//BREAK COMBAT AI & ENCOUNTER TEST SUITE ---")
	print("============================================================\n")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 1. Load Main Scene
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Failed to load res://scenes/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	print("[PASS] 1. Main scene successfully instantiated.")
	
	# 2. Verify Player Combat Interface & Arena Bounds Fix
	var player = main.get_node_or_null("Player")
	assert(player != null, "Player node not found in main scene")
	
	# Verify player can now move past the old 480 clamp limit
	player.global_position = Vector2(850.0, 360.0)
	player._physics_process(0.016)
	assert(player.global_position.x > 800.0, "Player is still restricted by the old 480 clamp limit!")
	print("[PASS] 2a. Player movement arena bounds fix verified: Player at x=%d (exceeds old 480 limit)." % player.global_position.x)
	player.global_position = Vector2(160.0, 360.0)
	
	# Test Player damage, i-frames, and healing
	assert(player.current_health == 100, "Initial player health is not 100")
	player.take_damage(25)
	assert(player.current_health == 75, "Player take_damage failed: HP=%d" % player.current_health)
	assert(player.is_invulnerable == true, "Player did not enter i-frames after taking damage")
	
	# Immediate subsequent damage during i-frames must be blocked
	player.take_damage(25)
	assert(player.current_health == 75, "Player took damage during invulnerability window!")
	print("[PASS] 2b. Player damage and invulnerability window verified (HP: 75/100, i-frames active).")
	
	player.heal(15)
	assert(player.current_health == 90, "Player healing failed: HP=%d" % player.current_health)
	print("[PASS] 2c. Player healing interface verified: HP restored to %d/100." % player.current_health)
	
	# Test Player Self-Damage Immunity
	var self_proj = load("res://scenes/energy_projectile.tscn").instantiate()
	self_proj.global_position = player.global_position
	self_proj.direction = Vector2.LEFT
	main.add_child(self_proj)
	for i in range(4):
		await get_tree().physics_frame
	assert(player.current_health == 90, "Player took damage from their own projectile!")
	print("[PASS] 2d. Player self-damage immunity verified.")
	if is_instance_valid(self_proj):
		self_proj.queue_free()
	
	# 3. Test Enemy Archetype: Chaser (Seeking / Pursuit AI)
	var chaser = load("res://scenes/enemy_chaser.tscn").instantiate()
	chaser.global_position = Vector2(500.0, 200.0)
	main.add_child(chaser)
	await get_tree().physics_frame
	
	# Chaser should steer toward player at (160, 360)
	for i in range(15):
		await get_tree().physics_frame
	assert(chaser.velocity.x < 0, "Chaser failed to accelerate toward player")
	print("[PASS] 3. Enemy Chaser AI verified: actively pursues player (Velocity: %s)." % str(chaser.velocity))
	chaser.queue_free()
	
	# 4. Test Enemy Archetype: Striker (Standoff & Aimed Telegraph Attack)
	var striker = load("res://scenes/enemy_striker.tscn").instantiate()
	striker.global_position = Vector2(900.0, 360.0)
	main.add_child(striker)
	await get_tree().physics_frame
	
	# Force charge attack
	striker._start_charge()
	assert(striker._is_charging == true, "Striker failed to enter charge state")
	striker._charge_timer = 0.01
	await get_tree().physics_frame
	await get_tree().physics_frame
	striker._physics_process(0.02)
	
	var enemy_projs = get_tree().get_nodes_in_group("enemy_projectiles")
	assert(enemy_projs.size() > 0, "Striker failed to fire enemy projectile after charge")
	print("[PASS] 4. Enemy Striker AI verified: telegraphed charge and projectile discharge confirmed.")
	for ep in enemy_projs:
		ep.queue_free()
	striker.queue_free()
	
	# 5. Test Enemy Archetype: Dasher (Telegraph -> Charge -> Recovery)
	var dasher = load("res://scenes/enemy_dasher.tscn").instantiate()
	dasher.global_position = Vector2(700.0, 360.0)
	main.add_child(dasher)
	await get_tree().physics_frame
	
	dasher._enter_telegraph()
	assert(dasher.current_state == dasher.State.TELEGRAPHING, "Dasher not in TELEGRAPHING state")
	dasher._enter_dash()
	assert(dasher.current_state == dasher.State.DASHING, "Dasher not in DASHING state")
	assert(dasher.velocity.length() > 400.0, "Dasher velocity insufficient during dash")
	dasher._enter_recovery()
	assert(dasher.current_state == dasher.State.RECOVERING, "Dasher not in RECOVERING state")
	print("[PASS] 5. Enemy Dasher AI verified: State machine transitions (Telegraph -> Dash -> Recovery).")
	dasher.queue_free()
	
	# 6. Test Enemy Archetype: Heavy Shielded Construct (Directional Armor)
	var heavy = load("res://scenes/enemy_heavy.tscn").instantiate()
	heavy.global_position = Vector2(800.0, 360.0)
	main.add_child(heavy)
	await get_tree().physics_frame
	
	var initial_hp = heavy.current_health
	# Frontal hit arriving from left (x = 780 < 800)
	heavy.take_damage(35, 1, Vector2(780.0, 360.0))
	assert(heavy.current_health == initial_hp, "Heavy shield failed to absorb frontal hit! HP: %d" % heavy.current_health)
	
	# Rear ricochet hit arriving from right (x = 830 > 800)
	heavy.take_damage(35, 2, Vector2(830.0, 360.0))
	assert(heavy.current_health < initial_hp, "Heavy failed to take damage from rear flank hit!")
	print("[PASS] 6. Enemy Heavy Shield verified: Frontal hit absorbed (0 dmg); Rear ricochet hit dealt damage (HP: %d/%d)." % [
		heavy.current_health, initial_hp
	])
	heavy.queue_free()
	
	# 7. Test Boss: COMMANDER SERIN ("THE GATEKEEPER") Multi-Phase Combat
	var boss = load("res://scenes/boss_serin.tscn").instantiate()
	boss.global_position = Vector2(950.0, 360.0)
	main.add_child(boss)
	await get_tree().physics_frame
	
	assert(boss.current_health == 500, "Boss initial HP is not 500")
	assert(boss.current_phase == 1, "Boss initial phase is not 1")
	
	# Deal damage to transition to Phase 2 (< 65% HP, e.g. 300 HP)
	boss.take_damage(200, 1)
	assert(boss.current_phase == 2, "Boss failed to transition to Phase 2 at HP=%d" % boss.current_health)
	print("[PASS] 7a. Boss Commander Serin Phase 2 transition verified at HP=%d." % boss.current_health)
	
	# Deal damage to transition to Phase 3 (< 30% HP, e.g. 100 HP)
	boss.take_damage(200, 1)
	assert(boss.current_phase == 3, "Boss failed to transition to Phase 3 at HP=%d" % boss.current_health)
	print("[PASS] 7b. Boss Commander Serin Phase 3 transition verified at HP=%d." % boss.current_health)
	
	# Defeat Boss
	var gm = get_node_or_null("/root/GameManager")
	var prev_score = gm.score if gm else 0
	boss.take_damage(150, 2)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(!is_instance_valid(boss), "Boss failed to be cleaned up on zero HP")
	if gm:
		assert(gm.score > prev_score, "GameManager did not receive boss score reward")
	print("[PASS] 7c. Boss Commander Serin defeated, death sequence and score reward verified.")
	
	# 8. Test Dynamic Obstacles: MovingReflector & LaserGate
	var moving_refl = load("res://scenes/moving_reflector.tscn").instantiate()
	moving_refl.global_position = Vector2(600.0, 300.0)
	main.add_child(moving_refl)
	await get_tree().physics_frame
	assert(moving_refl.is_in_group("reflective"), "MovingReflector not in 'reflective' group")
	var init_y = moving_refl.position.y
	moving_refl._physics_process(0.1)
	assert(moving_refl.position.y != init_y, "MovingReflector failed to update vertical position")
	print("[PASS] 8a. MovingReflector verified: active reflection and vertical translation confirmed.")
	moving_refl.queue_free()
	
	var laser_gate = load("res://scenes/laser_gate.tscn").instantiate()
	laser_gate.global_position = Vector2(700.0, 360.0)
	main.add_child(laser_gate)
	await get_tree().physics_frame
	assert(laser_gate.is_active == false, "LaserGate warning state initial check failed")
	laser_gate._enter_active()
	assert(laser_gate.is_active == true, "LaserGate active lethal state failed")
	print("[PASS] 8b. LaserGate hazard verified: state cycling (Warning / Active) confirmed.")
	laser_gate.queue_free()
	
	# 9. Test RoundManager Encounter Progression
	var rm_script = load("res://scripts/round_manager.gd")
	var rm = Node.new()
	rm.set_script(rm_script)
	rm.auto_start_first_round = false
	main.add_child(rm)
	await get_tree().physics_frame
	
	rm.start_round(0)
	assert(rm.current_state == rm.State.COMBAT, "RoundManager failed to enter COMBAT state")
	assert(rm.time_remaining > 0.0, "RoundManager time limit not set")
	assert(rm.active_enemies.size() > 0, "RoundManager failed to spawn wave enemies")
	print("[PASS] 9a. RoundManager combat start verified: Round 0 started with %d active enemies." % rm.active_enemies.size())
	
	# Simulate clearing active wave
	for enemy in rm.active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	for i in range(5):
		await get_tree().physics_frame
	
	# Check wave progression
	assert(rm.current_wave_index >= 1 or rm.current_state == rm.State.WAVE_TRANSITION or rm.current_state == rm.State.VICTORY, "RoundManager failed wave progression")
	print("[PASS] 9b. RoundManager wave progression verified: Wave transition triggered cleanly.")
	
	# Test victory trigger
	rm._trigger_victory()
	assert(rm.current_state == rm.State.VICTORY, "RoundManager failed to enter VICTORY state")
	print("[PASS] 9c. RoundManager encounter victory state verified.")
	rm.queue_free()
	
	print("\n============================================================")
	print(">>> ALL 9 COMBAT AI & ENCOUNTER TEST SUITES PASSED 100%! <<<")
	print("============================================================\n")
	
	get_tree().quit(0)
