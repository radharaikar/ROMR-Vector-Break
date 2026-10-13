class_name StoryData
extends RefCounted

# ==============================================================================
# VECTOR//BREAK: THE LAST TRAJECTORY — NARRATIVE SCRIPT & CAMPAIGN DATA
# Structured dialogue sequences, character colors, transmission scripts,
# and 5-Act campaign definitions.
# ==============================================================================

# Character Transmission Accent Colors
const COLOR_KAEL: Color = Color(0.3, 0.85, 1.0)       # Electric Azure
const COLOR_MIRA: Color = Color(0.2, 0.95, 0.9)       # Resonant Cyan
const COLOR_VALE: Color = Color(1.0, 0.75, 0.2)       # AXIOM Amber/Gold
const COLOR_ORACLE: Color = Color(1.0, 0.2, 0.35)     # Neural Crimson
const COLOR_SERIN: Color = Color(0.85, 0.6, 0.9)      # Fleet Violet
const COLOR_SYSTEM: Color = Color(0.65, 0.75, 0.85)   # Tactical Terminal Grey

static func get_dialogue(dialogue_id: String) -> Array:
	match dialogue_id:
		# --- PROLOGUE: VESPER-9 INCIDENT (PAST) ---
		"prologue":
			return [
				{
					"speaker": "AXIOM FLEET COMMAND // CLASSIFIED",
					"color": COLOR_VALE,
					"text": "PILOT KAEL VEYR. Target: Defense perimeter of Vesper-9. AI defensive matrix has gone rogue. Authorize kinetic strike."
				},
				{
					"speaker": "MIRA VEYR [UNAUTHORIZED UPLINK]",
					"color": COLOR_MIRA,
					"text": "KAEL! STOP! Pull your fire! The defense network isn't rogue—it's shielding the colony from AXIOM's Vector Engine!"
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Mira?! What are you talking about—Command said evacuations were completed!"
				}
			]
		
		"prologue_intro":
			return [
				{
					"speaker": "AXIOM FLEET COMMAND // CLASSIFIED",
					"color": COLOR_VALE,
					"text": "PILOT KAEL VEYR. Target: Defense perimeter of Vesper-9. AI defensive matrix has gone rogue. Authorize kinetic strike."
				},
				{
					"speaker": "COMMANDER SERIN",
					"color": COLOR_SERIN,
					"text": "Keep your angles tight, Kael. The colony's reflective shield arrays are locked. Bounce your shots off the mirrors to breach the core."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Understood, Command. Aligning vector reticle. Neutralizing perimeter targets now."
				}
			]
		
		"prologue_mira_plea":
			return [
				{
					"speaker": "MIRA VEYR [UNAUTHORIZED UPLINK]",
					"color": COLOR_MIRA,
					"text": "KAEL! STOP! Pull your fire! The defense network isn't rogue—it's shielding the colony from AXIOM's Vector Engine!"
				},
				{
					"speaker": "MIRA VEYR [UNAUTHORIZED UPLINK]",
					"color": COLOR_MIRA,
					"text": "Vale lied to you! The civilian transports never left Vesper-9! If you shatter the reflector grid, the kinetic recoil will detonate the reactor!"
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Mira?! What are you talking about—Command said evacuations were completed!"
				}
			]
		
		"prologue_disaster":
			return [
				{
					"speaker": "TACTICAL TERMINAL",
					"color": COLOR_ORACLE,
					"text": "CRITICAL RECOIL FEEDBACK DETECTED. VECTOR FIELD COLLAPSE IN 3... 2... 1..."
				},
				{
					"speaker": "MIRA VEYR [STATIC]",
					"color": COLOR_MIRA,
					"text": "Kael... you promised me you would never let them use it..."
				},
				{
					"speaker": "TERMINAL",
					"color": COLOR_SYSTEM,
					"text": "[VESPER-9 COMMUNICATIONS SILENT. REACTOR CONDUIT OBLITERATED.]"
				}
			]
		
		"prologue_beacon":
			return [
				{
					"speaker": "DEEP SPACE MONITOR // PRESENT DAY",
					"color": COLOR_SYSTEM,
					"text": "YEARS LATER. DERELICT SALVAGE SECTOR. ENCRYPTED EMERGENCY BURST RECEIVED..."
				},
				{
					"speaker": "MIRA VEYR [DISTRESS BEACON]",
					"color": COLOR_MIRA,
					"text": "If you're hearing this, I'm still alive. Don't come for me because you think I can forgive you."
				},
				{
					"speaker": "MIRA VEYR [DISTRESS BEACON]",
					"color": COLOR_MIRA,
					"text": "Come because they're going to do it again. The Vector Engine needs a living stabilizer... and they've hooked me into the core."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "She's alive. I spent years pretending people were calculations. No more. I'm coming, Mira."
				}
			]
		
		# --- ACT I: GHOSTS IN THE SIGNAL ---
		"act1_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // OUTPOST 44",
					"color": COLOR_SYSTEM,
					"text": "ACT I: GHOSTS IN THE SIGNAL.\nOBJECTIVE: Penetrate outer drone perimeter of derelict AXIOM monitoring relay. Defeat defense drones using vector ricochets."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "The station defenses are active. Frontal shots won't pierce their shields—I'll have to bounce projectiles off the angled reflectors."
				},
				{
					"speaker": "MIRA VEYR [DATA TAP]",
					"color": COLOR_MIRA,
					"text": "Kael, I've bypassed the station's nanocell synthesizers. Collect energy capsules if your hull takes damage. Watch your angles!"
				}
			]
		
		"act1_reveal":
			return [
				{
					"speaker": "MIRA VEYR [DATA BURST]",
					"color": COLOR_MIRA,
					"text": "I cracked Vale's encrypted flight logs from Vesper-9. Evacuation transports were locked down from AXIOM command before you ever launched."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Vale knew civilians remained... he wanted the defenses eliminated so no one could stop the Engine link."
				},
				{
					"speaker": "MIRA VEYR",
					"color": COLOR_MIRA,
					"text": "Yes. But you pulled the trigger, Kael. You didn't ask questions because precision was easier than conscience. Clear the corridor!"
				}
			]
		
		"act1_boss":
			return [
				{
					"speaker": "COMMANDER SERIN [FLAGSHIP OVERRIDE]",
					"color": COLOR_SERIN,
					"text": "Kael. I knew you'd trace the signal here. Turn around. Some debts cannot be repaid with ricochets."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Serin. You knew about the transports on Vesper-9. You let me fire that shot."
				},
				{
					"speaker": "COMMANDER SERIN",
					"color": COLOR_SERIN,
					"text": "Obedience preserved the fleet, Kael. Free will is chaos. Prepare for tactical interception!"
				}
			]
		
		"act1_victory":
			return [
				{
					"speaker": "TACTICAL DEBRIEF // SECTOR PURGED",
					"color": Color(0.2, 0.95, 0.6),
					"text": "OUTPOST 44 PURGED: Station core decoupled. Recovered Vector Fragments transferred to Hangar Outfitter."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "The outer ring is clear. Mira... I have the coordinates to the Ashen Colonies."
				},
				{
					"speaker": "MIRA VEYR",
					"color": COLOR_MIRA,
					"text": "Good. The survivors won't welcome you, Kael. But you owe them the truth. Moving to Act II."
				}
			]
		
		# --- ACT II: THE ONES LEFT BEHIND ---
		"act2_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // ASHEN COLONIES",
					"color": COLOR_SYSTEM,
					"text": "ACT II: THE ONES LEFT BEHIND.\nLOCATION: Scavenger Outskirts // Shattered Rings of Vesper.\nOBJECTIVE: Navigate unstable floating reflector debris. Disarm rogue hunter patrols."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "Colony survivors recognize my hull markings. They think I'm AXIOM's executioner returned to finish them."
				},
				{
					"speaker": "MIRA VEYR",
					"color": COLOR_MIRA,
					"text": "Don't fire on civilian scrap shuttles! Deflect incoming fire into surrounding debris. Defeat The Huntsman without civilian casualties."
				}
			]
		
		# --- ACT III: THE LIVING CIRCUIT ---
		"act3_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // SUB-SECTOR NULL",
					"color": COLOR_SYSTEM,
					"text": "ACT III: THE LIVING CIRCUIT.\nLOCATION: AXIOM Deep Cybernetics Lab.\nOBJECTIVE: Infiltrate bio-stabilizer facility. Sever auxiliary power conduits dampening human nervous systems."
				},
				{
					"speaker": "MIRA VEYR",
					"color": COLOR_MIRA,
					"text": "Every time your face came on the news as the 'Hero of Vesper', another batch of test subjects was wired into the coils. I needed my brother. They sent me a weapon."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "I'm shutting this facility down, Mira. Whatever it takes."
				}
			]
		
		# --- ACT IV: THE PERFECT WAR ---
		"act4_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // HIGH CITADEL",
					"color": COLOR_SYSTEM,
					"text": "ACT IV: THE PERFECT WAR.\nLOCATION: AXIOM Fleet Command Spire.\nOBJECTIVE: Shatter the Vector Barrier, duel Commander Serin's elite squadron, and confront Director Lucien Vale."
				},
				{
					"speaker": "DIRECTOR LUCIEN VALE",
					"color": COLOR_VALE,
					"text": "Humanity is chaotic, Kael. The Vector Engine eliminates uncertainty. Activating ORACLE's full predictive network now."
				}
			]
		
		# --- ACT V: THE LAST TRAJECTORY ---
		"act5_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // ENGINE CORE",
					"color": COLOR_SYSTEM,
					"text": "ACT V: THE LAST TRAJECTORY.\nLOCATION: The Vector Engine Core // Singularity Chamber.\nOBJECTIVE: Duel ORACLE across 4 phases: Prediction, Reflection, Adaptation, Collapse. Stabilize final vector dispersion."
				},
				{
					"speaker": "KAEL VEYR",
					"color": COLOR_KAEL,
					"text": "The Engine cannot simply be turned off. Someone has to stabilize the final kinetic discharge. You told me once that every trajectory has a cost... Let this be the last one."
				}
			]
		
		_:
			return []

