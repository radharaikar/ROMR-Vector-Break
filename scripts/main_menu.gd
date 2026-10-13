class_name MainMenu
extends Control

# ==============================================================================
# VECTOR//BREAK — HOMEPAGE / MAIN MENU
# Features centred prominent title, animated spaceship & starfield background,
# and 6 fully functional portals: PLAY (Biome Maps), COLLECTIONS, STORE,
# PLAYER LEVEL, SETTINGS, and QUIT.
# ==============================================================================

const SettingsManager = preload("res://scripts/settings_manager.gd")

@onready var play_btn: Button = $Margin/Center/MenuVBox/NavButtons/PlayBtn
@onready var collections_btn: Button = $Margin/Center/MenuVBox/NavButtons/CollectionsBtn
@onready var store_btn: Button = $Margin/Center/MenuVBox/NavButtons/StoreBtn
@onready var level_btn: Button = $Margin/Center/MenuVBox/NavButtons/LevelBtn
@onready var settings_btn: Button = $Margin/Center/MenuVBox/NavButtons/SettingsBtn
@onready var quit_btn: Button = $Margin/Center/MenuVBox/NavButtons/QuitBtn

@onready var currency_display: Label = $TopBar/HBox/CurrencyLabel
@onready var cores_display: Label = $TopBar/HBox/CoresLabel

# Modals
@onready var biome_modal: PanelContainer = $BiomeModal
@onready var collections_modal: PanelContainer = $CollectionsModal
@onready var level_modal: PanelContainer = $LevelModal
@onready var settings_modal: PanelContainer = $SettingsModal

# Animated floating ship preview
@onready var ship_preview: Sprite2D = $ShipContainer/ShipSprite

var _time_elapsed: float = 0.0
var _stars: Array[Dictionary] = []

func _ready() -> void:
	SettingsManager.load_settings()
	SaveManager.load_data()
	
	# Generate background starfield
	var rng = RandomNumberGenerator.new()
	rng.seed = 1337
	for i in range(90):
		_stars.append({
			"pos": Vector2(rng.randf_range(0, 1280), rng.randf_range(0, 720)),
			"size": rng.randf_range(0.8, 2.4),
			"alpha": rng.randf_range(0.3, 0.9)
		})
	
	_update_header_stats()
	_update_ship_skin()
	_connect_main_buttons()
	_setup_settings_controls()
	
	var close_biome: Button = $BiomeModal/Margin/VBox/HeaderHBox/CloseBiomeBtn
	var close_col: Button = $CollectionsModal/Margin/VBox/HeaderHBox/CloseCollectionsBtn
	var close_lvl: Button = $LevelModal/Margin/VBox/HeaderHBox/CloseLevelBtn
	var close_set: Button = $SettingsModal/Margin/VBox/HeaderHBox/CloseSettingsBtn
	if close_biome: close_biome.pressed.connect(_hide_all_modals)
	if close_col: close_col.pressed.connect(_hide_all_modals)
	if close_lvl: close_lvl.pressed.connect(_hide_all_modals)
	if close_set: close_set.pressed.connect(_hide_all_modals)
	
	# Hide all modals by default
	_hide_all_modals()

func _process(delta: float) -> void:
	_time_elapsed += delta
	queue_redraw()
	
	if ship_preview:
		# Gentle hover oscillation and thruster bob
		ship_preview.position.y = 360.0 + sin(_time_elapsed * 2.2) * 8.0
		ship_preview.rotation = sin(_time_elapsed * 1.5) * 0.04

func _draw() -> void:
	# Subtle drifting starfield
	for star in _stars:
		var pos = star["pos"]
		pos.x = fmod(pos.x - _time_elapsed * 15.0, 1280.0)
		if pos.x < 0: pos.x += 1280.0
		var a = star["alpha"] * (0.7 + sin(_time_elapsed * 3.0 + star["pos"].y) * 0.3)
		draw_circle(pos, star["size"], Color(0.8, 0.9, 1.0, a))
		
	# Subtle thruster particle tail behind ship
	if ship_preview:
		var tail_origin = ship_preview.global_position + Vector2(-36, 0)
		for i in range(5):
			var t_pos = tail_origin - Vector2(i * 12.0 + sin(_time_elapsed * 10.0 + i) * 4.0, (i % 2) * 2.0)
			var col = Color(0.2, 0.9, 1.0, 0.7 - i * 0.12) if (i % 2 == 0) else Color(1.0, 0.2, 0.7, 0.7 - i * 0.12)
			draw_circle(t_pos, 4.0 - i * 0.6, col)

