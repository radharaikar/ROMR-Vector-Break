class_name EnemyDasher
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY DASHER AI
# High-speed skirmisher: circles player anywhere in the arena, locks trajectory,
# telegraphs linear charge, lunges at extreme speed, and recovers vulnerably.
# ==============================================================================

enum State { TRACKING, TELEGRAPHING, DASHING, RECOVERING }
var current_state: State = State.TRACKING

@export var dash_speed: float = 480.0
@export var telegraph_duration: float = 0.6
@export var dash_duration: float = 0.55
@export var recovery_duration: float = 1.0
@export var contact_damage: int = 25

var _state_timer: float = 2.0
var _dash_vector: Vector2 = Vector2.LEFT
var _contact_cooldown: float = 0.0

func _init() -> void:
	max_health = 45
	score_value = 175
	base_speed = 90.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(1.0, 0.8, 0.2) # High-voltage amber skirmisher tint

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
				var to_player = (player.global_position - global_position).normalized()
				var dist_to_player = global_position.distance_to(player.global_position)
				rotation = lerp_angle(rotation, to_player.angle(), 6.0 * delta)
				
				# Position at combat staging orbit (~280px)
				var desired_pos = player.global_position - to_player * 280.0
				var move_dir = (desired_pos - global_position).normalized()
				velocity = velocity.move_toward(move_dir * base_speed, 260.0 * delta)
				_dash_vector = to_player
			else:
				velocity = velocity.move_toward(Vector2(-base_speed * 0.5, 0), 120.0 * delta)
			
			move_and_slide()
			if _state_timer <= 0.0:
				_enter_telegraph()
				
		State.TELEGRAPHING:
			velocity = velocity.move_toward(Vector2.ZERO, 350.0 * delta)
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
					_enter_recovery()
				else:
					# Bounce / slide along obstacle
					_dash_vector = _dash_vector.bounce(collision.get_normal())
					velocity = _dash_vector * dash_speed
			
			if _state_timer <= 0.0:
				_enter_recovery()
				
		State.RECOVERING:
			velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
			move_and_slide()
			if _state_timer <= 0.0:
				current_state = State.TRACKING
				_state_timer = randf_range(1.8, 2.8)
				modulate = Color(1.0, 0.8, 0.2)
	
	global_position.x = clamp(global_position.x, 40.0, 1250.0)
	global_position.y = clamp(global_position.y, 50.0, 670.0)

func _enter_telegraph() -> void:
	current_state = State.TELEGRAPHING
	_state_timer = telegraph_duration
	modulate = Color(1.8, 0.3, 0.1) # Warning crimson charge telegraph

func _enter_dash() -> void:
	current_state = State.DASHING
	_state_timer = dash_duration
	velocity = _dash_vector * dash_speed
	modulate = Color(2.0, 1.2, 0.4) # Kinetic energy burst

func _enter_recovery() -> void:
	current_state = State.RECOVERING
	_state_timer = recovery_duration
	modulate = Color(0.6, 0.6, 0.6, 0.8) # Exhaustion / recovery window

func _draw() -> void:
	if current_state == State.TELEGRAPHING:
		var progress = 1.0 - (_state_timer / telegraph_duration)
		var preview_end = to_local(global_position + _dash_vector * 320.0)
		var col = Color(1.0, 0.2, 0.2, lerp(0.4, 0.9, progress))
		draw_line(Vector2.ZERO, preview_end, col, 2.5)
		draw_circle(preview_end, 5.0 * progress, col)
