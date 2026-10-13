class_name BossSerin
extends CharacterBody2D

## COMMANDER SERIN — "THE GATEKEEPER"
## Multi-phase flagship boss combining telegraphed spreads, reflective barriers, and charge attacks.

signal boss_spawned(boss_name: String, max_hp: int)
signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(phase_number: int, phase_name: String)
signal boss_defeated(score_reward: int)

@export var max_health: int = 500
@export var boss_name: String = "COMMANDER SERIN [THE GATEKEEPER]"
@export var score_reward: int = 2500

var current_health: int = 500
var current_phase: int = 1
var is_dead: bool = false

var _time_elapsed: float = 0.0
var _attack_timer: float = 2.0
var _is_telegraphing: bool = false
var _telegraph_timer: float = 0.0
var _telegraph_target: Vector2 = Vector2.ZERO

var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")
var explosion_scene: PackedScene = preload("res://scenes/enemy_explosion.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	add_to_group("boss")
	emit_signal("boss_spawned", boss_name, max_health)
	emit_signal("boss_health_changed", current_health, max_health)
	emit_signal("boss_phase_changed", 1, "PHASE I: TARGET LOCK")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_time_elapsed += delta
	_attack_timer -= delta
	
	match current_phase:
		1:
			_process_phase_1(delta)
		2:
			_process_phase_2(delta)
		3:
			_process_phase_3(delta)
	
	move_and_slide()
	global_position.x = clamp(global_position.x, 800.0, 1150.0)
	global_position.y = clamp(global_position.y, 100.0, 620.0)
	
	if _is_telegraphing:
		_telegraph_timer -= delta
		queue_redraw()

func _process_phase_1(delta: float) -> void:
	# Sinusoidal vertical patrol at x ~ 980
	var target_y = 360.0 + sin(_time_elapsed * 1.5) * 180.0
	velocity.y = (target_y - global_position.y) * 3.5
	velocity.x = (980.0 - global_position.x) * 2.0
	
	if _attack_timer <= 0.0:
		_start_telegraph(0.6, _get_player_pos())
		_attack_timer = 2.2
		await get_tree().create_timer(0.6).timeout
		if not is_dead and current_phase == 1:
			_fire_aimed_spread(_telegraph_target, 3, 0.22)

func _process_phase_2(delta: float) -> void:
	# Figure-eight evasive maneuvers
	var target_y = 360.0 + sin(_time_elapsed * 2.0) * 210.0
	var target_x = 920.0 + cos(_time_elapsed * 1.2) * 100.0
	velocity.y = (target_y - global_position.y) * 4.0
	velocity.x = (target_x - global_position.x) * 3.0
	
	if _attack_timer <= 0.0:
		_start_telegraph(0.5, _get_player_pos())
		_attack_timer = 1.9
		await get_tree().create_timer(0.5).timeout
		if not is_dead and current_phase == 2:
			_fire_aimed_spread(_telegraph_target, 5, 0.3)

func _process_phase_3(delta: float) -> void:
	# High-speed vertical tracking and radial pulses
	var player_pos = _get_player_pos()
	velocity.y = (player_pos.y - global_position.y) * 4.5
	velocity.x = (900.0 - global_position.x) * 3.0
	
	if _attack_timer <= 0.0:
		_attack_timer = 1.7
		_start_telegraph(0.4, player_pos)
		await get_tree().create_timer(0.4).timeout
		if not is_dead and current_phase == 3:
			_fire_radial_burst(8)

func _start_telegraph(duration: float, target: Vector2) -> void:
	_is_telegraphing = true
	_telegraph_timer = duration
	_telegraph_target = target

func _fire_aimed_spread(target: Vector2, count: int, spread_angle: float) -> void:
	_is_telegraphing = false
	queue_redraw()
	if not projectile_scene or not get_parent():
		return
	
	var base_dir = (target - global_position).normalized()
	var half_count = (count - 1) / 2.0
	
	for i in range(count):
		var angle_offset = (float(i) - half_count) * spread_angle
		var dir = base_dir.rotated(angle_offset)
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + dir * 35.0
		proj.direction = dir
		proj.damage = 18
		get_parent().add_child(proj)

func _fire_radial_burst(count: int) -> void:
	_is_telegraphing = false
	queue_redraw()
	if not projectile_scene or not get_parent():
		return
	
	for i in range(count):
		var angle = (float(i) / float(count)) * TAU
		var dir = Vector2(cos(angle), sin(angle))
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + dir * 40.0
		proj.direction = dir
		proj.damage = 15
		get_parent().add_child(proj)

func _get_player_pos() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		return player.global_position
	return Vector2(160, 360)

func take_damage(amount: int, combo_multiplier: Variant = 1, _hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	
	current_health = max(0, current_health - amount)
	emit_signal("boss_health_changed", current_health, max_health)
	
	# Boss hit flash
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3.0, 1.0, 0.4, 1.0) # Gold-red flash
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	
	_check_phase_transition()
	
	if current_health <= 0:
		var multiplier_int: int = 1
		if typeof(combo_multiplier) == TYPE_INT or typeof(combo_multiplier) == TYPE_FLOAT:
			multiplier_int = int(combo_multiplier)
		_die(multiplier_int)

func _check_phase_transition() -> void:
	var health_pct = float(current_health) / float(max_health)
	
	if health_pct <= 0.30 and current_phase < 3:
		current_phase = 3
		emit_signal("boss_phase_changed", 3, "PHASE III: OVERDRIVE COLLAPSE")
		modulate = Color(1.2, 0.4, 0.3)
	elif health_pct <= 0.65 and current_phase < 2:
		current_phase = 2
		emit_signal("boss_phase_changed", 2, "PHASE II: REFLECTIVE BARRICADE")
		modulate = Color(1.1, 0.6, 0.9)

func _die(combo_multiplier: int = 1) -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("boss_defeated", score_reward)
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_hit(combo_multiplier)
		gm.add_score(score_reward, combo_multiplier)
	
	# Cascading explosion sequence
	if explosion_scene and get_parent():
		for i in range(6):
			var vfx = explosion_scene.instantiate()
			var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
			vfx.global_position = global_position + offset
			get_parent().add_child(vfx)
	
	queue_free()

func _draw() -> void:
	if _is_telegraphing and not is_dead:
		var to_target = (_telegraph_target - global_position).normalized()
		var beam_end = to_local(global_position + to_target * 500.0)
		draw_line(Vector2.ZERO, beam_end, Color(1.0, 0.2, 0.2, 0.7), 2.5)
