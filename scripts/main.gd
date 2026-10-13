class_name MainArena
extends Node2D

# ==============================================================================
# VECTOR//BREAK — MAIN COMBAT ARENA
# Manages scene initialization, dynamic biome loading, and environmental switching.
# ==============================================================================

func _ready() -> void:
	_setup_active_biome()

func _setup_active_biome() -> void:
	var biome_id = SaveManager.get_selected_biome()
	var info = BiomeData.get_biome(biome_id)
	var path = info.get("scene_path", "")
	
	if ResourceLoader.exists(path):
		var packed = load(path)
		if packed:
			# Hide fallback SpaceEnvironment
			var default_env = get_node_or_null("SpaceEnvironment")
			if default_env:
				default_env.visible = false
			
			var inst = packed.instantiate()
			inst.name = "ActiveBiomeEnvironment"
			add_child(inst)
			move_child(inst, 0)
			
			if biome_id != "neon_graveyard":
				# Hide default main scene reflectors so biome's unique reflectors are cleanly showcased
				_toggle_default_reflectors(false)
			else:
				# For neon_graveyard, use Main's own reflectors; avoid duplicate instances
				for refl in ["ReflectorUpper", "ReflectorLower", "ReflectorCenter"]:
					var r_node = inst.get_node_or_null(refl)
					if r_node:
						r_node.queue_free()

func _toggle_default_reflectors(enable: bool) -> void:
	for node_name in ["ReflectiveSurfaceLower", "ReflectiveSurfaceUpper", "Reflector45"]:
		var node = get_node_or_null(node_name)
		if node:
			node.visible = enable
			if node is CollisionObject2D:
				for child in node.get_children():
					if child is CollisionShape2D:
						child.set_deferred("disabled", not enable)
