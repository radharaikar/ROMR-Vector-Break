class_name CampaignMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — 5-ACT CAMPAIGN SELECTION SCREEN
# Displays complete campaign map, acts 1-5 status (Completed, Available, Locked),
# tactical briefings, boss targets, rewards, and launch triggers.
# ==============================================================================

@onready var back_button: Button = $Margin/VBox/Header/BackButton
@onready var act_list_container: VBoxContainer = $Margin/VBox/Body/ActScroll/ActListVBox
@onready var detail_title: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailTitle
@onready var detail_subtitle: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailSubtitle
@onready var detail_location: Label = $Margin/VBox/Body/DetailPanel/VBox/LocationRow/DetailLocation
@onready var detail_boss: Label = $Margin/VBox/Body/DetailPanel/VBox/BossRow/DetailBoss
@onready var detail_reward: Label = $Margin/VBox/Body/DetailPanel/VBox/RewardRow/DetailReward
@onready var detail_desc: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailDescPanel/Margin/DetailDesc
@onready var launch_button: Button = $Margin/VBox/Body/DetailPanel/VBox/LaunchButton
@onready var briefing_button: Button = $Margin/VBox/Body/DetailPanel/VBox/BriefingButton
@onready var dialogue: StoryDialogue = $StoryDialogue

var campaign_acts: Array[Dictionary] = []
var selected_act_index: int = 0

func _ready() -> void:
	SaveManager.load_data()
	campaign_acts = StoryData.get_campaign_acts()
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if launch_button:
		launch_button.pressed.connect(_on_launch_pressed)
	if briefing_button:
		briefing_button.pressed.connect(_on_briefing_pressed)
	
	_populate_act_list()
	_select_act(0)

func _populate_act_list() -> void:
	if not act_list_container:
		return
	
	for child in act_list_container.get_children():
		child.queue_free()
	
	for i in range(campaign_acts.size()):
		var act_data = campaign_acts[i]
		var act_num = act_data.get("act", 1)
		
		var is_unlocked = SaveManager.is_act_unlocked(act_num)
		var is_completed = SaveManager.is_act_completed(act_num)
		
		var status_str = "[COMPLETED]" if is_completed else ("[AVAILABLE]" if is_unlocked else "[LOCKED]")
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 48)
		btn.text = "%s  %s" % [act_data.get("title", ""), status_str]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if is_completed:
			btn.add_theme_color_override("font_color", Color(0.2, 0.95, 0.6))
		elif is_unlocked:
			btn.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
		
		btn.pressed.connect(func(): _select_act(i))
		act_list_container.add_child(btn)

func _select_act(index: int) -> void:
	if index < 0 or index >= campaign_acts.size():
		return
	selected_act_index = index
	var act_data = campaign_acts[selected_act_index]
	var act_num = act_data.get("act", 1)
	
	var is_unlocked = SaveManager.is_act_unlocked(act_num)
	var is_completed = SaveManager.is_act_completed(act_num)
	var is_playable = act_data.get("is_playable", false)
	
	if detail_title:
		detail_title.text = act_data.get("title", "")
	if detail_subtitle:
		detail_subtitle.text = act_data.get("subtitle", "")
	if detail_location:
		detail_location.text = act_data.get("location", "")
	if detail_boss:
		detail_boss.text = act_data.get("boss", "")
	if detail_reward:
		detail_reward.text = "%d VECTOR FRAGMENTS ◆" % act_data.get("reward", 0)
	if detail_desc:
		detail_desc.text = act_data.get("description", "")
	
	if launch_button:
		if is_completed:
			launch_button.text = "REPLAY MISSION"
			launch_button.disabled = false
		elif is_unlocked and is_playable:
			launch_button.text = "LAUNCH MISSION >>"
			launch_button.disabled = false
		elif is_unlocked and not is_playable:
			launch_button.text = "ACT DATA PREVIEW [AWAITING DEPLOYMENT]"
			launch_button.disabled = true
		else:
			launch_button.text = "LOCKED // COMPLETE PREVIOUS ACT"
			launch_button.disabled = true
	
	if briefing_button:
		briefing_button.visible = is_unlocked

func _on_launch_pressed() -> void:
	var act_data = campaign_acts[selected_act_index]
	var scene_path = act_data.get("scene_path", "res://scenes/main.tscn")
	get_tree().change_scene_to_file(scene_path)

func _on_briefing_pressed() -> void:
	var act_num = campaign_acts[selected_act_index].get("act", 1)
	var briefing_id = "act%d_briefing" % act_num
	if dialogue:
		dialogue.play_sequence(briefing_id)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
