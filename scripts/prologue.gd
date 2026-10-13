class_name PrologueScene
extends Node2D

# ==============================================================================
# VECTOR//BREAK — PROLOGUE: THE VESPER-9 TRAGEDY
# Playable prologue introducing flight controls, ricochet combat,
# the tragic Vesper-9 reactor collapse, and the present-day distress beacon.
# ==============================================================================

@onready var player: PlayerShip = $Player
@onready var dialogue: StoryDialogue = $StoryDialogue
@onready var objective_label: Label = $TutorialHUD/Margin/Panel/VBox/ObjectiveLabel
@onready var whiteout_rect: ColorRect = $WhiteoutCanvas/WhiteoutRect
@onready var title_card: Control = $TitleCanvas/TitleCard
@onready var targets_container: Node2D = $Targets

var targets_destroyed: int = 0
var total_targets: int = 2
var tutorial_step: int = 0
var is_reactor_collapsing: bool = false

func _ready() -> void:
	if whiteout_rect:
		whiteout_rect.modulate.a = 0.0
	if title_card:
		title_card.visible = false
	
	_update_objective("COMMENCING PRE-FLIGHT CHECK... WAITING FOR TRANSMISSION.")
	
	# Initial command dialogue
	get_tree().create_timer(0.4).timeout.connect(func():
		if dialogue:
			dialogue.play_sequence("prologue_intro", _on_intro_completed)
	)

func _on_intro_completed() -> void:
	tutorial_step = 1
	_update_objective("STEP 1: Maneuver with [W][A][S][D]. Aim with [MOUSE]. Shoot reflectors with [CLICK] / [SPACE]!")
	
	# Connect targets
	for child in targets_container.get_children():
		if child.has_signal("destroyed"):
			child.destroyed.connect(_on_target_destroyed)

func _on_target_destroyed(_score_val: int, _pos: Vector2) -> void:
	targets_destroyed += 1
	if targets_destroyed >= total_targets and not is_reactor_collapsing:
		is_reactor_collapsing = true
		_trigger_vesper_disaster()

func _update_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text

func _trigger_vesper_disaster() -> void:
	_update_objective("[ ! CRITICAL RECOIL WARNING ! ]")
	
	# Mira's frantic warning transmission
	if dialogue:
		dialogue.play_sequence("prologue_mira_plea", func():
			# Trigger reactor whiteout sequence
			_execute_whiteout_sequence()
		)

func _execute_whiteout_sequence() -> void:
	# Flash red and whiteout
	var tween = create_tween()
	tween.tween_property(whiteout_rect, "modulate:a", 1.0, 1.2)
	tween.tween_callback(func():
		# Play disaster dialogue during whiteout
		if dialogue:
			dialogue.play_sequence("prologue_disaster", func():
				# Fade to deep space black
				whiteout_rect.color = Color(0.01, 0.015, 0.04, 1.0)
				_trigger_present_day_beacon()
			)
	)

func _trigger_present_day_beacon() -> void:
	# Present day distress beacon transmission
	if dialogue:
		dialogue.play_sequence("prologue_beacon", func():
			_show_title_card()
		)

func _show_title_card() -> void:
	if title_card:
		title_card.visible = true
		title_card.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(title_card, "modulate:a", 1.0, 1.0)
		tween.tween_interval(2.5)
		tween.tween_callback(func():
			# Mark prologue complete and transition to Act 1
			SaveManager.set_story_flag("saw_prologue", true)
			SaveManager.save_data()
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		)
