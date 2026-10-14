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
	preload("res://scenes/enemy_drone.tscn"),
	preload("res://scenes/enemy_chaser.tscn"),
	preload("res://scenes/enemy_striker.tscn"),
	preload("res://scenes/enemy_dasher.tscn"),
	preload("res://scenes/enemy_heavy.tscn"),
	preload("res://scenes/enemy_elite.tscn")
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
		
		# Multi-directional entry vector avoiding player overlay
		drone.global_position = _get_spawn_position()
		get_parent().add_child(drone)

func _get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = player.global_position if player and is_instance_valid(player) else Vector2(200, 360)
	
	for _attempt in range(5):
		var pos = Vector2.ZERO
		var edge = randi() % 4
		match edge:
			0: # Right flank
				pos = Vector2(randf_range(1150.0, 1240.0), randf_range(100.0, 620.0))
			1: # Top corridor breach
				pos = Vector2(randf_range(450.0, 1150.0), randf_range(80.0, 150.0))
			2: # Bottom deck breach
				pos = Vector2(randf_range(450.0, 1150.0), randf_range(560.0, 630.0))
			3: # Rear sector (if safe)
				pos = Vector2(randf_range(90.0, 240.0), randf_range(100.0, 620.0))
		
		# Fair distance guard: never spawn directly onto the player
		if pos.distance_to(player_pos) > 220.0:
			return pos
			
	return Vector2(1200.0, randf_range(150.0, 570.0))
