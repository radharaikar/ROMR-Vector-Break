class_name EnemyStriker
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY STRIKER AI
# Long-range standoff sniper: maintains combat distance, evades close player
# incursions, telegraphs with targeting laser, and discharges hostile projectiles.
# ==============================================================================

@export var preferred_distance: float = 420.0
@export var min_safe_distance: float = 220.0
@export var fire_interval: float = 2.4
@export var charge_duration: float = 0.8
@export var projectile_damage: int = 18

var _fire_timer: float = 1.0
var _is_charging: bool = false
var _charge_timer: float = 0.0
var _aim_dir: Vector2 = Vector2.LEFT

enum State { REPOSITIONING, EVADING, TELEGRAPHING, ATTACKING }
var current_state: State = State.REPOSITIONING

var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

func _init() -> void:
	max_health = 60
	score_value = 200
	base_speed = 90.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(1.0, 0.3, 0.7) # Violet / magenta sniper tint

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var to_player = player.global_position - global_position
		var dist_to_player = to_player.length()
		var dir_to_player = to_player.normalized()
		_aim_dir = dir_to_player
		rotation = lerp_angle(rotation, dir_to_player.angle(), 6.0 * delta)
		
		# Proximity evasion check
		if dist_to_player < min_safe_distance and current_state != State.TELEGRAPHING:
			current_state = State.EVADING
		elif current_state == State.EVADING and dist_to_player >= preferred_distance * 0.8:
			current_state = State.REPOSITIONING
		
		match current_state:
			State.REPOSITIONING:
				# Move to maintain preferred standoff distance
				var desired_offset = -dir_to_player * preferred_distance
				var target_pos = player.global_position + desired_offset
				var move_dir = (target_pos - global_position).normalized()
				velocity = velocity.move_toward(move_dir * base_speed, 260.0 * delta)
				
				_fire_timer -= delta
				if _fire_timer <= 0.0 and dist_to_player <= preferred_distance * 1.3:
					_start_charge()
					
			State.EVADING:
				# Retreat away from aggressive player approach
				var retreat_dir = -dir_to_player
				velocity = velocity.move_toward(retreat_dir * (base_speed * 1.4), 380.0 * delta)
				
			State.TELEGRAPHING:
				# Slow to a steady hover during aim lock
				velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
				_charge_timer -= delta
				queue_redraw()
				if _charge_timer <= 0.0:
					_fire_shot()
	else:
		velocity = velocity.move_toward(Vector2(-base_speed * 0.5, 0), 120.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
	
	global_position.x = clamp(global_position.x, 50.0, 1240.0)
	global_position.y = clamp(global_position.y, 60.0, 660.0)

func _start_charge() -> void:
	current_state = State.TELEGRAPHING
	_is_charging = true
	_charge_timer = charge_duration

func _fire_shot() -> void:
	current_state = State.REPOSITIONING
	_is_charging = false
	_fire_timer = fire_interval
	queue_redraw()
	
	if projectile_scene and get_parent():
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + _aim_dir * 24.0
		proj.direction = _aim_dir
		proj.damage = projectile_damage
		proj.shooter = self # Cannot hurt self
		get_parent().add_child(proj)

func _draw() -> void:
	if current_state == State.TELEGRAPHING and _charge_timer > 0.0:
		var progress = 1.0 - (_charge_timer / charge_duration)
		var beam_len = 500.0
		var local_end = to_local(global_position + _aim_dir * beam_len)
		var alpha = lerp(0.3, 0.9, progress)
		var width = lerp(1.0, 3.5, progress)
		draw_line(Vector2.ZERO, local_end, Color(1.0, 0.2, 0.5, alpha), width)
		draw_circle(local_end, 3.0 * progress, Color(1.0, 0.4, 0.8, alpha))
