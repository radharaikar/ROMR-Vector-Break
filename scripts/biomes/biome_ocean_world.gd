class_name BiomeOceanWorld
extends BiomeEnvironmentBase

# ==============================================================================
# VECTOR//BREAK — BIOME 3: OCEAN WORLD (PELAGIC DEPTHS)
# Deep turquoise ocean gradient, water caustic rays, submerged research domes,
# bioluminescent kelp tendrils, and buoyant oscillating reflectors.
# ==============================================================================

var kelp_stalks: Array[Dictionary] = []
var domes: Array[Dictionary] = []
var time_elapsed: float = 0.0

@onready var hazard_zone: BiomeHazardZone = $HazardZone
@onready var bubble_particles: CPUParticles2D = $BubbleParticles
@onready var moving_reflector: Node2D = $BuoyantReflector

func _ready() -> void:
	biome_id = "ocean_world"
	super._ready()
	_generate_ocean_elements()
	queue_redraw()

func _generate_ocean_elements() -> void:
	# Submerged research habitat domes
	domes.append({"pos": Vector2(380, 672), "radius": 110.0})
	domes.append({"pos": Vector2(920, 672), "radius": 140.0})
	domes.append({"pos": Vector2(650, 672), "radius": 80.0})
	
	# Bioluminescent kelp tendrils
	var rng = RandomNumberGenerator.new()
	rng.seed = 303
	for i in range(14):
		kelp_stalks.append({
			"base_x": rng.randf_range(80, 1200),
			"height": rng.randf_range(160, 360),
			"freq": rng.randf_range(1.5, 3.0),
			"amp": rng.randf_range(12.0, 24.0),
			"color": Color(0.1, rng.randf_range(0.7, 0.95), 0.85, 0.6)
		})

func _process(delta: float) -> void:
	super._process(delta)
	time_elapsed += delta
	
	# Gently oscillate buoyant reflector
	if moving_reflector:
		var buoy_offset = sin(time_elapsed * 1.8) * 45.0
		moving_reflector.position.y = 360.0 + buoy_offset
	
	# Periodically redraw waving flora
	queue_redraw()

func _draw() -> void:
	# 1. Deep Abyssal Water Gradient
	var water_pts = PackedVector2Array([
		Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)
	])
	var water_colors = PackedColorArray([
		Color(0.01, 0.08, 0.18), # Deep indigo-cyan surface
		Color(0.01, 0.14, 0.26),
		Color(0.01, 0.05, 0.12), # Abyssal darkness floor
		Color(0.01, 0.05, 0.12)
	])
	draw_polygon(water_pts, water_colors)
	
	# 2. Caustic Shimmer Light Rays
	for i in range(5):
		var ray_x = 180 + i * 230
		var ray_offset = sin(time_elapsed * 1.2 + i) * 30.0
		var ray_pts = PackedVector2Array([
			Vector2(ray_x - 40 + ray_offset, 48),
			Vector2(ray_x + 40 + ray_offset, 48),
			Vector2(ray_x + 90 - ray_offset, 672),
			Vector2(ray_x - 90 - ray_offset, 672)
		])
		draw_polygon(ray_pts, PackedColorArray([
			Color(0.05, 0.85, 0.9, 0.06), Color(0.05, 0.85, 0.9, 0.06),
			Color(0.02, 0.35, 0.5, 0.02), Color(0.02, 0.35, 0.5, 0.02)
		]))
	
	# 3. Submerged Research Domes
	for d in domes:
		draw_circle(d["pos"], d["radius"], Color(0.02, 0.08, 0.16, 0.92))
		draw_arc(d["pos"], d["radius"], -PI, 0, 36, Color(0.1, 0.6, 0.8, 0.6), 2.5)
		# Interior illumination ring
		draw_circle(d["pos"] + Vector2(0, -30), 16.0, Color(0.2, 0.9, 0.8, 0.25))
	
	# 4. Bioluminescent Kelp Tendrils Waving in Currents
	for k in kelp_stalks:
		var wave = sin(time_elapsed * k["freq"] + k["base_x"] * 0.01) * k["amp"]
		var pts = PackedVector2Array([
			Vector2(k["base_x"], 672),
			Vector2(k["base_x"] + wave * 0.5, 672 - k["height"] * 0.5),
			Vector2(k["base_x"] + wave, 672 - k["height"])
		])
		draw_polyline(pts, k["color"], 3.0)
		# Glowing bioluminescent tip node
		draw_circle(pts[2], 4.5, Color(0.2, 1.0, 0.9, 0.9))
	
	# 5. Hydrodynamic Neon Conduits
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(0.0, 0.9, 0.85, 0.85), 2.5)
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(0.25, 0.5, 0.95, 0.85), 2.5)
	
	# Cyan chevron indicators
	for x in range(140, 1200, 190):
		draw_line(Vector2(x, 44), Vector2(x + 16, 44), Color(0.2, 1.0, 0.9, 0.9), 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 16, 676), Color(0.3, 0.6, 1.0, 0.9), 3.0)

func _on_hazard_warning() -> void:
	if hazard_zone:
		hazard_zone.trigger_warning()

func _on_hazard_trigger() -> void:
	if hazard_zone:
		hazard_zone.trigger_surge()
