class_name GeometricDrone
extends CharacterBody2D

@export var max_health: int = 50
@export var base_speed: float = 65.0
@export var bob_amplitude: float = 24.0
@export var bob_frequency: float = 2.2

var health: int
var base_y: float = 0.0
var time_elapsed: float = 0.0
var is_dead: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	health = max_health
	base_y = global_position.y
	# Randomize phase so multiple drones bob out of sync
	time_elapsed = randf() * TAU
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	time_elapsed += delta
	# Bobbing motion
	var target_y = base_y + sin(time_elapsed * bob_frequency) * bob_amplitude
	velocity.x = -base_speed
	velocity.y = (target_y - global_position.y) * 4.0
	
	move_and_slide()
	
	# Wrap around or respawn if exiting left border
	if global_position.x < -60.0:
		global_position.x = 1340.0
		base_y = randf_range(120.0, 600.0)
		global_position.y = base_y

func take_damage(amount: int, combo_multiplier: Variant = 1, _hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	
	health -= amount
	_flash_feedback()
	
	if health <= 0:
		var mult: int = 1
		if typeof(combo_multiplier) == TYPE_INT or typeof(combo_multiplier) == TYPE_FLOAT:
			mult = int(combo_multiplier)
		_die(mult)

func _flash_feedback() -> void:
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3.0, 1.2, 2.5, 1.0) # Intense neon flash
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _die(combo_multiplier: int) -> void:
	if is_dead:
		return
	is_dead = true
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_hit(combo_multiplier)
		gm.add_score(100, combo_multiplier)
		if gm.has_method("award_currency"):
			gm.award_currency(15, "drone_%d" % get_instance_id())
		if gm.has_method("spawn_pickup") and randf() < 0.3:
			gm.spawn_pickup(gm.PickupType.NANOCELL, global_position)
	
	# Spawn explosion particles
	_spawn_explosion()
	
	# Slight delay or immediate cleanup
	queue_free()

func _spawn_explosion() -> void:
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene:
		for i in range(4):
			var spark = spark_scene.instantiate()
			var angle = randf() * TAU
			var dir = Vector2(cos(angle), sin(angle))
			var col = Color(1.0, 0.2, 0.8) if (i % 2 == 0) else Color(0.2, 0.9, 1.0)
			spark.global_position = global_position
			if spark.has_method("setup"):
				spark.setup(dir, col)
			get_parent().add_child(spark)
