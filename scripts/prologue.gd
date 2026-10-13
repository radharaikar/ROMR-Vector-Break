class_name PrologueScene
extends Node2D

# ==============================================================================
# VECTOR//BREAK — PROLOGUE: THE FALL OF VESPER-9
# Playable tutorial and narrative inciting incident.
# Teaches movement, aiming, shooting, and vector ricochet mechanics.
# Shows the Vesper-9 disaster, Kael's guilt, and Mira's distress beacon.
# ==============================================================================

@onready var player: PlayerShip = $Player
@onready var objective_label: Label = $TutorialCanvas/ObjectivePanel/Margin/VBox/ObjectiveLabel
@onready var sub_label: Label = $TutorialCanvas/ObjectivePanel/Margin/VBox/SubLabel
@onready var transmission_panel: PanelContainer = $TutorialCanvas/TransmissionPanel
@onready var speaker_label: Label = $TutorialCanvas/TransmissionPanel/Margin/VBox/SpeakerLabel
@onready var message_label: Label = $TutorialCanvas/TransmissionPanel/Margin/VBox/MessageLabel
@onready var cutscene_overlay: Control = $CutsceneCanvas/Overlay
@onready var cutscene_text: Label = $CutsceneCanvas/Overlay/Center/VBox/CutsceneText
@onready var proceed_button: Button = $CutsceneCanvas/Overlay/Center/VBox/ProceedButton
@onready var hangar_button: Button = $CutsceneCanvas/Overlay/Center/VBox/HangarButton
@onready var flash_rect: ColorRect = $CutsceneCanvas/FlashRect

enum Step { INTRO, MOVEMENT, SHOOTING, RICOCHET, DISASTER, OUTRO }
var current_step: Step = Step.INTRO

var _player_initial_pos: Vector2 = Vector2.ZERO
var _target_dummy: Node = null
var _ricochet_target: Node = null
var _alarm_active: bool = false
var _alarm_timer: float = 0.0

func _ready() -> void:
	if cutscene_overlay: cutscene_overlay.visible = false
	if flash_rect: flash_rect.modulate.a = 0.0
	if transmission_panel: transmission_panel.visible = false
	
	if proceed_button: proceed_button.pressed.connect(_on_proceed_pressed)
	if hangar_button: hangar_button.pressed.connect(_on_hangar_pressed)
	
	if player:
		_player_initial_pos = player.global_position
	
	# Start prologue dialogue
	_show_transmission(
		"AXIOM TACTICAL NETWORK // VESPER-9",
		Color(1.0, 0.75, 0.2),
		"PILOT KAEL VEYR: Colony defense relays have failed safe-state parameters. Initiate perimeter suppression.",
		func(): _start_movement_tutorial()
	)

func _process(delta: float) -> void:
	if _alarm_active and flash_rect:
		_alarm_timer += delta * 5.0
		flash_rect.modulate = Color(1.0, 0.05, 0.1, 0.25 * (sin(_alarm_timer) * 0.5 + 0.5))

func _start_movement_tutorial() -> void:
	current_step = Step.MOVEMENT
	_set_objective("OBJECTIVE 1: CALIBRATE THRUSTER VECTORS", "Engage thrusters using [W, A, S, D] or [Arrow Keys].")
	
	# Monitor player movement
	var check_timer = get_tree().create_timer(0.2)
	check_timer.timeout.connect(_check_movement)

func _check_movement() -> void:
	if current_step != Step.MOVEMENT:
		return
	if player and player.global_position.distance_to(_player_initial_pos) > 80.0:
		_start_shooting_tutorial()
	else:
		get_tree().create_timer(0.2).timeout.connect(_check_movement)

func _start_shooting_tutorial() -> void:
	current_step = Step.SHOOTING
	_set_objective("OBJECTIVE 2: WEAPONS SYSTEM CHECK", "Aim with [MOUSE] and fire using [LEFT CLICK] or [SPACE].")
	
	# Spawn a static target drone
	var drone_scene = load("res://scenes/geometric_drone.tscn")
	if drone_scene:
		_target_dummy = drone_scene.instantiate()
		_target_dummy.global_position = Vector2(900, 360)
		_target_dummy.tree_exited.connect(_on_dummy_destroyed)
		add_child(_target_dummy)

