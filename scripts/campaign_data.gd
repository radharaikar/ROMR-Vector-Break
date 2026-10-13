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
					{"type": "heavy", "pos": Vector2(1320, 260)},
					{"type": "striker", "pos": Vector2(1320, 480)}
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
