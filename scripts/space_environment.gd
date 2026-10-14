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
	var biome_id = SaveManager.get_selected_biome() if SaveManager else "neon_graveyard"
	var bg_col_top = Color(0.02, 0.03, 0.07)
	var bg_col_mid = Color(0.04, 0.07, 0.16)
	var moon_col = Color(0.07, 0.11, 0.22, 0.8)
	var conduit_a = Color(0.1, 0.85, 1.0, 0.75)
	var conduit_b = Color(1.0, 0.18, 0.8, 0.75)
	
	match biome_id:
		"vesper_desert":
			bg_col_top = Color(0.06, 0.04, 0.02)
			bg_col_mid = Color(0.14, 0.09, 0.04)
			moon_col = Color(0.22, 0.15, 0.08, 0.85)
			conduit_a = Color(1.0, 0.75, 0.2, 0.85)
			conduit_b = Color(1.0, 0.4, 0.1, 0.75)
		"pelagic_depths":
			bg_col_top = Color(0.01, 0.03, 0.08)
			bg_col_mid = Color(0.02, 0.08, 0.18)
			moon_col = Color(0.04, 0.14, 0.26, 0.85)
			conduit_a = Color(0.2, 0.7, 1.0, 0.85)
			conduit_b = Color(0.0, 0.9, 0.8, 0.75)
		"pyroclastic_rift":
			bg_col_top = Color(0.08, 0.02, 0.02)
			bg_col_mid = Color(0.18, 0.04, 0.04)
			moon_col = Color(0.28, 0.08, 0.05, 0.85)
			conduit_a = Color(1.0, 0.3, 0.1, 0.85)
			conduit_b = Color(1.0, 0.7, 0.1, 0.75)
		"viridian_canopy":
			bg_col_top = Color(0.02, 0.06, 0.03)
			bg_col_mid = Color(0.04, 0.14, 0.07)
			moon_col = Color(0.06, 0.22, 0.11, 0.85)
			conduit_a = Color(0.2, 0.95, 0.5, 0.85)
			conduit_b = Color(0.1, 0.8, 0.7, 0.75)

	# 1. Deep Space Gradient
	var bg_rect = Rect2(0, 0, 1280, 720)
	var colors = PackedColorArray([
		bg_col_top,
		bg_col_mid,
		bg_col_mid,
		bg_col_top
	])
	var points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1280, 0),
		Vector2(1280, 720),
		Vector2(0, 720)
	])
	draw_polygon(points, colors)
	
	# 2. Celestial Body (Distant moon/planet with crescent rim)
	var moon_center = Vector2(490, 160)
	var moon_radius = 110.0
	draw_circle(moon_center, moon_radius, moon_col)
	# Subtle crater accents
	draw_circle(moon_center + Vector2(-30, -20), 18.0, Color(0.03, 0.05, 0.1, 0.6))
	draw_circle(moon_center + Vector2(20, 35), 24.0, Color(0.03, 0.05, 0.1, 0.5))
	draw_circle(moon_center + Vector2(-10, 50), 14.0, Color(0.03, 0.05, 0.1, 0.5))
	# Crescent atmosphere rim
	draw_arc(moon_center, moon_radius, -PI * 0.8, PI * 0.15, 64, conduit_a, 3.0)
	
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
	
	# 5. Neon Conduits (Biome-themed energy cables)
	draw_line(Vector2(0, 48), Vector2(1280, 48), conduit_a, 2.0)
	draw_line(Vector2(0, 672), Vector2(1280, 672), conduit_b, 2.0)
	
	# Decorative sci-fi chevron markings on borders
	for x in range(120, 1200, 180):
		draw_line(Vector2(x, 44), Vector2(x + 16, 44), conduit_a, 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 16, 676), conduit_b, 3.0)
