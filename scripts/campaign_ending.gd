class_name CampaignEnding
extends Control

# ==============================================================================
# VECTOR//BREAK — CAMPAIGN ENDING & CLIMAX PRESENTATION
# Displays the emotional narrative climax: Kael's sacrifice to save Mira,
# final decrypted transmission archive, complete campaign statistics, and menu actions.
# ==============================================================================

@onready var dialogue: StoryDialogue = $StoryDialogue
@onready var ending_panel: Control = $EndingOverlay
@onready var title_label: Label = $EndingOverlay/Center/Panel/Margin/VBox/TitleLabel
@onready var epilogue_label: Label = $EndingOverlay/Center/Panel/Margin/VBox/EpilogueLabel
@onready var stats_label: Label = $EndingOverlay/Center/Panel/Margin/VBox/StatsLabel
@onready var hangar_btn: Button = $EndingOverlay/Center/Panel/Margin/VBox/ButtonHBox/HangarButton
@onready var menu_btn: Button = $EndingOverlay/Center/Panel/Margin/VBox/ButtonHBox/MenuButton

var _time_elapsed: float = 0.0

func _ready() -> void:
	if ending_panel:
		ending_panel.visible = false
	
	if hangar_btn:
		hangar_btn.pressed.connect(_on_hangar_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
	
	# Mark campaign fully completed in SaveManager
	if SaveManager:
		var data = SaveManager.get_data()
		data["campaign_act"] = 5
		data["campaign_completed"] = true
		SaveManager.save_data()
	
	# Trigger the final narrative sequence
	get_tree().create_timer(0.5).timeout.connect(func():
		_play_final_dialogue()
	)

func _process(delta: float) -> void:
	_time_elapsed += delta
	queue_redraw()

func _draw() -> void:
	# Subtle drifting stardust & deep blue cosmic background
	for i in range(50):
		var x = fmod(i * 27.0 + _time_elapsed * 10.0, 1280.0)
		var y = fmod(i * 43.0, 720.0)
		draw_circle(Vector2(x, y), 1.2, Color(0.7, 0.85, 1.0, 0.4))
	
	# Atmospheric horizon energy line
	draw_line(Vector2(0, 680), Vector2(1280, 680), Color(0.2, 0.9, 1.0, 0.5), 1.5)

func _play_final_dialogue() -> void:
	if not dialogue:
		_show_epilogue()
		return
	
	var ending_script = [
		{
			"speaker": "ORACLE TACTICAL AI",
			"color": Color(1.0, 0.25, 0.4),
			"text": "CRITICAL ANOMALY: PREDICTION MATRIX COMPROMISED. RECOIL CONDUIT BREACHED AT 104% STRESS. TRAJECTORY DETERMINISM TERMINATED."
		},
		{
			"speaker": "MIRA VEYR [EMERGENCY FREQUENCY]",
			"color": Color(0.2, 0.95, 1.0),
			"text": "Kael! The core is destabilizing! The containment pod release is jammed—you have to disengage and jump now!"
		},
		{
			"speaker": "KAEL VEYR",
			"color": Color(0.3, 0.8, 1.0),
			"text": "I'm not jumping without you, Mira. I spent three years running from the ghosts of Vesper-9. My trajectory ends here."
		},
		{
			"speaker": "MIRA VEYR",
			"color": Color(0.2, 0.95, 1.0),
			"text": "Kael, no! If you manually trigger the reverse thruster inside the focal chamber, the kinetic feedback will destroy your ship!"
		},
		{
			"speaker": "KAEL VEYR",
			"color": Color(0.3, 0.8, 1.0),
			"text": "Every trajectory has a cost, Mira. This one is mine. Pod ejection sequence confirmed. Tell them the stars are clear."
		},
		{
			"speaker": "AUTOMATED FLIGHT RECORDER // FINAL ENTRY",
			"color": Color(1.0, 0.75, 0.2),
			"text": "POD JETTISON COMPLETE. VECTOR ENGINE CORE SHATTERED. PILOT KAEL VEYR — DISPERSED INTO THE SIGNAL."
		}
	]
	
	dialogue.play_sequence(ending_script, func():
		_show_epilogue()
	)

func _show_epilogue() -> void:
	if ending_panel:
		ending_panel.visible = true
	
	if epilogue_label:
		epilogue_label.text = """[ ARCHIVE RECOVERY // DECLASSIFIED AXIOM DOSSIER ]

Three days after the collapse of the Vector Engine, an independent salvage cutter intercepted an escape capsule in deep orbit around Vesper-9.

Mira Veyr survived.

The AXIOM deterministic control network has shattered. Without the living stabilizer, the Vector Conduit dissolved into harmless cosmic radiation, liberating the outer colonies from calculated servitude.

In the flight archives of Outpost 44, only one flight trajectory remains permanently logged: a single energy bolt, ricocheted through impossible geometry, choosing love over probability."""

	if stats_label and SaveManager:
		var score = SaveManager.get_data().get("stats", {}).get("total_score", 0)
		var fragments = SaveManager.get_currency()
		stats_label.text = "CAMPAIGN SCORE: %06d  |  RECOVERED FRAGMENTS: %d ◆  |  PILOT RANK: LEGEND OF VESPER" % [score, fragments]
	
	if hangar_btn:
		hangar_btn.grab_focus()

func _on_hangar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")

func _on_menu_pressed() -> void:
	if ResourceLoader.exists("res://scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hangar_menu.tscn")
