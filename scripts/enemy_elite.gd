class_name EnemyElite
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY ELITE ARBITER
# High-threat commander construct: dual rotating orbital energy shields,
# alternating plasma blasters, phase-warp displacement, and 5-way radial barrage.
# ==============================================================================

@export var fire_interval: float = 2.0
@export var warp_cooldown: float = 6.0
@export var shot_damage: int = 14

var _fire_timer: float = 1.5
var _warp_timer: float = 4.0
var _orbital_angle: float = 0.0
var _is_warping: bool = false
var _warp_charge_timer: float = 0.0
var _in_overdrive: bool = false
var _shot_side: int = 1

enum State { TACTICAL_ORBIT, WARP_AMBUSH, RADIAL_BURST }
var current_state: State = State.TACTICAL_ORBIT

var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

func _init() -> void:
	max_health = 220
	score_value = 500
	base_speed = 105.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(1.2, 0.4, 1.1) # Elite royal magenta / violet core

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_orbital_angle += (6.0 if _in_overdrive else 3.2) * delta
	queue_redraw()
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var to_player = (player.global_position - global_position).normalized()
		var dist_to_player = global_position.distance_to(player.global_position)
		
		# Turn toward player
		rotation = lerp_angle(rotation, to_player.angle(), 5.0 * delta)
		
		# Check Overdrive condition (< 40% max HP)
		if current_health < max_health * 0.4 and not _in_overdrive:
			_in_overdrive = true
			base_speed = 135.0
			modulate = Color(1.8, 0.2, 0.5) # Blood-crimson overdrive
		
		# Timers
		_warp_timer -= delta
		if _warp_timer <= 0.0 and dist_to_player < 220.0 and not _is_warping:
			_trigger_phase_warp()
		
		_fire_timer -= delta
		if _fire_timer <= 0.0 and not _is_warping:
			if _in_overdrive and randf() < 0.4:
				_fire_radial_barrage(to_player)
				_fire_timer = 2.6
			else:
				_fire_twin_plasma(to_player)
				_fire_timer = 1.6 if _in_overdrive else fire_interval
		
		# Flight movement: Standoff tactical orbit (~280px)
		var desired_pos = player.global_position - to_player * 290.0
		var move_dir = (desired_pos - global_position).normalized()
		velocity = velocity.move_toward(move_dir * base_speed, 280.0 * delta)
	else:
		velocity = velocity.move_toward(Vector2(-base_speed * 0.5, 0), 120.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
	
	global_position.x = clamp(global_position.x, 60.0, 1220.0)
	global_position.y = clamp(global_position.y, 70.0, 650.0)

func _fire_twin_plasma(target_dir: Vector2) -> void:
	if not projectile_scene or not get_parent():
		return
	
	_shot_side = -_shot_side
	var perp = Vector2(-target_dir.y, target_dir.x) * (20.0 * _shot_side)
	var spawn_pos = global_position + target_dir * 24.0 + perp
	
	var proj = projectile_scene.instantiate()
	proj.global_position = spawn_pos
	proj.direction = target_dir
	proj.speed = 480.0
	proj.damage = shot_damage
	proj.shooter = self # Self-damage guard
	proj.add_collision_exception_with(self)
	get_parent().add_child(proj)

func _fire_radial_barrage(target_dir: Vector2) -> void:
	if not projectile_scene or not get_parent():
		return
	
	var angles = [-0.32, -0.16, 0.0, 0.16, 0.32]
	for ang in angles:
		var dir = target_dir.rotated(ang)
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + dir * 28.0
		proj.direction = dir
		proj.speed = 420.0
		proj.damage = int(shot_damage * 0.85)
		proj.shooter = self
		proj.add_collision_exception_with(self)
		get_parent().add_child(proj)

func _trigger_phase_warp() -> void:
	_is_warping = true
	_warp_timer = warp_cooldown
	
	# Spawn departure flash
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene and get_parent():
		for i in range(4):
			var spark = spark_scene.instantiate()
			spark.global_position = global_position
			spark.setup(Vector2.from_angle(randf() * TAU), Color(1.5, 0.3, 1.8))
			get_parent().add_child(spark)
	
	# Compute safe ambush coordinate away from borders
	var player = get_tree().get_first_node_in_group("player")
	var new_x = randf_range(300.0, 1100.0)
	var new_y = randf_range(120.0, 600.0)
	if player and is_instance_valid(player):
		# Re-appear at a tactical 350px offset
		var warp_vec = Vector2.from_angle(randf() * TAU) * 350.0
		var candidate = player.global_position + warp_vec
		new_x = clamp(candidate.x, 80.0, 1200.0)
		new_y = clamp(candidate.y, 80.0, 640.0)
	
	global_position = Vector2(new_x, new_y)
	
	# Arrival effect
	if spark_scene and get_parent():
		var spark = spark_scene.instantiate()
		spark.global_position = global_position
		spark.setup(Vector2.ZERO, Color(2.0, 1.8, 0.4))
		get_parent().add_child(spark)
	
	_is_warping = false

func take_damage(amount: int, combo_multiplier: Variant = 1, hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	
	super.take_damage(amount, combo_multiplier, hit_point)
	
	# If struck while not in warp cooldown, chance to reactive-warp away
	if current_health > 0 and _warp_timer <= 2.0 and randf() < 0.35:
		_trigger_phase_warp()

func _draw() -> void:
	# Draw dual rotating orbital shield rings
	var ring_radius = 34.0
	var ring_col_a = Color(1.0, 0.3, 0.8, 0.85) if not _in_overdrive else Color(1.5, 0.2, 0.2, 0.95)
	var ring_col_b = Color(0.2, 0.9, 1.0, 0.85) if not _in_overdrive else Color(1.2, 0.8, 0.1, 0.95)
	
	# Primary rotating segmented arc
	draw_arc(Vector2.ZERO, ring_radius, _orbital_angle, _orbital_angle + PI * 0.8, 16, ring_col_a, 2.5)
	draw_arc(Vector2.ZERO, ring_radius, _orbital_angle + PI, _orbital_angle + PI * 1.8, 16, ring_col_a, 2.5)
	
	# Counter-rotating outer nodes
	var node_r = 42.0
	var p1 = Vector2(cos(-_orbital_angle * 1.2), sin(-_orbital_angle * 1.2)) * node_r
	var p2 = -p1
	draw_circle(p1, 4.0, ring_col_b)
	draw_circle(p2, 4.0, ring_col_b)
