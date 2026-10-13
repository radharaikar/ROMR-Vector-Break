class_name MainArena
extends Node2D

# ==============================================================================
# VECTOR//BREAK — MAIN COMBAT ARENA
# Manages scene initialization, active biome environment loading,
# and background orchestration.
# ==============================================================================

func _ready() -> void:
	_setup_active_biome()

func _setup_active_biome() -> void:
	var biome_id = SaveManager.get_selected_biome()
	if biome_id != "neon_graveyard":
		var info = BiomeData.get_biome(biome_id)
		var path = info.get("scene_path", "")
		if ResourceLoader.exists(path):
			var packed = load(path)
			if packed:
				var default_env = get_node_or_null("SpaceEnvironment")
				if default_env:
					default_env.visible = false
				var inst = packed.instantiate()
				inst.name = "ActiveBiomeEnvironment"
				add_child(inst)
				move_child(inst, 0)
