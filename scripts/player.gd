class_name PlayerShip
extends CharacterBody2D

signal health_changed(current_hp: int, max_hp: int)
signal player_damaged(damage: int, hit_source: Node)
signal player_healed(amount: int)
signal invulnerability_changed(is_invulnerable: bool)
signal player_died()

@export var max_speed: float = 380.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0
@export var fire_cooldown: float = 0.18

@export var max_health: int = 100
var current_health: int = 100
var is_invulnerable: bool = false
var invuln_timer: float = 0.0
const I_FRAMES_DURATION: float = 1.0

var can_fire: bool = true
var fire_timer: float = 0.0
var is_dead: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var muzzle: Marker2D = get_node_or_null("Muzzle")

# Arena bounds for player movement across the arena
const MIN_X: float = 50.0
const MAX_X: float = 1220.0
const MIN_Y: float = 60.0
const MAX_Y: float = 660.0

func _ready() -> void:
	current_health = max_health
	add_to_group("player")
	emit_signal("health_changed", current_health, max_health)

func _process(delta: float) -> void:
	if is_dead:
		return

	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0.0:
			can_fire = true
	
	if is_invulnerable:
		invuln_timer -= delta
		# Blinking visual feedback
		if sprite:
			sprite.visible = int(invuln_timer * 12.0) % 2 == 0
		if invuln_timer <= 0.0:
			is_invulnerable = false
			if sprite:
				sprite.visible = true
			emit_signal("invulnerability_changed", false)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_fire()
	
	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

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

func take_damage(amount: int, hit_source: Node = null) -> void:
	if is_dead or is_invulnerable or amount <= 0:
		return
	
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health, max_health)
	emit_signal("player_damaged", amount, hit_source)
	
	# Hit flash
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3.0, 0.4, 0.4, 1.0) # Red damage flash
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	
	# Enter invulnerability window
	set_invulnerable(I_FRAMES_DURATION)
	
	if current_health <= 0:
		_die()

func set_invulnerable(duration: float) -> void:
	is_invulnerable = true
	invuln_timer = duration
	emit_signal("invulnerability_changed", true)

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health, max_health)
	emit_signal("player_healed", amount)

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func is_alive() -> bool:
	return not is_dead

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("player_died")
	
	# Spawn explosion
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene:
		for i in range(6):
			var spark = spark_scene.instantiate()
			spark.global_position = global_position
			var angle = randf() * TAU
			spark.setup(Vector2(cos(angle), sin(angle)), Color(1.0, 0.3, 0.2))
			get_parent().add_child(spark)
	
	if sprite:
		sprite.visible = false

func _try_fire() -> void:
	if not can_fire or is_dead:
		return
	can_fire = false
	fire_timer = fire_cooldown
	
	var muzzle_pos = muzzle.global_position if muzzle else global_position + Vector2(28, 0)
	var mouse_pos = get_global_mouse_position()
	var shoot_dir = (mouse_pos - muzzle_pos).normalized()
	if shoot_dir == Vector2.ZERO:
		shoot_dir = Vector2.RIGHT
	
	var proj_scene = load("res://scenes/energy_projectile.tscn")
	if proj_scene:
		var proj = proj_scene.instantiate()
		proj.global_position = muzzle_pos
		proj.direction = shoot_dir
		get_parent().add_child(proj)
		
		# Slight recoil kick
		velocity -= shoot_dir * 45.0

func _draw() -> void:
	if is_dead:
		return

	# Draw neon aiming vector line towards mouse cursor
	var muzzle_pos = muzzle.position if muzzle else Vector2(28, 0)
	var local_mouse = to_local(get_global_mouse_position())
	var aim_dir = (local_mouse - muzzle_pos).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT
	var preview_length = 120.0
	var aim_end = muzzle_pos + aim_dir * preview_length
	
	# Faint cyan aiming laser
	draw_line(muzzle_pos, aim_end, Color(0.2, 0.8, 1.0, 0.4), 1.5)
	# Crosshair dot at aiming distance
	draw_circle(aim_end, 2.5, Color(0.3, 0.9, 1.0, 0.7))
