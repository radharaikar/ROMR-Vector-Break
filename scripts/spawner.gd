class_name EnemySpawner
extends Node2D

@export var max_active_enemies: int = 3
@export var spawn_interval: float = 3.0

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
		var drone = drone_scene.instantiate()
		drone.global_position = Vector2(1320.0, randf_range(140.0, 580.0))
		get_parent().add_child(drone)
