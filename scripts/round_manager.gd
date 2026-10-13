class_name RoundManager
extends Node

## Central Round and Wave Controller for VECTOR//BREAK.
## Manages encounter pacing, countdown timers, wave transitions, and victory/defeat logic.

signal round_started(round_index: int, round_name: String, time_limit: float)
signal wave_started(wave_index: int, total_waves: int)
signal enemy_count_changed(remaining: int, total: int)
signal round_time_tick(time_remaining: float)
signal wave_cleared(wave_index: int)
signal round_victory(round_index: int, total_score: int)
signal round_defeat(reason: String)

enum State { INACTIVE, COMBAT, WAVE_TRANSITION, VICTORY, DEFEAT }
var current_state: State = State.INACTIVE

@export var auto_start_first_round: bool = true

var current_round_index: int = 0
var current_wave_index: int = 0
var time_remaining: float = 60.0
var is_paused: bool = false

var round_definitions: Array[Dictionary] = []
var active_enemies: Array[Node] = []
var _wave_clearing: bool = false

# Preloaded enemy scenes
var enemy_scenes: Dictionary = {
	"drone": preload("res://scenes/enemy_drone.tscn"),
	"chaser": preload("res://scenes/enemy_chaser.tscn"),
	"striker": preload("res://scenes/enemy_striker.tscn"),
	"dasher": preload("res://scenes/enemy_dasher.tscn"),
	"heavy": preload("res://scenes/enemy_heavy.tscn"),
	"boss_serin": preload("res://scenes/boss_serin.tscn")
}

func _ready() -> void:
	round_definitions = CampaignData.get_round_definitions()
	
	# Connect to player death if player exists
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)
	
	if auto_start_first_round and round_definitions.size() > 0:
		start_round(0)

func _process(delta: float) -> void:
	if current_state != State.COMBAT or is_paused:
		return
	
	time_remaining -= delta
	emit_signal("round_time_tick", max(0.0, time_remaining))
	
	if time_remaining <= 0.0:
		_trigger_defeat("TACTICAL TIME LIMIT EXPIRED")

func start_round(round_idx: int) -> void:
	if round_idx < 0 or round_idx >= round_definitions.size():
		return
	
	current_round_index = round_idx
	current_wave_index = 0
	_wave_clearing = false
	_cleanup_active_enemies()
	
	var r_data = round_definitions[current_round_index]
	time_remaining = r_data.get("time_limit", 60.0)
	current_state = State.COMBAT
	
	emit_signal("round_started", current_round_index, r_data.get("name", "ROUND"), time_remaining)
	_spawn_wave(current_wave_index)

func _spawn_wave(wave_idx: int) -> void:
	var r_data = round_definitions[current_round_index]
	var waves = r_data.get("waves", [])
	
	if wave_idx >= waves.size():
		_trigger_victory()
		return
	
	current_wave_index = wave_idx
	_wave_clearing = false
	active_enemies.clear()
	
	var spawn_list = waves[wave_idx]
	emit_signal("wave_started", current_wave_index + 1, waves.size())
	
	var arena = get_parent() if get_parent() else self
	
	for spawn_info in spawn_list:
		var type_key = spawn_info.get("type", "drone")
		if enemy_scenes.has(type_key):
			var enemy = enemy_scenes[type_key].instantiate()
			enemy.global_position = spawn_info.get("pos", Vector2(1320, 360))
			
			# Monitor enemy destruction
			enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))
			active_enemies.append(enemy)
			arena.add_child(enemy)
	
	emit_signal("enemy_count_changed", active_enemies.size(), active_enemies.size())

func _on_enemy_removed(enemy_node: Node) -> void:
	if enemy_node in active_enemies:
		active_enemies.erase(enemy_node)
	
	if current_state == State.COMBAT:
		emit_signal("enemy_count_changed", active_enemies.size(), active_enemies.size())
		
		# Check wave completion (with guard against duplicate events)
		if active_enemies.size() == 0 and not _wave_clearing:
			_wave_clearing = true
			_on_wave_cleared()

func _on_wave_cleared() -> void:
	emit_signal("wave_cleared", current_wave_index + 1)
	
	var r_data = round_definitions[current_round_index]
	var waves = r_data.get("waves", [])
	
	if current_wave_index + 1 < waves.size():
		current_state = State.WAVE_TRANSITION
		# Brief tactical interval before next wave
		var timer = get_tree().create_timer(1.2)
		timer.timeout.connect(func():
			if current_state == State.WAVE_TRANSITION:
				current_state = State.COMBAT
				_spawn_wave(current_wave_index + 1)
		)
	else:
		_trigger_victory()

func _trigger_victory() -> void:
	if current_state == State.VICTORY or current_state == State.DEFEAT:
		return
	current_state = State.VICTORY
	
	var total_score = 0
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		total_score = gm.score
	
	emit_signal("round_victory", current_round_index, total_score)

func _trigger_defeat(reason: String) -> void:
	if current_state == State.VICTORY or current_state == State.DEFEAT:
		return
	current_state = State.DEFEAT
	emit_signal("round_defeat", reason)

func _on_player_died() -> void:
	_trigger_defeat("PILOT HULL DESTROYED")

func _cleanup_active_enemies() -> void:
	for e in active_enemies:
		if is_instance_valid(e):
			e.queue_free()
	active_enemies.clear()

func pause_round() -> void:
	is_paused = true

func resume_round() -> void:
	is_paused = false

func restart_current_round() -> void:
	start_round(current_round_index)

func get_current_round_info() -> Dictionary:
	if current_round_index < round_definitions.size():
		return round_definitions[current_round_index]
	return {}
