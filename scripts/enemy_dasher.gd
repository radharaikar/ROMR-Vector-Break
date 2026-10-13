class_name EnemyDasher
extends "res://scripts/enemy_base.gd"

## High-speed skirmisher. Telegraphs a linear charge, dashes, then enters a recovery window.

enum State { TRACKING, TELEGRAPHING, DASHING, RECOVERING }
var current_state: State = State.TRACKING

@export var dash_speed: float = 460.0
@export var telegraph_duration: float = 0.6
@export var dash_duration: float = 0.55
@export var recovery_duration: float = 1.2
@export var contact_damage: int = 25

var _state_timer: float = 2.0
var _dash_vector: Vector2 = Vector2.LEFT
var _contact_cooldown: float = 0.0

func _init() -> void:
	max_health = 45
	score_value = 175
	base_speed = 80.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(1.0, 0.8, 0.2) # High-voltage amber tint

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	
	_state_timer -= delta
	
	match current_state:
		State.TRACKING:
			var player = get_tree().get_first_node_in_group("player")
			if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
				var target_pos = Vector2(clamp(player.global_position.x + 350.0, 600.0, 1150.0), player.global_position.y)
				velocity = velocity.move_toward((target_pos - global_position).normalized() * base_speed, 250.0 * delta)
				_dash_vector = (player.global_position - global_position).normalized()
			else:
				velocity = velocity.move_toward(Vector2(-base_speed, 0), 100.0 * delta)
			
			move_and_slide()
			if _state_timer <= 0.0:
				_enter_telegraph()
				
		State.TELEGRAPHING:
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			move_and_slide()
			queue_redraw()
			if _state_timer <= 0.0:
				_enter_dash()
				
		State.DASHING:
			velocity = _dash_vector * dash_speed
			var collision = move_and_collide(velocity * delta)
			if collision:
				var collider = collision.get_collider()
				if collider and collider.is_in_group("player") and _contact_cooldown <= 0.0:
					collider.take_damage(contact_damage, self)
					_contact_cooldown = 1.0
			if _state_timer <= 0.0:
				_enter_recovery()
				
		State.RECOVERING:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			move_and_slide()
			if _state_timer <= 0.0:
				_enter_tracking()

func _enter_telegraph() -> void:
	current_state = State.TELEGRAPHING
	_state_timer = telegraph_duration

func _enter_dash() -> void:
	current_state = State.DASHING
	_state_timer = dash_duration
	velocity = _dash_vector * dash_speed
	queue_redraw()

func _enter_recovery() -> void:
	current_state = State.RECOVERING
	_state_timer = recovery_duration

func _enter_tracking() -> void:
	current_state = State.TRACKING
	_state_timer = 2.0

func _draw() -> void:
	if current_state == State.TELEGRAPHING and not is_dead:
		var progress = 1.0 - (_state_timer / telegraph_duration)
		var alert_end = to_local(global_position + _dash_vector * 320.0)
		var alert_col = Color(1.0, 0.7, 0.0, lerp(0.3, 0.9, progress))
		draw_line(Vector2.ZERO, alert_end, alert_col, lerp(1.5, 4.0, progress))
		draw_circle(Vector2.ZERO, lerp(6.0, 14.0, progress), Color(1.0, 0.9, 0.2, 0.5))
