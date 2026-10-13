class_name StoreMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HANGAR STORE & LOADOUT OUTFITTER
# Manages purchase and equipping of player chassis skins and combat upgrades.
# ==============================================================================

@onready var currency_label: Label = $Margin/VBox/Header/CurrencyLabel
@onready var preview_sprite: Sprite2D = $Margin/VBox/Body/PreviewArea/ShipPreviewContainer/ShipSprite
@onready var preview_name: Label = $Margin/VBox/Body/PreviewArea/PreviewName
@onready var preview_desc: Label = $Margin/VBox/Body/PreviewArea/PreviewDesc
@onready var action_button: Button = $Margin/VBox/Body/PreviewArea/ActionButton
@onready var back_button: Button = $Margin/VBox/Header/BackButton
@onready var skin_list_container: VBoxContainer = $Margin/VBox/Body/CatalogScroll/CatalogVBox/SkinsList
@onready var upgrade_list_container: VBoxContainer = $Margin/VBox/Body/CatalogScroll/CatalogVBox/UpgradesList

var selected_item_id: String = "skin_default"
var is_selected_an_upgrade: bool = false

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
		"desc": "Increases max projectile ricochet bounces by +1 and grants bounce speed bonus."
	},
	"upgrade_nanocell": {
		"name": "Emergency Nanocell",
		"cost": 100,
		"desc": "Nanocells restore +10 bonus HP and grants 1 starting Reconstruction Core."
	},
	"upgrade_frame": {
		"name": "Stabilized Frame",
		"cost": 150,
		"desc": "Reinforces ship structure, boosting Max Health from 100 to 125 HP."
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
	
	_refresh_ui()
	_select_skin(SaveManager.get_equipped_skin())

func _refresh_ui() -> void:
	if currency_label:
		currency_label.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()
	
	_populate_skins()
	_populate_upgrades()
	_update_preview()

func _populate_skins() -> void:
	if not skin_list_container:
		return
	
	for child in skin_list_container.get_children():
		child.queue_free()
	
	for skin_id in SKINS_CATALOG.keys():
		var data = SKINS_CATALOG[skin_id]
		var btn = Button.new()
		var is_unlocked = SaveManager.is_skin_unlocked(skin_id)
		var is_equipped = (SaveManager.get_equipped_skin() == skin_id)
		
		var status_str = "[EQUIPPED]" if is_equipped else ("[OWNED]" if is_unlocked else "[%d ◆]" % data["cost"])
		btn.text = "%s  %s" % [data["name"], status_str]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _select_skin(skin_id))
		skin_list_container.add_child(btn)

func _populate_upgrades() -> void:
	if not upgrade_list_container:
		return
	
	for child in upgrade_list_container.get_children():
		child.queue_free()
	
	for up_id in UPGRADES_CATALOG.keys():
		var data = UPGRADES_CATALOG[up_id]
		var btn = Button.new()
		var is_unlocked = SaveManager.is_upgrade_unlocked(up_id)
		
		var status_str = "[INSTALLED]" if is_unlocked else "[%d ◆]" % data["cost"]
		btn.text = "%s  %s" % [data["name"], status_str]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _select_upgrade(up_id))
		upgrade_list_container.add_child(btn)

func _select_skin(skin_id: String) -> void:
	selected_item_id = skin_id
	is_selected_an_upgrade = false
	_update_preview()

func _select_upgrade(up_id: String) -> void:
	selected_item_id = up_id
	is_selected_an_upgrade = true
	_update_preview()

func _update_preview() -> void:
	if not is_selected_an_upgrade:
		var data = SKINS_CATALOG.get(selected_item_id, {})
		if preview_name: preview_name.text = data.get("name", "")
		if preview_desc: preview_desc.text = data.get("desc", "")
		
		if preview_sprite:
			var tex_path = data.get("tex", "res://assets/sprites/player_ship.png")
			if ResourceLoader.exists(tex_path):
				preview_sprite.texture = load(tex_path)
			preview_sprite.visible = true
		
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
		if preview_name: preview_name.text = data.get("name", "")
		if preview_desc: preview_desc.text = data.get("desc", "")
		if preview_sprite: preview_sprite.visible = false
		
		var is_unlocked = SaveManager.is_upgrade_unlocked(selected_item_id)
		if action_button:
			if is_unlocked:
				action_button.text = "MODULE INSTALLED"
				action_button.disabled = true
			else:
				var cost = data.get("cost", 0)
				action_button.text = "INSTALL UPGRADE [%d ◆]" % cost
				action_button.disabled = (SaveManager.get_currency() < cost)

func _on_action_pressed() -> void:
	if not is_selected_an_upgrade:
		var is_unlocked = SaveManager.is_skin_unlocked(selected_item_id)
		if is_unlocked:
			SaveManager.equip_skin(selected_item_id)
		else:
			var cost = SKINS_CATALOG[selected_item_id]["cost"]
			if SaveManager.spend_currency(cost):
				SaveManager.unlock_skin(selected_item_id)
				SaveManager.equip_skin(selected_item_id)
	else:
		var cost = UPGRADES_CATALOG[selected_item_id]["cost"]
		if SaveManager.spend_currency(cost):
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
