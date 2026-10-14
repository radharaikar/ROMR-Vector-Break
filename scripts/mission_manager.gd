class_name MissionManager
extends Node

# ==============================================================================
# VECTOR//BREAK — CAMPAIGN MISSION & NARRATIVE CONTROLLER
# Coordinates story dialogues, transmission triggers, and mission completion.
# ==============================================================================

@export var mission_id: String = "act1_m1"
@export var show_briefing_on_start: bool = true

@onready var dialogue: StoryDialogue = get_node_or_null("../StoryDialogue")

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.story_transmission_requested.connect(_on_transmission_requested)
		gm.mission_briefing_requested.connect(_on_briefing_requested)
		gm.victory_requested.connect(_on_victory_requested)
		gm.wave_completed.connect(_on_wave_completed)
	
	if show_briefing_on_start and dialogue:
		if not SaveManager.get_story_flag("saw_briefing_" + mission_id):
			SaveManager.set_story_flag("saw_briefing_" + mission_id, true)
			# Small frame delay for scene tree stability
			get_tree().create_timer(0.3).timeout.connect(func():
				dialogue.play_sequence("act1_briefing")
			)

func _on_transmission_requested(transmission_id: String) -> void:
	if dialogue:
		dialogue.play_sequence(transmission_id)

func _on_briefing_requested(req_mission_id: String) -> void:
	if dialogue:
		dialogue.play_sequence("act1_briefing")

func _on_victory_requested(_mission_id: String) -> void:
	if dialogue:
		dialogue.play_sequence("act1_victory", func():
			# Award mission completion bonus
			SaveManager.add_currency(100)
			var data = SaveManager.get_data()
			var completed: Array = data.get("completed_missions", [])
			if mission_id not in completed:
				completed.append(mission_id)
				data["completed_missions"] = completed
				SaveManager.save_data()
		)

func _on_wave_completed(round_num: int, _reward: int) -> void:
	# Trigger in-game radio reveal on wave 2
	if round_num == 2 and dialogue:
		dialogue.play_sequence("in_game_reveal")
