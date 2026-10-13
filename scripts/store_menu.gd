class_name StoreMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HANGAR STORE & LOADOUT OUTFITTER
# Manages purchase and equipping of player chassis skins and combat upgrades.
# ==============================================================================

@onready var currency_label: Label = $Margin/VBox/Header/CurrencyLabel
@onready var preview_sprite: Sprite2D = $Margin/VBox/Body/PreviewArea/ShipPreviewContainer/ShipSprite
@onready var upgrade_graphic: Control = $Margin/VBox/Body/PreviewArea/ShipPreviewContainer/UpgradeGraphic
@onready var preview_name: Label = $Margin/VBox/Body/PreviewArea/PreviewName
@onready var preview_desc: Label = $Margin/VBox/Body/PreviewArea/PreviewDesc
@onready var action_button: Button = $Margin/VBox/Body/PreviewArea/ActionButton
@onready var back_button: Button = $Margin/VBox/Header/BackButton
@onready var skin_list_container: VBoxContainer = $Margin/VBox/Body/CatalogScroll/CatalogVBox/SkinsList
@onready var upgrade_list_container: VBoxContainer = $Margin/VBox/Body/CatalogScroll/CatalogVBox/UpgradesList

var selected_item_id: String = "skin_default"
var is_selected_an_upgrade: bool = false

# Cache item buttons for quick visual highlight updates
var _item_buttons: Dictionary = {}

const SKINS_CATALOG = {
	"skin_default": {
		"name": "AXIOM Interceptor",
		"cost": 0,
		"desc": "Standard pale titanium hull with cyan conduit trim. Factory spec.",
		"tex": "res://assets/sprites/player_ship.png",
		"color": Color(1.0, 1.0, 1.0)
	},
	"skin_prototype": {
		"name": "Stealth Prototype Frame",
		"cost": 150,
		"desc": "Obsidian alloy frame with golden kinetic conduits. Absorbs radar reflection.",
		"tex": "res://assets/sprites/player_ship_prototype.png",
		"color": Color(0.7, 0.85, 1.35)
	},
	"skin_squad": {
		"name": "Serin Squad Frame",
		"cost": 250,
		"desc": "Markings of Kael's former assault squadron on Vesper-9. Crimson tactical edges.",
		"tex": "res://assets/sprites/player_ship_squad.png",
		"color": Color(1.25, 0.75, 0.85)
	},
	"skin_vector": {
		"name": "Resonant Vector Frame",
		"cost": 400,
		"desc": "Experimental field-resonator that shimmers with magenta kinetic feedback.",
		"tex": "res://assets/sprites/player_ship_vector.png",
		"color": Color(1.35, 0.65, 1.5)
	}
}

const UPGRADES_CATALOG = {
	"upgrade_capacitor": {
		"name": "Vector Capacitor",
		"cost": 120,
		"desc": "Increases max projectile ricochet bounces by +1 and grants a +15% bounce speed boost."
	},
	"upgrade_nanocell": {
		"name": "Emergency Nanocell",
		"cost": 100,
		"desc": "Nanocells restore +10 bonus HP (35 HP total) and grants 1 starting Reconstruction Core."
	},
	"upgrade_frame": {
		"name": "Stabilized Frame",
		"cost": 150,
		"desc": "Reinforces ship structure, permanently boosting Max Hull Integrity from 100 to 125 HP."
	},
	"upgrade_targeting": {
		"name": "Targeting Matrix",
		"cost": 80,
		"desc": "Extends the neon aiming laser guide line by +50% for cleaner bounce calculations."
	}
}

func _ready() -> void:
	SaveManager.load_data()
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if action_button:
		action_button.pressed.connect(_on_action_pressed)
	
	_populate_catalog()
	_select_skin(SaveManager.get_equipped_skin())

func _refresh_ui() -> void:
	if currency_label:
		currency_label.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()
	
	_update_all_row_styles()
	_update_preview()

# ==============================================================================
# CATALOG ROW CREATION & MANAGEMENT
# ==============================================================================

func _populate_catalog() -> void:
	_item_buttons.clear()
	
	# Populate skins
	if skin_list_container:
		for child in skin_list_container.get_children():
			child.queue_free()
		for skin_id in SKINS_CATALOG.keys():
			_create_item_row(skin_id, false, skin_list_container)
	
	# Populate upgrades
	if upgrade_list_container:
		for child in upgrade_list_container.get_children():
			child.queue_free()
		for up_id in UPGRADES_CATALOG.keys():
			_create_item_row(up_id, true, upgrade_list_container)
	
	_refresh_ui()

func _create_item_row(item_id: String, is_upgrade: bool, container: VBoxContainer) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 36)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	if is_upgrade:
		btn.pressed.connect(_select_upgrade.bind(item_id))
	else:
		btn.pressed.connect(_select_skin.bind(item_id))
	
	container.add_child(btn)
	_item_buttons[item_id] = btn
	return btn

