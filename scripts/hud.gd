class_name ArcadeHUD
extends CanvasLayer

# ==============================================================================
# VECTOR//BREAK — COMPREHENSIVE HUD CONTROLLER
# Displays real-time Hull Integrity, Score, Combo, Currency (Fragments),
# Reconstruct Cores, Round/Wave Status, Boss Health Bar, Mission Banners,
# Pause Menu (with Controls Manual), and Defeat/Revive Modal.
# ==============================================================================

@onready var title_label: Label = get_node_or_null("Control/TitleMargin/VBox/TitleLabel")
@onready var status_label: Label = get_node_or_null("Control/TitleMargin/VBox/StatusLabel")
@onready var score_label: Label = get_node_or_null("Control/MarginContainer/VBoxContainer/ScoreLabel")
@onready var combo_label: Label = get_node_or_null("Control/MarginContainer/VBoxContainer/ComboBadge/ComboLabel")
@onready var combo_badge: PanelContainer = get_node_or_null("Control/MarginContainer/VBoxContainer/ComboBadge")
@onready var currency_label: Label = get_node_or_null("Control/MarginContainer/VBoxContainer/CurrencyLabel")
@onready var cores_label: Label = get_node_or_null("Control/MarginContainer/VBoxContainer/CoresLabel")

# Mission Banners
@onready var banner_label: Label = get_node_or_null("Control/CenterBanner/BannerLabel")
@onready var center_banner: Control = get_node_or_null("Control/CenterBanner")

# Player Health Bar UI
@onready var health_bar: ProgressBar = get_node_or_null("Control/HealthMargin/HealthPanel/VBoxContainer/HealthProgressBar")
@onready var health_label: Label = get_node_or_null("Control/HealthMargin/HealthPanel/VBoxContainer/HealthHeader/HealthLabel")
@onready var critical_warning: Label = get_node_or_null("Control/HealthMargin/HealthPanel/VBoxContainer/CriticalWarning")

# Boss Health Bar UI
@onready var boss_health_margin: Control = get_node_or_null("Control/BossHealthMargin")
@onready var boss_title_label: Label = get_node_or_null("Control/BossHealthMargin/BossPanel/VBox/BossTitleLabel")
@onready var boss_progress_bar: ProgressBar = get_node_or_null("Control/BossHealthMargin/BossPanel/VBox/BossProgressBar")

# Defeat / Second Chance Modal
@onready var defeat_overlay: Control = get_node_or_null("Control/DefeatOverlay")
@onready var revive_button: Button = get_node_or_null("Control/DefeatOverlay/CenterContainer/DefeatPanel/VBox/ButtonContainer/ReviveButton")
@onready var retry_button: Button = get_node_or_null("Control/DefeatOverlay/CenterContainer/DefeatPanel/VBox/ButtonContainer/RetryButton")
@onready var hangar_button: Button = get_node_or_null("Control/DefeatOverlay/CenterContainer/DefeatPanel/VBox/ButtonContainer/HangarButton")

# Pause Menu Overlay
@onready var pause_overlay: Control = get_node_or_null("Control/PauseOverlay")
@onready var resume_btn: Button = get_node_or_null("Control/PauseOverlay/Center/PausePanel/Margin/VBox/ResumeButton")
@onready var restart_btn: Button = get_node_or_null("Control/PauseOverlay/Center/PausePanel/Margin/VBox/RestartButton")
@onready var controls_btn: Button = get_node_or_null("Control/PauseOverlay/Center/PausePanel/Margin/VBox/ControlsButton")
@onready var hangar_abort_btn: Button = get_node_or_null("Control/PauseOverlay/Center/PausePanel/Margin/VBox/HangarAbortButton")
@onready var controls_modal: Control = get_node_or_null("Control/PauseOverlay/ControlsModal")
@onready var close_controls_btn: Button = get_node_or_null("Control/PauseOverlay/ControlsModal/Margin/VBox/CloseControlsBtn")

