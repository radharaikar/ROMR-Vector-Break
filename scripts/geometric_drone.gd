class_name GeometricDrone
extends CharacterBody2D

# ==============================================================================
# VECTOR//BREAK — GEOMETRIC DRONE AI
# Active pursuit AI: tracks player position, turns toward player, accelerates,
# performs attack lunges, and slides cleanly around obstacles.
# ==============================================================================

@export var max_health: int = 50
@export var base_speed: float = 85.0
@export var attack_lunge_speed: float = 140.0
@export var contact_damage: int = 10
@export var fire_interval: float = 3.4
@export var shot_damage: int = 10

var health: int
var is_dead: bool = false
var _contact_cooldown: float = 0.0
var _time_elapsed: float = 0.0
var _fire_timer: float = 2.2
var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

enum State { PURSUING, ATTACKING, RECOVERING }
var current_state: State = State.PURSUING

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	_time_elapsed = randf() * TAU
	_fire_timer = randf_range(1.8, 3.2)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_time_elapsed += delta
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var to_player = (player.global_position - global_position).normalized()
		var dist_to_player = global_position.distance_to(player.global_position)
		
		# Smoothly rotate toward player
		rotation = lerp_angle(rotation, to_player.angle(), 6.0 * delta)
		
		# Controlled hostile projectile firing
		_fire_timer -= delta
		if _fire_timer <= 0.0 and dist_to_player < 700.0 and dist_to_player > 110.0:
			_fire_shot(to_player)
			_fire_timer = randf_range(2.8, 4.0)
		
		# State Machine
		match current_state:
			State.PURSUING:
				# Sinusoidal micro-wave weaving to make flight dynamic
				var weave_offset = Vector2(-to_player.y, to_player.x) * sin(_time_elapsed * 3.0) * 0.35
				var pursue_vector = (to_player + weave_offset).normalized()
				velocity = velocity.move_toward(pursue_vector * base_speed, 220.0 * delta)
				
				if dist_to_player < 120.0:
					current_state = State.ATTACKING
					
			State.ATTACKING:
				# Accelerated attack lunge
				velocity = velocity.move_toward(to_player * attack_lunge_speed, 350.0 * delta)
				if dist_to_player > 160.0:
					current_state = State.PURSUING
					
			State.RECOVERING:
				velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
				if _contact_cooldown <= 0.2:
					current_state = State.PURSUING
	else:
		# Idle patrol drift if player is absent or dead
		velocity = velocity.move_toward(Vector2(-base_speed * 0.6, 0), 120.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
			collider.take_damage(contact_damage, self)
			_contact_cooldown = 1.0
			current_state = State.RECOVERING
			velocity = normal * 80.0 # Rebound away on impact
		else:
			# Slide smoothly along surfaces to avoid getting stuck
			velocity = velocity.slide(normal)
	
	# Clamp within arena margins
	global_position.x = clamp(global_position.x, 30.0, 1260.0)
	global_position.y = clamp(global_position.y, 40.0, 680.0)

func take_damage(amount: int, combo_multiplier: Variant = 1, _hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	
	health -= amount
	_flash_feedback()
	
	if health <= 0:
		var mult: int = 1
		if typeof(combo_multiplier) == TYPE_INT or typeof(combo_multiplier) == TYPE_FLOAT:
			mult = int(combo_multiplier)
		_die(mult)

func _flash_feedback() -> void:
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3.0, 1.2, 2.5, 1.0)
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.16)

func _die(combo_multiplier: int) -> void:
	if is_dead:
		return
	is_dead = true
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_hit(combo_multiplier)
		gm.add_score(100, combo_multiplier)
		if gm.has_method("award_currency"):
			gm.award_currency(15, "drone_%d" % get_instance_id())
		if gm.has_method("spawn_pickup"):
			var safe_pos = Vector2(clamp(global_position.x, 80.0, 1200.0), clamp(global_position.y, 80.0, 640.0))
			var player_node = get_tree().get_first_node_in_group("player") if is_inside_tree() else null
			var is_damaged = player_node != null and "current_health" in player_node and "max_health" in player_node and player_node.current_health < player_node.max_health
			var drop_chance: float = 0.40 if is_damaged else 0.20
			if randf() < drop_chance:
				gm.spawn_pickup(gm.PickupType.NANOCELL, safe_pos)
	
	_spawn_explosion()
	queue_free()

func _spawn_explosion() -> void:
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene and get_parent():
		for i in range(4):
			var spark = spark_scene.instantiate()
			var angle = randf() * TAU
			var dir = Vector2(cos(angle), sin(angle))
			var col = Color(1.0, 0.2, 0.8) if (i % 2 == 0) else Color(0.2, 0.9, 1.0)
			spark.global_position = global_position
			if spark.has_method("setup"):
				spark.setup(dir, col)
			get_parent().add_child(spark)

func _fire_shot(target_dir: Vector2) -> void:
	if projectile_scene and get_parent():
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + target_dir * 20.0
		proj.direction = target_dir
		proj.speed = 360.0
		proj.damage = shot_damage
		proj.shooter = self # Prevent self-damage
		get_parent().add_child(proj)
