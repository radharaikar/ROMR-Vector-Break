class_name EnemyHeavy
extends "res://scripts/enemy_base.gd"

# ==============================================================================
# VECTOR//BREAK — ENEMY HEAVY DREADNOUGHT AI
# Armored juggernaut: turns frontal shield toward incoming fire, repositions to
# cut off the player, fires heavy hostile cannon blasts, and requires ricochet flank hits.
# ==============================================================================

@export var shield_active: bool = true
@export var fire_interval: float = 3.2
@export var cannon_damage: int = 24

var _fire_timer: float = 2.0
var _shield_flash_timer: float = 0.0

enum State { REPOSITIONING, ATTACKING }
var current_state: State = State.REPOSITIONING

var projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")

func _init() -> void:
	max_health = 150
	score_value = 350
	base_speed = 55.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(0.85, 0.95, 1.1)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if _shield_flash_timer > 0.0:
		_shield_flash_timer -= delta
		queue_redraw()
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.has_method("is_alive") and player.is_alive():
		var to_player = (player.global_position - global_position).normalized()
		var dist_to_player = global_position.distance_to(player.global_position)
		
		# Steady tactical advance toward the player
		var advance_dir = to_player
		if dist_to_player < 160.0:
			advance_dir = -to_player # Keep minimum buffer distance
		velocity = velocity.move_toward(advance_dir * base_speed, 180.0 * delta)
		
		# Heavy cannon attack timer
		_fire_timer -= delta
		if _fire_timer <= 0.0 and dist_to_player < 600.0:
			_fire_heavy_cannon(to_player)
	else:
		velocity = velocity.move_toward(Vector2(-base_speed * 0.5, 0), 100.0 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
	
	global_position.x = clamp(global_position.x, 60.0, 1220.0)
	global_position.y = clamp(global_position.y, 70.0, 650.0)

func _fire_heavy_cannon(target_dir: Vector2) -> void:
	_fire_timer = fire_interval
	if projectile_scene and get_parent():
		var angles = [0.0, 0.16, -0.16]
		for ang in angles:
			var spread_dir = target_dir.rotated(ang)
			var proj = projectile_scene.instantiate()
			proj.global_position = global_position + spread_dir * 32.0
			proj.direction = spread_dir
			proj.damage = cannon_damage
			proj.speed = 380.0
			proj.shooter = self # Prevent self-damage
			proj.add_collision_exception_with(self)
			get_parent().add_child(proj)

func take_damage(amount: int, combo_multiplier: Variant = 1, hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	
	# Check if hit struck the frontal shield
	if shield_active and hit_point != Vector2.ZERO:
		var local_hit = to_local(hit_point)
		# If hit arrived from the left (front face of the enemy)
		if local_hit.x < 10.0:
			_deflect_hit(hit_point)
			return
	
	# Flank or rear ricochet hit: apply full damage
	super.take_damage(amount, combo_multiplier, hit_point)

func _deflect_hit(point: Vector2) -> void:
	_shield_flash_timer = 0.2
	queue_redraw()
	
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene and get_parent():
		var spark = spark_scene.instantiate()
		spark.global_position = point
		if spark.has_method("setup"):
			spark.setup(Vector2.LEFT, Color(0.2, 0.9, 1.0))
		get_parent().add_child(spark)

func _draw() -> void:
	if shield_active:
		var shield_color = Color(0.2, 0.85, 1.0, 0.95) if _shield_flash_timer > 0.0 else Color(0.2, 0.7, 1.0, 0.6)
		var shield_width = 4.0 if _shield_flash_timer > 0.0 else 2.5
		# Arc facing left (from PI*0.55 to PI*1.45)
		draw_arc(Vector2(-6, 0), 28.0, PI * 0.55, PI * 1.45, 16, shield_color, shield_width)
