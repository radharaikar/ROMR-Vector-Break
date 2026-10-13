class_name BiomeAlienForest
extends BiomeEnvironmentBase

# ==============================================================================
# VECTOR//BREAK — BIOME 5: ALIEN FOREST (VIRIDIAN CANOPY)
# Deep green/teal jungle canopy, massive alien fungal trunks, bioluminescent
# spore pods, overgrown lab ruins, and toxic spore cloud hazards.
# ==============================================================================

var fungal_trunks: Array[Dictionary] = []
var spore_clusters: Array[Dictionary] = []
var time_elapsed: float = 0.0

@onready var hazard_zone: BiomeHazardZone = $HazardZone
@onready var spore_particles: CPUParticles2D = $SporeParticles

func _ready() -> void:
	biome_id = "alien_forest"
	super._ready()
	_generate_forest_elements()
	queue_redraw()

func _generate_forest_elements() -> void:
	# Massive alien tree trunks
	fungal_trunks.append({"pos": Vector2(300, 672), "width": 80.0, "height": 380.0})
	fungal_trunks.append({"pos": Vector2(740, 672), "width": 95.0, "height": 340.0})
	fungal_trunks.append({"pos": Vector2(1080, 672), "width": 85.0, "height": 420.0})
	fungal_trunks.append({"pos": Vector2(520, 48), "width": 70.0, "height": -260.0})
	
	# Bioluminescent spore shelf caps
	spore_clusters.append({"pos": Vector2(340, 420), "radius": 24.0, "color": Color(0.2, 1.0, 0.6, 0.9)})
	spore_clusters.append({"pos": Vector2(785, 460), "radius": 28.0, "color": Color(0.1, 0.9, 0.8, 0.9)})
	spore_clusters.append({"pos": Vector2(1120, 360), "radius": 22.0, "color": Color(0.3, 1.0, 0.5, 0.9)})
	spore_clusters.append({"pos": Vector2(550, 220), "radius": 20.0, "color": Color(0.2, 0.95, 0.7, 0.9)})

func _process(delta: float) -> void:
	super._process(delta)
	time_elapsed += delta
	queue_redraw()

func _draw() -> void:
	# 1. Deep Teal & Viridian Canopy Gradient
	var canopy_pts = PackedVector2Array([
		Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)
	])
	var canopy_colors = PackedColorArray([
		Color(0.01, 0.06, 0.05), # Dark teal canopy
		Color(0.02, 0.12, 0.08),
		Color(0.03, 0.18, 0.12), # Viridian depth
		Color(0.01, 0.06, 0.05)
	])
	draw_polygon(canopy_pts, canopy_colors)
	
	# 2. Distant Canopy Leaves / Organic Arcs
	for i in range(8):
		var arc_x = 100 + i * 160
		draw_circle(Vector2(arc_x, 80), 90.0, Color(0.02, 0.10, 0.07, 0.45))
	
	# 3. Giant Alien Fungal Trunks
	for t in fungal_trunks:
		var rect = Rect2(t["pos"].x - t["width"] * 0.5, t["pos"].y, t["width"], -t["height"])
		draw_rect(rect, Color(0.03, 0.10, 0.07, 0.95))
		# Overgrown vine striations
		for y in range(int(min(t["pos"].y, t["pos"].y - t["height"])), int(max(t["pos"].y, t["pos"].y - t["height"])), 40):
			draw_line(
				Vector2(t["pos"].x - t["width"] * 0.5, y),
				Vector2(t["pos"].x + t["width"] * 0.5, y + 20),
				Color(0.08, 0.28, 0.18, 0.7),
				2.0
			)
	
	# 4. Bioluminescent Spore Shelf Clusters (Pulsating)
	var spore_pulse = (sin(time_elapsed * 2.4) + 1.0) * 0.5
	for sc in spore_clusters:
		# Outer spore glow
		draw_circle(sc["pos"], sc["radius"] * (1.2 + spore_pulse * 0.25), Color(sc["color"].r, sc["color"].g, sc["color"].b, 0.25))
		# Solid shelf cap
		draw_circle(sc["pos"], sc["radius"], sc["color"])
		# Core bright node
		draw_circle(sc["pos"], sc["radius"] * 0.4, Color(0.9, 1.0, 0.8, 0.95))
	
	# 5. Overgrown Bio-Conduits
	draw_line(Vector2(0, 48), Vector2(1280, 48), Color(0.15, 0.95, 0.55, 0.85), 2.5)
	draw_line(Vector2(0, 672), Vector2(1280, 672), Color(0.05, 0.8, 0.75, 0.85), 2.5)
	
	# Viridian chevron markings
	for x in range(120, 1200, 180):
		draw_line(Vector2(x, 44), Vector2(x + 16, 44), Color(0.2, 1.0, 0.6, 0.9), 3.0)
		draw_line(Vector2(x, 676), Vector2(x + 16, 676), Color(0.1, 0.9, 0.8, 0.9), 3.0)

func _on_hazard_warning() -> void:
	if hazard_zone:
		hazard_zone.trigger_warning()

func _on_hazard_trigger() -> void:
	if hazard_zone:
		hazard_zone.trigger_surge()