var _warning_pulse_time: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if gm.has_signal("score_updated"):
			gm.score_updated.connect(_on_score_updated)
		if gm.has_signal("combo_updated"):
			gm.combo_updated.connect(_on_combo_updated)
		if gm.has_signal("currency_updated"):
			gm.currency_updated.connect(_on_currency_updated)
		_on_score_updated(gm.score)
		_on_combo_updated(gm.combo)
		if gm.has_method("get_currency"):
			_on_currency_updated(gm.get_currency())
	
	_update_cores_display()
	_connect_player()
	
	# Connect to RoundManager if in scene
	var rm = get_tree().get_first_node_in_group("round_manager")
	if rm:
		_hook_round_manager(rm)
	
	# Connect defeat buttons
	if revive_button: revive_button.pressed.connect(_on_revive_pressed)
	if retry_button: retry_button.pressed.connect(_on_retry_pressed)
	if hangar_button: hangar_button.pressed.connect(_on_hangar_pressed)
	
	# Connect pause buttons
	if resume_btn: resume_btn.pressed.connect(_resume_game)
	if restart_btn: restart_btn.pressed.connect(_on_retry_pressed)
	if controls_btn: controls_btn.pressed.connect(func(): if controls_modal: controls_modal.visible = true)
	if close_controls_btn: close_controls_btn.pressed.connect(func(): if controls_modal: controls_modal.visible = false)
	if hangar_abort_btn: hangar_abort_btn.pressed.connect(_on_hangar_pressed)
	
	if defeat_overlay: defeat_overlay.visible = false
	if pause_overlay: pause_overlay.visible = false
	if boss_health_margin: boss_health_margin.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause()
			get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	if defeat_overlay and defeat_overlay.visible:
		return # Do not toggle pause if defeat screen is visible
		
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	if pause_overlay:
		pause_overlay.visible = is_paused
	if controls_modal:
		controls_modal.visible = false

func _resume_game() -> void:
	get_tree().paused = false
	if pause_overlay:
		pause_overlay.visible = false
	if controls_modal:
		controls_modal.visible = false

func _process(delta: float) -> void:
	if critical_warning and critical_warning.visible:
		_warning_pulse_time += delta * 6.0
		critical_warning.modulate.a = 0.3 + abs(sin(_warning_pulse_time)) * 0.7

func _connect_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.has_signal("health_changed") and not player.health_changed.is_connected(_on_health_changed):
			player.health_changed.connect(_on_health_changed)
		if player.has_signal("player_died") and not player.player_died.is_connected(_on_player_died):
			player.player_died.connect(_on_player_died)
		if "current_health" in player and "max_health" in player:
			_on_health_changed(player.current_health, player.max_health)

func _hook_round_manager(rm: Node) -> void:
	if rm.has_signal("round_started"):
		rm.round_started.connect(_on_round_started)
	if rm.has_signal("wave_started"):
		rm.wave_started.connect(_on_wave_started)
	if rm.has_signal("round_time_tick"):
		rm.round_time_tick.connect(_on_time_tick)
	if rm.has_signal("enemy_count_changed"):
		rm.enemy_count_changed.connect(_on_enemy_count_changed)
	if rm.has_signal("round_victory"):
		rm.round_victory.connect(_on_victory)
	if rm.has_signal("round_defeat"):
		rm.round_defeat.connect(_on_defeat)

func _on_score_updated(new_score: int) -> void:
	if score_label:
		score_label.text = "SCORE  %06d" % new_score

