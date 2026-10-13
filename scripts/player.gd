class_name PlayerShip
extends CharacterBody2D

@export var max_speed: float = 380.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0
@export var fire_cooldown: float = 0.18

var can_fire: bool = true
var fire_timer: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var muzzle: Marker2D = get_node_or_null("Muzzle")

# Arena bounds for player movement (left sector)
const MIN_X: float = 50.0
const MAX_X: float = 480.0
const MIN_Y: float = 60.0
const MAX_Y: float = 660.0

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0.0:
			can_fire = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_fire()
	
	queue_redraw()

func _physics_process(delta: float) -> void:
	# WASD / Arrow Keys movement
	var input_vector = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()
	
	# Clamp player to arena boundary
	global_position.x = clamp(global_position.x, MIN_X, MAX_X)
	global_position.y = clamp(global_position.y, MIN_Y, MAX_Y)
	
	# Subtle pitch tilt following vertical velocity
	if sprite:
		sprite.rotation = lerp(sprite.rotation, (velocity.y / max_speed) * 0.18, 12.0 * delta)

func _try_fire() -> void:
	if not can_fire:
		return
	can_fire = false
	fire_timer = fire_cooldown
	
	var muzzle_pos = muzzle.global_position if muzzle else global_position + Vector2(28, 0)
	var mouse_pos = get_global_mouse_position()
	var shoot_dir = (mouse_pos - muzzle_pos).normalized()
	
	var proj_scene = load("res://scenes/energy_projectile.tscn")
	if proj_scene:
		var proj = proj_scene.instantiate()
		proj.global_position = muzzle_pos
		proj.direction = shoot_dir
		get_parent().add_child(proj)
		
		# Slight recoil kick
		velocity -= shoot_dir * 45.0

func _draw() -> void:
	# Draw neon aiming vector line towards mouse cursor
	var muzzle_pos = muzzle.position if muzzle else Vector2(28, 0)
	var local_mouse = to_local(get_global_mouse_position())
	var aim_dir = (local_mouse - muzzle_pos).normalized()
	var preview_length = 120.0
	var aim_end = muzzle_pos + aim_dir * preview_length
	
	# Faint cyan aiming laser
	draw_line(muzzle_pos, aim_end, Color(0.2, 0.8, 1.0, 0.4), 1.5)
	# Crosshair dot at aiming distance
	draw_circle(aim_end, 2.5, Color(0.3, 0.9, 1.0, 0.7))
