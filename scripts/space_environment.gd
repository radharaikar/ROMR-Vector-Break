class_name SpaceEnvironment
extends Node2D

# ==============================================================================
# VECTOR//BREAK — DYNAMIC CELESTIAL & SCI-FI SPACE ENVIRONMENT
# Procedurally renders atmospheric backdrops for all 5 campaign biomes:
# - Volumetric glowing nebulae and cosmic dust
# - High-detail celestial moon/planet with atmospheric rim, craters, and orbital rings
# - Layered twinkling starfield with subtle ambient parallax
# - Biome-themed industrial catwalks, bulkheads, and vector conduit lines
# ==============================================================================

var stars: Array[Dictionary] = []
var station_girders: Array[Rect2] = []
var _drift_timer: float = 0.0

func _ready() -> void:
	z_index = -10
	_generate_stars()
	_generate_structures()

func _generate_stars() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(140):
		stars.append({
			"pos": Vector2(rng.randf_range(0, 1280), rng.randf_range(0, 720)),
			"size": rng.randf_range(0.8, 2.4),
			"color": Color(rng.randf_range(0.75, 1.0), rng.randf_range(0.85, 1.0), 1.0, rng.randf_range(0.35, 0.9)),
			"twinkle_speed": rng.randf_range(1.5, 4.0),
			"twinkle_offset": rng.randf_range(0, TAU)
		})

func _generate_structures() -> void:
	station_girders.clear()
	# Upper and lower hangar ceiling/floor silhouettes
	station_girders.append(Rect2(0, 0, 1280, 48))
	station_girders.append(Rect2(0, 672, 1280, 48))
	# Vertical support pillars in background
	station_girders.append(Rect2(360, 48, 28, 624))
	station_girders.append(Rect2(780, 48, 36, 624))
	station_girders.append(Rect2(1100, 48, 32, 624))

func _process(delta: float) -> void:
	_drift_timer += delta
	queue_redraw()

