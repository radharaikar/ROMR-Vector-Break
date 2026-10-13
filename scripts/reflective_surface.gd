class_name ReflectiveSurface
extends StaticBody2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	add_to_group("reflective")

func on_ricochet(impact_pos: Vector2, _normal: Vector2) -> void:
	# Visual feedback on ricochet
	var tween = create_tween()
	modulate = Color(2.5, 1.0, 2.5, 1.0) # Bright neon magenta flash
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
