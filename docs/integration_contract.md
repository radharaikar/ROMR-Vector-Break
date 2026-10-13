# ROMR // VECTOR//BREAK — Integration Interface Contract
**Document Version:** 1.0.0  
**Ownership Split:** Dell (Combat & Encounters) / ASUS (Economy, Progression & UI)

---

## 1. Ownership & Responsibility Boundaries

| System Domain | Responsible Node / Machine | Scope & Ownership |
|---|---|---|
| **Combat Engine & AI** | **Dell** | Enemy AI behavior, projectile collision, combat hit detection, ricochet mechanics, boss phases, difficulty scaling. |
| **Encounter & Flow** | **Dell** | RoundManager, wave spawning, countdown timers, combat obstacles, combat victory/defeat logic. |
| **Player Combat Core** | **Dell** | Ship movement physics, mouse aiming, projectile firing, combat damage intake, i-frames. |
| **Player Presentation & UI** | **ASUS** | Health bar HUD presentation, shield gauges, player death/revive animations, game-over screen. |
| **Economy & Upgrades** | **ASUS** | Healing pickups, scrap/currency drops, store, hangar menu, skins, ship abilities, save/load. |
| **Narrative & Meta UI** | **ASUS** | Mission briefing dialogue boxes, cutscene screens, campaign level-select menu, settings. |

---

## 2. Shared Signal & Method Contracts

To ensure zero merge conflicts and seamless integration, both sides adhere to decoupled signals and small duck-typed APIs.

### 2.1 Player Health & Damage Contract (Target: Node in group `"player"`)

Dell implements a robust combat damage receiver on `PlayerShip`. ASUS provides the visual HUD bar and revive loop.

```gdscript
# Signals emitted by Player
signal health_changed(current_hp: int, max_hp: int)
signal player_damaged(damage: int, hit_source: Node)
signal player_healed(amount: int)
signal invulnerability_changed(is_invulnerable: bool)
signal player_died()

# Methods callable by ASUS or combat entities
func take_damage(amount: int, hit_source: Node = null) -> void
func heal(amount: int) -> void
func get_health() -> int
func get_max_health() -> int
func is_alive() -> bool
func set_invulnerable(duration: float) -> void
```

*Contract Rules:*
* When `amount <= 0`, `take_damage()` does nothing.
* Player has a default invulnerability window (`i_frames = 1.0s`) with blinking visual feedback to prevent multi-hit frame snagging.
* ASUS's healing drops call `player.heal(amount)`.

---

### 2.2 Enemy Damage Contract (Target: Nodes in group `"enemies"`)

All enemies inherit from `EnemyBase` (`scripts/enemy_base.gd`).

```gdscript
# Signals emitted by EnemyBase
signal health_changed(current_hp: int, max_hp: int)
signal hit_taken(damage: int, hit_normal: Vector2)
signal destroyed(score_reward: int, death_position: Vector2)

# Methods on EnemyBase
func take_damage(amount: int, combo_multiplier: Variant = 1, hit_point: Vector2 = Vector2.ZERO) -> void
func die(combo_multiplier: int = 1) -> void
```

*Contract Rules:*
* Dell projectiles call `take_damage(damage, ricochet_combo, collision.get_position())`.
* When destroyed, the enemy awards `score_value * max(1, combo)` to `GameManager` and emits `destroyed`.
* ASUS collectible drops connect to `enemy.destroyed` to spawn scrap or energy cores at `death_position`.

---

### 2.3 Reflective Surface Contract (Target: Nodes in group `"reflective"`)

Reflective geometry redirects energy bolts using mathematical vector reflection.

```gdscript
# Required group
add_to_group("reflective")

# Required method called by EnergyProjectile upon collision
func on_ricochet(impact_point: Vector2, normal: Vector2) -> void
```

*Contract Rules:*
* `normal` is the collision normal vector provided by Godot physics `Vector2.bounce(normal)`.
* Reflectors pulse visually and spawn ricochet particle flashes.

---

### 2.4 Round & Encounter Manager Contract (`scripts/round_manager.gd`)

Dell provides `RoundManager` as a singleton or scene node managing combat rounds.

```gdscript
# Signals emitted by RoundManager
signal round_started(round_index: int, round_name: String, time_limit: float)
signal wave_started(wave_index: int, total_waves: int)
signal enemy_count_changed(remaining: int, total: int)
signal round_time_tick(time_remaining: float)
signal wave_cleared(wave_index: int)
signal round_victory(round_index: int, total_score: int)
signal round_defeat(reason: String)

# Methods callable by ASUS UI
func start_round(round_index: int) -> void
func pause_round() -> void
func resume_round() -> void
func restart_current_round() -> void
func get_current_round_info() -> Dictionary
```

*Contract Rules:*
* ASUS mission briefing UI listens for `round_started`, displays briefing text, and calls `start_round()` or `resume_round()`.
* ASUS game-over/revive UI listens for `round_defeat`, handles player revival currency/tokens, and calls `restart_current_round()` or `resume_round()`.

---

### 2.5 Boss Interface Contract (Target: Boss nodes in group `"boss"`)

```gdscript
# Signals emitted by Boss
signal boss_spawned(boss_name: String, max_hp: int)
signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(phase_number: int, phase_name: String)
signal boss_defeated(score_reward: int)
```

*Contract Rules:*
* ASUS boss health bar overlay connects to `boss_health_changed` and `boss_phase_changed`.

---

### 2.6 Campaign Data & Narrative Contract (`scripts/campaign_data.gd`)

Dell exposes campaign level definitions as structured data:
```gdscript
CampaignData.get_act_levels(act_index: int) -> Array[Dictionary]
```
Each level entry includes:
* `id`: String identifier (e.g. `"1-1"`, `"1-boss"`)
* `title`: Mission name
* `briefing`: Narrative briefing string (from Story Bible)
* `dialogue_hooks`: Array of speaker/text pairs for ASUS dialogue display
* `target_score`: Par score for grade
* `time_limit`: Seconds allowed
