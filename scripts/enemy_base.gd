class_name EnemyBase
extends CharacterBody2D

## Base class for geometric enemies in VECTOR//BREAK.
## Integrates health, damage intake, hit-flash feedback, death explosion,
## and score synchronization with GameManager.

signal health_changed(current_hp: int, max_hp: int)
signal hit_taken(damage: int, hit_normal: Vector2)
signal destroyed(score: int, death_position: Vector2)

@export_group("Stats")
@export var max_health: int = 50
@export var score_value: int = 100
@export var base_speed: float = 65.0

@export_group("Visuals")
@export var sprite_node: CanvasItem
@export var hit_flash_color: Color = Color(3.0, 1.2, 2.5, 1.0) # Intense neon hit flash
@export var explosion_scene: PackedScene

var current_health: int = 0
var health: int:
	get:
		return current_health
	set(val):
		current_health = val

var is_dead: bool = false
var _flash_tween: Tween

func _init() -> void:
	current_health = max_health

func _enter_tree() -> void:
	if current_health <= 0 and not is_dead:
		current_health = max_health

func _ready() -> void:
	if current_health <= 0 and not is_dead:
		current_health = max_health
	add_to_group("enemies")
	
	if sprite_node == null:
		sprite_node = get_node_or_null("Sprite2D")
		if sprite_node == null:
			sprite_node = get_node_or_null("AnimatedSprite2D")

## Standard damage interface compatible with both Dell projectile and duck-typing
func take_damage(amount: int, combo_multiplier: Variant = 1, _hit_point: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	
	if current_health <= 0:
		current_health = max_health
		
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	var norm = Vector2.ZERO
	if combo_multiplier is Vector2:
		norm = combo_multiplier
	hit_taken.emit(amount, norm)
	
	_trigger_hit_flash()
	
	if current_health <= 0:
		var multiplier_int: int = 1
		if typeof(combo_multiplier) == TYPE_INT or typeof(combo_multiplier) == TYPE_FLOAT:
			multiplier_int = int(combo_multiplier)
		die(multiplier_int)

## Duck-typing fallback methods
func hit(damage_amount: int) -> void:
	take_damage(damage_amount)

func apply_damage(damage_amount: int) -> void:
	take_damage(damage_amount)

func on_hit(damage_amount: int) -> void:
	take_damage(damage_amount)

func _trigger_hit_flash() -> void:
	if sprite_node == null or not is_inside_tree():
		return
	
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
		
	_flash_tween = create_tween()
	if _flash_tween != null:
		sprite_node.modulate = hit_flash_color
		_flash_tween.tween_property(sprite_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)

func die(combo_multiplier: int = 1) -> void:
	if is_dead:
		return
	is_dead = true
	
	destroyed.emit(score_value, global_position)
	
	# Award score & combo to GameManager if present
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_hit(combo_multiplier)
		gm.add_score(score_value, combo_multiplier)
		if gm.has_method("award_currency"):
			gm.award_currency(15, "enemy_%s_%d" % [name, get_instance_id()])
		if gm.has_method("spawn_pickup"):
			var safe_pos = Vector2(clamp(global_position.x, 80.0, 1200.0), clamp(global_position.y, 80.0, 640.0))
			var player_node = get_tree().get_first_node_in_group("player") if is_inside_tree() else null
			var is_damaged = player_node != null and "current_health" in player_node and "max_health" in player_node and player_node.current_health < player_node.max_health
			var drop_chance: float = 0.40 if is_damaged else 0.20
			if randf() < drop_chance:
				gm.spawn_pickup(gm.PickupType.NANOCELL, safe_pos)
	
	# Spawn explosion VFX
	if explosion_scene != null and get_parent() != null and is_inside_tree():
		var vfx = explosion_scene.instantiate()
		vfx.global_position = global_position
		get_parent().add_child(vfx)
		
	queue_free()
