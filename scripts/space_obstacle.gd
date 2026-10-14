class_name SpaceObstacle
extends StaticBody2D

# ==============================================================================
# VECTOR//BREAK — MODULAR SCI-FI ARENA OBSTACLE
# Distinct silhouettes: Metallic Debris, Angular Asteroids, Industrial Barricades,
# and Broken Satellites. Supports optional reflective polarization.
# ==============================================================================

enum ObstacleType { DEBRIS, ASTEROID, BARRICADE, SATELLITE }

@export var obstacle_type: ObstacleType = ObstacleType.DEBRIS
@export var is_reflective: bool = false
@export var obstacle_size: float = 32.0

var _pulse_timer: float = 0.0

func _ready() -> void:
	collision_layer = 4 # Obstacle / world layer
	collision_mask = 3 # Characters & Projectiles
	
	if is_reflective:
		add_to_group("reflective")
	
	# Generate collision shape according to size
	var col = get_node_or_null("CollisionShape2D")
	if not col:
		col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape = CircleShape2D.new()
		shape.radius = obstacle_size * 0.85
		col.shape = shape
		add_child(col)

func _process(delta: float) -> void:
	_pulse_timer += delta * 2.0
	queue_redraw()

func _draw() -> void:
	var col_accent = Color(0.1, 0.85, 1.0) if is_reflective else Color(0.6, 0.7, 0.9)
	var col_dark = Color(0.06, 0.08, 0.16)
	var glow_pulse = 0.7 + sin(_pulse_timer) * 0.3
	
	match obstacle_type:
		ObstacleType.DEBRIS:
			# Hexagonal faceted metallic plate with circuit seams
			var pts: PackedVector2Array = [
				Vector2(-obstacle_size, 0),
				Vector2(-obstacle_size * 0.5, -obstacle_size * 0.86),
				Vector2(obstacle_size * 0.5, -obstacle_size * 0.86),
				Vector2(obstacle_size, 0),
				Vector2(obstacle_size * 0.5, obstacle_size * 0.86),
				Vector2(-obstacle_size * 0.5, obstacle_size * 0.86)
			]
			draw_colored_polygon(pts, col_dark)
			draw_polyline(pts, col_accent, 2.5)
			draw_line(pts[0], pts[3], Color(0.2, 0.9, 1.0, 0.6 * glow_pulse), 1.5)
			draw_circle(Vector2.ZERO, 3.5, Color(1.0, 0.2, 0.6, glow_pulse))
			
		ObstacleType.ASTEROID:
			# Angular jagged rock with glowing mineral veins
			var pts: PackedVector2Array = [
				Vector2(-obstacle_size * 1.1, -obstacle_size * 0.3),
				Vector2(-obstacle_size * 0.4, -obstacle_size),
				Vector2(obstacle_size * 0.6, -obstacle_size * 0.8),
				Vector2(obstacle_size * 1.05, obstacle_size * 0.1),
				Vector2(obstacle_size * 0.5, obstacle_size * 0.95),
				Vector2(-obstacle_size * 0.7, obstacle_size * 0.7)
			]
			draw_colored_polygon(pts, Color(0.08, 0.07, 0.12))
			draw_polyline(pts, Color(0.5, 0.45, 0.7), 2.0)
			# Crystal vein
			draw_line(pts[1], pts[4], Color(0.9, 0.2, 0.8, 0.75 * glow_pulse), 2.0)
			draw_line(pts[0], Vector2.ZERO, Color(0.2, 0.8, 1.0, 0.5 * glow_pulse), 1.5)
			
		ObstacleType.BARRICADE:
			# Industrial station structural bulkhead beam
			var w = obstacle_size * 1.3
			var h = obstacle_size * 0.65
			var rect = Rect2(-w * 0.5, -h * 0.5, w, h)
			draw_rect(rect, Color(0.05, 0.07, 0.14))
			draw_rect(rect, Color(1.0, 0.7, 0.1, 0.85), false, 2.0)
			# Hazard chevron stripes
			for i in range(-2, 3):
				var x_off = i * 14.0
				draw_line(Vector2(x_off - 6, -h * 0.4), Vector2(x_off + 6, h * 0.4), Color(1.0, 0.7, 0.1, 0.6 * glow_pulse), 2.0)
				
		ObstacleType.SATELLITE:
			# Satellite solar wing with central antenna mast
			var r = obstacle_size * 0.8
			draw_rect(Rect2(-r, -r * 0.35, r * 0.7, r * 0.7), Color(0.02, 0.15, 0.25))
			draw_rect(Rect2(-r, -r * 0.35, r * 0.7, r * 0.7), Color(0.1, 0.8, 1.0), false, 1.5)
			draw_rect(Rect2(r * 0.3, -r * 0.35, r * 0.7, r * 0.7), Color(0.02, 0.15, 0.25))
			draw_rect(Rect2(r * 0.3, -r * 0.35, r * 0.7, r * 0.7), Color(0.1, 0.8, 1.0), false, 1.5)
			# Central bus and antenna
			draw_circle(Vector2.ZERO, 9.0, Color(0.1, 0.12, 0.2))
			draw_circle(Vector2.ZERO, 9.0, Color(0.9, 0.9, 1.0), false, 2.0)
			draw_line(Vector2.ZERO, Vector2(0, -r * 1.1), Color(1.0, 0.3, 0.3, glow_pulse), 2.0)
			draw_circle(Vector2(0, -r * 1.1), 3.0, Color(1.0, 0.3, 0.3, glow_pulse))
