class_name HangarMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HANGAR / MAIN HUB MENU
# Home menu offering Campaign Continue, New Game (with Prologue),
# Hangar Store / Outfitter, 5-Act Mission Matrix, Credits, and Quit.
# ==============================================================================

@onready var continue_btn: Button = $Margin/HBox/NavVBox/ContinueBtn
@onready var new_game_btn: Button = $Margin/HBox/NavVBox/NewGameBtn
@onready var store_btn: Button = $Margin/HBox/NavVBox/StoreBtn
@onready var briefing_btn: Button = $Margin/HBox/NavVBox/BriefingBtn
@onready var credits_btn: Button = $Margin/HBox/NavVBox/CreditsBtn
@onready var quit_btn: Button = $Margin/HBox/NavVBox/QuitBtn

@onready var currency_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/CurrencyLabel
@onready var cores_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/CoresLabel
@onready var act_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/ActLabel
@onready var ship_sprite: Sprite2D = $Margin/HBox/DisplayVBox/ShipPanel/SpriteContainer/ShipSprite
@onready var dialogue_layer: StoryDialogue = $StoryDialogue
@onready var credits_modal: PanelContainer = $CreditsModal
@onready var close_credits_btn: Button = $CreditsModal/VBox/CloseCreditsBtn

@onready var campaign_modal: PanelContainer = $CampaignModal
@onready var launch_act1_btn: Button = $CampaignModal/Margin/VBox/Scroll/ActList/Act1Card/M/VB/LaunchAct1Btn
@onready var close_campaign_btn: Button = $CampaignModal/Margin/VBox/CloseCampaignBtn

func _ready() -> void:
	SaveManager.load_data()
	_update_hub_display()
	_setup_campaign_matrix()
	
	var has_save = FileAccess.file_exists(SaveManager.SAVE_PATH)
	if continue_btn:
		continue_btn.disabled = not has_save
		continue_btn.pressed.connect(_on_continue_pressed)
	
	if new_game_btn: new_game_btn.pressed.connect(_on_new_game_pressed)
	if store_btn: store_btn.pressed.connect(_on_store_pressed)
	if briefing_btn: briefing_btn.pressed.connect(_on_briefing_pressed)
	if credits_btn: credits_btn.pressed.connect(_on_credits_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)
	
	if close_credits_btn:
		close_credits_btn.pressed.connect(func(): if credits_modal: credits_modal.visible = false)
	
	if launch_act1_btn: launch_act1_btn.pressed.connect(func(): _launch_act(1))
	if close_campaign_btn:
		close_campaign_btn.pressed.connect(func(): if campaign_modal: campaign_modal.visible = false)
	
	if credits_modal: credits_modal.visible = false
	if campaign_modal: campaign_modal.visible = false

func _setup_campaign_matrix() -> void:
	var unlocked_act = SaveManager.get_data().get("campaign_act", 1)
	var act_titles = {
		1: "GHOSTS IN THE SIGNAL",
		2: "THE ONES LEFT BEHIND",
		3: "THE LIVING CIRCUIT",
		4: "THE PERFECT WAR",
		5: "THE LAST TRAJECTORY"
	}
	
	for act_num in range(1, 6):
		var card_path = "CampaignModal/Margin/VBox/Scroll/ActList/Act%dCard/M/VB" % act_num
		var vb = get_node_or_null(card_path)
		if not vb: continue
		
		var title_node: Label = vb.get_node_or_null("T")
		var is_unlocked = (unlocked_act >= act_num)
		
		if title_node:
			var roman = ["I", "II", "III", "IV", "V"][act_num - 1]
			var t_name = act_titles.get(act_num, "UNKNOWN")
			if is_unlocked:
				title_node.text = "ACT %s — %s [PLAYABLE // UNLOCKED]" % [roman, t_name]
				title_node.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))
			else:
				title_node.text = "ACT %s — %s [LOCKED]" % [roman, t_name]
				title_node.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
		
		# If act > 1, inject launch button if unlocked and not already added
		if act_num > 1 and is_unlocked:
			var btn_name = "LaunchAct%dBtn" % act_num
			if not vb.has_node(btn_name):
				var btn = Button.new()
				btn.name = btn_name
				btn.custom_minimum_size = Vector2(0, 32)
				btn.text = "[ LAUNCH MISSION: ACT %d >> ]" % act_num
				btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
				btn.pressed.connect(func(): _launch_act(act_num))
				vb.add_child(btn)

func _launch_act(act_num: int) -> void:
	if SaveManager:
		SaveManager.get_data()["selected_act"] = act_num
		SaveManager.save_data()
	get_tree().change_scene_to_file("res://scenes/act1_mission.tscn")

func _update_hub_display() -> void:
	if currency_label:
		currency_label.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()
	if cores_label:
		cores_label.text = "RECONSTRUCTION CORES: %d ⬡" % SaveManager.get_reconstruction_cores()
	if act_label:
		var act = SaveManager.get_data().get("campaign_act", 1)
		act_label.text = "ACTIVE CAMPAIGN: ACT %d // OUTPOST 44" % act
	
	if ship_sprite:
		var skin_id = SaveManager.get_equipped_skin()
		var tex_path = "res://assets/sprites/player_ship.png"
		match skin_id:
			"skin_prototype":
				tex_path = "res://assets/sprites/player_ship_prototype.png"
			"skin_squad":
				tex_path = "res://assets/sprites/player_ship_squad.png"
			"skin_vector":
				tex_path = "res://assets/sprites/player_ship_vector.png"
		
		if ResourceLoader.exists(tex_path):
			ship_sprite.texture = load(tex_path)

func _on_continue_pressed() -> void:
	var act = SaveManager.get_data().get("campaign_act", 1)
	_launch_act(act)

func _on_new_game_pressed() -> void:
	SaveManager.reset_data()
	SaveManager.add_currency(50) # Starting stipend
	_update_hub_display()
	_setup_campaign_matrix()
	get_tree().change_scene_to_file("res://scenes/prologue.tscn")

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/store_menu.tscn")

func _on_briefing_pressed() -> void:
	_setup_campaign_matrix()
	if campaign_modal:
		campaign_modal.visible = true

func _on_launch_act1_pressed() -> void:
	_launch_act(1)

func _on_credits_pressed() -> void:
	if credits_modal:
		credits_modal.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
