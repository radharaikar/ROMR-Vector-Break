class_name SpaceObstacle
extends StaticBody2D

# ==============================================================================
# VECTOR//BREAK — BIOME-SPECIFIC SCI-FI ARENA OBSTACLE
# Dynamically adapts visual appearance, materials, and decals to match each
# of the 5 campaign biomes:
# - Neon Graveyard: Abandoned spacecraft wreckage & broken energy barriers
# - Vesper Desert Downs: Sand-eroded research outposts & weathered solar grids
# - Pelagic Depths: Submerged pressure pods & bioluminescent conduits
# - Pyroclastic Rift: Heat-resistant cooling towers & magma basalt formations
# - Viridian Canopy: Overgrown research domes & cybernetic root bulkheads
# ==============================================================================

enum ObstacleType { DEBRIS, ASTEROID, BARRICADE, SATELLITE }

@export var obstacle_type: ObstacleType = ObstacleType.DEBRIS
@export var is_reflective: bool = false
@export var obstacle_size: float = 32.0
@export var custom_biome_id: String = ""

var current_biome: String = "neon_graveyard"
var _pulse_timer: float = 0.0

func set_biome(biome_id: String) -> void:
	custom_biome_id = biome_id
	current_biome = biome_id
	queue_redraw()

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
		if obstacle_type == ObstacleType.BARRICADE:
			var box = RectangleShape2D.new()
			box.size = Vector2(obstacle_size * 1.3, obstacle_size * 0.7)
			col.shape = box
		else:
			var shape = CircleShape2D.new()
			shape.radius = obstacle_size * 0.85
			col.shape = shape
		add_child(col)

func _process(delta: float) -> void:
	_pulse_timer += delta * 2.0
	queue_redraw()

func _get_biome_id() -> String:
	if not custom_biome_id.is_empty():
		return custom_biome_id
	if SaveManager:
		return SaveManager.get_selected_biome()
	return "neon_graveyard"

