class_name ArcadeHUD
extends CanvasLayer

@onready var score_label: Label = $Control/MarginContainer/VBoxContainer/ScoreLabel
@onready var combo_label: Label = $Control/MarginContainer/VBoxContainer/ComboBadge/ComboLabel
@onready var combo_badge: PanelContainer = $Control/MarginContainer/VBoxContainer/ComboBadge

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.score_updated.connect(_on_score_updated)
		gm.combo_updated.connect(_on_combo_updated)
		_on_score_updated(gm.score)
		_on_combo_updated(gm.combo)

func _on_score_updated(new_score: int) -> void:
	if score_label:
		score_label.text = "SCORE  %06d" % new_score

func _on_combo_updated(new_combo: int) -> void:
	if combo_label:
		combo_label.text = "COMBO  x%d" % new_combo
		
		# Animate combo bump effect if > 1
		if new_combo > 1 and combo_badge:
			var tween = create_tween()
			combo_badge.scale = Vector2(1.25, 1.25)
			combo_badge.modulate = Color(2.5, 1.0, 2.2) # Neon magenta flash
			tween.tween_property(combo_badge, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(combo_badge, "modulate", Color(1.0, 1.0, 1.0), 0.2)
