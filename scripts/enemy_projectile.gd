class_name HostileProjectile
extends CharacterBody2D

# ==============================================================================
# VECTOR//BREAK — HOSTILE ENEMY PROJECTILE
# High-velocity crimson energy bolt.
# Targets the player, cannot damage owner, ricochets once off mirrors.
# ==============================================================================

@export var speed: float = 460.0
@export var damage: int = 15
@export var max_bounces: int = 1

var direction: Vector2 = Vector2.LEFT
var bounces: int = 0
var lifetime: float = 5.0
var shooter: Node = null
var trail_points: Array[Vector2] = []
var _has_hit: bool = false

func _ready() -> void:
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	add_to_group("enemy_projectiles")

func _physics_process(delta: float) -> void:
	if _has_hit:
		return
		
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	
	trail_points.push_front(global_position)
	if trail_points.size() > 8:
		trail_points.pop_back()
	queue_redraw()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		# Prevent self-damage on the enemy that discharged this shot
		if collider == shooter:
			return
		
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			_has_hit = true
			collider.take_damage(damage, self)
			_destroy()
		elif collider and collider.is_in_group("reflective"):
			if bounces < max_bounces:
				velocity = velocity.bounce(normal)
				direction = velocity.normalized()
				rotation = velocity.angle()
				bounces += 1
				global_position += normal * 3.0
			else:
				_destroy()
		elif collider and (collider.is_in_group("enemies") or collider.is_in_group("enemy_projectiles")):
			# Pass through other hostiles and projectile volleys without collision
			pass
		else:
			# Non-reflective wall or boundary
			_destroy()

func _draw() -> void:
	# Hostile crimson / amber trail
	if trail_points.size() < 2:
		return
	for i in range(trail_points.size() - 1):
		var p1 = to_local(trail_points[i])
		var p2 = to_local(trail_points[i + 1])
		var alpha = 1.0 - (float(i) / float(trail_points.size()))
		var width = lerp(3.5, 1.0, float(i) / float(trail_points.size()))
		draw_line(p1, p2, Color(1.0, 0.2, 0.1, alpha * 0.8), width + 2.0)
		draw_line(p1, p2, Color(1.0, 0.9, 0.3, alpha * 0.95), width * 0.6)

func _destroy() -> void:
	var spark_scene = load("res://scenes/impact_spark.tscn")
	if spark_scene and get_parent():
		var spark = spark_scene.instantiate()
		spark.global_position = global_position
		if spark.has_method("setup"):
			spark.setup(-direction, Color(1.0, 0.25, 0.1))
		get_parent().add_child(spark)
	queue_free()
