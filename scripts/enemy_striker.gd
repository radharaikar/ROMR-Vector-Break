class_name EnemyStriker
extends "res://scripts/enemy_base.gd"

## Long-range artillery enemy. Maintains standoff distance, telegraphs, and fires aimed projectiles.

@export var preferred_x: float = 920.0
@export var fire_interval: float = 2.4
@export var charge_duration: float = 0.8
@export var projectile_damage: int = 20

var _fire_timer: float = 1.0
var _is_charging: bool = false
var _charge_timer: float = 0.0
var _aim_dir: Vector2 = Vector2.LEFT

var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

func _init() -> void:
	max_health = 60
	score_value = 200
	base_speed = 70.0
	super._init()

func _ready() -> void:
	super._ready()
	# Distinct violet/magenta tactical tint
	modulate = Color(1.0, 0.3, 0.7)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	var target_pos = global_position
	
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		# Maintain preferred X position and track player Y
		var target_x = clamp(preferred_x, 750.0, 1100.0)
		var target_y = player.global_position.y
		target_pos = Vector2(target_x, target_y)
		_aim_dir = (player.global_position - global_position).normalized()
	
	# Move toward standoff station
	velocity = velocity.move_toward((target_pos - global_position).normalized() * base_speed, 300.0 * delta)
	move_and_slide()
	
	# Attack cycle
	if not _is_charging:
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			_start_charge()
	else:
		_charge_timer -= delta
		queue_redraw()
		if _charge_timer <= 0.0:
			_fire_shot()

func _start_charge() -> void:
	_is_charging = true
	_charge_timer = charge_duration

func _fire_shot() -> void:
	_is_charging = false
	_fire_timer = fire_interval
	queue_redraw()
	
	if projectile_scene and get_parent():
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + _aim_dir * 20.0
		proj.direction = _aim_dir
		proj.damage = projectile_damage
		get_parent().add_child(proj)

func _draw() -> void:
	if _is_charging and not is_dead:
		# Draw telegraph warning laser line
		var progress = 1.0 - (_charge_timer / charge_duration)
		var line_end = to_local(global_position + _aim_dir * 450.0)
		var col = Color(1.0, 0.1, 0.1, lerp(0.25, 0.85, progress))
		draw_line(Vector2.ZERO, line_end, col, lerp(1.0, 3.0, progress))
		draw_circle(Vector2.ZERO, lerp(4.0, 10.0, progress), Color(1.0, 0.4, 0.1, 0.6))
