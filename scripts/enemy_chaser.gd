class_name EnemyChaser
extends "res://scripts/enemy_base.gd"

## Aggressive pursuer enemy. Actively tracks and closes in on player position.

@export var chase_speed: float = 145.0
@export var turn_rate: float = 4.5
@export var contact_damage: int = 15

var _contact_cooldown: float = 0.0

func _init() -> void:
	max_health = 40
	score_value = 150
	base_speed = 145.0
	super._init()

func _ready() -> void:
	super._ready()
	# Distinct red/orange hunter tint
	modulate = Color(1.0, 0.45, 0.3)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var to_player = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(to_player * chase_speed, turn_rate * chase_speed * delta)
		rotation = lerp_angle(rotation, to_player.angle(), 8.0 * delta)
	else:
		velocity = velocity.move_toward(Vector2(-base_speed, 0), 200.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
			collider.take_damage(contact_damage, self)
			_contact_cooldown = 1.0
			velocity = -velocity * 0.5 # Rebound slightly on hit
