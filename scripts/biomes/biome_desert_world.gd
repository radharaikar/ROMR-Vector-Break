class_name BiomeDesertWorld
extends BiomeEnvironmentBase

# ==============================================================================
# VECTOR//BREAK — BIOME 2: DESERT WORLD (VESPER DESERT DOWNS)
# Ochre dunes, blazing amber solar orb, ruined futuristic collector spires,
# and sweeping sandstorm particles.
# ==============================================================================

var dunes: Array[PackedVector2Array] = []
var monoliths: Array[Rect2] = []

@onready var hazard_zone: BiomeHazardZone = $HazardZone
@onready var sandstorm_particles: CPUParticles2D = $SandstormParticles

func _ready() -> void:
	biome_id = "desert_world"
	super._ready()
	_generate_desert_elements()
	queue_redraw()

func _generate_desert_elements() -> void:
	# Far sand dune
	var far_pts = PackedVector2Array([
		Vector2(0, 720), Vector2(0, 380),
		Vector2(200, 340), Vector2(450, 370), Vector2(700, 330),
		Vector2(950, 360), Vector2(1280, 320), Vector2(1280, 720)
	])
	dunes.append(far_pts)
	
	# Mid sand dune
	var mid_pts = PackedVector2Array([
		Vector2(0, 720), Vector2(0, 480),
		Vector2(300, 440), Vector2(600, 490), Vector2(850, 450),
		Vector2(1100, 470), Vector2(1280, 430), Vector2(1280, 720)
	])
	dunes.append(mid_pts)
	
	# Ruined outpost solar spires / monolith pillars
	monoliths.append(Rect2(320, 200, 28, 472))
	monoliths.append(Rect2(760, 260, 34, 412))
	monoliths.append(Rect2(1040, 180, 24, 492))

func _draw() -> void:
	# 1. Warm Ochre & Terra Cotta Atmosphere
	var sky_pts = PackedVector2Array([
		Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)
	])
	var sky_colors = PackedColorArray([
		Color(0.24, 0.10, 0.04), # Dusky terra-cotta
		Color(0.38, 0.18, 0.06), # Amber sky
		Color(0.52, 0.28, 0.08), # Warm horizon
		Color(0.24, 0.10, 0.04)
	])
	draw_polygon(sky_pts, sky_colors)
	
	# 2. Scorching Solar Orb
	var sun_pos = Vector2(820, 140)
	draw_circle(sun_pos, 75.0, Color(1.0, 0.85, 0.4, 0.85))
	draw_circle(sun_pos, 100.0, Color(1.0, 0.65, 0.2, 0.3))
	draw_arc(sun_pos, 120.0, 0, TAU, 48, Color(1.0, 0.5, 0.1, 0.25), 3.0)
	
	# 3. Far Dunes
	if dunes.size() > 0:
		draw_polygon(dunes[0], PackedColorArray([Color(0.42, 0.22, 0.08)]))
	
	# 4. Ruined Spire Silhouettes
	for m in monoliths:
		draw_rect(m, Color(0.22, 0.12, 0.06, 0.95))
		# Weathered cross vents
		for y in range(int(m.position.y + 40), int(m.position.y + m.size.y - 40), 50):
			draw_line(Vector2(m.position.x, y), Vector2(m.position.x + m.size.x, y), Color(0.12, 0.06, 0.03, 0.8), 2.0)
	
	# 5. Near Dunes
	if dunes.size() > 1:
		draw_polygon(dunes[1], PackedColorArray([Color(0.32, 0.16, 0.06)]))
	
	# 6. Industrial Perimeter Borders (Weathered copper/amber conduit)
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(1.0, 0.65, 0.15, 0.85), 2.5)
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(0.95, 0.35, 0.1, 0.85), 2.5)
	
	# Amber chevron hazard indicators
	for x in range(100, 1200, 200):
		draw_line(Vector2(x, 44), Vector2(x + 18, 44), Color(1.0, 0.8, 0.2, 0.9), 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 18, 676), Color(1.0, 0.5, 0.1, 0.9), 3.0)

func _on_hazard_warning() -> void:
	if hazard_zone:
		hazard_zone.trigger_warning()

func _on_hazard_trigger() -> void:
	if hazard_zone:
		hazard_zone.trigger_surge()
