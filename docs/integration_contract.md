# VECTOR//BREAK — Dell & ASUS Integration Contract & Checklist

**Game:** VECTOR//BREAK  
**Team:** ROMR (RESPawn 2.0 12-Hour Sci-Fi Game Jam)  
**Engine:** Godot 4.7.2 Forward+ | GDScript  
**Document Purpose:** Defines shared technical boundaries, node naming, collision matrix, exact file paths, interface protocols, and verification tests between the Dell developer (Player, Physics, Core Project) and the ASUS developer (Art Assets, Enemies, Visual Effects).

---

## 1. Ownership Demarcation

| Area | Dell Ownership | ASUS Ownership |
| :--- | :--- | :--- |
| **Engine Core** | `project.godot`, Main scene, Viewport settings | *No modifications* |
| **Player** | Movement controller, mouse aim, weapon trigger | Visual sprite & thruster sheet provided |
| **Weapons / Physics** | Projectile node, raycasting, ricochet math | Projectile sprite, impact & bounce VFX provided |
| **Enemies** | Integration into spawning wave system | Enemy base class, 3 archetypes, scenes, death VFX |
| **Environment** | Level geometry tilemap/containers | Reflector sprites, angled mirror scenes |

---

## 2. Collision Matrix (Godot 2D Physics Layers)

To prevent collision cross-talk between allies, projectiles, and reflectors, the following layer allocation is established:

| Layer Bit | Value | Name | Used By | Collides With (Mask) |
| :---: | :---: | :--- | :--- | :--- |
| **1 (Bit 0)** | `1` | `World / Walls` | Static boundaries, station catwalks | Player, Enemies, Projectiles |
| **2 (Bit 1)** | `2` | `Player` | Player ship hitbox (`CharacterBody2D`) | World, Enemy Projectiles, Enemy Bodies |
| **3 (Bit 2)** | `4` | `Enemies` | Drone, Fast, Heavy (`CharacterBody2D`) | World (1), Player Projectiles (8) |
| **4 (Bit 3)** | `8` | `Player Projectiles` | Laser bolts (`Area2D` or `RayCast2D`) | World (1), Enemies (4), Reflectors (16) |
| **5 (Bit 4)** | `16`| `Reflectors` | Angled mirrors, bounce barriers | Player Projectiles (8) |

*Summary: Enemies set `collision_layer = 4`, `collision_mask = 3` (or 9). Reflectors set `collision_layer = 16`, `collision_mask = 0`.*

---

## 3. Damage Protocol & Signal Signatures

### Projectile-to-Enemy Damage Call
When the Dell's projectile detects a collision with an enemy collider:

```gdscript
# Primary damage interface (full vector context)
if collider.has_method("take_damage"):
    collider.take_damage(damage_amount, hit_normal, hit_point)
# Fallback duck-typing alternatives supported by EnemyBase:
elif collider.has_method("hit"):
    collider.hit(damage_amount)
elif collider.has_method("apply_damage"):
    collider.apply_damage(damage_amount)
elif collider.has_method("on_hit"):
    collider.on_hit(damage_amount)
```

### Enemy Signals
Every enemy emits three decoupled Godot signals:
```gdscript
signal health_changed(current_hp: int, max_hp: int)
signal hit_taken(damage: int, hit_normal: Vector2)
signal destroyed(score: int, death_position: Vector2)
```

- When connecting to Score / Combo UI in Main Scene:
  ```gdscript
  enemy.destroyed.connect(_on_enemy_destroyed)
  
  func _on_enemy_destroyed(score_value: int, death_pos: Vector2) -> void:
      score += score_value
      combo += 1
  ```

---

## 4. Reflector Ricochet Protocol

When the Dell's projectile hits a surface:

```gdscript
# Check if hit collider is a reflector
if collider.is_in_group("reflectors") or collider.get_meta("is_reflective", false):
    var incoming_dir: Vector2 = projectile_velocity.normalized()
    var bounce_normal: Vector2 = collision_info.get_normal()
    var reflected_dir: Vector2 = incoming_dir.bounce(bounce_normal)
    
    # Notify reflector to trigger contact flash VFX
    if collider.has_method("on_ricochet"):
        collider.on_ricochet(collision_info.get_position(), bounce_normal)
    
    # Redirect projectile velocity along reflected direction
    projectile_velocity = reflected_dir * speed
```

---

## 5. Master Asset Manifest

