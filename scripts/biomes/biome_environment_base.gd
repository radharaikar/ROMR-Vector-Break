class_name BiomeEnvironmentBase
extends Node2D

# ==============================================================================
# VECTOR//BREAK — BIOME ENVIRONMENT BASE CLASS
# Base class for all 5 world environments. Provides shared arena bounds,
# ambient particle manager, hazard coordination, and reflector anchoring.
# ==============================================================================

@export var biome_id: String = "neon_graveyard"
@export var hazard_active: bool = true

var biome_info: Dictionary = {}
var hazard_timer: float = 0.0
var hazard_interval: float = 5.0
var hazard_warning_active: bool = false

# Boundary references
var top_boundary: StaticBody2D
var bottom_boundary: StaticBody2D

func _ready() -> void:
	z_index = -10
	biome_info = BiomeData.get_biome(biome_id)
	hazard_interval = biome_info.get("hazard_interval", 5.0)
	hazard_timer = hazard_interval
	
	_create_arena_boundaries()
	_setup_ambient_particles()

func _create_arena_boundaries() -> void:
	# Ensure standard arena boundaries (ceiling at y=48, floor at y=672)
	var borders = StaticBody2D.new()
	borders.name = "BiomeArenaBorders"
	borders.collision_layer = 4
	borders.collision_mask = 3
	
	# Top boundary
	var top_shape = CollisionShape2D.new()
	var top_bound = WorldBoundaryShape2D.new()
	top_bound.normal = Vector2(0, 1)
	top_shape.shape = top_bound
	top_shape.position = Vector2(640, 48)
	borders.add_child(top_shape)
	
	# Bottom boundary
	var bot_shape = CollisionShape2D.new()
	var bot_bound = WorldBoundaryShape2D.new()
	bot_bound.normal = Vector2(0, -1)
	bot_shape.shape = bot_bound
	bot_shape.position = Vector2(640, 672)
	borders.add_child(bot_shape)
	
	add_child(borders)

func _process(delta: float) -> void:
	if not hazard_active:
		return
	
	hazard_timer -= delta
	if hazard_timer <= 1.5 and not hazard_warning_active:
		hazard_warning_active = true
		_on_hazard_warning()
	
	if hazard_timer <= 0.0:
		hazard_timer = hazard_interval
		hazard_warning_active = false
		_on_hazard_trigger()

func _setup_ambient_particles() -> void:
	# Overridden in concrete biome classes
	pass

func _on_hazard_warning() -> void:
	# Overridden in concrete biome classes to telegraph hazard (warning flashes, SFX, indicators)
	pass

func _on_hazard_trigger() -> void:
	# Overridden in concrete biome classes to execute hazard surge
	pass

func get_spawn_regions() -> Array[Rect2]:
	var regions = biome_info.get("spawn_regions", [])
	var res: Array[Rect2] = []
	for r in regions:
		if r is Rect2:
			res.append(r)
	if res.is_empty():
		res.append(Rect2(850, 120, 350, 480))
	return res
