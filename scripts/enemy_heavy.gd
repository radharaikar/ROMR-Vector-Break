class_name EnemyHeavy
extends "res://scripts/enemy_base.gd"

## Armored heavy construct with a directional frontal energy shield.
## Frontal direct hits are absorbed; ricochets off reflectors must be used to strike its flank/rear.

@export var shield_active: bool = true
var _shield_flash_timer: float = 0.0

func _init() -> void:
	max_health = 150
	score_value = 350
	base_speed = 38.0
	super._init()

func _ready() -> void:
	super._ready()
	modulate = Color(0.8, 0.9, 1.1)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if _shield_flash_timer > 0.0:
		_shield_flash_timer -= delta
		queue_redraw()
	
	# Slow, steady forward advance
	velocity = Vector2(-base_speed, 0)
	move_and_slide()
	
	if global_position.x < -80.0:
		global_position.x = 1380.0

func take_damage(amount: int, combo_multiplier: Variant = 1, hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	
	# Check if hit struck the frontal shield
	if shield_active and hit_point != Vector2.ZERO:
		var local_hit = hit_point - global_position
		# If hit arrived from the left (front face of the enemy)
		if local_hit.x < 10.0:
			_deflect_hit(hit_point)
			return
	
	# Rear or flank hit: take full damage
	super.take_damage(amount, combo_multiplier, hit_point)

func _deflect_hit(point: Vector2) -> void:
	_shield_flash_timer = 0.2
	queue_redraw()
	
	# Spawn deflection sparks
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene and get_parent():
		var spark = spark_scene.instantiate()
		spark.global_position = point
		if spark.has_method("setup"):
			spark.setup(Vector2.LEFT, Color(0.2, 0.9, 1.0))
		get_parent().add_child(spark)

func _draw() -> void:
	# Draw frontal energy shield arc
	var shield_color = Color(0.2, 0.85, 1.0, 0.95) if _shield_flash_timer > 0.0 else Color(0.2, 0.7, 1.0, 0.6)
	var shield_width = 4.0 if _shield_flash_timer > 0.0 else 2.5
	# Arc facing left (from PI*0.6 to PI*1.4)
	draw_arc(Vector2(-6, 0), 28.0, PI * 0.55, PI * 1.45, 16, shield_color, shield_width)
