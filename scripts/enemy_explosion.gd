class_name EnemyExplosion
extends AnimatedSprite2D

## Self-terminating destruction effect for enemies in VECTOR//BREAK.
## Automatically plays on spawn and frees itself upon completion.

func _ready() -> void:
	play("default")
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()
