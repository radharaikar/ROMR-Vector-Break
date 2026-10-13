class_name EnemyDrone
extends "res://scripts/enemy_base.gd"

## Basic geometric spike drone for VECTOR//BREAK.
## Drifts horizontally with a smooth sinusoidal vertical wave pattern.

@export_group("Movement")
@export var bob_amplitude: float = 24.0
@export var bob_frequency: float = 2.2

var _time_elapsed: float = 0.0
var _initial_y: float = 0.0

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
	
	# Horizontal advance & sinusoidal vertical bob
	var target_y = _initial_y + sin(_time_elapsed * bob_frequency) * bob_amplitude
	velocity.x = -base_speed
	velocity.y = (target_y - global_position.y) * 4.0
	
	if is_inside_tree() and get_world_2d() != null:
		move_and_slide()
		
	# Arena wrap-around if exiting left border
	if global_position.x < -60.0:
		global_position.x = 1340.0
		_initial_y = randf_range(120.0, 600.0)
		global_position.y = _initial_y
