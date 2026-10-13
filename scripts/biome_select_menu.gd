class_name BiomeSelectMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — BIOME SELECTION & UNLOCK MENU
# Enables browsing all 5 planetary biomes, inspecting environmental hazards,
# unlocking locked biomes with Vector Fragments, and deploying to selected worlds.
# ==============================================================================

@onready var back_button: Button = $Margin/VBox/Header/BackButton
@onready var currency_label: Label = $Margin/VBox/Header/CurrencyLabel
@onready var biome_list_container: VBoxContainer = $Margin/VBox/Body/BiomeScroll/BiomeListVBox

# Detail Panel
@onready var detail_title: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailTitle
@onready var detail_subtitle: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailSubtitle
@onready var detail_difficulty: Label = $Margin/VBox/Body/DetailPanel/VBox/DiffRow/DetailDiff
@onready var detail_hazard: Label = $Margin/VBox/Body/DetailPanel/VBox/HazardRow/DetailHazard
@onready var detail_cost: Label = $Margin/VBox/Body/DetailPanel/VBox/CostRow/DetailCost
@onready var detail_desc: Label = $Margin/VBox/Body/DetailPanel/VBox/DetailDescPanel/Margin/DetailDesc
@onready var deploy_button: Button = $Margin/VBox/Body/DetailPanel/VBox/DeployButton
@onready var unlock_button: Button = $Margin/VBox/Body/DetailPanel/VBox/UnlockButton
@onready var status_msg: Label = $Margin/VBox/Body/DetailPanel/VBox/StatusMsg

var biomes: Array[Dictionary] = []
var selected_index: int = 0

func _ready() -> void:
	SaveManager.load_data()
	biomes = BiomeData.get_all_biomes()
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if deploy_button:
		deploy_button.pressed.connect(_on_deploy_pressed)
	if unlock_button:
		unlock_button.pressed.connect(_on_unlock_pressed)
	
	_update_header()
	_populate_biome_list()
	
	# Focus currently equipped biome initially
	var active_id = SaveManager.get_selected_biome()
	var initial_idx = 0
	for i in range(biomes.size()):
		if biomes[i]["id"] == active_id:
			initial_idx = i
			break
	_select_biome(initial_idx)

func _update_header() -> void:
	if currency_label:
		currency_label.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()

func _populate_biome_list() -> void:
	if not biome_list_container:
		return
	
	for child in biome_list_container.get_children():
		child.queue_free()
	
	var active_biome_id = SaveManager.get_selected_biome()
	
	for i in range(biomes.size()):
		var b = biomes[i]
		var b_id = b["id"]
		var is_unlocked = SaveManager.is_biome_unlocked(b_id)
		var is_active = (b_id == active_biome_id)
		var cost = b.get("unlock_cost", 0)
		
		var status_str = "[ACTIVE]" if is_active else ("[UNLOCKED]" if is_unlocked else "[LOCKED - %d ◆]" % cost)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "  %s   %s" % [b["name"], status_str]
		
		if is_active:
			btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
		elif is_unlocked:
			btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))
		else:
			btn.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
		
		btn.pressed.connect(func(): _select_biome(i))
		biome_list_container.add_child(btn)

func _select_biome(index: int) -> void:
	if index < 0 or index >= biomes.size():
		return
	
	selected_index = index
	var b = biomes[selected_index]
	var b_id = b["id"]
	var is_unlocked = SaveManager.is_biome_unlocked(b_id)
	var is_active = (b_id == SaveManager.get_selected_biome())
	var cost = b.get("unlock_cost", 0)
	var current_frag = SaveManager.get_currency()
	
	if detail_title:
		detail_title.text = b.get("name", "")
	if detail_subtitle:
		detail_subtitle.text = b.get("subtitle", "")
	if detail_difficulty:
		detail_difficulty.text = b.get("difficulty", "STANDARD")
	if detail_hazard:
		detail_hazard.text = "%s: %s" % [b.get("hazard_name", "None"), b.get("hazard_description", "")]
	if detail_cost:
		detail_cost.text = "FREE" if cost == 0 else "%d VECTOR FRAGMENTS ◆" % cost
	if detail_desc:
		detail_desc.text = b.get("description", "")
	
	if status_msg:
		status_msg.text = ""
	
	if is_unlocked:
		if unlock_button:
			unlock_button.visible = false
		if deploy_button:
			deploy_button.visible = true
			deploy_button.text = "CURRENTLY ACTIVE WORLD" if is_active else "SELECT & DEPLOY TO WORLD >>"
			deploy_button.disabled = false
	else:
		if deploy_button:
			deploy_button.visible = false
		if unlock_button:
			unlock_button.visible = true
			if current_frag >= cost:
				unlock_button.text = "UNLOCK BIOME [%d VECTOR FRAGMENTS ◆]" % cost
				unlock_button.disabled = false
			else:
				unlock_button.text = "INSUFFICIENT FRAGMENTS (NEED %d ◆, HAVE %d ◆)" % [cost, current_frag]
				unlock_button.disabled = true

func _on_unlock_pressed() -> void:
	var b = biomes[selected_index]
	var b_id = b["id"]
	var cost = b.get("unlock_cost", 0)
	
	if SaveManager.get_currency() < cost:
		if status_msg:
			status_msg.text = "[!] INSUFFICIENT FRAGMENTS. COMPLETE MISSIONS TO EARN BOUNTY."
		return
	
	if SaveManager.unlock_biome(b_id):
		# Automatically select newly unlocked biome
		SaveManager.set_selected_biome(b_id)
		_update_header()
		_populate_biome_list()
		_select_biome(selected_index)
		if status_msg:
			status_msg.text = "[OK] BIOME UNLOCKED AND SET AS ACTIVE COMBAT THEATER!"

func _on_deploy_pressed() -> void:
	var b = biomes[selected_index]
	var b_id = b["id"]
	SaveManager.set_selected_biome(b_id)
	# Transition directly to combat arena in selected biome
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
