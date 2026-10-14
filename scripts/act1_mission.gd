class_name Act1Mission
extends Node2D

# ==============================================================================
# VECTOR//BREAK — ACT I: GHOSTS IN THE SIGNAL
# Location: Outer Graveyard (Derelict AXIOM Space Station)
# Features 4 progressive combat encounters, dynamic reflectors, laser hazard gates,
# story transmissions revealing the truth of Vesper-9, and Commander Serin boss fight.
# ==============================================================================

@onready var player: PlayerShip = $Player
@onready var round_manager: RoundManager = $RoundManager
@onready var hud: ArcadeHUD = $HUD
@onready var dialogue: StoryDialogue = $StoryDialogue
@onready var victory_canvas: CanvasLayer = $VictoryCanvas
@onready var victory_panel: Control = $VictoryCanvas/VictoryOverlay
@onready var victory_score_label: Label = $VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/ScoreLabel
@onready var victory_currency_label: Label = $VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/CurrencyLabel
@onready var hub_button: Button = $VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/Buttons/HubButton
@onready var replay_button: Button = $VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/Buttons/ReplayButton

var current_act: int = 1
var _boss_instance: Node = null

func _ready() -> void:
	if victory_panel: victory_panel.visible = false
	if hub_button: hub_button.pressed.connect(_on_hub_pressed)
	if replay_button: replay_button.pressed.connect(_on_replay_pressed)
	
	# Determine active act from SaveManager
	var data = SaveManager.get_data() if SaveManager else {}
	var biome_id = SaveManager.get_selected_biome() if SaveManager else "neon_graveyard"
	var act_from_biome = CampaignData.get_act_for_biome(biome_id)
	current_act = data.get("selected_act", act_from_biome)
	
	if round_manager:
		round_manager.set_act(current_act)
		round_manager.round_started.connect(_on_round_started)
		round_manager.round_victory.connect(_on_round_victory)
		round_manager.wave_cleared.connect(_on_wave_cleared)
	
	# Set environment & obstacle biomes
	var active_biome = CampaignData.get_biome_for_act(current_act)
	var space_env = get_node_or_null("SpaceEnvironment")
	if space_env and space_env.has_method("set_biome"):
		space_env.set_biome(active_biome)
	
	for obs in get_tree().get_nodes_in_group("obstacles"):
		if obs.has_method("set_biome"):
			obs.set_biome(active_biome)
	
	# Show Act Briefing on launch
	var briefing_id = "act%d_briefing" % current_act
	if not StoryData.has_sequence(briefing_id):
		briefing_id = "act1_briefing"
	
	get_tree().create_timer(0.4).timeout.connect(func():
		if dialogue:
			dialogue.play_sequence(briefing_id, func():
				# Start combat rounds after briefing
				if round_manager:
					round_manager.start_round(0)
			)
		else:
			if round_manager:
				round_manager.start_round(0)
	)

func _on_round_started(round_idx: int, round_name: String, _time_limit: float) -> void:
	# Story transmissions tied to specific rounds
	if current_act == 1:
		match round_idx:
			1: # Round 2: Infiltration Vector
				get_tree().create_timer(1.0).timeout.connect(func():
					if dialogue:
						dialogue.play_sequence("in_game_reveal")
				)
			2: # Round 3: Armored Bulwark
				get_tree().create_timer(1.0).timeout.connect(func():
					if dialogue:
						var truth_log = [
							{
								"speaker": "DATA LOG // VESPER-9 BLACK BOX",
								"color": Color(1.0, 0.4, 0.2),
								"text": "DECRYPTED MEMORY CORE: Colony defense grid was NOT hostile. It was attempting an emergency shutdown of AXIOM's Vector Conduit."
							},
							{
								"speaker": "KAEL VEYR",
								"color": Color(0.3, 0.8, 1.0),
								"text": "They told us the colony attacked first... Vale staged the entire incident to test the Engine under combat stress."
							}
						]
						dialogue.play_sequence(truth_log)
				)
			3: # Round 4: The Gatekeeper (Commander Serin)
				get_tree().create_timer(0.5).timeout.connect(func():
					if dialogue:
						var boss_intro = [
							{
								"speaker": "COMMANDER SERIN // FLAGSHIP 'RESOLUTE'",
								"color": Color(1.0, 0.3, 0.4),
								"text": "Kael. I knew you would come. Turn your ship around. Vale is beyond our reach, and Mira belongs to the Engine now."
							},
							{
								"speaker": "KAEL VEYR",
								"color": Color(0.3, 0.8, 1.0),
								"text": "You knew civilians were on Vesper-9, Serin. You stood down and watched."
							},
							{
								"speaker": "COMMANDER SERIN",
								"color": Color(1.0, 0.3, 0.4),
								"text": "I followed orders so the squadron would live! But you... you always believed one clean trajectory could rewrite history. Prove it!"
							}
						]
						dialogue.play_sequence(boss_intro)
				)
	elif current_act == 5 and round_idx == 1:
		get_tree().create_timer(0.5).timeout.connect(func():
			if dialogue:
				dialogue.play_sequence("boss_intro")
		)

