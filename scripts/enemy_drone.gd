class_name EnemyDrone
extends "res://scripts/enemy_base.gd"

## Basic geometric spike drone for VECTOR//BREAK.
## Drifts horizontally with a sinusoidal vertical wave pattern, gently pressuring player altitude.

@export_group("Movement")
@export var bob_amplitude: float = 24.0
@export var bob_frequency: float = 2.2
@export var contact_damage: int = 10

var _time_elapsed: float = 0.0
var _initial_y: float = 0.0
var _contact_cooldown: float = 0.0

func _init() -> void:
	max_health = 50
	score_value = 100
	base_speed = 65.0
	super._init()

func _ready() -> void:
	super._ready()
	_initial_y = global_position.y
	_time_elapsed = randf() * TAU

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	_time_elapsed += delta
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	
	# Gentle altitude tracking toward player
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var target_altitude = player.global_position.y
		_initial_y = lerp(_initial_y, target_altitude, 0.4 * delta)
	
	# Horizontal advance & sinusoidal vertical bob
	var target_y = _initial_y + sin(_time_elapsed * bob_frequency) * bob_amplitude
	velocity.x = -base_speed
	velocity.y = (target_y - global_position.y) * 4.0
	
	if is_inside_tree() and get_world_2d() != null:
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
				collider.take_damage(contact_damage, self)
				_contact_cooldown = 1.0
		
	# Arena wrap-around if exiting left border
	if global_position.x < -60.0:
		global_position.x = 1340.0
		_initial_y = randf_range(120.0, 600.0)
		global_position.y = _initial_y