func _update_header_stats() -> void:
	if currency_display:
		currency_display.text = "VECTOR FRAGMENTS: %d ◆" % SaveManager.get_currency()
	if cores_display:
		cores_display.text = "RECON CORES: %d ⬡" % SaveManager.get_reconstruction_cores()

func _update_ship_skin() -> void:
	if not ship_preview:
		return
	var skin_id = SaveManager.get_equipped_skin()
	var tex_path = "res://assets/sprites/player_ship.png"
	match skin_id:
		"skin_prototype": tex_path = "res://assets/sprites/player_ship_prototype.png"
		"skin_squad": tex_path = "res://assets/sprites/player_ship_squad.png"
		"skin_vector": tex_path = "res://assets/sprites/player_ship_vector.png"
	if ResourceLoader.exists(tex_path):
		ship_preview.texture = load(tex_path)

func _connect_main_buttons() -> void:
	if play_btn: play_btn.pressed.connect(_on_play_pressed)
	if collections_btn: collections_btn.pressed.connect(_on_collections_pressed)
	if store_btn: store_btn.pressed.connect(_on_store_pressed)
	if level_btn: level_btn.pressed.connect(_on_level_pressed)
	if settings_btn: settings_btn.pressed.connect(_on_settings_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)

func _hide_all_modals() -> void:
	if biome_modal: biome_modal.visible = false
	if collections_modal: collections_modal.visible = false
	if level_modal: level_modal.visible = false
	if settings_modal: settings_modal.visible = false

# ==============================================================================
# 1. PLAY / BIOME SELECTION FLOW (2 FREE MAPS + 3 UNLOCKABLE)
# ==============================================================================

func _on_play_pressed() -> void:
	_hide_all_modals()
	_populate_biome_list()
	if biome_modal:
		biome_modal.visible = true

