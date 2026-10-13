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

var health: int
var is_dead: bool = false
var _contact_cooldown: float = 0.0
var _time_elapsed: float = 0.0

enum State { PURSUING, ATTACKING, RECOVERING }
var current_state: State = State.PURSUING

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	_time_elapsed = randf() * TAU

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
		if gm.has_method("spawn_pickup") and randf() < 0.35:
			gm.spawn_pickup(gm.PickupType.NANOCELL, global_position)
	
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