| Filename | Dimensions | Intended Engine Use | Frame Slice Info |
| :--- | :---: | :--- | :--- |
| `player_ship.png` | 48×32 | Player Ship default visual | Single static frame |
| `player_ship_sheet.png` | 192×32 | Player Ship animated thruster | 4 frames @ 48×32 (10 FPS) |
| `enemy_drone_basic.png` | 32×32 | Basic Drone default visual | Single static frame |
| `enemy_drone_basic_sheet.png` | 128×32 | Basic Drone pulsing core | 4 frames @ 32×32 (6 FPS) |
| `enemy_fast.png` | 32×32 | Fast Interceptor default visual | Single static frame |
| `enemy_fast_sheet.png` | 128×32 | Fast Interceptor micro-jets | 4 frames @ 32×32 (10 FPS) |
| `enemy_heavy.png` | 48×48 | Heavy Dreadnought default visual | Single static frame |
| `enemy_heavy_sheet.png` | 192×48 | Heavy Dreadnought reactor & vents | 4 frames @ 48×48 (6 FPS) |
| `reflector_angled_45.png` | 32×32 | 45° diagonal mirror (Bottom-Left to Top-Right) | Single static frame |
| `reflector_angled_135.png`| 32×32 | 135° diagonal mirror (Top-Left to Bottom-Right) | Single static frame |
| `reflector_bar_h.png` | 32×16 | Horizontal surface bounce barrier | Single static frame |
| `reflector_bar_v.png` | 16×32 | Vertical surface bounce barrier | Single static frame |
| `projectile_laser.png` | 20×8 | Player laser bolt sprite | Single static frame |
| `impact_spark_sheet.png` | 128×32 | Projectile impact spark VFX | 4 frames @ 32×32 (16 FPS, no loop) |
| `ricochet_flash.png` | 32×32 | Bounce contact point flare | Single static frame (0.15s fade) |
| `enemy_explode_sheet.png` | 128×32 | Enemy death explosion VFX | 4 frames @ 32×32 (12 FPS, no loop) |
| `showcase_pack_preview.png`| 360×200 | Visual reference & palette verification | Full reference sheet |

---

## 6. Integration Step Checklist (Once Baseline is Pulled)

### Step 1: Copy Assets
Copy all subfolders in `romr_prep/assets/` to `res://assets/`:
- `res://assets/player/`
- `res://assets/enemies/`
- `res://assets/environment/`
- `res://assets/vfx/`

### Step 2: Copy Scenes & Scripts
Copy all subfolders in `romr_prep/scenes/` to `res://scenes/`:
- `res://scenes/enemies/` (`enemy_base.gd`, `enemy_drone.gd`, `enemy_drone.tscn`, `enemy_fast.gd`, `enemy_fast.tscn`, `enemy_heavy.gd`, `enemy_heavy.tscn`)
- `res://scenes/environment/` (`reflector_surface.gd`, `reflector_45.tscn`, `reflector_135.tscn`, `reflector_bar_h.tscn`, `reflector_bar_v.tscn`)
- `res://scenes/vfx/` (`enemy_explosion.gd`, `enemy_explosion.tscn`, `impact_vfx.gd`, `impact_vfx.tscn`, `ricochet_flash.gd`, `ricochet_flash.tscn`)

### Step 3: Configure Project Settings (in `project.godot`)
1. **Texture Filtering:** Set `rendering/textures/canvas_textures/default_texture_filter = 0` (Nearest) to ensure all sprites render with 0 blur.
2. **Layer Names:**
   - Layer 1: World
   - Layer 2: Player
   - Layer 3: Enemies
   - Layer 4: Player Projectiles
   - Layer 5: Reflectors

### Step 4: Verification Tests to Perform After Integration
1. **Spawn Enemy:** Instantiate `enemy_drone.tscn` into the main gameplay scene.
2. **Laser Hit Test:** Fire player projectile at drone. Verify white hit-flash occurs, and enemy HP drops.
3. **Destruction Test:** Fire 3 shots at drone. Verify it explodes into shards (`enemy_explosion.tscn`) and emits `destroyed(100, position)`.
4. **Ricochet Test:** Place `reflector_45.tscn` in projectile path. Shoot horizontally at reflector face. Verify beam ricochets 90° upward and spawns contact flare.
5. **Ricochet-Kill Test:** Angle reflector so the ricocheting beam hits an enemy drone behind cover. Confirm damage registers on bounced hit.