func _update_all_row_styles() -> void:
	for item_id in _item_buttons.keys():
		var btn: Button = _item_buttons[item_id]
		if not is_instance_valid(btn):
			continue
		
		var is_selected: bool = (item_id == selected_item_id)
		var is_upgrade: bool = UPGRADES_CATALOG.has(item_id)
		var item_name: String = ""
		var status_str: String = ""
		
		if is_upgrade:
			var data = UPGRADES_CATALOG[item_id]
			item_name = data["name"]
			var is_unlocked = SaveManager.is_upgrade_unlocked(item_id)
			status_str = "[INSTALLED]" if is_unlocked else "[%d ◆]" % data["cost"]
		else:
			var data = SKINS_CATALOG[item_id]
			item_name = data["name"]
			var is_unlocked = SaveManager.is_skin_unlocked(item_id)
			var is_equipped = (SaveManager.get_equipped_skin() == item_id)
			status_str = "[EQUIPPED]" if is_equipped else ("[OWNED]" if is_unlocked else "[%d ◆]" % data["cost"])
		
		var prefix = "► " if is_selected else "  "
		btn.text = "%s%s   %s" % [prefix, item_name, status_str]
		
		# Apply selected highlight styling
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		
		if is_selected:
			style.bg_color = Color(0.08, 0.16, 0.28, 0.95)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(0.2, 0.95, 1.0, 1.0)
			btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0, 1.0))
		else:
			style.bg_color = Color(0.04, 0.06, 0.11, 0.75)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.border_color = Color(0.18, 0.26, 0.38, 0.5)
			btn.add_theme_color_override("font_color", Color(0.82, 0.88, 0.96, 0.9))
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

# ==============================================================================
# ITEM SELECTION & PREVIEW
# ==============================================================================

func _select_skin(skin_id: String) -> void:
	selected_item_id = skin_id
	is_selected_an_upgrade = false
	_refresh_ui()

func _select_upgrade(up_id: String) -> void:
	selected_item_id = up_id
	is_selected_an_upgrade = true
	_refresh_ui()

func _update_preview() -> void:
	if not is_selected_an_upgrade:
		var data = SKINS_CATALOG.get(selected_item_id, {})
		if preview_name:
			preview_name.text = data.get("name", "")
			preview_name.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0, 1.0))
		if preview_desc:
			preview_desc.text = data.get("desc", "")
		
		if upgrade_graphic:
			upgrade_graphic.visible = false
		if preview_sprite:
			preview_sprite.visible = true
			var tex_path = data.get("tex", "res://assets/sprites/player_ship.png")
			if ResourceLoader.exists(tex_path):
				preview_sprite.texture = load(tex_path)
			preview_sprite.modulate = data.get("color", Color.WHITE)
		
		var is_unlocked = SaveManager.is_skin_unlocked(selected_item_id)
		var is_equipped = (SaveManager.get_equipped_skin() == selected_item_id)
		
		if action_button:
			if is_equipped:
				action_button.text = "EQUIPPED"
				action_button.disabled = true
			elif is_unlocked:
				action_button.text = "EQUIP CHASSIS"
				action_button.disabled = false
			else:
				var cost = data.get("cost", 0)
				action_button.text = "PURCHASE [%d ◆]" % cost
				action_button.disabled = (SaveManager.get_currency() < cost)
	else:
		var data = UPGRADES_CATALOG.get(selected_item_id, {})
		if preview_name:
			preview_name.text = data.get("name", "")
			preview_name.add_theme_color_override("font_color", Color(0.3, 1.0, 0.8, 1.0))
		if preview_desc:
			preview_desc.text = data.get("desc", "")
		
		if preview_sprite:
			preview_sprite.visible = false
		if upgrade_graphic:
			upgrade_graphic.visible = true
			upgrade_graphic.set_upgrade(selected_item_id)
		
		var is_unlocked = SaveManager.is_upgrade_unlocked(selected_item_id)
		if action_button:
			if is_unlocked:
				action_button.text = "MODULE INSTALLED"
				action_button.disabled = true
			else:
				var cost = data.get("cost", 0)
				action_button.text = "INSTALL UPGRADE [%d ◆]" % cost
				action_button.disabled = (SaveManager.get_currency() < cost)

# ==============================================================================
# ACTIONS & PURCHASES
# ==============================================================================

func _on_action_pressed() -> void:
	if not is_selected_an_upgrade:
		var is_unlocked = SaveManager.is_skin_unlocked(selected_item_id)
		if is_unlocked:
			SaveManager.equip_skin(selected_item_id)
		else:
			var cost = SKINS_CATALOG[selected_item_id]["cost"]
			if SaveManager.get_currency() >= cost and SaveManager.spend_currency(cost):
				SaveManager.unlock_skin(selected_item_id)
				SaveManager.equip_skin(selected_item_id)
	else:
		var is_unlocked = SaveManager.is_upgrade_unlocked(selected_item_id)
		if not is_unlocked:
			var cost = UPGRADES_CATALOG[selected_item_id]["cost"]
			if SaveManager.get_currency() >= cost and SaveManager.spend_currency(cost):
				SaveManager.unlock_upgrade(selected_item_id)
				if selected_item_id == "upgrade_nanocell":
					SaveManager.add_reconstruction_core(1)
	
	_refresh_ui()

func _on_back_pressed() -> void:
	if ResourceLoader.exists("res://scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif ResourceLoader.exists("res://scenes/hangar_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