func _populate_biome_list() -> void:
	var container = $BiomeModal/Margin/VBox/Scroll/BiomeList
	if not container: return
	
	# Clear old cards
	for child in container.get_children():
		child.queue_free()
		
	var biomes = CampaignData.get_biome_definitions()
	var selected_id = SaveManager.get_selected_biome()
	var player_currency = SaveManager.get_currency()
	
	for b in biomes:
		var id: String = b["id"]
		var is_unlocked: bool = SaveManager.is_biome_unlocked(id)
		var is_selected: bool = (id == selected_id)
		var cost: int = b.get("cost", 0)
		
		var card = PanelContainer.new()
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.03, 0.04, 0.09, 0.92)
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 2
		card_style.border_color = b["accent_color"] if is_selected else (Color(0.2, 0.5, 0.7) if is_unlocked else Color(0.3, 0.3, 0.35))
		card_style.corner_radius_top_left = 6
		card_style.corner_radius_top_right = 6
		card_style.corner_radius_bottom_right = 6
		card_style.corner_radius_bottom_left = 6
		card.add_theme_stylebox_override("panel", card_style)
		
		var m = MarginContainer.new()
		m.add_theme_constant_override("margin_left", 16)
		m.add_theme_constant_override("margin_top", 12)
		m.add_theme_constant_override("margin_right", 16)
		m.add_theme_constant_override("margin_bottom", 12)
		card.add_child(m)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		m.add_child(hbox)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = b["name"] + (" [ACTIVE]" if is_selected else (" [FREE]" if b["free"] else ""))
		name_lbl.add_theme_color_override("font_color", b["accent_color"])
		name_lbl.add_theme_font_size_override("font_size", 16)
		info_vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = b["description"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
		desc_lbl.add_theme_font_size_override("font_size", 12)
		info_vbox.add_child(desc_lbl)
		
		var action_btn = Button.new()
		action_btn.custom_minimum_size = Vector2(170, 42)
		hbox.add_child(action_btn)
		
		if is_unlocked:
			action_btn.text = "DEPLOY >>" if not is_selected else "ACTIVE"
			action_btn.disabled = is_selected
			action_btn.pressed.connect(func():
				SaveManager.select_biome(id)
				_hide_all_modals()
				get_tree().change_scene_to_file("res://scenes/act1_mission.tscn")
			)
		else:
			action_btn.text = "UNLOCK (%d ◆)" % cost
			action_btn.disabled = (player_currency < cost)
			action_btn.pressed.connect(func():
				if SaveManager.unlock_biome(id, cost):
					_update_header_stats()
					_populate_biome_list()
			)
			
		container.add_child(card)

# ==============================================================================
# 2. COLLECTIONS CATALOGUE
# ==============================================================================

func _on_collections_pressed() -> void:
	_hide_all_modals()
	_populate_collections_list()
	if collections_modal:
		collections_modal.visible = true

func _populate_collections_list() -> void:
	var list = $CollectionsModal/Margin/VBox/Scroll/CollectionsList
	if not list: return
	for c in list.get_children(): c.queue_free()
	
	var catalogue = [
		{"name": "Standard Vector Frame", "type": "SHIP SKIN", "desc": "Standard-issue AXIOM interceptor with balanced vector telemetry.", "owned": true},
		{"name": "Prototype Interceptor", "type": "SHIP SKIN", "desc": "Experimental high-mobility frame with agile thrusters.", "owned": SaveManager.is_skin_unlocked("skin_prototype")},
		{"name": "Squadron Vanguard", "type": "SHIP SKIN", "desc": "Tactical combat skin featuring reinforced hull geometry.", "owned": SaveManager.is_skin_unlocked("skin_squad")},
		{"name": "Vector Phantom", "type": "SHIP SKIN", "desc": "Stealth prototype designed for covert deep-space incursions.", "owned": SaveManager.is_skin_unlocked("skin_vector")},
		{"name": "Flux Vector Capacitor", "type": "CORE UPGRADE", "desc": "Amplifies projectile bounce retention by +1 collision.", "owned": SaveManager.is_upgrade_unlocked("upgrade_capacitor")},
		{"name": "Emergency Nanocell Matrix", "type": "CORE UPGRADE", "desc": "Enhances nanocell repair efficiency by +10 HP per pickup.", "owned": SaveManager.is_upgrade_unlocked("upgrade_nanocell")},
		{"name": "Reinforced Titanium Frame", "type": "CORE UPGRADE", "desc": "Hardens internal hull structure to sustain heavy kinetic impacts.", "owned": SaveManager.is_upgrade_unlocked("upgrade_frame")},
		{"name": "Quantum Targeting Array", "type": "CORE UPGRADE", "desc": "Optimizes predictive fire trajectory guidance algorithms.", "owned": SaveManager.is_upgrade_unlocked("upgrade_targeting")},
		{"name": "Reconstruction Core", "type": "RECOVERY PROTOCOL", "desc": "Emergency nanite matrix providing an instant mid-combat revive.", "owned": SaveManager.get_reconstruction_cores() > 0}
	]
	
	for item in catalogue:
		var panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.03, 0.04, 0.09, 0.88)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.1, 0.85, 1.0, 0.7) if item["owned"] else Color(0.3, 0.3, 0.4, 0.5)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		panel.add_theme_stylebox_override("panel", style)
		
		var m = MarginContainer.new()
		m.add_theme_constant_override("margin_left", 14)
		m.add_theme_constant_override("margin_top", 10)
		m.add_theme_constant_override("margin_right", 14)
		m.add_theme_constant_override("margin_bottom", 10)
		panel.add_child(m)
		
		var hb = HBoxContainer.new()
		m.add_child(hb)
		
		var vb = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(vb)
		
		var title = Label.new()
		title.text = item["name"] + ("  [ACQUIRED]" if item["owned"] else "  [LOCKED]")
		title.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0) if item["owned"] else Color(0.6, 0.6, 0.7))
		title.add_theme_font_size_override("font_size", 14)
		vb.add_child(title)
		
		var sub = Label.new()
		sub.text = item["type"] + " // " + item["desc"]
		sub.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
		sub.add_theme_font_size_override("font_size", 11)
		vb.add_child(sub)
		
		list.add_child(panel)

