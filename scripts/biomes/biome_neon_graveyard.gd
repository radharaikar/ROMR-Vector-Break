class_name BiomeNeonGraveyard
extends BiomeEnvironmentBase

# ==============================================================================
# VECTOR//BREAK — BIOME 1: NEON GRAVEYARD
# Dark navy space expanse, multi-layered starfield, abandoned station catwalks,
# electric cyan and magenta energy conduits.
# ==============================================================================

var stars: Array[Dictionary] = []
var girders: Array[Rect2] = []

@onready var hazard_zone: BiomeHazardZone = $HazardZone
@onready var particles: CPUParticles2D = $SpaceDustParticles

func _ready() -> void:
	biome_id = "neon_graveyard"
	super._ready()
	_generate_space_elements()
	queue_redraw()

func _generate_space_elements() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 101
	for i in range(100):
		stars.append({
			"pos": Vector2(rng.randf_range(0, 1280), rng.randf_range(48, 672)),
			"size": rng.randf_range(1.0, 2.5),
			"color": Color(rng.randf_range(0.6, 1.0), rng.randf_range(0.8, 1.0), 1.0, rng.randf_range(0.4, 0.9))
		})
	
	# Station framework girders
	girders.append(Rect2(0, 0, 1280, 48))
	girders.append(Rect2(0, 672, 1280, 48))
	girders.append(Rect2(420, 48, 24, 624))
	girders.append(Rect2(880, 48, 28, 624))

func _draw() -> void:
	# Deep space backdrop
	var rect = Rect2(0, 0, 1280, 720)
	var colors = PackedColorArray([
		Color(0.02, 0.03, 0.07),
		Color(0.04, 0.07, 0.16),
		Color(0.06, 0.08, 0.18),
		Color(0.02, 0.03, 0.07)
	])
	var pts = PackedVector2Array([
		Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)
	])
	draw_polygon(pts, colors)
	
	# Celestial moon with crescent atmosphere
	draw_circle(Vector2(520, 160), 90.0, Color(0.07, 0.11, 0.22, 0.75))
	draw_arc(Vector2(520, 160), 90.0, -PI * 0.8, PI * 0.1, 48, Color(0.2, 0.85, 1.0, 0.45), 2.5)
	
	# Stars
	for s in stars:
		draw_circle(s["pos"], s["size"], s["color"])
	
	# Catwalks and pillars
	for g in girders:
		draw_rect(g, Color(0.04, 0.05, 0.09, 0.92))
		if g.size.x < 50:
			for y in range(int(g.position.y), int(g.position.y + g.size.y), 70):
				draw_line(Vector2(g.position.x, y), Vector2(g.position.x + g.size.x, y + 35), Color(0.08, 0.12, 0.2, 0.7), 1.5)
	
	# Neon conduits
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(0.1, 0.85, 1.0, 0.8), 2.5)
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(1.0, 0.18, 0.8, 0.8), 2.5)

func _on_hazard_warning() -> void:
	if hazard_zone:
		hazard_zone.trigger_warning()

func _on_hazard_trigger() -> void:
	if hazard_zone:
		hazard_zone.trigger_surge()
