class_name StoryData
extends RefCounted

# ==============================================================================
# VECTOR//BREAK: THE LAST TRAJECTORY — NARRATIVE SCRIPT DATA
# Contains structured dialogue scripts for Prologue, Mission Briefings,
# In-Game Transmissions, Boss Introductions, and Act Endings.
# ==============================================================================

static func get_dialogue(dialogue_id: String) -> Array:
	match dialogue_id:
		"prologue":
			return [
				{
					"speaker": "AUTOMATED FLIGHT RECORDER",
					"color": Color(0.6, 0.7, 0.8),
					"text": "ARCHIVE ENTRY: VESPER-9 DEFENSE COLLAPSE. RETRIEVING DECRYPTED AUDIO BURST..."
				},
				{
					"speaker": "MIRA VEYR [EMERGENCY FREQUENCY]",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Kael... if you're hearing this, I'm still alive. Don't come for me because you think I can forgive you."
				},
				{
					"speaker": "MIRA VEYR [EMERGENCY FREQUENCY]",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Come because AXIOM is going to do it again. The Vector Engine needs a living stabilizer... and they've hooked me into the core."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Mira... I spent years believing my shots were clean. That every trajectory could fix what came before. Hold on. I'm coming."
				}
			]
		
		"act1_briefing":
			return [
				{
					"speaker": "TACTICAL UPLINK // OUTPOST 44",
					"color": Color(1.0, 0.75, 0.2),
					"text": "MISSION 01: GHOSTS IN THE SIGNAL.\nOBJECTIVE: Penetrate outer drone perimeter. Destroy AXIOM patrol drones using vector ricochet physics."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "The station defenses are active. Direct frontal shots won't pierce their shields—I'll have to bounce projectiles off the angled reflectors."
				},
				{
					"speaker": "MIRA VEYR [DATA TAP]",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Kael, I've bypassed the station's nanocell synthesizers. Collect energy capsules if your hull takes damage. Watch your angles!"
				}
			]
		
		"in_game_reveal":
			return [
				{
					"speaker": "MIRA VEYR [STATIC BURST]",
					"color": Color(0.2, 0.9, 1.0),
					"text": "I spent three years listening to Vale hail you as the Hero of Vesper. Every medal they pinned on you, another colony went dark."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Vale lied to the entire squadron, Mira! We thought the defense batteries were compromised!"
				},
				{
					"speaker": "MIRA VEYR",
					"color": Color(0.2, 0.9, 1.0),
					"text": "You didn't ask questions because precision was easier than conscience. Finish this patrol—we have to reach the primary conduit."
				}
			]
		
		"boss_intro":
			return [
				{
					"speaker": "ORACLE TACTICAL AI",
					"color": Color(1.0, 0.2, 0.35),
					"text": "ALERT: UNREGISTERED PILOT SIGNATURE DETECTED. SUBJECT: KAEL VEYR. TRAJECTORY CALCULATED."
				},
				{
					"speaker": "ORACLE TACTICAL AI",
					"color": Color(1.0, 0.2, 0.35),
					"text": "PHASE 1 ENGAGED: PREDICTION PROTOCOL. FREE WILL IS AN IMPERFECTION IN THE VECTOR LATTICE."
				}
			]
		
		"elite_encounter":
			return [
				{
					"speaker": "LUCIEN VALE [AXIOM HIGH COMMAND]",
					"color": Color(1.0, 0.25, 0.25),
					"text": "Subject Kael Veyr. You cannot outrun the calculations. Elite Arbiter unit deployed to terminate trajectory."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Save your calculations, Vale. I'm breaking the circuit."
				}
			]
		
		"wave_escalation":
			return [
				{
					"speaker": "ORACLE TACTICAL AI",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Trajectory deviation detected. Hostile reinforcements arriving from multiple breaches."
				}
			]
		
		"act1_victory":
			return [
				{
					"speaker": "TACTICAL DEBRIEF // SECTOR CLEAR",
					"color": Color(0.2, 0.95, 0.6),
					"text": "SECTOR 01 PURGED: AXIOM PERIMETER BROKEN.\nKinetic relay decoupled. Recovered Vector Fragments transferred to Hangar inventory."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "The outer ring is clear. Mira... I have the access codes to the central spire."
				},
				{
					"speaker": "MIRA VEYR",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Good. But the deeper you go, the more unstable the recoil becomes. Remember what I told you: Every trajectory has a cost."
				}
			]
		
		"act2_briefing":
			return [
				{
					"speaker": "MIRA VEYR [DATA TAP]",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Kael, you've breached the Ashen Colonies. The atmosphere is choked with Vesper-9 fallout. Lucien Vale has deployed the Huntsman to intercept you."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "I see their searchlights. Fast Dashers and heavy barricades ahead. I'm cutting through."
				}
			]
		
		"act2_victory":
			return [
				{
					"speaker": "TACTICAL DEBRIEF // SECTOR CLEAR",
					"color": Color(0.2, 0.95, 0.6),
					"text": "ACT II CLEARED: ASHEN COLONIES SECURED.\nThe Huntsman has been neutralized. Telemetry conduit acquired."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "I've recovered the laboratory coordinates. Mira, I'm heading into the deep research trench."
				}
			]
		
		"act3_briefing":
			return [
				{
					"speaker": "LUCIEN VALE [AXIOM HIGH COMMAND]",
					"color": Color(1.0, 0.25, 0.25),
					"text": "Subject Kael Veyr. You dismantled my patrol and my hunter. But you cannot bypass the Living Circuit. The Warden awaits."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Your constructs don't frighten me, Vale. Where is my sister?"
				},
				{
					"speaker": "MIRA VEYR",
					"color": Color(0.2, 0.9, 1.0),
					"text": "Kael... I can feel the Engine pulsing. It's draining the colony capacitors. Watch the angled reflectors!"
				}
			]
		
		"act3_victory":
			return [
				{
					"speaker": "TACTICAL DEBRIEF // SECTOR CLEAR",
					"color": Color(0.2, 0.95, 0.6),
					"text": "ACT III CLEARED: AXIOM RESEARCH BREACHED.\nThe Warden construct is offline. Citadel transit unlocked."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "The bio-laboratories are quiet. Mira, the path to the Citadel is open."
				}
			]
		
		"act4_briefing":
			return [
				{
					"speaker": "COMMANDER SERIN // CITADEL DEFENSE",
					"color": Color(1.0, 0.35, 0.4),
					"text": "This is the final line, Kael. The Citadel fleet is scrambled. If you cross this threshold, there is no return."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "You surrendered your conscience to AXIOM three years ago, Serin. I'm breaking the fleet."
				}
			]
		
		"act4_victory":
			return [
				{
					"speaker": "TACTICAL DEBRIEF // SECTOR CLEAR",
					"color": Color(0.2, 0.95, 0.6),
					"text": "ACT IV CLEARED: CITADEL DEFENSES NEUTRALIZED.\nFleet flagship crippled. Heart of the Engine accessible."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Serin is down. The Citadel core has collapsed. I'm entering the Vector chamber."
				}
			]
		
		"act5_briefing":
			return [
				{
					"speaker": "ORACLE TACTICAL AI",
					"color": Color(1.0, 0.25, 0.4),
					"text": "SUBJECT KAEL VEYR. YOU HAVE REACHED THE FOCAL CORE. PROBABILITY OF RESCUING SUBJECT MIRA VEYR: 0.0000%."
				},
				{
					"speaker": "KAEL VEYR",
					"color": Color(0.3, 0.8, 1.0),
					"text": "Keep calculating, ORACLE. I'm terminating the program."
				}
			]
		
		_:
			return []

static func has_sequence(dialogue_id: String) -> bool:
	return get_dialogue(dialogue_id).size() > 0
