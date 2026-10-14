class_name CampaignData
extends RefCounted

## Campaign progression data for VECTOR//BREAK — THE LAST TRAJECTORY.
## Exposes structured level definitions, narrative briefings, and wave compositions
## for all 5 acts of the complete finite campaign.

static func get_round_definitions(act_number: int = 1) -> Array[Dictionary]:
	match act_number:
		2:
			return [
				{
					"id": "2-1",
					"name": "ROUND 1: ASHEN FALLOUT",
					"act": "ACT II: THE ONES LEFT BEHIND",
					"briefing": "Kael, we have arrived in the ruins of the Vesper-9 outer colony. Swarm interceptors and fast dashers are sweeping the fallout fields.",
					"time_limit": 65.0,
					"waves": [
						[
							{"type": "dasher", "pos": Vector2(1320, 260)},
							{"type": "drone", "pos": Vector2(1320, 460)}
						],
						[
							{"type": "dasher", "pos": Vector2(1320, 200)},
							{"type": "chaser", "pos": Vector2(1320, 360)},
							{"type": "dasher", "pos": Vector2(1320, 520)}
						]
					]
				},
				{
					"id": "2-2",
					"name": "ROUND 2: DEEP COLONY RUINS",
					"act": "ACT II: THE ONES LEFT BEHIND",
					"briefing": "Heavy armored defense constructs detected. Frontal shields absorb direct damage—bounce your energy bolts to strike their unprotected rear thrusters!",
					"time_limit": 75.0,
					"waves": [
						[
							{"type": "heavy", "pos": Vector2(1320, 360)},
							{"type": "striker", "pos": Vector2(1320, 220)}
						],
						[
							{"type": "heavy", "pos": Vector2(1320, 240)},
							{"type": "chaser", "pos": Vector2(1320, 380)},
							{"type": "striker", "pos": Vector2(1320, 520)}
						]
					]
				},
				{
					"id": "2-3",
					"name": "ROUND 3: THE HUNTSMAN",
					"act": "ACT II: THE ONES LEFT BEHIND",
					"briefing": "AXIOM Hunter Interceptor detected: The Huntsman. 'Subject Kael Veyr. Your sister belongs to the Vector Engine.' Eliminate the commander!",
					"time_limit": 90.0,
					"waves": [
						[
							{"type": "elite", "pos": Vector2(1050, 360)},
							{"type": "dasher", "pos": Vector2(1320, 220)},
							{"type": "dasher", "pos": Vector2(1320, 500)}
						]
					]
				}
			]
		3:
			return [
				{
					"id": "3-1",
					"name": "ROUND 1: BIO-VECTOR CONDUIT",
					"act": "ACT III: THE LIVING CIRCUIT",
					"briefing": "AXIOM Research Division subsurface facilities. Bioluminescent energy conduits are feeding power to the central stabilization lattice.",
					"time_limit": 70.0,
					"waves": [
						[
							{"type": "chaser", "pos": Vector2(1320, 240)},
							{"type": "striker", "pos": Vector2(1320, 480)}
						],
						[
							{"type": "elite", "pos": Vector2(1320, 360)},
							{"type": "chaser", "pos": Vector2(1320, 200)},
							{"type": "chaser", "pos": Vector2(1320, 520)}
						]
					]
				},
				{
					"id": "3-2",
					"name": "ROUND 2: NEURAL INCUBATOR",
					"act": "ACT III: THE LIVING CIRCUIT",
					"briefing": "The Warden security construct has locked the primary corridor with overlapping heavy shields. Ricochet your trajectory to clear the way!",
					"time_limit": 80.0,
					"waves": [
						[
							{"type": "heavy", "pos": Vector2(1320, 300)},
							{"type": "heavy", "pos": Vector2(1320, 460)}
						],
						[
							{"type": "elite", "pos": Vector2(1320, 360)},
							{"type": "heavy", "pos": Vector2(1320, 220)},
							{"type": "striker", "pos": Vector2(1320, 500)}
						]
					]
				},
				{
					"id": "3-3",
					"name": "ROUND 3: THE WARDEN",
					"act": "ACT III: THE LIVING CIRCUIT",
					"briefing": "AXIOM Bio-Vector Guardian: The Warden. Neutralize the heavy defense dreadnought to unlock the transit lift to the Citadel!",
					"time_limit": 95.0,
					"waves": [
						[
							{"type": "heavy", "pos": Vector2(1050, 360)},
							{"type": "elite", "pos": Vector2(1250, 220)},
							{"type": "striker", "pos": Vector2(1250, 500)}
						]
					]
				}
			]
		4:
			return [
				{
					"id": "4-1",
					"name": "ROUND 1: CITADEL PERIMETER",
					"act": "ACT IV: THE PERFECT WAR",
					"briefing": "AXIOM Citadel Core. Lucien Vale has mobilized the full squadron. Heavy artillery strikes and plasma barrages incoming!",
					"time_limit": 75.0,
					"waves": [
						[
							{"type": "striker", "pos": Vector2(1320, 220)},
							{"type": "striker", "pos": Vector2(1320, 500)},
							{"type": "dasher", "pos": Vector2(1320, 360)}
						],
						[
							{"type": "heavy", "pos": Vector2(1320, 260)},
							{"type": "heavy", "pos": Vector2(1320, 460)},
							{"type": "elite", "pos": Vector2(1320, 360)}
						]
					]
				},
				{
					"id": "4-2",
					"name": "ROUND 2: VALE'S ROYAL GUARD",
					"act": "ACT IV: THE PERFECT WAR",
					"briefing": "Vale's personal escort arbiters deployed. Use angled reflectors to bypass their phased shields!",
					"time_limit": 85.0,
					"waves": [
						[
							{"type": "elite", "pos": Vector2(1320, 280)},
							{"type": "elite", "pos": Vector2(1320, 440)}
						],
						[
							{"type": "heavy", "pos": Vector2(1320, 360)},
							{"type": "elite", "pos": Vector2(1320, 200)},
							{"type": "dasher", "pos": Vector2(1320, 520)}
						]
					]
				},
				{
					"id": "4-3",
					"name": "ROUND 3: COMMANDER SERIN PHASE 3",
					"act": "ACT IV: THE PERFECT WAR",
					"briefing": "Commander Serin's flagship 'Resolute' stands between you and the Engine. 'End this, Kael. For Vesper-9!' Destroy the flagship!",
					"time_limit": 110.0,
					"waves": [
						[
							{"type": "boss_serin", "pos": Vector2(1050, 360)}
						]
					]
				}
			]
		5:
			return [
				{
					"id": "5-1",
					"name": "ROUND 1: VECTOR CORE THRESHOLD",
					"act": "ACT V: THE LAST TRAJECTORY",
					"briefing": "Inside the Vector Engine chamber. The fabric of space is folding. Heavy neural guardians protecting ORACLE's calculation nexus.",
					"time_limit": 80.0,
					"waves": [
						[
							{"type": "heavy", "pos": Vector2(1320, 260)},
							{"type": "elite", "pos": Vector2(1320, 460)}
						],
						[
							{"type": "elite", "pos": Vector2(1320, 300)},
							{"type": "heavy", "pos": Vector2(1320, 420)},
							{"type": "striker", "pos": Vector2(1320, 200)},
							{"type": "dasher", "pos": Vector2(1320, 540)}
						]
					]
				},
				{
					"id": "5-2",
					"name": "ROUND 2: ORACLE TACTICAL CORE",
					"act": "ACT V: THE LAST TRAJECTORY",
					"briefing": "ORACLE Core: 'ALL TRAJECTORIES TERMINATE HERE.' Destroy the tactical AI core to break Mira's containment locks!",
					"time_limit": 120.0,
					"waves": [
						[
							{"type": "boss_serin", "pos": Vector2(1050, 360)}
						]
					]
				}
			]
		_: # Default to Act 1
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

static func get_act_for_biome(biome_id: String) -> int:
	match biome_id:
		"neon_graveyard": return 1
		"vesper_desert": return 2
		"pelagic_depths": return 3
		"pyroclastic_rift": return 4
		"viridian_canopy": return 5
		_: return 1

static func get_biome_for_act(act_num: int) -> String:
	match act_num:
		1: return "neon_graveyard"
		2: return "vesper_desert"
		3: return "pelagic_depths"
		4: return "pyroclastic_rift"
		5: return "viridian_canopy"
		_: return "neon_graveyard"