func _draw() -> void:
	var biome_id = _get_biome_id()
	var glow_pulse = 0.7 + sin(_pulse_timer) * 0.3
	
	# Determine Biome Palette
	var col_accent = Color(0.1, 0.85, 1.0)
	var col_secondary = Color(1.0, 0.2, 0.7)
	var col_dark = Color(0.05, 0.07, 0.14)
	var col_rock = Color(0.08, 0.08, 0.14)
	
	match biome_id:
		"vesper_desert":
			col_accent = Color(1.0, 0.75, 0.2)
			col_secondary = Color(0.9, 0.4, 0.1)
			col_dark = Color(0.12, 0.08, 0.04)
			col_rock = Color(0.18, 0.12, 0.06)
		"pelagic_depths":
			col_accent = Color(0.15, 0.95, 0.85)
			col_secondary = Color(0.2, 0.55, 1.0)
			col_dark = Color(0.02, 0.08, 0.16)
			col_rock = Color(0.04, 0.10, 0.18)
		"pyroclastic_rift":
			col_accent = Color(1.0, 0.3, 0.15)
			col_secondary = Color(1.0, 0.75, 0.1)
			col_dark = Color(0.14, 0.04, 0.04)
			col_rock = Color(0.20, 0.05, 0.05)
		"viridian_canopy":
			col_accent = Color(0.2, 0.95, 0.5)
			col_secondary = Color(0.1, 0.8, 0.75)
			col_dark = Color(0.03, 0.10, 0.05)
			col_rock = Color(0.05, 0.14, 0.08)
		_:
			# Neon graveyard defaults
			col_accent = Color(0.1, 0.9, 1.0) if is_reflective else Color(0.5, 0.75, 1.0)
			col_secondary = Color(1.0, 0.2, 0.75)
			col_dark = Color(0.04, 0.06, 0.14)
			col_rock = Color(0.07, 0.09, 0.18)
	
	if is_reflective:
		col_accent = Color(0.15, 0.95, 1.0)
	
	match obstacle_type:
		ObstacleType.DEBRIS:
			# Hexagonal faceted metallic plate with circuit seams and biome hazard marks
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
			draw_line(pts[0], pts[3], Color(col_accent.r, col_accent.g, col_accent.b, 0.6 * glow_pulse), 1.5)
			draw_line(pts[1], pts[4], Color(col_secondary.r, col_secondary.g, col_secondary.b, 0.5 * glow_pulse), 1.5)
			draw_circle(Vector2.ZERO, 4.0, Color(col_secondary.r, col_secondary.g, col_secondary.b, glow_pulse))
			
			# Biome-specific detail
			if biome_id == "viridian_canopy":
				# Overgrown cyber-tendril across the plate
				draw_arc(Vector2.ZERO, obstacle_size * 0.6, 0.2, 2.5, 16, Color(0.2, 0.9, 0.4, 0.8), 2.0)
			elif biome_id == "pyroclastic_rift":
				# Magma thermal vent line
				draw_line(Vector2(-12, 0), Vector2(12, 0), Color(1.0, 0.4, 0.1, glow_pulse), 3.0)
			elif biome_id == "vesper_desert":
				# Sand erosion stripes
				draw_line(pts[5] + Vector2(6, -6), pts[2] + Vector2(-6, 6), Color(1.0, 0.7, 0.2, 0.5), 1.5)
			
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
			draw_colored_polygon(pts, col_rock)
			draw_polyline(pts, col_accent * 0.85, 2.0)
			# Energy vein
			draw_line(pts[1], pts[4], Color(col_secondary.r, col_secondary.g, col_secondary.b, 0.75 * glow_pulse), 2.0)
			draw_line(pts[0], Vector2.ZERO, Color(col_accent.r, col_accent.g, col_accent.b, 0.5 * glow_pulse), 1.5)
			draw_circle(pts[4] * 0.6, 3.0, Color(col_secondary.r, col_secondary.g, col_secondary.b, glow_pulse))
			
		ObstacleType.BARRICADE:
			# Industrial station structural bulkhead beam
			var w = obstacle_size * 1.3
			var h = obstacle_size * 0.65
			var rect = Rect2(-w * 0.5, -h * 0.5, w, h)
			draw_rect(rect, col_dark)
			draw_rect(rect, col_accent, false, 2.0)
			# Hazard chevron stripes
			for i in range(-2, 3):
				var x_off = i * 14.0
				draw_line(Vector2(x_off - 6, -h * 0.4), Vector2(x_off + 6, h * 0.4), Color(col_accent.r, col_accent.g, col_accent.b, 0.65 * glow_pulse), 2.0)
			# Reinforced bolt rivets
			draw_circle(Vector2(-w * 0.42, -h * 0.32), 2.0, col_accent)
			draw_circle(Vector2(w * 0.42, -h * 0.32), 2.0, col_accent)
			draw_circle(Vector2(-w * 0.42, h * 0.32), 2.0, col_accent)
			draw_circle(Vector2(w * 0.42, h * 0.32), 2.0, col_accent)
				
		ObstacleType.SATELLITE:
			# Satellite solar array with central antenna mast
			var r = obstacle_size * 0.8
			draw_rect(Rect2(-r, -r * 0.35, r * 0.7, r * 0.7), Color(col_dark.r * 1.2, col_dark.g * 1.2, col_dark.b * 1.4))
			draw_rect(Rect2(-r, -r * 0.35, r * 0.7, r * 0.7), col_accent, false, 1.5)
			draw_rect(Rect2(r * 0.3, -r * 0.35, r * 0.7, r * 0.7), Color(col_dark.r * 1.2, col_dark.g * 1.2, col_dark.b * 1.4))
			draw_rect(Rect2(r * 0.3, -r * 0.35, r * 0.7, r * 0.7), col_accent, false, 1.5)
			# Solar grid lines
			draw_line(Vector2(-r * 0.65, -r * 0.35), Vector2(-r * 0.65, r * 0.35), col_accent * 0.5, 1.0)
			draw_line(Vector2(r * 0.65, -r * 0.35), Vector2(r * 0.65, r * 0.35), col_accent * 0.5, 1.0)
			# Central bus and antenna
			draw_circle(Vector2.ZERO, 9.0, col_dark)
			draw_circle(Vector2.ZERO, 9.0, col_accent, false, 2.0)
			draw_line(Vector2.ZERO, Vector2(0, -r * 1.15), Color(col_secondary.r, col_secondary.g, col_secondary.b, glow_pulse), 2.0)
			draw_circle(Vector2(0, -r * 1.15), 3.5, Color(col_secondary.r, col_secondary.g, col_secondary.b, glow_pulse))