# ==============================================================================
# 3. STORE
# ==============================================================================

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/store_menu.tscn")

# ==============================================================================
# 4. PLAYER LEVEL & PROGRESSION
# ==============================================================================

func _on_level_pressed() -> void:
	_hide_all_modals()
	_update_level_display()
	if level_modal:
		level_modal.visible = true

func _update_level_display() -> void:
	var total_score = SaveManager.get_data().get("stats", {}).get("total_score", 0)
	var xp_per_level: int = 1500
	var player_level: int = 1 + int(total_score / xp_per_level)
	var current_xp: int = total_score % xp_per_level
	var progress_pct: float = float(current_xp) / float(xp_per_level)
	
	var lvl_lbl = $LevelModal/Margin/VBox/LevelHeaderLabel
	var xp_lbl = $LevelModal/Margin/VBox/XpLabel
	var bar = $LevelModal/Margin/VBox/LevelBar
	var perks_lbl = $LevelModal/Margin/VBox/PerksLabel
	
	if lvl_lbl: lvl_lbl.text = "PILOT RANK: LEVEL %d" % player_level
	if xp_lbl: xp_lbl.text = "EXPERIENCE: %d / %d XP  (TOTAL ACCUMULATED SCORE: %d)" % [current_xp, xp_per_level, total_score]
	if bar: bar.value = progress_pct * 100.0
	if perks_lbl:
		perks_lbl.text = "TACTICAL PRIVILEGES:\n• Level 1: Outpost 44 Flight Clearance (Granted)\n• Level 2: Emergency Nanocell Magnetization (+15%% Range)\n• Level 3: Dual Vector Thruster Overclock (+5%% Agility)\n• Level 4: Vesper-9 Classified Archive Decryption"

# ==============================================================================
# 5. SETTINGS
# ==============================================================================

func _on_settings_pressed() -> void:
	_hide_all_modals()
	if settings_modal:
		settings_modal.visible = true

func _setup_settings_controls() -> void:
	var cfg = SettingsManager.get_settings()
	
	var master_slider: HSlider = $SettingsModal/Margin/VBox/Grid/MasterSlider
	var sfx_slider: HSlider = $SettingsModal/Margin/VBox/Grid/SfxSlider
	var fs_check: CheckBox = $SettingsModal/Margin/VBox/Grid/FullscreenCheck
	var shake_check: CheckBox = $SettingsModal/Margin/VBox/Grid/ShakeCheck
	var res_opt: OptionButton = $SettingsModal/Margin/VBox/Grid/ResolutionOption
	var aim_slider: HSlider = $SettingsModal/Margin/VBox/Grid/AimSlider
	
	if master_slider:
		master_slider.value = cfg.get("master_volume", 0.85) * 100.0
		master_slider.value_changed.connect(func(v): SettingsManager.set_master_volume(v / 100.0))
		
	if sfx_slider:
		sfx_slider.value = cfg.get("sfx_volume", 0.9) * 100.0
		sfx_slider.value_changed.connect(func(v): SettingsManager.set_sfx_volume(v / 100.0))
		
	if fs_check:
		fs_check.button_pressed = cfg.get("fullscreen", false)
		fs_check.toggled.connect(func(b): SettingsManager.set_fullscreen(b))
		
	if shake_check:
		shake_check.button_pressed = cfg.get("screen_shake", true)
		shake_check.toggled.connect(func(b): SettingsManager.set_screen_shake(b))
		
	if aim_slider:
		aim_slider.value = cfg.get("aim_sensitivity", 1.0)
		aim_slider.value_changed.connect(func(v): SettingsManager.set_aim_sensitivity(v))
		
	if res_opt:
		res_opt.clear()
		res_opt.add_item("1280 x 720 (Standard)")
		res_opt.add_item("1920 x 1080 (Full HD)")
		res_opt.item_selected.connect(func(idx):
			if idx == 0: SettingsManager.set_resolution(1280, 720)
			elif idx == 1: SettingsManager.set_resolution(1920, 1080)
		)

func _on_quit_pressed() -> void:
	get_tree().quit()