func _on_combo_updated(new_combo: int) -> void:
	if combo_label:
		combo_label.text = "COMBO  x%d" % new_combo
	
	if combo_badge:
		if new_combo > 1:
			var tween = create_tween()
			combo_badge.scale = Vector2(1.25, 1.25)
			combo_badge.modulate = Color(1.5, 0.4, 1.2, 1.0)
			tween.tween_property(combo_badge, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(combo_badge, "modulate", Color(1.0, 1.0, 1.0), 0.2)

func _on_currency_updated(new_balance: int) -> void:
	if currency_label:
		currency_label.text = "FRAGMENTS  %04d ◆" % new_balance

func _update_cores_display() -> void:
	if cores_label and SaveManager:
		var cores = SaveManager.get_reconstruction_cores()
		cores_label.text = "CORES  %d ⬡" % cores

func _on_health_changed(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	
	if health_label:
		health_label.text = "HULL INTEGRITY  %d / %d" % [current, maximum]
	
	var health_ratio: float = float(current) / float(maximum) if maximum > 0 else 0.0
	if critical_warning:
		critical_warning.visible = (health_ratio <= 0.25 and current > 0)

func show_boss_health(boss_name: String, max_hp: int) -> void:
	if boss_health_margin:
		boss_health_margin.visible = true
	if boss_title_label:
		boss_title_label.text = "FLAGSHIP: " + boss_name
	if boss_progress_bar:
		boss_progress_bar.max_value = max_hp
		boss_progress_bar.value = max_hp

func update_boss_health(current: int, maximum: int) -> void:
	if boss_health_margin and not boss_health_margin.visible:
		boss_health_margin.visible = true
	if boss_progress_bar:
		boss_progress_bar.max_value = maximum
		boss_progress_bar.value = current

func hide_boss_health() -> void:
	if boss_health_margin:
		boss_health_margin.visible = false

func _on_round_started(_idx: int, round_name: String, _time: float) -> void:
	show_banner(round_name, Color(0.2, 0.9, 1.0))
	if title_label:
		title_label.text = "VECTOR//BREAK — " + round_name

func _on_wave_started(wave_idx: int, total_waves: int) -> void:
	if status_label:
		status_label.text = "WAVE %d / %d" % [wave_idx, total_waves]

func _on_time_tick(time_val: float) -> void:
	var mins = int(time_val) / 60
	var secs = int(time_val) % 60
	if status_label:
		var current_text = status_label.text.split(" | ")[0]
		status_label.text = "%s | TIME: %02d:%02d" % [current_text, mins, secs]

func _on_enemy_count_changed(remaining: int, _total: int) -> void:
	if status_label:
		var parts = status_label.text.split(" | ")
		var wave_part = parts[0]
		var time_part = parts[1] if parts.size() > 1 else ""
		status_label.text = "%s | %s | HOSTILES: %d" % [wave_part, time_part, remaining]

func _on_victory(_round_idx: int, _score: int) -> void:
	show_banner("SECTOR SECURED — VICTORY", Color(0.3, 1.0, 0.5))
	hide_boss_health()

func _on_defeat(reason: String) -> void:
	show_banner("MISSION FAILED: " + reason, Color(1.0, 0.25, 0.2))

func show_banner(text: String, color: Color) -> void:
	if banner_label and center_banner:
		banner_label.text = text
		banner_label.modulate = color
		center_banner.visible = true
		center_banner.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(1.8)
		tween.tween_property(center_banner, "modulate:a", 0.0, 0.5)

# ==============================================================================
# DEFEAT & REVIVE FLOW
# ==============================================================================

func _on_player_died() -> void:
	# Clear hostile projectiles in transit to prevent cheap hits behind menu
	var enemy_projectiles = get_tree().get_nodes_in_group("enemy_projectiles")
	for p in enemy_projectiles:
		if is_instance_valid(p):
			p.queue_free()

	if defeat_overlay:
		defeat_overlay.visible = true
		
		# Check if revive option is available
		var gm = get_node_or_null("/root/GameManager")
		var can_rev = gm.can_revive() if (gm and gm.has_method("can_revive")) else false
		
		if revive_button:
			revive_button.visible = can_rev
			if can_rev and SaveManager:
				var cores = SaveManager.get_reconstruction_cores()
				if cores > 0:
					revive_button.text = "[ SECOND CHANCE: USE CORE (%d AVAILABLE) ]" % cores
				else:
					revive_button.text = "[ SECOND CHANCE: SYNTHESIZE (50 FRAGMENTS) ]"

func _on_revive_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("execute_revive"):
		if gm.execute_revive():
			if defeat_overlay:
				defeat_overlay.visible = false
			_update_cores_display()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_hangar_pressed() -> void:
	get_tree().paused = false
	if ResourceLoader.exists("res://scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif ResourceLoader.exists("res://scenes/hangar_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
	else:
		get_tree().reload_current_scene()