func _draw() -> void:
	var biome_id = SaveManager.get_selected_biome() if SaveManager else "neon_graveyard"
	var bg_col_top = Color(0.02, 0.03, 0.07)
	var bg_col_mid = Color(0.04, 0.07, 0.16)
	var moon_col = Color(0.09, 0.14, 0.26)
	var moon_shadow = Color(0.03, 0.05, 0.10)
	var conduit_a = Color(0.1, 0.85, 1.0, 0.85)
	var conduit_b = Color(1.0, 0.20, 0.8, 0.80)
	var nebula_col = Color(0.1, 0.25, 0.6, 0.12)
	var ring_col = Color(0.2, 0.7, 1.0, 0.25)
	
	match biome_id:
		"vesper_desert":
			bg_col_top = Color(0.06, 0.04, 0.02)
			bg_col_mid = Color(0.14, 0.09, 0.04)
			moon_col = Color(0.26, 0.18, 0.09)
			moon_shadow = Color(0.08, 0.05, 0.02)
			conduit_a = Color(1.0, 0.75, 0.2, 0.85)
			conduit_b = Color(1.0, 0.4, 0.1, 0.75)
			nebula_col = Color(0.6, 0.35, 0.1, 0.14)
			ring_col = Color(1.0, 0.75, 0.3, 0.25)
		"pelagic_depths":
			bg_col_top = Color(0.01, 0.03, 0.08)
			bg_col_mid = Color(0.02, 0.08, 0.18)
			moon_col = Color(0.06, 0.18, 0.32)
			moon_shadow = Color(0.01, 0.04, 0.09)
			conduit_a = Color(0.2, 0.7, 1.0, 0.85)
			conduit_b = Color(0.0, 0.9, 0.8, 0.75)
			nebula_col = Color(0.05, 0.3, 0.5, 0.15)
			ring_col = Color(0.1, 0.9, 0.8, 0.25)
		"pyroclastic_rift":
			bg_col_top = Color(0.08, 0.02, 0.02)
			bg_col_mid = Color(0.18, 0.04, 0.04)
			moon_col = Color(0.32, 0.10, 0.06)
			moon_shadow = Color(0.10, 0.02, 0.02)
			conduit_a = Color(1.0, 0.3, 0.1, 0.85)
			conduit_b = Color(1.0, 0.75, 0.1, 0.75)
			nebula_col = Color(0.6, 0.15, 0.05, 0.15)
			ring_col = Color(1.0, 0.4, 0.1, 0.30)
		"viridian_canopy":
			bg_col_top = Color(0.02, 0.06, 0.03)
			bg_col_mid = Color(0.04, 0.14, 0.07)
			moon_col = Color(0.08, 0.26, 0.14)
			moon_shadow = Color(0.02, 0.07, 0.03)
			conduit_a = Color(0.2, 0.95, 0.5, 0.85)
			conduit_b = Color(0.1, 0.8, 0.7, 0.75)
			nebula_col = Color(0.1, 0.5, 0.2, 0.14)
			ring_col = Color(0.2, 0.95, 0.6, 0.25)

	# 1. Deep Space Gradient Background
	var points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1280, 0),
		Vector2(1280, 720),
		Vector2(0, 720)
	])
	var colors = PackedColorArray([bg_col_top, bg_col_mid, bg_col_mid, bg_col_top])
	draw_polygon(points, colors)
	
	# 2. Cosmic Nebula Clouds (Soft layered translucent fields)
	var neb_centers = [
		Vector2(320, 240),
		Vector2(880, 480),
		Vector2(640, 160)
	]
	for idx in range(neb_centers.size()):
		var nc = neb_centers[idx]
		var drift = Vector2(sin(_drift_timer * 0.2 + idx) * 12.0, cos(_drift_timer * 0.15 + idx) * 8.0)
		draw_circle(nc + drift, 160.0, nebula_col)
		draw_circle(nc + drift, 100.0, Color(nebula_col.r, nebula_col.g, nebula_col.b, nebula_col.a * 1.5))
	
	# 3. Distant Stars (Twinkling with gentle parallax)
	for star in stars:
		var twinkle = 0.6 + sin(_drift_timer * star["twinkle_speed"] + star["twinkle_offset"]) * 0.4
		var c = Color(star["color"].r, star["color"].g, star["color"].b, star["color"].a * twinkle)
		draw_circle(star["pos"], star["size"], c)
	
	# 4. High-Detail Celestial Moon / Planet
	var moon_center = Vector2(480, 160)
	var moon_radius = 118.0
	
	# Atmospheric outer haze (multi-layer halo)
	draw_circle(moon_center, moon_radius + 14.0, Color(conduit_a.r, conduit_a.g, conduit_a.b, 0.08))
	draw_circle(moon_center, moon_radius + 6.0, Color(conduit_a.r, conduit_a.g, conduit_a.b, 0.15))
	
	# Planet base & shadow terminator
	draw_circle(moon_center, moon_radius, moon_shadow)
	
	# Illuminated crescent body
	var crescent_pts: PackedVector2Array = []
	for i in range(33):
		var ang = -PI * 0.5 + (PI * float(i) / 32.0)
		crescent_pts.append(moon_center + Vector2(cos(ang), sin(ang)) * moon_radius)
	# Inner terminator curve
	for i in range(32, -1, -1):
		var ang = -PI * 0.5 + (PI * float(i) / 32.0)
		crescent_pts.append(moon_center + Vector2(cos(ang) * 0.35, sin(ang)) * moon_radius)
	draw_colored_polygon(crescent_pts, moon_col)
	
	# Planet craters with illuminated rims & shadowed bowls
	var craters = [
		{"pos": Vector2(-28, -25), "r": 20.0},
		{"pos": Vector2(18, 32), "r": 26.0},
		{"pos": Vector2(-12, 48), "r": 15.0},
		{"pos": Vector2(35, -12), "r": 14.0},
		{"pos": Vector2(-42, 10), "r": 16.0}
	]
	for cr in craters:
		var cp = moon_center + cr["pos"]
		draw_circle(cp, cr["r"], Color(0.01, 0.02, 0.05, 0.7))
		draw_arc(cp, cr["r"], -PI * 0.6, PI * 0.25, 20, Color(conduit_a.r, conduit_a.g, conduit_a.b, 0.65), 1.5)
	
	# Planetary Orbital Ring
	var ring_pts_upper: PackedVector2Array = []
	var ring_pts_lower: PackedVector2Array = []
	for i in range(33):
		var t = float(i) / 32.0
		var ang = -PI + t * TAU
		var pt = moon_center + Vector2(cos(ang) * (moon_radius * 1.8), sin(ang) * (moon_radius * 0.35))
		if sin(ang) < 0:
			ring_pts_upper.append(pt)
		else:
			ring_pts_lower.append(pt)
	
	# Draw front half of orbital ring
	if ring_pts_lower.size() > 1:
		draw_polyline(ring_pts_lower, ring_col, 3.5)
		draw_polyline(ring_pts_lower, Color(conduit_a.r, conduit_a.g, conduit_a.b, 0.4), 1.5)
	
	# Atmosphere crest arc
	draw_arc(moon_center, moon_radius, -PI * 0.65, PI * 0.2, 48, Color(conduit_a.r, conduit_a.g, conduit_a.b, 0.95), 2.5)
	
	# 5. Industrial Catwalks & Girders (Dark silhouettes)
	for rect in station_girders:
		draw_rect(rect, Color(0.03, 0.04, 0.08, 0.94))
		if rect.size.x < 50 and rect.size.y > 100:
			for y_brace in range(int(rect.position.y), int(rect.position.y + rect.size.y), 60):
				draw_line(
					Vector2(rect.position.x, y_brace),
					Vector2(rect.position.x + rect.size.x, y_brace + 30),
					Color(0.06, 0.08, 0.15, 0.7),
					1.5
				)
	
	# 6. Biome-Themed Vector Conduits
	draw_line(Vector2(0, 48), Vector2(1280, 48), conduit_a, 2.0)
	draw_line(Vector2(0, 672), Vector2(1280, 672), conduit_b, 2.0)
	for x in range(120, 1200, 180):
		draw_line(Vector2(x, 44), Vector2(x + 16, 44), conduit_a, 3.0)
