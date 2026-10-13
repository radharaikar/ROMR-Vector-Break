class_name EnemyDrone
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY DRONE AI
# Pursuit drone: turns toward player, accelerates along multi-directional trajectories,
# attacks with kinetic lunges, and slides cleanly along obstacle walls.
# ==============================================================================

@export_group("Combat Movement")
@export var pursue_speed: float = 95.0
@export var lunge_speed: float = 150.0
@export var turn_rate: float = 6.0
@export var contact_damage: int = 12

var _time_elapsed: float = 0.0
var _contact_cooldown: float = 0.0

enum State { PURSUING, ATTACKING, RECOVERING }
var current_state: State = State.PURSUING

func _init() -> void:
	max_health = 50
	score_value = 100
	base_speed = 95.0
	super._init()

func _ready() -> void:
	super._ready()
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
		rotation = lerp_angle(rotation, to_player.angle(), turn_rate * delta)
		
		match current_state:
			State.PURSUING:
				# Dynamic trajectory tracking with lateral wave weaving
				var lateral_weave = Vector2(-to_player.y, to_player.x) * sin(_time_elapsed * 3.5) * 0.3
				var trajectory = (to_player + lateral_weave).normalized()
				velocity = velocity.move_toward(trajectory * pursue_speed, 240.0 * delta)
				
				if dist_to_player < 130.0:
					current_state = State.ATTACKING
					
			State.ATTACKING:
				velocity = velocity.move_toward(to_player * lunge_speed, 380.0 * delta)
				if dist_to_player > 180.0:
					current_state = State.PURSUING
					
			State.RECOVERING:
				velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
				if _contact_cooldown <= 0.2:
					current_state = State.PURSUING
	else:
		velocity = velocity.move_toward(Vector2(-base_speed * 0.6, 0), 120.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
			collider.take_damage(contact_damage, self)
			_contact_cooldown = 1.0
			current_state = State.RECOVERING
			velocity = normal * 90.0
		else:
			# Surface slide vector to avoid getting hung up on reflectors/boundaries
			velocity = velocity.slide(normal)
	
	# Keep within active play arena
	global_position.x = clamp(global_position.x, 30.0, 1260.0)
	global_position.y = clamp(global_position.y, 40.0, 680.0)
