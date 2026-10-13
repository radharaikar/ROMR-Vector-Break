extends Node

# ==============================================================================
# VECTOR//BREAK — CENTRAL GAME MANAGER
# Singleton managing score, combo multipliers, currency economy, pickups,
# waves synchronization, and campaign story requests.
# ==============================================================================

signal score_updated(new_score: int)
signal combo_updated(new_combo: int)
signal currency_updated(new_balance: int)
signal wave_started(wave_number: int, wave_name: String)
signal wave_completed(wave_number: int, reward: int)
signal boss_spawned(boss_name: String, max_hp: int)
signal boss_defeated(boss_name: String, reward: int)
signal story_transmission_requested(transmission_id: String)
signal mission_briefing_requested(mission_id: String)
signal victory_requested(mission_id: String)

enum PickupType {
	NANOCELL,
	FRAGMENT
}

var score: int = 0
var combo: int = 1
var max_combo: int = 1
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 3.5

# Anti-duplicate transaction ledger
var _processed_transactions: Dictionary = {}
var has_used_revive_this_run: bool = false

static var instance: GameManager = null

func _init() -> void:
	instance = self

func _ready() -> void:
	# Load persistent save data on startup
	SaveManager.load_data()
	emit_signal("score_updated", score)
	emit_signal("combo_updated", combo)
	emit_signal("currency_updated", get_currency())

func _process(delta: float) -> void:
	if combo > 1:
		combo_timer -= delta
		if combo_timer <= 0.0:
			reset_combo()

# ==============================================================================
# SCORE & COMBO SYSTEM (DELL BASELINE COMPATIBLE)
# ==============================================================================

func add_score(base_points: int, multiplier: int = 1) -> void:
	var total_multiplier = max(1, multiplier * combo)
	var points = base_points * total_multiplier
	score += points
	emit_signal("score_updated", score)

func register_hit(ricochet_count: int) -> int:
	combo += max(1, ricochet_count)
	if combo > max_combo:
		max_combo = combo
	combo_timer = COMBO_TIMEOUT
	emit_signal("combo_updated", combo)
	return combo

func reset_combo() -> void:
	combo = 1
	combo_timer = 0.0
	emit_signal("combo_updated", combo)

# ==============================================================================
# CURRENCY & ECONOMY SYSTEM
# ==============================================================================

func get_currency() -> int:
	return SaveManager.get_currency()

func award_currency(amount: int, transaction_id: String = "") -> int:
	if amount <= 0:
		return get_currency()
	
	# Prevent duplicate reward awards if transaction_id provided
	if not transaction_id.is_empty():
		if _processed_transactions.has(transaction_id):
			return get_currency()
		_processed_transactions[transaction_id] = true
	
	var new_balance = SaveManager.add_currency(amount)
	emit_signal("currency_updated", new_balance)
	return new_balance

func spend_currency(amount: int) -> bool:
	if amount <= 0:
		return true
	var success = SaveManager.spend_currency(amount)
	if success:
		emit_signal("currency_updated", get_currency())
	return success

# ==============================================================================
# PICKUP SPAWNER API
# ==============================================================================

func spawn_pickup(type: PickupType, spawn_pos: Vector2, value: int = 15) -> Node2D:
	var scene_path: String = ""
	match type:
		PickupType.NANOCELL:
			scene_path = "res://scenes/pickup_nanocell.tscn"
		PickupType.FRAGMENT:
			scene_path = "res://scenes/pickup_fragment.tscn"
	
	if ResourceLoader.exists(scene_path):
		var packed = load(scene_path)
		if packed:
			var pickup = packed.instantiate()
			pickup.global_position = spawn_pos
			if type == PickupType.FRAGMENT and "fragment_value" in pickup:
				pickup.fragment_value = value
			get_tree().current_scene.add_child(pickup)
			return pickup
	return null

# ==============================================================================
# REVIVE / SECOND CHANCE SYSTEM
# ==============================================================================

func can_revive() -> bool:
	if has_used_revive_this_run:
		return false
	# Can revive if player has an Emergency Core OR has >= 50 fragments
	return SaveManager.get_reconstruction_cores() > 0 or get_currency() >= 50

func execute_revive() -> bool:
	if not can_revive():
		return false
	
	# Consume Core first, else spend 50 fragments
	if SaveManager.get_reconstruction_cores() > 0:
		SaveManager.use_reconstruction_core()
	else:
		spend_currency(50)
	
	has_used_revive_this_run = true
	
	# Find player and execute revive
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("revive"):
		player.revive(0.5)
		return true
	
	return false

# ==============================================================================
# STORY & WAVE NOTIFICATION HOOKS
# ==============================================================================

func request_briefing(mission_id: String) -> void:
	emit_signal("mission_briefing_requested", mission_id)

func trigger_transmission(transmission_id: String) -> void:
	emit_signal("story_transmission_requested", transmission_id)

func trigger_victory(mission_id: String) -> void:
	emit_signal("victory_requested", mission_id)

func notify_wave_started(round_num: int, wave_name: String = "") -> void:
	emit_signal("wave_started", round_num, wave_name)

func notify_wave_completed(round_num: int, reward: int = 50) -> void:
	var tx_id = "wave_%d_reward" % round_num
	award_currency(reward, tx_id)
	emit_signal("wave_completed", round_num, reward)

func notify_boss_spawned(boss_name: String, max_hp: int) -> void:
	emit_signal("boss_spawned", boss_name, max_hp)

func notify_boss_defeated(boss_name: String, reward: int = 250) -> void:
	var tx_id = "boss_%s_reward" % boss_name
	award_currency(reward, tx_id)
	emit_signal("boss_defeated", boss_name, reward)
