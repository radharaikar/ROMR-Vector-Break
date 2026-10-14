class_name LaserGate
extends Area2D

## Pulsating energy gate hazard. Cycles between telegraphed warning and active lethal laser.

@export var warning_duration: float = 2.0
@export var active_duration: float = 1.4
@export var damage: int = 20
@export var beam_length: float = 240.0

var is_active: bool = false
var _state_timer: float = 2.0
var _contact_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_enter_warning()

func _physics_process(delta: float) -> void:
	_state_timer -= delta
	if _contact_timer > 0.0:
		_contact_timer -= delta
	
	if is_active:
		if _contact_timer <= 0.0:
			for body in get_overlapping_bodies():
				if body.is_in_group("player") and body.has_method("take_damage"):
					body.take_damage(damage, self)
					_contact_timer = 0.8
		if _state_timer <= 0.0:
			_enter_warning()
	else:
		if _state_timer <= 0.0:
			_enter_active()
	
	queue_redraw()

func _enter_warning() -> void:
	is_active = false
	_state_timer = warning_duration
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _enter_active() -> void:
	is_active = true
	_state_timer = active_duration
	if collision_shape:
		collision_shape.set_deferred("disabled", false)

func _draw() -> void:
	var start_pt = Vector2(0, -beam_length * 0.5)
	var end_pt = Vector2(0, beam_length * 0.5)
	
	if is_active:
		# Lethal laser beam
		draw_line(start_pt, end_pt, Color(1.0, 0.15, 0.1, 0.9), 6.0)
		draw_line(start_pt, end_pt, Color(1.0, 0.9, 0.7, 1.0), 2.5)
	else:
		# Telegraphed warning beam (dim pulsing)
		var progress = 1.0 - (_state_timer / warning_duration)
		var alpha = lerp(0.15, 0.55, progress)
		draw_line(start_pt, end_pt, Color(1.0, 0.3, 0.1, alpha), 2.0)
