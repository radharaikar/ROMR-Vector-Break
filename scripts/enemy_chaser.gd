class_name EnemyChaser
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY CHASER AI
# Aggressive pursuit hunter: cuts off angles with predictive velocity leading,
# strikes in close quarters, and slides around obstacle geometry.
# ==============================================================================

@export var chase_speed: float = 155.0
@export var attack_speed: float = 210.0
@export var turn_rate: float = 7.5
@export var contact_damage: int = 15

var _contact_cooldown: float = 0.0

enum State { PURSUING, ATTACKING, RECOVERING }
var current_state: State = State.PURSUING

func _init() -> void:
	max_health = 40
	score_value = 150
	base_speed = 155.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(1.0, 0.45, 0.3) # Crimson / orange hunter tint

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		# Lead target: aim ahead of player's current velocity
		var player_vel = player.velocity if "velocity" in player else Vector2.ZERO
		var predicted_pos = player.global_position + player_vel * 0.2
		var to_target = (predicted_pos - global_position).normalized()
		var dist_to_player = global_position.distance_to(player.global_position)
		
		rotation = lerp_angle(rotation, to_target.angle(), turn_rate * delta)
		
		match current_state:
			State.PURSUING:
				velocity = velocity.move_toward(to_target * chase_speed, 340.0 * delta)
				if dist_to_player < 110.0:
					current_state = State.ATTACKING
					
			State.ATTACKING:
				velocity = velocity.move_toward(to_target * attack_speed, 460.0 * delta)
				if dist_to_player > 160.0:
					current_state = State.PURSUING
					
			State.RECOVERING:
				velocity = velocity.move_toward(Vector2.ZERO, 260.0 * delta)
				if _contact_cooldown <= 0.2:
					current_state = State.PURSUING
	else:
		velocity = velocity.move_toward(Vector2(-base_speed * 0.5, 0), 150.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
			collider.take_damage(contact_damage, self)
			_contact_cooldown = 1.0
			current_state = State.RECOVERING
			velocity = normal * 100.0
		else:
			# Surface slide vector to prevent jamming against reflectors
			velocity = velocity.slide(normal)
	
	global_position.x = clamp(global_position.x, 30.0, 1260.0)
	global_position.y = clamp(global_position.y, 40.0, 680.0)
