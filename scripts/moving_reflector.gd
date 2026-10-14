class_name MovingReflector
extends StaticBody2D

## Dynamic vertically translating reflector. Shifts ricochet vectors in real time.

@export var move_speed: float = 75.0
@export var min_y: float = 180.0
@export var max_y: float = 540.0

var _direction: float = 1.0

func _ready() -> void:
	add_to_group("reflective")
	add_to_group("reflectors")

func _physics_process(delta: float) -> void:
	position.y += _direction * move_speed * delta
	if position.y >= max_y:
		position.y = max_y
		_direction = -1.0
	elif position.y <= min_y:
		position.y = min_y
		_direction = 1.0

func on_ricochet(impact_pos: Vector2, _normal: Vector2) -> void:
	var tween = create_tween()
	modulate = Color(2.5, 1.0, 2.5, 1.0)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
