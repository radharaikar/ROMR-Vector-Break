class_name CinematicIntro
extends Control

# ==============================================================================
# VECTOR//BREAK — CINEMATIC GAME INTRO
# Atmospheric transmission sequence revealing the Vesper-9 catastrophe,
# prominent central title reveal, and seamless transition to the Main Menu.
# ==============================================================================

const SettingsManager = preload("res://scripts/settings_manager.gd")

@onready var transmission_panel: PanelContainer = $Margin/Center/TransmissionPanel
@onready var transmission_label: Label = $Margin/Center/TransmissionPanel/Margin/VBox/TransmissionLabel
@onready var title_container: VBoxContainer = $Margin/Center/TitleContainer
@onready var title_label: Label = $Margin/Center/TitleContainer/TitleLabel
@onready var subtitle_label: Label = $Margin/Center/TitleContainer/SubtitleLabel
@onready var tagline_label: Label = $Margin/Center/TitleContainer/TaglineLabel
@onready var prompt_label: Label = $Margin/Center/TitleContainer/PromptLabel
@onready var skip_btn: Button = $SkipMargin/SkipBtn

var _current_step: int = 0
var _elapsed: float = 0.0
var _can_advance: bool = false
var _stars: Array[Vector2] = []

func _ready() -> void:
	SettingsManager.load_settings()
	SaveManager.load_data()
	
	# Seed stars
	for i in range(140):
		_stars.append(Vector2(randf_range(0, 1280), randf_range(0, 720)))
		
	if skip_btn:
		skip_btn.pressed.connect(_finish_intro)
	
	transmission_panel.visible = true
	title_container.visible = false
	prompt_label.visible = false
	
	_play_sequence()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		_finish_intro()
	elif event is InputEventMouseButton and event.pressed:
		if _can_advance:
			_finish_intro()

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

func _draw() -> void:
	# Subtle drifting starfield
	for star in _stars:
		var pos = star
		pos.x = fmod(pos.x - _elapsed * 12.0, 1280.0)
		if pos.x < 0: pos.x += 1280.0
		var alpha = 0.4 + sin(_elapsed * 2.0 + star.y) * 0.3
		draw_circle(pos, 1.2, Color(0.7, 0.9, 1.0, alpha))
		
	# Subtle horizontal scanlines
	for y in range(0, 720, 8):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(0.0, 0.1, 0.2, 0.08), 1.0)

func _play_sequence() -> void:
	# Sequence Step 1: Incoming transmission header
	transmission_label.text = "[ ENCRYPTED AXIOM CARRIER FREQUENCY // SECTOR VESPER-9 ]\n\n...ESTABLISHING QUANTUM LINK..."
	await get_tree().create_timer(1.2).timeout
	if not is_inside_tree(): return
	
	# Sequence Step 2: Emergency transmission reveal
	transmission_label.text = "[ EMERGENCY BEACON: RESEARCH STATION VESPER-9 ]\n\n\"The disaster was not an accident.\nEvery trajectory was calculated.\nDo not let Lucien Vale seal the archives.\"\n\n— ORACLE TACTICAL AI"
	await get_tree().create_timer(2.6).timeout
	if not is_inside_tree(): return
	
	# Sequence Step 3: Fade out transmission & reveal prominent Title
	var tween = create_tween()
	tween.tween_property(transmission_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	if not is_inside_tree(): return
	
	transmission_panel.visible = false
	title_container.visible = true
	title_container.modulate.a = 0.0
	
	var title_tween = create_tween()
	title_tween.tween_property(title_container, "modulate:a", 1.0, 0.8)
	await title_tween.finished
	if not is_inside_tree(): return
	
	_can_advance = true
	prompt_label.visible = true
	
	# Auto proceed after 3 seconds
	await get_tree().create_timer(3.2).timeout
	if is_inside_tree():
		_finish_intro()

func _finish_intro() -> void:
	SaveManager.set_story_flag("saw_cinematic_intro", true)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
