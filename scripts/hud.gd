class_name ArcadeHUD
extends CanvasLayer

@onready var score_label: Label = $Control/MarginContainer/VBoxContainer/ScoreLabel
@onready var combo_label: Label = $Control/MarginContainer/VBoxContainer/ComboBadge/ComboLabel
@onready var combo_badge: PanelContainer = $Control/MarginContainer/VBoxContainer/ComboBadge
@onready var title_label: Label = $Control/TitleMargin/VBox/TitleLabel
@onready var status_label: Label = get_node_or_null("Control/TitleMargin/VBox/StatusLabel")
@onready var banner_label: Label = get_node_or_null("Control/CenterBanner/BannerLabel")
@onready var center_banner: Control = get_node_or_null("Control/CenterBanner")

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.score_updated.connect(_on_score_updated)
		gm.combo_updated.connect(_on_combo_updated)
		_on_score_updated(gm.score)
		_on_combo_updated(gm.combo)
	
	# Connect to RoundManager if in scene
	var rm = get_tree().get_first_node_in_group("round_manager")
	if rm:
		_hook_round_manager(rm)

func _hook_round_manager(rm: Node) -> void:
	if rm.has_signal("round_started"):
		rm.round_started.connect(_on_round_started)
	if rm.has_signal("wave_started"):
		rm.wave_started.connect(_on_wave_started)
	if rm.has_signal("round_time_tick"):
		rm.round_time_tick.connect(_on_time_tick)
	if rm.has_signal("enemy_count_changed"):
		rm.enemy_count_changed.connect(_on_enemy_count_changed)
	if rm.has_signal("round_victory"):
		rm.round_victory.connect(_on_victory)
	if rm.has_signal("round_defeat"):
		rm.round_defeat.connect(_on_defeat)

func _on_score_updated(new_score: int) -> void:
	if score_label:
		score_label.text = "SCORE  %06d" % new_score

func _on_combo_updated(new_combo: int) -> void:
	if combo_label:
		combo_label.text = "COMBO  x%d" % new_combo
		if new_combo > 1 and combo_badge:
			var tween = create_tween()
			combo_badge.scale = Vector2(1.25, 1.25)
			combo_badge.modulate = Color(2.5, 1.0, 2.2)
			tween.tween_property(combo_badge, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(combo_badge, "modulate", Color(1.0, 1.0, 1.0), 0.2)

func _on_round_started(_idx: int, round_name: String, _time: float) -> void:
	show_banner(round_name, Color(0.2, 0.9, 1.0))
	if title_label:
		title_label.text = "VECTOR//BREAK — " + round_name

func _on_wave_started(wave_idx: int, total_waves: int) -> void:
	if status_label:
		status_label.text = "WAVE %d / %d" % [wave_idx, total_waves]

func _on_time_tick(time_val: float) -> void:
	var mins = int(time_val) / 60
	var secs = int(time_val) % 60
	if status_label:
		var current_text = status_label.text.split(" | ")[0]
		status_label.text = "%s | TIME: %02d:%02d" % [current_text, mins, secs]

func _on_enemy_count_changed(remaining: int, _total: int) -> void:
	if status_label:
		var parts = status_label.text.split(" | ")
		var wave_part = parts[0]
		var time_part = parts[1] if parts.size() > 1 else ""
		status_label.text = "%s | %s | HOSTILES: %d" % [wave_part, time_part, remaining]

func _on_victory(_round_idx: int, _score: int) -> void:
	show_banner("SECTOR SECURED — VICTORY", Color(0.3, 1.0, 0.5))

func _on_defeat(reason: String) -> void:
	show_banner("MISSION FAILED: " + reason, Color(1.0, 0.25, 0.2))

func show_banner(text: String, color: Color) -> void:
	if banner_label and center_banner:
		banner_label.text = text
		banner_label.modulate = color
		center_banner.visible = true
		center_banner.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(1.8)
		tween.tween_property(center_banner, "modulate:a", 0.0, 0.5)
