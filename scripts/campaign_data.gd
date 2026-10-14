class_name CampaignData
extends RefCounted

## Campaign progression data for VECTOR//BREAK — THE LAST TRAJECTORY.
## Exposes structured level definitions, narrative briefings, and wave compositions.

static func get_round_definitions() -> Array[Dictionary]:
	return [
		{
			"id": "1-1",
			"name": "ROUND 1: RECON PATROL",
			"act": "ACT I: GHOSTS IN THE SIGNAL",
			"briefing": "Kael, we are detecting automated security drones outside the derelict communications relay. Sweep the perimeter and establish tactical superiority.",
			"time_limit": 60.0,
			"waves": [
				[
					{"type": "drone", "pos": Vector2(1320, 260)},
					{"type": "drone", "pos": Vector2(1320, 460)}
				],
				[
					{"type": "drone", "pos": Vector2(1320, 200)},
					{"type": "chaser", "pos": Vector2(1320, 360)},
					{"type": "drone", "pos": Vector2(1320, 520)}
				]
			]
		},
		{
			"id": "1-2",
			"name": "ROUND 2: INFILTRATION VECTOR",
			"act": "ACT I: GHOSTS IN THE SIGNAL",
			"briefing": "Security grid escalated. Artillery Strikers are locking our coordinates while Dashers guard the corridor. Use angles and the moving reflectors to break their lock!",
			"time_limit": 75.0,
			"waves": [
				[
					{"type": "striker", "pos": Vector2(1320, 240)},
					{"type": "dasher", "pos": Vector2(1320, 480)}
				],
				[
					{"type": "striker", "pos": Vector2(1320, 220)},
					{"type": "dasher", "pos": Vector2(1320, 360)},
					{"type": "chaser", "pos": Vector2(1320, 500)}
				]
			]
		},
		{
			"id": "1-3",
			"name": "ROUND 3: ARMORED BULWARK",
			"act": "ACT I: GHOSTS IN THE SIGNAL",
			"briefing": "AXIOM Heavy constructs detected. Frontal shields absorb direct kinetic impacts. You MUST bounce your energy bolts off the environment to strike their unshielded rear!",
			"time_limit": 80.0,
			"waves": [
				[
					{"type": "heavy", "pos": Vector2(1320, 360)},
					{"type": "chaser", "pos": Vector2(1320, 220)}
				],
				[
					{"type": "elite", "pos": Vector2(1320, 360)},
					{"type": "heavy", "pos": Vector2(1320, 220)},
					{"type": "striker", "pos": Vector2(1320, 500)}
				]
			]
		},
		{
			"id": "1-4",
			"name": "ROUND 4: THE GATEKEEPER",
			"act": "ACT I: GHOSTS IN THE SIGNAL",
			"briefing": "Flagship signature detected: Commander Serin. 'Kael, turn back. Certain trajectories cannot be undone.' Neutralize the flagship!",
			"time_limit": 110.0,
			"waves": [
				[
					{"type": "boss_serin", "pos": Vector2(1050, 360)}
				]
			]
		}
	]

static func get_biome_definitions() -> Array[Dictionary]:
	return [
		{
			"id": "neon_graveyard",
			"name": "NEON GRAVEYARD",
			"subtitle": "OUTPOST 44 SECTOR",
			"description": "Derelict communications hub surrounded by vector-polarized mirror debris and deep indigo vacuum.",
			"free": true,
			"cost": 0,
			"bg_color": Color(0.02, 0.03, 0.08, 1.0),
			"accent_color": Color(0.1, 0.9, 1.0, 1.0)
		},
		{
			"id": "vesper_desert",
			"name": "VESPER DESERT DOWNS",
			"subtitle": "VESPER-9 WASTES",
			"description": "Arid planetary fallout expanse with electromagnetic dust storms and oxidized titanium wreckage.",
			"free": true,
			"cost": 0,
			"bg_color": Color(0.06, 0.04, 0.02, 1.0),
			"accent_color": Color(1.0, 0.75, 0.2, 1.0)
		},
		{
			"id": "pelagic_depths",
			"name": "PELAGIC DEPTHS",
			"subtitle": "HYDRO-PRESSURE TRENCH",
			"description": "Subsurface aquatic abyss where bioluminescent conduits pulse under crushing planetary pressure.",
			"free": false,
			"cost": 450,
			"bg_color": Color(0.01, 0.04, 0.09, 1.0),
			"accent_color": Color(0.2, 0.65, 1.0, 1.0)
		},
		{
			"id": "pyroclastic_rift",
			"name": "PYROCLASTIC RIFT",
			"subtitle": "MANTLE EXTRACTION CORE",
			"description": "Superheated tectonic fissure with plasma flares, molten basalt fields, and thermal turbulence.",
			"free": false,
			"cost": 750,
			"bg_color": Color(0.08, 0.02, 0.02, 1.0),
			"accent_color": Color(1.0, 0.28, 0.15, 1.0)
		},
		{
			"id": "viridian_canopy",
			"name": "VIRIDIAN CANOPY",
			"subtitle": "BIO-RESEARCH HABITAT",
			"description": "Overgrown orbital botanical sphere where cybernetic flora has consumed automated defense stations.",
			"free": false,
			"cost": 1200,
			"bg_color": Color(0.02, 0.06, 0.03, 1.0),
			"accent_color": Color(0.2, 0.95, 0.5, 1.0)
		}
	]
