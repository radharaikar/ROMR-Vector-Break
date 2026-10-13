class_name BiomeHazardZone
extends Area2D

# ==============================================================================
# VECTOR//BREAK — BIOME ENVIRONMENTAL HAZARD ZONE
# Represents an environmental hazard in a biome (lava vent, sand squall,
# abyssal geyser, spore eruption). Telegraphed clearly with warning pulses.
# ==============================================================================

signal hazard_warned()
signal hazard_erupted()

@export var hazard_type: String = "GENERIC"
@export var damage: int = 15
@export var warning_duration: float = 1.5
@export var surge_duration: float = 1.0

var is_warning: bool = false
var is_active_surge: bool = false
var surge_timer: float = 0.0

@onready var visual_shape: ColorRect = $HazardRect
@onready var warning_label: Label = $WarningLabel

func _ready() -> void:
	collision_layer = 0
	collision_mask = 3 # Detects Player (layer 1) and Enemies (layer 2)
	
	if warning_label:
		warning_label.visible = false
	if visual_shape:
		visual_shape.modulate.a = 0.15

func _process(delta: float) -> void:
	if is_warning:
		# Rapid pulsation warning
		var pulse = (sin(Time.get_ticks_msec() * 0.012) + 1.0) * 0.5
		if visual_shape:
			visual_shape.modulate.a = 0.3 + pulse * 0.5
	elif is_active_surge:
		surge_timer -= delta
		if visual_shape:
			visual_shape.modulate.a = 0.9
		if surge_timer <= 0.0:
			end_surge()

func trigger_warning() -> void:
	is_warning = true
	is_active_surge = false
	if warning_label:
		warning_label.visible = true
	emit_signal("hazard_warned")

func trigger_surge() -> void:
	is_warning = false
	is_active_surge = true
	surge_timer = surge_duration
	if warning_label:
		warning_label.visible = false
	emit_signal("hazard_erupted")
	_apply_hazard_damage()

func end_surge() -> void:
	is_active_surge = false
	is_warning = false
	if warning_label:
		warning_label.visible = false
	if visual_shape:
		visual_shape.modulate.a = 0.15

func _apply_hazard_damage() -> void:
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.has_method("take_damage"):
			b.take_damage(damage)
