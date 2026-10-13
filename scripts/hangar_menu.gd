class_name HangarMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HANGAR / MAIN HUB MENU
# Home menu offering Campaign Continue, New Game (with Prologue),
# Hangar Store / Outfitter, Mission Briefings, Credits, and Quit.
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

func _ready() -> void:
	SaveManager.load_data()
	_update_hub_display()
	
	if continue_btn: continue_btn.pressed.connect(_on_continue_pressed)
	if new_game_btn: new_game_btn.pressed.connect(_on_new_game_pressed)
	if store_btn: store_btn.pressed.connect(_on_store_pressed)
	if briefing_btn: briefing_btn.pressed.connect(_on_briefing_pressed)
	if credits_btn: credits_btn.pressed.connect(_on_credits_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)
	if close_credits_btn: close_credits_btn.pressed.connect(func(): credits_modal.visible = false)
	
	if credits_modal:
		credits_modal.visible = false

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
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_new_game_pressed() -> void:
	SaveManager.reset_data()
	SaveManager.add_currency(50) # Starting stipend
	_update_hub_display()
	
	# Play Prologue transmission, then launch main scene
	if dialogue_layer:
		dialogue_layer.play_sequence("prologue", func():
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		)
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/store_menu.tscn")

func _on_briefing_pressed() -> void:
	if dialogue_layer:
		dialogue_layer.play_sequence("act1_briefing")

func _on_credits_pressed() -> void:
	if credits_modal:
		credits_modal.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
