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
		
		_:
			return []
