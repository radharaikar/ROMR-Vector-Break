class_name ReflectorSurface
extends StaticBody2D

## Reflective surface component for VECTOR//BREAK.
## Identifies bounce geometry and provides surface normal feedback for projectile reflection.

signal laser_bounced(impact_point: Vector2, normal: Vector2)

@export var is_reflective: bool = true
@export var bounce_effect_scene: PackedScene

func _init() -> void:
	set_meta("is_reflective", true)

func _ready() -> void:
	add_to_group("reflective")
	add_to_group("reflectors")
	set_meta("is_reflective", true)

## Method called by Dell's EnergyProjectile upon ricochet collision
func on_ricochet(impact_point: Vector2, normal: Vector2) -> void:
	laser_bounced.emit(impact_point, normal)
	
	# Visual modulate pulse feedback on reflector
	var tween = create_tween()
	if tween:
		modulate = Color(2.5, 1.0, 2.5, 1.0) # Bright neon magenta flash
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Spawn ricochet flash particle effect
	if bounce_effect_scene != null and get_parent() != null and is_inside_tree():
		var fx = bounce_effect_scene.instantiate()
		fx.global_position = impact_point
		get_parent().add_child(fx)
