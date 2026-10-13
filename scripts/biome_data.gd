class_name BiomeData
extends RefCounted

# ==============================================================================
# VECTOR//BREAK — BIOME SYSTEM CONFIGURATION & REGISTRY
# Defines all 5 distinct world biomes: Visual palettes, lore descriptions,
# unlock costs, hazards, spawn regions, and environment scene configurations.
# ==============================================================================

const BIOMES: Array[Dictionary] = [
	{
		"id": "neon_graveyard",
		"name": "NEON GRAVEYARD",
		"subtitle": "Derelict Orbital Relay // Sector 01",
		"description": "Dark navy space expanse drifting with station wreckage, dead satellites, and fractured solar arrays. Electric cyan and magenta conduit lines pulse faintly through the debris.",
		"unlock_cost": 0,
		"difficulty": "RECONNAISSANCE (NORMAL)",
		"scene_path": "res://scenes/biomes/biome_neon_graveyard.tscn",
		"hazard_type": "DRIFTING_DEBRIS",
		"hazard_name": "Zero-G Debris Field",
		"hazard_description": "Floating station fragments disrupt firing angles; bounce kinetic shots off angled reflectors.",
		"hazard_interval": 6.0,
		"colors": {
			"bg_dark": Color(0.02, 0.03, 0.07),
			"bg_mid": Color(0.05, 0.08, 0.18),
			"accent_cyan": Color(0.1, 0.85, 1.0),
			"accent_magenta": Color(1.0, 0.18, 0.8),
			"text": Color(0.85, 0.95, 1.0)
		},
		"spawn_regions": [Rect2(850, 120, 350, 480)],
		"reflector_preset": "standard_cross",
		"ambient_particles": "space_dust"
	},
	{
		"id": "desert_world",
		"name": "VESPER DESERT DOWNS",
		"subtitle": "Ochre Dune Sea // Outpost Dustfall",
		"description": "A scorching planetary expanse of ochre dunes, wind-carved sandstone mesas, and sand-buried solar collector towers. Thermal air currents and drifting dust particles sweep the arid plains.",
		"unlock_cost": 100,
		"difficulty": "TACTICAL (MODERATE)",
		"scene_path": "res://scenes/biomes/biome_desert_world.tscn",
		"hazard_type": "SANDSTORM_HEAT",
		"hazard_name": "Thermal Sandstorm Squall",
		"hazard_description": "Drifting sand squalls reduce visibility; utilize ruined outpost columns and sandstone mesas for cover.",
		"hazard_interval": 5.0,
		"colors": {
			"bg_dark": Color(0.14, 0.07, 0.03),
			"bg_mid": Color(0.25, 0.14, 0.06),
			"accent_cyan": Color(1.0, 0.7, 0.2), # Ochre/Gold primary
			"accent_magenta": Color(0.95, 0.35, 0.1), # Terracotta secondary
			"text": Color(1.0, 0.92, 0.8)
		},
		"spawn_regions": [Rect2(820, 140, 380, 440)],
		"reflector_preset": "dune_pass",
		"ambient_particles": "sand_dust"
	},
	{
		"id": "ocean_world",
		"name": "PELAGIC DEPTHS",
		"subtitle": "Submerged Research Biosphere // Abyss-7",
		"description": "Deep ocean trench illuminated by bioluminescent abyssal flora, rising bubble streams, and flooded laboratory domes. Buoyant current fluctuations bend projectile trajectories.",
		"unlock_cost": 200,
		"difficulty": "HAZARDOUS (HARD)",
		"scene_path": "res://scenes/biomes/biome_ocean_world.tscn",
		"hazard_type": "ABYSSAL_CURRENT",
		"hazard_name": "Hydrothermal Updraft",
		"hazard_description": "Rising bubble plumes exert upward drift; floating buoyant buoys serve as moving reflector surfaces.",
		"hazard_interval": 4.5,
		"colors": {
			"bg_dark": Color(0.01, 0.05, 0.11),
			"bg_mid": Color(0.02, 0.12, 0.22),
			"accent_cyan": Color(0.0, 0.9, 0.85), # Turquoise primary
			"accent_magenta": Color(0.25, 0.5, 0.95), # Deep Azure secondary
			"text": Color(0.8, 0.95, 1.0)
		},
		"spawn_regions": [Rect2(850, 100, 360, 520)],
		"reflector_preset": "buoyant_barricade",
		"ambient_particles": "bubbles"
	},
	{
		"id": "volcanic_world",
		"name": "PYROCLASTIC RIFT",
		"subtitle": "Obsidian Caldera // Foundry Sector 0",
		"description": "A tectonic hellscape of jagged basalt crags, glowing molten lava channels, and spewing geothermal vents. Thick sulfur smoke and rising glowing embers fill the superheated atmosphere.",
		"unlock_cost": 350,
		"difficulty": "SEVERE (VERY HARD)",
		"scene_path": "res://scenes/biomes/biome_volcanic_world.tscn",
		"hazard_type": "MAGMA_SURGE",
		"hazard_name": "Geothermal Magma Vents",
		"hazard_description": "Telegraphed volcanic vent flares erupt periodically from the floor, scorching unshielded hulls in the plume.",
		"hazard_interval": 4.0,
		"colors": {
			"bg_dark": Color(0.11, 0.02, 0.02),
			"bg_mid": Color(0.22, 0.04, 0.02),
			"accent_cyan": Color(1.0, 0.25, 0.08), # Molten Crimson primary
			"accent_magenta": Color(1.0, 0.75, 0.15), # Lava Gold secondary
			"text": Color(1.0, 0.88, 0.8)
		},
		"spawn_regions": [Rect2(850, 150, 350, 420)],
		"reflector_preset": "basalt_choke",
		"ambient_particles": "fire_embers"
	},
	{
		"id": "alien_forest",
		"name": "VIRIDIAN CANOPY",
		"subtitle": "Xenobiological Cradle // Sub-Sector Null",
		"description": "Massive alien tree canopy woven from bioluminescent fungal trunks, glowing spore pods, and overgrown laboratory conduits. Toxic spore emissions drift through the dark teal understory.",
		"unlock_cost": 500,
		"difficulty": "LETHAL (EXTREME)",
		"scene_path": "res://scenes/biomes/biome_alien_forest.tscn",
		"hazard_type": "SPORE_ERUPTION",
		"hazard_name": "Bioluminescent Spore Burst",
		"hazard_description": "Spore burst clusters release dense bioluminescent clouds that disrupt targeting reticles and hull shielding.",
		"hazard_interval": 3.5,
		"colors": {
			"bg_dark": Color(0.01, 0.07, 0.05),
			"bg_mid": Color(0.02, 0.14, 0.10),
			"accent_cyan": Color(0.15, 0.95, 0.55), # Emerald Green primary
			"accent_magenta": Color(0.05, 0.8, 0.75), # Viridian Teal secondary
			"text": Color(0.85, 1.0, 0.9)
		},
		"spawn_regions": [Rect2(820, 120, 380, 480)],
		"reflector_preset": "fungal_spire",
		"ambient_particles": "spores"
	}
]

static func get_all_biomes() -> Array[Dictionary]:
	return BIOMES

static func get_biome(biome_id: String) -> Dictionary:
	for b in BIOMES:
		if b["id"] == biome_id:
			return b
	return BIOMES[0] # Default to neon_graveyard fallback

static func get_biome_cost(biome_id: String) -> int:
	var b = get_biome(biome_id)
	return b.get("unlock_cost", 0)

static func is_valid_biome(biome_id: String) -> bool:
	for b in BIOMES:
		if b["id"] == biome_id:
			return true
	return false
