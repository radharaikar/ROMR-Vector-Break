class_name SpaceEnvironment
extends Node2D

# Procedurally renders atmospheric sci-fi space station backdrop matching reference concept:
# - Deep navy and black tones (#050817 to #0b112c)
# - Large atmospheric celestial planet / moon in background
# - Industrial space station girders, catwalk silhouettes, and neon conduits

var stars: Array[Dictionary] = []
var station_girders: Array[Rect2] = []

func _ready() -> void:
	z_index = -10
	_generate_stars()
	_generate_structures()

func _generate_stars() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(120):
		stars.append({
			"pos": Vector2(rng.randf_range(0, 1280), rng.randf_range(0, 720)),
			"size": rng.randf_range(0.8, 2.2),
			"color": Color(rng.randf_range(0.7, 1.0), rng.randf_range(0.8, 1.0), 1.0, rng.randf_range(0.3, 0.9))
		})

func _generate_structures() -> void:
	# Upper and lower hangar ceiling/floor silhouettes
	station_girders.append(Rect2(0, 0, 1280, 48))
	station_girders.append(Rect2(0, 672, 1280, 48))
	# Vertical support pillars in background
	station_girders.append(Rect2(360, 48, 28, 624))
	station_girders.append(Rect2(780, 48, 36, 624))
	station_girders.append(Rect2(1100, 48, 32, 624))

func _draw() -> void:
	# 1. Deep Space Gradient
	var bg_rect = Rect2(0, 0, 1280, 720)
	var colors = PackedColorArray([
		Color(0.02, 0.03, 0.07), # Deep space black/navy
		Color(0.04, 0.07, 0.16),
		Color(0.06, 0.08, 0.19),
		Color(0.02, 0.03, 0.08)
	])
	var points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1280, 0),
		Vector2(1280, 720),
		Vector2(0, 720)
	])
	draw_polygon(points, colors)
	
	# 2. Celestial Body (Distant moon/planet with blue-white crescent rim)
	var moon_center = Vector2(490, 160)
	var moon_radius = 110.0
	draw_circle(moon_center, moon_radius, Color(0.07, 0.11, 0.22, 0.8))
	# Subtle crater accents
	draw_circle(moon_center + Vector2(-30, -20), 18.0, Color(0.05, 0.08, 0.17, 0.6))
	draw_circle(moon_center + Vector2(20, 35), 24.0, Color(0.05, 0.08, 0.17, 0.5))
	draw_circle(moon_center + Vector2(-10, 50), 14.0, Color(0.05, 0.08, 0.17, 0.5))
	# Crescent atmosphere rim
	draw_arc(moon_center, moon_radius, -PI * 0.8, PI * 0.15, 64, Color(0.3, 0.7, 1.0, 0.45), 3.0)
	
	# 3. Distant Stars
	for star in stars:
		draw_circle(star["pos"], star["size"], star["color"])
	
	# 4. Industrial Catwalks and Girders (Dark metallic structural silhouettes)
	for rect in station_girders:
		draw_rect(rect, Color(0.04, 0.05, 0.09, 0.92))
		# Diagonal cross braces on vertical pillars
		if rect.size.x < 50 and rect.size.y > 100:
			for y_brace in range(int(rect.position.y), int(rect.position.y + rect.size.y), 60):
				draw_line(
					Vector2(rect.position.x, y_brace),
					Vector2(rect.position.x + rect.size.x, y_brace + 30),
					Color(0.06, 0.08, 0.14, 0.7),
					1.5
				)
	
	# 5. Neon Conduits (Magenta and Cyan energy cables)
	# Upper cyan conduit
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(0.1, 0.85, 1.0, 0.75), 2.0)
	# Lower magenta conduit
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(1.0, 0.18, 0.8, 0.75), 2.0)
	
	# Decorative sci-fi chevron markings on borders
	for x in range(120, 1200, 180):
		draw_line(Vector2(x, 44), Vector2(x + 16, 44), Color(0.3, 0.9, 1.0, 0.9), 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 16, 676), Color(1.0, 0.3, 0.85, 0.9), 3.0)
