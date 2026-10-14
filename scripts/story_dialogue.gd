class_name StoryDialogue
extends CanvasLayer

# ==============================================================================
# VECTOR//BREAK — STORY DIALOGUE & TRANSMISSION OVERLAY
# Displays dynamic character transmissions with procedural avatars, speaker headers,
# typewriter effect, strict ENTER navigation, SPACEBAR isolation, and gameplay pausing.
# ==============================================================================

signal dialogue_finished()

@onready var container: Control = $Control
@onready var avatar: Control = get_node_or_null("Control/MarginContainer/Panel/MainHBox/CharacterAvatar")
@onready var speaker_label: Label = get_node_or_null("Control/MarginContainer/Panel/MainHBox/VBox/SpeakerLabel")
@onready var message_label: Label = get_node_or_null("Control/MarginContainer/Panel/MainHBox/VBox/MessageLabel")
@onready var next_button: Button = get_node_or_null("Control/MarginContainer/Panel/MainHBox/VBox/BottomRow/NextButton")
@onready var skip_button: Button = get_node_or_null("Control/MarginContainer/Panel/MainHBox/VBox/BottomRow/SkipButton")

var _dialogue_lines: Array = []
var _current_index: int = 0
var _is_typing: bool = false
var _type_tween: Tween = null
var _completion_callback: Callable = Callable()
var _is_active: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func _exit_tree() -> void:
	if _is_active and get_tree():
		get_tree().paused = false

func _input(event: InputEvent) -> void:
	if not visible or not _is_active:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		# ENTER advances or finishes line
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_next_pressed()
			get_viewport().set_input_as_handled()
			return
		
		# SPACEBAR is explicitly consumed to isolate input and prevent accidental firing or dialogue skip
		if event.keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			return
		
		# ESC must NOT skip storyline dialogue (preserved for pause menu only)
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			return

func play_sequence(sequence: Variant, callback: Callable = Callable()) -> void:
	_completion_callback = callback
	if typeof(sequence) == TYPE_STRING:
		_dialogue_lines = StoryData.get_dialogue(sequence)
	elif typeof(sequence) == TYPE_ARRAY:
		_dialogue_lines = sequence
	else:
		_dialogue_lines = []
	
	if _dialogue_lines.is_empty():
		_finish_sequence()
		return
	
	_is_active = true
	_current_index = 0
	visible = true
	
	# Pause active gameplay simulation while dialogue is displayed
	get_tree().paused = true
	
	_show_line(_current_index)

func _show_line(index: int) -> void:
	if index >= _dialogue_lines.size():
		_finish_sequence()
		return
	
	var line_data = _dialogue_lines[index]
	var speaker = line_data.get("speaker", "TRANSMISSION")
	var col = line_data.get("color", Color(0.3, 0.9, 1.0))
	var full_text = line_data.get("text", "")
	
	# Distinct styling for ORACLE AI vs Human pilots
	if "ORACLE" in speaker.to_upper():
		col = Color(1.0, 0.25, 0.4)
		if speaker_label:
			speaker_label.text = "◆ [ AI NETWORK // %s ] ◆" % speaker
	else:
		if speaker_label:
			speaker_label.text = "[ %s ]" % speaker
			
	if speaker_label:
		speaker_label.modulate = col
	
	if avatar and avatar.has_method("set_speaker"):
		avatar.set_speaker(speaker, col)
	
	if message_label:
		message_label.text = full_text
		message_label.visible_characters = 0
		_is_typing = true
		
		if _type_tween and _type_tween.is_valid():
			_type_tween.kill()
		
		_type_tween = create_tween()
		var duration = max(0.35, float(full_text.length()) * 0.018)
		_type_tween.tween_property(message_label, "visible_ratio", 1.0, duration)
		_type_tween.tween_callback(func(): _is_typing = false)

func _on_next_pressed() -> void:
	if _is_typing:
		# Immediately finish typing current line
		if _type_tween and _type_tween.is_valid():
			_type_tween.kill()
		if message_label:
			message_label.visible_ratio = 1.0
		_is_typing = false
	else:
		# Advance to next line
		_current_index += 1
		_show_line(_current_index)

func _on_skip_pressed() -> void:
	_finish_sequence()

func _finish_sequence() -> void:
	if _type_tween and _type_tween.is_valid():
		_type_tween.kill()
	visible = false
	_is_active = false
	
	# Resume gameplay simulation
	if get_tree():
		get_tree().paused = false
		
	emit_signal("dialogue_finished")
	if _completion_callback.is_valid():
		var cb = _completion_callback
		_completion_callback = Callable()
		cb.call()

func is_active() -> bool:
	return _is_active

func get_current_line_index() -> int:
	return _current_index