func _on_dummy_destroyed() -> void:
	if current_step == Step.SHOOTING:
		_start_ricochet_tutorial()

func _start_ricochet_tutorial() -> void:
	current_step = Step.RICOCHET
	_set_objective(
		"OBJECTIVE 3: VECTOR RICOCHET PROTOCOL",
		"Target shield active! Bounce laser off the [45° REFLECTOR] to hit its unshielded flank."
	)
	
	# Spawn 45 degree reflector
	var refl_scene = load("res://scenes/reflector_45.tscn")
	if refl_scene:
		var refl = refl_scene.instantiate()
		refl.global_position = Vector2(620, 240)
		add_child(refl)
	
	# Spawn Heavy shielded enemy
	var heavy_scene = load("res://scenes/enemy_heavy.tscn")
	if heavy_scene:
		_ricochet_target = heavy_scene.instantiate()
		_ricochet_target.global_position = Vector2(620, 480)
		_ricochet_target.tree_exited.connect(_on_ricochet_target_destroyed)
		add_child(_ricochet_target)

func _on_ricochet_target_destroyed() -> void:
	if current_step == Step.RICOCHET:
		_trigger_cataclysm()

func _trigger_cataclysm() -> void:
	current_step = Step.DISASTER
	_set_objective("EMERGENCY: SYSTEM IRREGULARITY", "CRITICAL ANOMALY IN CORE VECTOR MATRIX!")
	_alarm_active = true
	
	# Disable player firing during cutscene
	if player:
		player.can_fire = false
	
	_show_transmission(
		"DIRECTOR LUCIEN VALE // AXIOM HIGH COMMAND",
		Color(1.0, 0.25, 0.35),
		"Flight Leader Veyr, vector overload initiated. Detonate the colony reactor core now.",
		func():
			_show_transmission(
				"MIRA VEYR [EMERGENCY FREQUENCY]",
				Color(0.2, 0.9, 1.0),
				"Kael! Stop! There are civilian shuttles still inside the docking ring! Vale locked the evacuation seals—Kael, you promised me you would never let them use it—",
				func(): _detonate_reactor()
			)
	)

func _detonate_reactor() -> void:
	_alarm_active = false
	if flash_rect:
		var tween = create_tween()
		flash_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		tween.tween_interval(1.0)
		tween.tween_property(flash_rect, "modulate:a", 1.0, 0.1)
		tween.tween_callback(_show_time_jump)

func _show_time_jump() -> void:
	if transmission_panel: transmission_panel.visible = false
	if cutscene_overlay:
		cutscene_overlay.visible = true
		cutscene_text.text = """[ THREE YEARS LATER ]

OUTER RELAY SECTOR // 0.4 AU FROM VESPER-9 DEBRIS FIELD

DECRYPTED INCOMING TRANSMISSION:

"Kael... if you're hearing this, I'm still alive.
Don't come for me because you think I can forgive you.
Come because AXIOM is going to do it again.
The Vector Engine needs a living stabilizer... and they've hooked me into the core.
Every trajectory has a cost."
— Mira Veyr

========================================
VECTOR//BREAK — THE LAST TRAJECTORY
========================================"""

func _set_objective(title: String, subtitle: String) -> void:
	if objective_label: objective_label.text = title
	if sub_label: sub_label.text = subtitle

func _show_transmission(speaker: String, col: Color, msg: String, on_complete: Callable) -> void:
	if not transmission_panel:
		on_complete.call()
		return
	
	speaker_label.text = speaker
	speaker_label.modulate = col
	message_label.text = msg
	transmission_panel.visible = true
	
	var timer = get_tree().create_timer(3.5)
	timer.timeout.connect(func():
		transmission_panel.visible = false
		on_complete.call()
	)

func _on_proceed_pressed() -> void:
	SaveManager.set_story_flag("completed_prologue", true)
	SaveManager.save_data()
	get_tree().change_scene_to_file("res://scenes/act1_mission.tscn")

func _on_hangar_pressed() -> void:
	SaveManager.set_story_flag("completed_prologue", true)
	SaveManager.save_data()
	get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
