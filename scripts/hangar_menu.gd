class_name HangarMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HANGAR / MAIN HUB MENU
# Home menu offering Campaign Continue, New Game (with confirmation),
# 5-Act Campaign Map, Hangar Store / Outfitter, Credits, and Quit.
# ==============================================================================

@onready var continue_btn: Button = $Margin/HBox/NavVBox/ContinueBtn
@onready var new_game_btn: Button = $Margin/HBox/NavVBox/NewGameBtn
@onready var campaign_btn: Button = $Margin/HBox/NavVBox/CampaignBtn
@onready var store_btn: Button = $Margin/HBox/NavVBox/StoreBtn
@onready var credits_btn: Button = $Margin/HBox/NavVBox/CreditsBtn
@onready var quit_btn: Button = $Margin/HBox/NavVBox/QuitBtn

@onready var currency_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/CurrencyLabel
@onready var cores_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/CoresLabel
@onready var act_label: Label = $Margin/HBox/DisplayVBox/StatsPanel/VBox/ActLabel
@onready var ship_sprite: Sprite2D = $Margin/HBox/DisplayVBox/ShipPanel/SpriteContainer/ShipSprite
@onready var dialogue_layer: StoryDialogue = $StoryDialogue
@onready var credits_modal: PanelContainer = $CreditsModal
@onready var close_credits_btn: Button = $CreditsModal/VBox/CloseCreditsBtn

# New Game Confirmation Modal
@onready var confirm_modal: PanelContainer = $NewGameModal
@onready var confirm_btn: Button = $NewGameModal/VBox/ButtonRow/ConfirmBtn
@onready var cancel_btn: Button = $NewGameModal/VBox/ButtonRow/CancelBtn

func _ready() -> void:
	SaveManager.load_data()
	_update_hub_display()
	
	if continue_btn: continue_btn.pressed.connect(_on_continue_pressed)
	if new_game_btn: new_game_btn.pressed.connect(_on_new_game_pressed)
	if campaign_btn: campaign_btn.pressed.connect(_on_campaign_pressed)
	if store_btn: store_btn.pressed.connect(_on_store_pressed)
	if credits_btn: credits_btn.pressed.connect(_on_credits_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)
	if close_credits_btn: close_credits_btn.pressed.connect(func(): credits_modal.visible = false)
	
	if confirm_btn: confirm_btn.pressed.connect(_on_confirm_new_game)
	if cancel_btn: cancel_btn.pressed.connect(_on_cancel_new_game)
	
	if credits_modal: credits_modal.visible = false
	if confirm_modal: confirm_modal.visible = false

func _update_hub_display() -> void:
	var has_save = SaveManager.has_active_save()
	var act_num = SaveManager.get_data().get("campaign_act", 1)
	
	if continue_btn:
		if has_save:
			continue_btn.disabled = false
			continue_btn.text = "CONTINUE CAMPAIGN (ACT %d) >>" % act_num
			continue_btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
		else:
			continue_btn.disabled = true
			continue_btn.text = "CONTINUE CAMPAIGN [NO SAVE]"
			continue_btn.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	
	if currency_label:
		currency_label.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()
	if cores_label:
		cores_label.text = "RECONSTRUCTION CORES: %d ⬡" % SaveManager.get_reconstruction_cores()
	if act_label:
		act_label.text = "ACTIVE CAMPAIGN: ACT %d // OUTPOST 44" % act_num
	
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
	# Opens the Campaign Map where the player can continue their journey
	get_tree().change_scene_to_file("res://scenes/campaign_menu.tscn")

func _on_new_game_pressed() -> void:
	if confirm_modal:
		confirm_modal.visible = true

func _on_confirm_new_game() -> void:
	if confirm_modal:
		confirm_modal.visible = false
	SaveManager.reset_campaign_only()
	get_tree().change_scene_to_file("res://scenes/prologue.tscn")

func _on_cancel_new_game() -> void:
	if confirm_modal:
		confirm_modal.visible = false

func _on_campaign_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/campaign_menu.tscn")

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/store_menu.tscn")

func _on_credits_pressed() -> void:
	if credits_modal:
		credits_modal.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