func _on_wave_cleared(wave_idx: int) -> void:
	pass

func _on_round_victory(_round_idx: int, total_score: int) -> void:
	# Final mission victory: trigger victory dialogue and completion overlay
	_trigger_act_completion(total_score)

func _trigger_act_completion(total_score: int) -> void:
	# Save progression
	SaveManager.add_currency(150)
	var data = SaveManager.get_data()
	data["campaign_act"] = max(data.get("campaign_act", 1), current_act + 1)
	var completed: Array = data.get("completed_missions", [])
	var mission_tag = "act%d_m1" % current_act
	if mission_tag not in completed:
		completed.append(mission_tag)
	data["completed_missions"] = completed
	SaveManager.save_data()
	
	if current_act >= 5:
		# Narrative climax: Transition directly to CampaignEnding scene
		get_tree().change_scene_to_file("res://scenes/campaign_ending.tscn")
		return
	
	var victory_id = "act%d_victory" % current_act
	if StoryData.has_sequence(victory_id):
		if dialogue:
			dialogue.play_sequence(victory_id, func():
				_show_victory_screen(total_score)
			)
		else:
			_show_victory_screen(total_score)
	else:
		if dialogue:
			dialogue.play_sequence("act1_victory", func():
				_show_victory_screen(total_score)
			)
		else:
			_show_victory_screen(total_score)

func _show_victory_screen(total_score: int) -> void:
	var act_names = {
		1: "ACT II [THE ONES LEFT BEHIND]",
		2: "ACT III [THE LIVING CIRCUIT]",
		3: "ACT IV [THE PERFECT WAR]",
		4: "ACT V [THE LAST TRAJECTORY]"
	}
	var title_node: Label = get_node_or_null("VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/Title")
	var sub_node: Label = get_node_or_null("VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/Sub")
	var unlock_node: Label = get_node_or_null("VictoryCanvas/VictoryOverlay/Center/Panel/Margin/VBox/UnlockLabel")
	
	if title_node:
		title_node.text = "ACT %d PURGED // MISSION COMPLETE" % current_act
	if sub_node:
		sub_node.text = "Sector secured. Tactical telemetry retrieved."
	if unlock_node:
		if current_act < 5:
			unlock_node.text = "CAMPAIGN PROGRESSION: %s UNLOCKED" % act_names.get(current_act, "NEXT ACT")
		else:
			unlock_node.text = "CAMPAIGN STATUS: COMPLETE"
	
	if victory_score_label:
		victory_score_label.text = "FINAL SCORE: %06d" % total_score
	if victory_currency_label:
		victory_currency_label.text = "RECOVERED FRAGMENTS: +150 ◆ (TOTAL: %d ◆)" % SaveManager.get_currency()
	
	if victory_panel:
		victory_panel.visible = true
	if hub_button:
		hub_button.grab_focus()

func _on_hub_pressed() -> void:
	if ResourceLoader.exists("res://scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()
