class_name StoryDialogue
extends CanvasLayer

# ==============================================================================
# VECTOR//BREAK — STORY DIALOGUE & TRANSMISSION OVERLAY
# Displays dynamic character transmissions with speaker headers, custom colors,
# typewriter effect, and instant skip support.
# ==============================================================================

signal dialogue_finished()

@onready var container: Control = $Control
@onready var speaker_label: Label = $Control/MarginContainer/Panel/VBox/SpeakerLabel
@onready var message_label: Label = $Control/MarginContainer/Panel/VBox/MessageLabel
@onready var next_button: Button = $Control/MarginContainer/Panel/VBox/BottomRow/NextButton
@onready var skip_button: Button = $Control/MarginContainer/Panel/VBox/BottomRow/SkipButton

var _dialogue_lines: Array = []
var _current_index: int = 0
var _is_typing: bool = false
var _type_tween: Tween = null
var _completion_callback: Callable = Callable()

func _ready() -> void:
	visible = false
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		_on_next_pressed()
		get_viewport().set_input_as_handled()

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
	
	_current_index = 0
	visible = true
	_show_line(_current_index)

func _show_line(index: int) -> void:
	if index >= _dialogue_lines.size():
		_finish_sequence()
		return
	
	var line_data = _dialogue_lines[index]
	var speaker = line_data.get("speaker", "TRANSMISSION")
	var col = line_data.get("color", Color(0.3, 0.9, 1.0))
	var full_text = line_data.get("text", "")
	
	if speaker_label:
		speaker_label.text = "[ %s ]" % speaker
		speaker_label.modulate = col
	
	if message_label:
		message_label.text = full_text
		message_label.visible_characters = 0
		_is_typing = true
		
		if _type_tween and _type_tween.is_valid():
			_type_tween.kill()
		
		_type_tween = create_tween()
		var duration = max(0.4, float(full_text.length()) * 0.02)
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
	emit_signal("dialogue_finished")
	if _completion_callback.is_valid():
		_completion_callback.call()
		_completion_callback = Callable()
