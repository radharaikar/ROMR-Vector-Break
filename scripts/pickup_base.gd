class_name PickupBase
extends Area2D

# ==============================================================================
# VECTOR//BREAK — REUSABLE PICKUP BASE CLASS
# Handles floating animation, collision detection, duplicate guard, and cleanup.
# ==============================================================================

signal collected(player_node: Node2D)

@export var bob_amplitude: float = 4.0
@export var bob_speed: float = 3.5

var is_collected: bool = false
var _initial_y: float = 0.0
var _time_passed: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	_initial_y = position.y
	_time_passed = randf() * TAU # Randomize initial phase
	
	# Set collision layer / mask: Pickups monitor layer 1 (Player CharacterBody2D) & layer 2 (Hitbox)
	collision_layer = 0
	collision_mask = 3
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	
	_time_passed += delta * bob_speed
	position.y = _initial_y + sin(_time_passed) * bob_amplitude
	
	if sprite:
		# Gentle pulsing glow
		sprite.scale = Vector2.ONE * (1.0 + sin(_time_passed * 1.5) * 0.08)

func _on_body_entered(body: Node2D) -> void:
	if body and (body.is_in_group("player") or body.name == "Player" or body is CharacterBody2D):
		_try_collect(body)

func _on_area_entered(area: Area2D) -> void:
	var parent_body = area.get_parent()
	if parent_body and (parent_body.is_in_group("player") or parent_body.name == "Player"):
		_try_collect(parent_body)

func _try_collect(target_node: Node2D) -> void:
	if is_collected:
		return
	if not (target_node.is_in_group("player") or target_node.name == "Player"):
		return
	if "is_dead" in target_node and target_node.is_dead:
		return
	if not can_collect(target_node):
		return
	
	# Atomic collection lock
	is_collected = true
	emit_signal("collected", target_node)
	apply_pickup(target_node)
	_play_pickup_effects()

# Overridden by subclasses
func can_collect(_target_node: Node2D) -> bool:
	return true

# Overridden by subclasses
func apply_pickup(_target_node: Node2D) -> void:
	pass

func _play_pickup_effects() -> void:
	# Clean scale-down & fade tween before freeing
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)