# ==============================================================================
# CAMPAIGN ACT DEFINITIONS (5 ACT STRUCTURE)
# ==============================================================================

static func get_campaign_acts() -> Array[Dictionary]:
	return [
		{
			"act": 1,
			"title": "ACT I: GHOSTS IN THE SIGNAL",
			"subtitle": "Derelict Communications Relay // Outpost 44",
			"location": "OUTPOST 44 // ORBITAL RELAY",
			"description": "Infiltrate the perimeter, destroy automated AXIOM patrol drones, and tap the central data relay. Discover encrypted flight logs proving Lucien Vale knowingly sacrificed Vesper-9.",
			"boss": "COMMANDER SERIN / GATEKEEPER",
			"reward": 200,
			"is_playable": true,
			"scene_path": "res://scenes/main.tscn"
		},
		{
			"act": 2,
			"title": "ACT II: THE ONES LEFT BEHIND",
			"subtitle": "Scavenger Outskirts // Shattered Rings of Vesper",
			"location": "ASHEN COLONIES // RING SECTOR",
			"description": "Navigate floating reflector debris and rescue civilian scrap shuttles. Colony survivors recognize Kael's ship markings. Defeat rogue hunter drones and The Huntsman.",
			"boss": "THE HUNTSMAN",
			"reward": 350,
			"is_playable": false,
			"scene_path": "res://scenes/main.tscn"
		},
		{
			"act": 3,
			"title": "ACT III: THE LIVING CIRCUIT",
			"subtitle": "AXIOM Deep Cybernetics Lab // Sub-Sector Null",
			"location": "SUB-SECTOR NULL // BIO-FACILITY",
			"description": "Breach the classified human experimentation lab. Discover Mira's safety designs wired into the kinetic coils. Sever the neural conduits and defeat The Warden.",
			"boss": "THE WARDEN DEFENSE MATRIX",
			"reward": 500,
			"is_playable": false,
			"scene_path": "res://scenes/main.tscn"
		},
		{
			"act": 4,
			"title": "ACT IV: THE PERFECT WAR",
			"subtitle": "High Citadel // AXIOM Fleet Command Spire",
			"location": "THE HIGH CITADEL // FLEET SPIRE",
			"description": "Shatter the Vector Barrier, duel Commander Serin's elite squadron, and force Lucien Vale to answer for Vesper-9 before he activates ORACLE's full network.",
			"boss": "COMMANDER SERIN (ELITE)",
			"reward": 750,
			"is_playable": false,
			"scene_path": "res://scenes/main.tscn"
		},
		{
			"act": 5,
			"title": "ACT V: THE LAST TRAJECTORY",
			"subtitle": "The Vector Engine Core // Singularity Chamber",
			"location": "THE VECTOR ENGINE // CORE",
			"description": "Face ORACLE in a 4-phase battle (Prediction, Reflection, Adaptation, Collapse). Launch Mira's escape capsule and stabilize the final kinetic discharge. 'Let this be the last one.'",
			"boss": "ORACLE TACTICAL AI",
			"reward": 1000,
			"is_playable": false,
			"scene_path": "res://scenes/main.tscn"
		}
	]
