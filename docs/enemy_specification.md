# VECTOR//BREAK — Enemy Specification & Design Architecture

**Author:** ROMR Art / Technical-Art / Enemy Design (ASUS Machine)  
**Target:** Godot 4.7.2 Forward+ / Mobile / Compatibility | GDScript  
**Document Status:** Complete & Ready for Integration  

---

## 1. Overview & Enemy Archetypes

In **VECTOR//BREAK**, combat is built around vector geometry, angles, and ricochet mechanics. Enemies serve as geometric targets that challenge the player's firing angles and crowd-control capabilities.

All enemies inherit from `EnemyBase` (`CharacterBody2D`) with floating motion mode (`MOTION_MODE_FLOATING`).

### Archetype Matrix

| Unit | File / Scene | HP | Speed | Score | Collision Profile | Movement Pattern | Threat Level |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :---: |
| **Spike Drone (Basic)** | `enemy_drone.tscn` | 3 | 50.0 px/s | 100 | Circle (r=12px) | Sinusoidal horizontal wave | Low–Medium |
| **Dart Interceptor (Fast)** | `enemy_fast.tscn` | 1 | 140.0 px/s | 150 | Triangle polygon (21x18px) | High-speed zigzag dive | Medium |
| **Armored Dreadnought (Heavy)** | `enemy_heavy.tscn` | 8 | 25.0 px/s | 500 | Box (34x34px) | Slow steady bulkhead push | High |

---

## 2. Technical Enemy Architecture

### Hierarchy & Script Structure
```text
EnemyBase (CharacterBody2D)
├── Sprite2D / AnimatedSprite2D [texture_filter = NEAREST]
├── CollisionShape2D / CollisionPolygon2D
└── Optional: AudioStreamPlayer2D / HitFlashTimer
```

### Signal Interface
Every enemy emits standard Godot signals for decoupled gameplay integration:

```gdscript
signal health_changed(current_hp: int, max_hp: int)
signal hit_taken(damage: int, hit_normal: Vector2)
signal destroyed(score: int, death_position: Vector2)
```

- When `health_changed` fires: HUD or floating health bars can update.
- When `hit_taken` fires: Screen-shake triggers, audio hooks play hit thud.
- When `destroyed` fires: Score manager adds `score`, combo counter increments, death explosion VFX spawns.

### Damage Handling & Duck-Typing Contract
To avoid guessing Dell's exact function name, `EnemyBase` implements all common projectile interfaces:

```gdscript
func take_damage(amount: int, hit_normal: Vector2 = Vector2.ZERO, hit_point: Vector2 = Vector2.ZERO) -> void
func hit(damage_amount: int) -> void
func apply_damage(damage_amount: int) -> void
func on_hit(damage_amount: int) -> void
```

Each redirects internally to `take_damage()`:
1. Deducts HP.
2. Emits `health_changed` and `hit_taken`.
3. Triggers immediate **white-hot hit-flash tween** (0.08 seconds modulate pulse).
4. If `current_health <= 0`, calls `die()`.

### Hit Reaction & Visual Feedback
- **Hit Flash:** Tweens `sprite_node.modulate` from `Color(1.5, 1.5, 1.5, 1.0)` back to `Color.WHITE` in 80ms.
- **Death Dissolution:** Spawns `enemy_explode_sheet.png` (4-frame core rupture & metal shard scatter) at `global_position`, emits `destroyed(score, global_position)`, and invokes `queue_free()`.

---

## 3. Spawning & Wave Placement Guidance

- **Wave Formation 1 (Screen Sweep):** 3-4 Basic Drones staggered vertically by 40px, bobbing out of phase (`sin(time * 3.0 + phase)`).
- **Wave Formation 2 (Flank Interceptor):** 2 Fast Interceptors swooping from the top-right and bottom-right diagonals towards player coordinates.
- **Wave Formation 3 (Bulwark):** 1 Heavy Dreadnought in the center lane flanked by reflective barriers above and below, forcing player to ricochet shots behind its armor.
