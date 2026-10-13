class_name Player
extends CharacterBody2D

## Signals for HUD and gameplay synchronization
signal health_changed(current: int, max: int)
signal player_damaged(amount: int, hit_source: Variant)
signal player_healed(amount: int)
signal invulnerability_changed(is_invulnerable: bool)
signal player_died()

@export var max_speed: float = 380.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0
@export var fire_cooldown: float = 0.18

# Health and survival parameters
@export var max_health: int = 100
var current_health: int = 100
var is_invulnerable: bool = false
var invulnerability_duration: float = 0.8
var invulnerability_timer: float = 0.0
var is_dead: bool = false

# Weapon and progression modifiers
var can_fire: bool = true
var fire_timer: float = 0.0
var max_projectile_bounces_bonus: int = 0
var aim_preview_length: float = 120.0
var current_skin_id: String = "skin_default"

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var muzzle: Marker2D = get_node_or_null("Muzzle")

# Playable arena movement boundaries
const MIN_X: float = 60.0
const MAX_X: float = 1220.0 # Full 1280x720 arena width with boundary margins
const MIN_Y: float = 60.0
const MAX_Y: float = 660.0

func _ready() -> void:
	add_to_group("player")
	if SaveManager:
		apply_upgrades()
		apply_skin(SaveManager.get_equipped_skin())
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func _process(delta: float) -> void:
	# Post-damage invulnerability countdown and visual flicker
	if is_invulnerable:
		invulnerability_timer -= delta
		if sprite:
			sprite.modulate.a = 0.35 if fmod(invulnerability_timer * 14.0, 2.0) > 1.0 else 1.0
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			if sprite:
				sprite.modulate.a = 1.0
			emit_signal("invulnerability_changed", false)
	
	if is_dead:
		queue_redraw()
		return
	
	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0.0:
			can_fire = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_SPACE):
		_try_fire()
	
	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
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
	
	# Clamp position to arena boundaries
	global_position.x = clamp(global_position.x, MIN_X, MAX_X)
	global_position.y = clamp(global_position.y, MIN_Y, MAX_Y)
	
	# Subtle ship banking tilt based on vertical velocity
	if sprite:
		sprite.rotation = lerp(sprite.rotation, (velocity.y / max_speed) * 0.18, 12.0 * delta)

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
		
		# Apply Vector Capacitor upgrade bonus if present
		if max_projectile_bounces_bonus > 0 and "max_bounces" in proj:
			proj.max_bounces += max_projectile_bounces_bonus
		
		get_parent().add_child(proj)
		
		# Recoil kick
		velocity -= shoot_dir * 40.0

func _draw() -> void:
	if is_dead:
		return
	
	# Draw neon aiming vector line towards mouse cursor
	var muzzle_pos = muzzle.position if muzzle else Vector2(28, 0)
	var local_mouse = to_local(get_global_mouse_position())
	var aim_dir = (local_mouse - muzzle_pos).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT
	var aim_end = muzzle_pos + aim_dir * aim_preview_length
	
	# Faint cyan aiming laser
	draw_line(muzzle_pos, aim_end, Color(0.2, 0.8, 1.0, 0.45), 1.5)
	# Crosshair dot at aiming distance
	draw_circle(aim_end, 2.5, Color(0.3, 0.9, 1.0, 0.75))

# ==============================================================================
# COMBAT DAMAGE & HEALING INTERFACE
# ==============================================================================

func take_damage(amount: int, hit_source: Variant = null) -> bool:
	if is_dead or is_invulnerable or amount <= 0:
		return false
	
	var actual_damage: int = max(1, amount)
	current_health = max(0, current_health - actual_damage)
	
	emit_signal("player_damaged", actual_damage, hit_source)
	emit_signal("health_changed", current_health, max_health)
	
	# Visual hurt flash
	if sprite:
		var original_color = _get_skin_color(current_skin_id)
		var tween = create_tween()
		sprite.modulate = Color(2.5, 0.3, 0.5, 1.0) # High-energy crimson flash
		tween.tween_property(sprite, "modulate", original_color, 0.16)
	
	if current_health <= 0:
		is_dead = true
		emit_signal("player_died")
		_on_death()
	else:
		is_invulnerable = true
		invulnerability_timer = invulnerability_duration
		emit_signal("invulnerability_changed", true)
	
	return true

func set_invulnerable(duration: float) -> void:
	is_invulnerable = true
	invulnerability_timer = duration
	emit_signal("invulnerability_changed", true)

func heal(amount: int) -> int:
	if is_dead or amount <= 0:
		return 0
	
	var old_health: int = current_health
	current_health = min(max_health, current_health + amount)
	var restored: int = current_health - old_health
	
	if restored > 0:
		emit_signal("player_healed", restored)
		emit_signal("health_changed", current_health, max_health)
		
		# Healing pulse flash
		if sprite:
			var original_color = _get_skin_color(current_skin_id)
			var tween = create_tween()
			sprite.modulate = Color(0.4, 2.5, 1.4, 1.0) # Emerald nanite flash
			tween.tween_property(sprite, "modulate", original_color, 0.2)
	
	return restored

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func is_alive() -> bool:
	return not is_dead

func revive(health_percentage: float = 0.5) -> void:
	is_dead = false
	current_health = int(clamp(max_health * health_percentage, 1, max_health))
	is_invulnerable = true
	invulnerability_timer = 2.0 # 2.0 seconds post-revive immunity
	
	emit_signal("health_changed", current_health, max_health)
	emit_signal("invulnerability_changed", true)
	
	if sprite:
		sprite.modulate = Color(0.5, 2.0, 2.5, 1.0) # Reconstruction cyan aura
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", _get_skin_color(current_skin_id), 0.35)

func _on_death() -> void:
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene:
		for i in range(6):
			var spark = spark_scene.instantiate()
			spark.global_position = global_position
			var angle = randf() * TAU
			spark.setup(Vector2(cos(angle), sin(angle)), Color(1.0, 0.3, 0.2))
			get_parent().add_child(spark)

	var vfx_scene = load("res://scenes/enemy_explosion.tscn")
	if vfx_scene:
		var vfx = vfx_scene.instantiate()
		vfx.global_position = global_position
		vfx.scale = Vector2(1.5, 1.5)
		get_parent().add_child(vfx)

# ==============================================================================
# UPGRADES & SKINS APPLICATION
# ==============================================================================

func apply_upgrades() -> void:
	if not SaveManager:
		return
	if SaveManager.is_upgrade_unlocked("upgrade_frame"):
		max_health = 125
	else:
		max_health = 100
	
	if SaveManager.is_upgrade_unlocked("upgrade_targeting"):
		aim_preview_length = 180.0
	else:
		aim_preview_length = 120.0
	
	if SaveManager.is_upgrade_unlocked("upgrade_capacitor"):
		max_projectile_bounces_bonus = 1
	else:
		max_projectile_bounces_bonus = 0

func apply_skin(skin_id: String) -> void:
	current_skin_id = skin_id
	if sprite:
		sprite.modulate = _get_skin_color(skin_id)

func _get_skin_color(skin_id: String) -> Color:
	match skin_id:
		"skin_prototype":
			return Color(0.7, 0.85, 1.35, 1.0) # Stealth dark navy / azure glow
		"skin_squad":
			return Color(1.25, 0.75, 0.85, 1.0) # Vesper crimson squadron
		"skin_vector":
			return Color(1.35, 0.65, 1.5, 1.0) # Resonant magenta / chromatic vector
		_:
			return Color(1.0, 1.0, 1.0, 1.0) # Standard AXIOM interceptor
