# VECTOR//BREAK — PLAYER PROGRESSION, ECONOMY & UPGRADES SPECIFICATION

**Game:** VECTOR//BREAK — THE LAST TRAJECTORY  
**Team:** ROMR (RESPawn 2.0 12-Hour Sci-Fi Game Jam)  
**Document Purpose:** System specification for Player Health, Pickups, Economy, Hangar Store, Upgrades, Skins, and Save System.

---

## 1. Player Health & Survival System

### Core Parameters
* `base_max_health`: `100` (Int)
* `current_health`: Clamped between `0` and `max_health`
* `invulnerability_duration`: `0.8` seconds post-damage
* `damage_flash_color`: `Color(1.0, 0.2, 0.4, 0.8)` (Neon crimson/magenta flash)

### Signals Emitted by Player
```gdscript
signal health_changed(current: int, maximum: int)
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal player_died()
signal invulnerability_changed(is_invulnerable: bool)
```

### Public Methods
* `take_damage(amount: int, hit_source: Variant = null) -> bool`:
  - Returns `true` if damage was applied, `false` if blocked by invulnerability or player already dead.
  - Flashes sprite white/red, initiates 0.8s invulnerability flicker.
  - If health drops to 0, emits `player_died` **exactly once** and disables input.
* `heal(amount: int) -> int`:
  - Returns actual health restored (capped at `max_health`).
  - Emits `player_healed` and `health_changed`.
* `revive(health_percentage: float = 0.5) -> void`:
  - Restores player with specified percentage of max health (default 50%).
  - Grants 2.0 seconds of post-revive invulnerability.
  - Clears `is_dead` state, re-enables controls.

---

## 2. In-Combat Pickups & Collectibles

### A. Nanocell Healing Capsule
* **Visual:** Glowing hexagonal cyan/emerald nanite capsule with oscillating energy ring.
* **Size:** 24×24 pixel sprite.
* **Healing Value:** `25 HP` (+10 bonus if *Emergency Nanocell* upgrade is equipped).
* **Rule:** If the player is at 100% max health, the Nanocell is **NOT** consumed, preserving it for later.
* **Anti-Duplicate:** Atomic pickup consumption check (`is_collected` guard) before freeing node.

### B. Vector Fragment (Currency Pickup)
* **Visual:** Rotating cyan/magenta kinetic shard / data octahedron.
* **Size:** 16×16 pixel sprite.
* **Value:** Configurable (`10`, `25`, `50` Fragments).
* **Behavior:** Floating bob animation; when player enters pickup area, fragment smoothly glides to player with an audio/visual pop.

### Pickup Spawn API for Dell Combat Systems
Dell enemy scripts or wave controllers can request drops without coupling to scene paths:
```gdscript
# Spawn via GameManager singleton:
GameManager.spawn_pickup(GameManager.PickupType.NANOCELL, enemy_death_position)
GameManager.spawn_pickup(GameManager.PickupType.FRAGMENT, enemy_death_position, 25)
```

---

## 3. Economy & Persistent Currency

### Currency: Vector Fragments
* **Balance:** Stored centrally in `SaveManager` and tracked dynamically in `GameManager`.
* **Sources:**
  - Standard Drone Kill: `15 Fragments`
  - Heavy Dreadnought Kill: `40 Fragments`
  - Wave Clear Bonus: `50 Fragments`
  - Boss Defeat Reward: `250 Fragments`
  - In-Arena Pickups: `10 – 50 Fragments`
* **Integrity Guard:** Every reward transaction includes a source transaction ID; duplicate wave-clear or death signals cannot award duplicate currency.

---

## 4. Second Chance & Revive System

### Emergency Reconstruction Cores
* **Lore:** Experimental cybernetic bio-dampers capable of reversing fatal kinetic shock.
* **Rules:**
  - Upon player death (`player_died`), active combat pauses.
  - If player possesses an Emergency Reconstruction Core (or has ≥50 Vector Fragments to synthesize one), a **[SECOND CHANCE: REVIVE]** button is presented.
  - Revive restores player to 50% HP at current position with 2.0s invulnerability.
  - Max **1 revive per run/mission**.
  - **Narrative Exception:** Revive is disabled during the final sacrifice in Act V.

---

## 5. Hangar Store: Skins & Upgrades

### Player Skins
All skins visually modify the player ship sprite, engine trail, and UI accent colors:

| ID | Name | Cost | Visual Style | Lore |
| :--- | :--- | :---: | :--- | :--- |
| `skin_default` | **AXIOM Interceptor** | Free | Pale Steel & Neon Cyan | Standard military issue vector fighter. |
| `skin_prototype` | **AXIOM Stealth Prototype** | 150 | Obsidian Navy & Golden Amber | Unregistered black-ops chassis recovered from Outpost 44. |
| `skin_squad` | **Serin Squad Frame** | 250 | Battleship Slate & Crimson Edge | Markings of Kael's former squadron on Vesper-9. |
| `skin_vector` | **Resonant Vector Frame** | 400 | Prismatic Violet & High-Glow Magenta | Experimental field-resonator that shimmers with kinetic feedback. |

### Upgrades
Every upgrade has clear, balanced gameplay impact without breaking core ricochet skill:

| ID | Name | Cost | Effect |
| :--- | :--- | :---: | :--- |
| `upgrade_capacitor` | **Vector Capacitor** | 120 | Increases projectile maximum bounce count by +1 and grants +10% bounce velocity. |
| `upgrade_nanocell` | **Emergency Nanocell** | 100 | Nanocells heal +10 bonus HP (35 HP total) and grants 1 starting Reconstruction Core. |
| `upgrade_frame` | **Stabilized Frame** | 150 | Increases Player Max HP from 100 to 125, improving structural survivability. |
| `upgrade_targeting` | **Targeting Matrix** | 80 | Extends the neon aiming laser guide line by +50% for cleaner bounce calculations. |

---

## 6. Persistent Save/Load System (`SaveManager`)

### File Path
`user://save_data.json`

### JSON Schema (Version 1)
```json
{
  "version": 1,
  "currency": 250,
  "reconstruction_cores": 1,
  "campaign_act": 1,
  "campaign_mission": 1,
  "completed_missions": ["act1_m1"],
  "unlocked_skins": ["skin_default", "skin_prototype"],
  "equipped_skin": "skin_default",
  "unlocked_upgrades": {
    "upgrade_capacitor": true,
    "upgrade_frame": false,
    "upgrade_nanocell": false,
    "upgrade_targeting": false
  },
  "story_flags": {
    "saw_prologue": true,
    "mira_contacted": false
  },
  "stats": {
    "total_kills": 42,
    "total_ricochets": 128,
    "total_score": 15400
  }
}
```

### Safety Features
1. **Atomic Write:** Writes to temporary file before replacing to avoid corruption on crash.
2. **Safe Fallback:** If the file is missing or corrupted, initializes default values without throwing engine errors.
3. **Save Milestones:** Saved upon shop purchases, mission completion, and return to hangar (never per-frame).
