class_name CharacterAvatar
extends Control

# ==============================================================================
# VECTOR//BREAK — PROCEDURAL SCI-FI CHARACTER AVATAR
# Draws stylized, high-contrast holographic portraits for each storyline character:
# - KAEL VEYR: Cyan ace pilot helmet silhouette & tactical visor
# - MIRA VEYR: Magenta & cyan neural core with resonant frequency lattice
# - LUCIEN VALE: Red authoritarian command diamond & geometric gaze
# - ORACLE TACTICAL AI: Hexagonal neural matrix with concentric telemetry rings
# - COMMANDER SERIN: Amber/crimson heavy fleet insignia with battle wings
# - TACTICAL UPLINK / DATA LOG: High-frequency terminal waveform & status blip
# ==============================================================================

var speaker_name: String = "KAEL VEYR"
var accent_color: Color = Color(0.2, 0.9, 1.0)
var _anim_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(80, 80)

func set_speaker(speaker: String, col: Color) -> void:
	speaker_name = speaker.to_upper()
	accent_color = col
	queue_redraw()

func _process(delta: float) -> void:
	if visible:
		_anim_timer += delta * 3.0
		queue_redraw()

func _draw() -> void:
	var center = size * 0.5
	var r = min(size.x, size.y) * 0.44
	var pulse = 0.8 + sin(_anim_timer) * 0.2
	
	# 1. Hologram Outer Frame
	var bg_col = Color(0.02, 0.04, 0.08, 0.9)
	draw_circle(center, r + 4.0, bg_col)
	draw_arc(center, r + 4.0, 0, TAU, 32, accent_color * 0.5, 1.5)
	
	# Corner reticles
	var s = r + 6.0
	draw_line(center + Vector2(-s, -s), center + Vector2(-s + 10, -s), accent_color, 2.0)
	draw_line(center + Vector2(-s, -s), center + Vector2(-s, -s + 10), accent_color, 2.0)
	draw_line(center + Vector2(s, -s), center + Vector2(s - 10, -s), accent_color, 2.0)
	draw_line(center + Vector2(s, -s), center + Vector2(s, -s + 10), accent_color, 2.0)
	draw_line(center + Vector2(-s, s), center + Vector2(-s + 10, s), accent_color, 2.0)
	draw_line(center + Vector2(-s, s), center + Vector2(-s, s - 10), accent_color, 2.0)
	draw_line(center + Vector2(s, s), center + Vector2(s - 10, s), accent_color, 2.0)
	draw_line(center + Vector2(s, s), center + Vector2(s, s - 10), accent_color, 2.0)

	# 2. Distinct Character Emblem
	if "KAEL" in speaker_name:
		# Pilot helmet & visor
		var helm_poly: PackedVector2Array = [
			center + Vector2(-18, 18),
			center + Vector2(-22, -4),
			center + Vector2(-12, -22),
			center + Vector2(12, -22),
			center + Vector2(22, -4),
			center + Vector2(18, 18),
			center + Vector2(0, 14)
		]
		draw_colored_polygon(helm_poly, Color(0.05, 0.12, 0.22))
		draw_polyline(helm_poly, accent_color, 2.0)
		# Visor arc
		var visor_pts: PackedVector2Array = [
			center + Vector2(-14, -6),
			center + Vector2(0, -10),
			center + Vector2(14, -6),
			center + Vector2(12, 2),
			center + Vector2(0, 5),
			center + Vector2(-12, 2)
		]
		draw_colored_polygon(visor_pts, Color(0.1, 0.9, 1.0, 0.75 * pulse))
		draw_polyline(visor_pts, Color(0.8, 1.0, 1.0), 1.5)
		
	elif "MIRA" in speaker_name:
		# Neural crystal core & resonance rings
		draw_arc(center, r * 0.75, 0, TAU, 24, Color(0.9, 0.3, 0.85, 0.4 * pulse), 1.0)
		var crystal: PackedVector2Array = [
			center + Vector2(0, -22),
			center + Vector2(14, -6),
			center + Vector2(10, 16),
			center + Vector2(0, 24),
			center + Vector2(-10, 16),
			center + Vector2(-14, -6)
		]
		draw_colored_polygon(crystal, Color(0.15, 0.05, 0.2))
		draw_polyline(crystal, accent_color, 2.0)
		# Inner neural pulse
		draw_line(center + Vector2(0, -22), center + Vector2(0, 24), Color(1.0, 0.5, 0.9, pulse), 2.0)
		draw_line(center + Vector2(-14, -6), center + Vector2(14, -6), Color(0.3, 0.9, 1.0, pulse), 1.5)
		draw_circle(center, 4.0, Color(1.0, 0.8, 1.0, pulse))
		
	elif "VALE" in speaker_name:
		# Authoritarian AXIOM command diamond & cold geometric eye
		var diamond: PackedVector2Array = [
			center + Vector2(0, -24),
			center + Vector2(22, 0),
			center + Vector2(0, 24),
			center + Vector2(-22, 0)
		]
		draw_colored_polygon(diamond, Color(0.18, 0.03, 0.04))
		draw_polyline(diamond, accent_color, 2.5)
		draw_circle(center, 8.0, Color(0.08, 0.01, 0.02))
		draw_circle(center, 8.0, Color(1.0, 0.2, 0.2, pulse), false, 1.5)
		draw_line(center + Vector2(-14, 0), center + Vector2(14, 0), Color(1.0, 0.3, 0.3, pulse), 2.0)
		draw_circle(center, 3.0, Color(1.0, 0.8, 0.8, pulse))
		
	elif "ORACLE" in speaker_name:
		# Hexagonal AI neural matrix with concentric telemetry rings
		var hex: PackedVector2Array = [
			center + Vector2(0, -22),
			center + Vector2(19, -11),
			center + Vector2(19, 11),
			center + Vector2(0, 22),
			center + Vector2(-19, 11),
			center + Vector2(-19, -11)
		]
		draw_colored_polygon(hex, Color(0.08, 0.02, 0.06))
		draw_polyline(hex, accent_color, 2.0)
		draw_arc(center, 12.0, 0, TAU, 16, Color(1.0, 0.25, 0.4, pulse), 1.5)
		draw_arc(center, 6.0, 0, TAU, 12, Color(0.2, 1.0, 0.8, pulse), 1.5)
		draw_circle(center, 2.5, Color(1.0, 1.0, 1.0, pulse))
		
	elif "SERIN" in speaker_name:
		# Commander heavy fleet insignia with battle wings
		var shield: PackedVector2Array = [
			center + Vector2(-18, -16),
			center + Vector2(18, -16),
			center + Vector2(18, 4),
			center + Vector2(0, 22),
			center + Vector2(-18, 4)
		]
		draw_colored_polygon(shield, Color(0.18, 0.08, 0.04))
		draw_polyline(shield, accent_color, 2.0)
		# Officer chevron
		draw_line(center + Vector2(-12, -8), center + Vector2(0, 4), Color(1.0, 0.8, 0.3, pulse), 2.5)
		draw_line(center + Vector2(12, -8), center + Vector2(0, 4), Color(1.0, 0.8, 0.3, pulse), 2.5)
		draw_line(center + Vector2(-12, -14), center + Vector2(0, -2), Color(1.0, 0.5, 0.2, pulse), 2.0)
		draw_line(center + Vector2(12, -14), center + Vector2(0, -2), Color(1.0, 0.5, 0.2, pulse), 2.0)
		
	else:
		# Terminal / Data uplink waveform
		draw_rect(Rect2(center.x - 18, center.y - 18, 36, 36), Color(0.05, 0.08, 0.12))
		draw_rect(Rect2(center.x - 18, center.y - 18, 36, 36), accent_color, false, 1.5)
		var pts: PackedVector2Array = [
			center + Vector2(-14, 0),
			center + Vector2(-8, -10 * pulse),
			center + Vector2(-2, 12 * pulse),
			center + Vector2(4, -14 * pulse),
			center + Vector2(10, 8 * pulse),
			center + Vector2(14, 0)
		]
		draw_polyline(pts, accent_color, 2.0)
