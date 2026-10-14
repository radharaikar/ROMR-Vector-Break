class_name CustomCursor
extends Node2D

# ==============================================================================
# VECTOR//BREAK — TACTICAL COMBAT RETICLE
# Displays a central targeting dot and four corner brackets.
# Color states:
#   - Cyan / White: Normal tracking
#   - Magenta: Hovering over an active enemy
#   - Bright White / Gold: Firing flash pulse
# ==============================================================================

@export var bracket_distance: float = 14.0
@export var bracket_arm_length: float = 6.0
@export var bracket_thickness: float = 1.5

var is_hovering_enemy: bool = false
var _flash_timer: float = 0.0

const COLOR_NORMAL: Color = Color(0.2, 0.9, 1.0, 0.95)
const COLOR_CORE: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_ENEMY_HOVER: Color = Color(1.0, 0.15, 0.8, 1.0)
const COLOR_FLASH: Color = Color(2.5, 2.2, 1.2, 1.0)

func _ready() -> void:
	z_index = 100 # Always render above world and gameplay elements
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Hook into player fire event if player exists
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_fired"):
		player.player_fired.connect(trigger_fire_flash)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if _flash_timer > 0.0:
		_flash_timer -= delta
	
	# Check proximity to any active enemy in the arena
	is_hovering_enemy = false
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			if "is_dead" in enemy and enemy.is_dead:
				continue
			if enemy.global_position.distance_to(global_position) <= 38.0:
				is_hovering_enemy = true
				break
	
	queue_redraw()

func trigger_fire_flash(_projectile: Node = null) -> void:
	_flash_timer = 0.10

func _draw() -> void:
	var active_color: Color = COLOR_NORMAL
	var dot_color: Color = COLOR_CORE
	
	if _flash_timer > 0.0:
		active_color = COLOR_FLASH
		dot_color = COLOR_FLASH
	elif is_hovering_enemy:
		active_color = COLOR_ENEMY_HOVER
		dot_color = COLOR_CORE
	
	# 1. Central targeting dot
	draw_circle(Vector2.ZERO, 2.5, dot_color)
	
	# 2. Four corner brackets
	var d = bracket_distance
	var arm = bracket_arm_length
	var w = bracket_thickness
	
	# Top-Left Bracket
	draw_line(Vector2(-d, -d + arm), Vector2(-d, -d), active_color, w)
	draw_line(Vector2(-d, -d), Vector2(-d + arm, -d), active_color, w)
	
	# Top-Right Bracket
	draw_line(Vector2(d, -d + arm), Vector2(d, -d), active_color, w)
	draw_line(Vector2(d, -d), Vector2(d - arm, -d), active_color, w)
	
	# Bottom-Left Bracket
	draw_line(Vector2(-d, d - arm), Vector2(-d, d), active_color, w)
	draw_line(Vector2(-d, d), Vector2(-d + arm, d), active_color, w)
	
	# Bottom-Right Bracket
	draw_line(Vector2(d, d - arm), Vector2(d, d), active_color, w)
	draw_line(Vector2(d, d), Vector2(d - arm, d), active_color, w)
