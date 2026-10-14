class_name RicochetFlash
extends Sprite2D

## Temporary flash effect at the ricochet bounce point.
## Automatically fades and frees itself.

func _ready() -> void:
	texture_filter = TEXTURE_FILTER_NEAREST
	modulate = Color(2.5, 1.0, 2.5, 1.0) # Bright neon magenta flash
	var tween = create_tween()
	if tween:
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		tween.tween_callback(queue_free)
