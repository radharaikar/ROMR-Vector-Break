class_name BiomeVolcanicWorld
extends BiomeEnvironmentBase

# ==============================================================================
# VECTOR//BREAK — BIOME 4: VOLCANIC WORLD (PYROCLASTIC RIFT)
# Obsidian caldera, pulsating molten lava channels, basalt pillar crags,
# rising fire embers, and telegraphed geothermal magma vents.
# ==============================================================================

var crags: Array[PackedVector2Array] = []
var lava_fissures: Array[Rect2] = []
var time_elapsed: float = 0.0

@onready var hazard_zone: BiomeHazardZone = $HazardZone
@onready var ember_particles: CPUParticles2D = $FireEmberParticles

func _ready() -> void:
	biome_id = "volcanic_world"
	super._ready()
	_generate_volcanic_elements()
	queue_redraw()

func _generate_volcanic_elements() -> void:
	# Jagged basalt pillar crags
	var crag1 = PackedVector2Array([
		Vector2(260, 672), Vector2(280, 480), Vector2(320, 420),
		Vector2(360, 510), Vector2(380, 672)
	])
	crags.append(crag1)
	
	var crag2 = PackedVector2Array([
		Vector2(780, 672), Vector2(810, 440), Vector2(850, 390),
		Vector2(900, 460), Vector2(930, 672)
	])
	crags.append(crag2)
	
	var crag_top = PackedVector2Array([
		Vector2(540, 48), Vector2(570, 180), Vector2(610, 220),
		Vector2(650, 160), Vector2(680, 48)
	])
	crags.append(crag_top)
	
	# Molten lava channels at bottom
	lava_fissures.append(Rect2(0, 640, 1280, 32))
	lava_fissures.append(Rect2(420, 620, 320, 20))

func _process(delta: float) -> void:
	super._process(delta)
	time_elapsed += delta
	# Slight redraw pulse for glowing lava
	queue_redraw()

func _draw() -> void:
	# 1. Ash & Crimson Pall Gradient
	var sky_pts = PackedVector2Array([
		Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)
	])
	var sky_colors = PackedColorArray([
		Color(0.08, 0.01, 0.01), # Ash obsidian
		Color(0.18, 0.03, 0.02),
		Color(0.28, 0.05, 0.02), # Crimson horizon glow
		Color(0.12, 0.02, 0.01)
	])
	draw_polygon(sky_pts, sky_colors)
	
	# 2. Glowing Molten Lava Lake & Cracks
	var pulse = (sin(time_elapsed * 3.0) + 1.0) * 0.5
	var lava_color = Color(1.0, 0.25 + pulse * 0.15, 0.05, 0.95)
	var glow_color = Color(1.0, 0.55 + pulse * 0.2, 0.1, 0.4)
	
	for fiss in lava_fissures:
		# Outer heat glow
		draw_rect(Rect2(fiss.position.x, fiss.position.y - 10, fiss.size.x, fiss.size.y + 20), glow_color)
		# Magma core
		draw_rect(fiss, lava_color)
	
	# 3. Jagged Basalt Rock Crags
	for c in crags:
		draw_polygon(c, PackedColorArray([Color(0.08, 0.04, 0.04, 0.96)]))
		# Basalt fracture lines
		draw_polyline(c, Color(0.2, 0.08, 0.06, 0.8), 2.0)
	
	# 4. Superheated Boundary Conduits
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(1.0, 0.28, 0.08, 0.9), 2.5)
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(1.0, 0.72, 0.15, 0.9), 3.0)
	
	# Magma warning hashmarks
	for x in range(80, 1200, 160):
		draw_line(Vector2(x, 44), Vector2(x + 18, 44), Color(1.0, 0.4, 0.1, 0.9), 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 18, 676), Color(1.0, 0.85, 0.2, 0.9), 3.0)

func _on_hazard_warning() -> void:
	if hazard_zone:
		hazard_zone.trigger_warning()

func _on_hazard_trigger() -> void:
	if hazard_zone:
		hazard_zone.trigger_surge()
