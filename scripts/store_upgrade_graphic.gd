class_name StoreUpgradeGraphic
extends Control

# ==============================================================================
# VECTOR//BREAK — STORE UPGRADE PREVIEW GRAPHIC
# Renders crisp procedural vector blueprint illustrations for combat upgrades.
# ==============================================================================

var current_upgrade_id: String = ""

func set_upgrade(up_id: String) -> void:
	current_upgrade_id = up_id
	queue_redraw()

func _draw() -> void:
	if current_upgrade_id.is_empty():
		return
	
	var center: Vector2 = size * 0.5
	if center == Vector2.ZERO:
		center = Vector2(270.0, 110.0)
	
	# Draw background grid & radar ring
	draw_arc(center, 70.0, 0, TAU, 32, Color(0.1, 0.4, 0.6, 0.25), 1.5)
	draw_arc(center, 90.0, 0, TAU, 48, Color(0.1, 0.3, 0.5, 0.15), 1.0)
	draw_line(center - Vector2(100, 0), center + Vector2(100, 0), Color(0.1, 0.5, 0.7, 0.2), 1.0)
	draw_line(center - Vector2(0, 80), center + Vector2(0, 80), Color(0.1, 0.5, 0.7, 0.2), 1.0)
	
	match current_upgrade_id:
		"upgrade_capacitor":
			# Dual cyan capacitor coils with lightning discharge vectors
			var cyan = Color(0.2, 0.95, 1.0, 0.95)
			var white = Color(1.0, 1.0, 1.0, 0.9)
			# Outer capacitor plates
			draw_rect(Rect2(center.x - 45, center.y - 35, 14, 70), cyan, false, 2.5)
			draw_rect(Rect2(center.x + 31, center.y - 35, 14, 70), cyan, false, 2.5)
			# Central energy core
			draw_circle(center, 18.0, Color(0.1, 0.8, 1.0, 0.4))
			draw_arc(center, 18.0, 0, TAU, 24, white, 2.0)
			# Dynamic electric arcs
			var arc_points = [
				center + Vector2(-30, 0),
				center + Vector2(-12, -10),
				center + Vector2(4, 8),
				center + Vector2(30, 0)
			]
			for i in range(arc_points.size() - 1):
				draw_line(arc_points[i], arc_points[i+1], cyan, 2.0)
			# Pulse label
			draw_string(ThemeDB.fallback_font, center + Vector2(-68, 60), "KINETIC VECTOR CAPACITOR", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, cyan)

		"upgrade_nanocell":
			# Emerald & cyan emergency medical nanocell with hexagonal lattice
			var green = Color(0.2, 1.0, 0.65, 0.95)
			var cyan = Color(0.2, 0.9, 1.0, 0.8)
			# Central medical cross
			draw_rect(Rect2(center.x - 10, center.y - 35, 20, 70), green, true)
			draw_rect(Rect2(center.x - 35, center.y - 10, 70, 20), green, true)
			# Hexagonal bounding shield
			var hex_points: PackedVector2Array = []
			for i in range(6):
				var angle = i * TAU / 6.0 - PI / 6.0
				hex_points.append(center + Vector2(cos(angle), sin(angle)) * 52.0)
			hex_points.append(hex_points[0])
			for i in range(6):
				draw_line(hex_points[i], hex_points[i+1], cyan, 2.0)
			# Pulse label
			draw_string(ThemeDB.fallback_font, center + Vector2(-70, 60), "EMERGENCY NANOCELL MATRIX", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, green)

		"upgrade_frame":
			# Heavy titanium reinforced armor plate schematic
			var magenta = Color(1.0, 0.35, 0.85, 0.95)
			var amber = Color(1.0, 0.8, 0.25, 0.9)
			# Armor plate contour
			var pts: PackedVector2Array = [
				center + Vector2(0, -42),
				center + Vector2(42, -22),
				center + Vector2(34, 32),
				center + Vector2(0, 48),
				center + Vector2(-34, 32),
				center + Vector2(-42, -22),
				center + Vector2(0, -42)
			]
			for i in range(pts.size() - 1):
				draw_line(pts[i], pts[i+1], magenta, 3.0)
			# Internal reinforcing struts
			draw_line(pts[0], pts[3], amber, 2.0)
			draw_line(pts[1], pts[4], Color(magenta.r, magenta.g, magenta.b, 0.6), 1.5)
			draw_line(pts[2], pts[5], Color(magenta.r, magenta.g, magenta.b, 0.6), 1.5)
			draw_string(ThemeDB.fallback_font, center + Vector2(-65, 60), "REINFORCED TITANIUM HULL", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, magenta)

		"upgrade_targeting":
			# Holographic targeting reticle with predictive trajectory line
			var cyan = Color(0.2, 0.95, 1.0, 0.95)
			var red = Color(1.0, 0.25, 0.35, 0.9)
			# Outer reticle brackets
			draw_arc(center, 38.0, -0.4, 0.4, 16, cyan, 2.5)
			draw_arc(center, 38.0, PI - 0.4, PI + 0.4, 16, cyan, 2.5)
			draw_arc(center, 38.0, PI * 0.5 - 0.4, PI * 0.5 + 0.4, 16, cyan, 2.5)
			draw_arc(center, 38.0, -PI * 0.5 - 0.4, -PI * 0.5 + 0.4, 16, cyan, 2.5)
			# Center dot & crosshair
			draw_circle(center, 3.5, red)
			draw_line(center - Vector2(16, 0), center + Vector2(16, 0), cyan, 1.5)
			draw_line(center - Vector2(0, 16), center + Vector2(0, 16), cyan, 1.5)
			# Predictive trajectory dashed vector
			draw_line(center, center + Vector2(60, -35), Color(0.3, 0.9, 1.0, 0.7), 1.5)
			draw_circle(center + Vector2(60, -35), 4.0, cyan)
			draw_string(ThemeDB.fallback_font, center + Vector2(-62, 60), "QUANTUM TARGETING ARRAY", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, cyan)

		_:
			# Generic tactical icon
			var col = Color(0.2, 0.9, 1.0, 0.8)
			draw_rect(Rect2(center.x - 30, center.y - 30, 60, 60), col, false, 2.0)
			draw_string(ThemeDB.fallback_font, center + Vector2(-40, 60), "TACTICAL MODULE", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, col)
