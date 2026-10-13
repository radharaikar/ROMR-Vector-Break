class_name EnemySpawner
extends Node2D

# ==============================================================================
# VECTOR//BREAK — MULTI-DIRECTIONAL ENEMY SPAWNER
# Spawns hostile waves from multiple arena perimeter vectors:
# right flanks, top corridors, and lower sectors.
# ==============================================================================

@export var max_active_enemies: int = 4
@export var spawn_interval: float = 3.0
@export var drone_scenes: Array[PackedScene] = [
	preload("res://scenes/geometric_drone.tscn"),
	preload("res://scenes/enemy_drone.tscn")
]

var spawn_timer: float = 0.5
var drone_scene: PackedScene = preload("res://scenes/geometric_drone.tscn")

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = spawn_interval
		_check_and_spawn()

func _check_and_spawn() -> void:
	var current_enemies = get_tree().get_nodes_in_group("enemies")
	if current_enemies.size() < max_active_enemies:
		var scene_to_spawn = drone_scenes.pick_random() if drone_scenes.size() > 0 else drone_scene
		var drone = scene_to_spawn.instantiate()
		
		# Multi-directional entry vector
		drone.global_position = _get_spawn_position()
		get_parent().add_child(drone)

func _get_spawn_position() -> Vector2:
	var edge = randi() % 3
	match edge:
		0: # Right edge
			return Vector2(1310.0, randf_range(140.0, 580.0))
		1: # Top ceiling breach
			return Vector2(randf_range(500.0, 1150.0), -30.0)
		2: # Bottom deck breach
			return Vector2(randf_range(500.0, 1150.0), 750.0)
		_:
			return Vector2(1310.0, 360.0)
