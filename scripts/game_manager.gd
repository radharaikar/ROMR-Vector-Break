extends Node

signal score_updated(new_score: int)
signal combo_updated(new_combo: int)

var score: int = 0
var combo: int = 1
var max_combo: int = 1
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 3.5

static var instance: GameManager = null

func _init() -> void:
	instance = self

func _ready() -> void:
	emit_signal("score_updated", score)
	emit_signal("combo_updated", combo)

func _process(delta: float) -> void:
	if combo > 1:
		combo_timer -= delta
		if combo_timer <= 0.0:
			reset_combo()

func add_score(base_points: int, multiplier: int = 1) -> void:
	var total_multiplier = max(1, multiplier * combo)
	var points = base_points * total_multiplier
	score += points
	emit_signal("score_updated", score)

func register_hit(ricochet_count: int) -> int:
	# Bounces reward higher combos
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
