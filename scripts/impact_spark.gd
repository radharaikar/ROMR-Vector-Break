class_name ImpactSpark
extends Node2D

@onready var particles: CPUParticles2D = get_node_or_null("CPUParticles2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	if particles:
		particles.emitting = true
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.15)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
	
	# Auto cleanup after particle emission finishes
	var timer = get_tree().create_timer(0.4)
	timer.timeout.connect(queue_free)

func setup(normal_direction: Vector2, color: Color) -> void:
	if sprite:
		sprite.modulate = color
	if particles:
		particles.color = color
		particles.direction = normal_direction
		particles.spread = 75.0
