class_name EnergyProjectile
extends CharacterBody2D

@export var speed: float = 900.0
@export var damage: int = 35
@export var max_bounces: int = 4

var direction: Vector2 = Vector2.RIGHT
var bounces: int = 0
var ricochet_combo: int = 1
var lifetime: float = 4.0

var trail_points: Array[Vector2] = []
const MAX_TRAIL_POINTS: int = 12

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	add_to_group("projectiles")

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	
	# Update trail history (in global coords)
	trail_points.push_front(global_position)
	if trail_points.size() > MAX_TRAIL_POINTS:
		trail_points.pop_back()
	queue_redraw()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if collider and collider.is_in_group("reflective"):
			# True mathematical vector reflection: Vector2.bounce(normal)
			velocity = velocity.bounce(normal)
			direction = velocity.normalized()
			rotation = velocity.angle()
			bounces += 1
			ricochet_combo += 1
			
			if collider.has_method("on_ricochet"):
				collider.on_ricochet(collision.get_position(), normal)
			
			_spawn_sparks(collision.get_position(), normal, Color(0.2, 0.9, 1.0))
			_spawn_sparks(collision.get_position(), normal, Color(1.0, 0.2, 0.9))
			
			# Nudge away from surface to prevent tunneling or double-collision
			global_position += normal * 3.0
			
			if bounces >= max_bounces:
				_destroy()
		elif collider and collider.is_in_group("player"):
			# Ignore player to prevent firing self-hits in tight maneuvers
			pass
		elif collider and collider.has_method("take_damage"):
			collider.take_damage(damage, ricochet_combo, collision.get_position())
			_spawn_sparks(collision.get_position(), -direction, Color(1.0, 0.3, 0.8))
			_destroy()
		else:
			# Non-reflective obstacle or boundary
			_spawn_sparks(collision.get_position(), normal, Color(0.3, 0.7, 1.0))
			_destroy()

func _draw() -> void:
	# Draw electric cyan laser trail behind projectile
	if trail_points.size() < 2:
		return
	
	for i in range(trail_points.size() - 1):
		var p1 = to_local(trail_points[i])
		var p2 = to_local(trail_points[i + 1])
		var alpha = 1.0 - (float(i) / float(trail_points.size()))
		var width = lerp(4.0, 1.0, float(i) / float(trail_points.size()))
		# Electric cyan outer glow
		draw_line(p1, p2, Color(0.1, 0.8, 1.0, alpha * 0.7), width + 2.0)
		# White hot core
		draw_line(p1, p2, Color(1.0, 1.0, 1.0, alpha * 0.9), width * 0.5)

func _spawn_sparks(pos: Vector2, dir: Vector2, color: Color) -> void:
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene:
		var spark = spark_scene.instantiate()
		spark.global_position = pos
		if spark.has_method("setup"):
			spark.setup(dir, color)
		get_parent().add_child(spark)

func _destroy() -> void:
	queue_free()
