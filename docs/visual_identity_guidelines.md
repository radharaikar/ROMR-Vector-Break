# VECTOR//BREAK — Visual Identity Guidelines & Palette Specification

**Visual Target Reference:** Concept Poster (`VECTOR//BREAK — A ROMR GAME`)  
**Engine:** Godot 4.7.2  
**Art Style:** Clean, high-contrast arcade sci-fi pixel art with neon emissive accents  

---

## 1. Exact Color Palette & Swatches

### Environment & Hull Darks
- **Deep Space Void:** `#0a0e1c` / `(10, 14, 28)` — Background cosmos, empty sky
- **Obsidian Bulkhead:** `#151b2e` / `(21, 27, 46)` — Station catwalks, enemy shadow armor
- **Gunmetal Alloy:** `#262e44` / `(38, 46, 68)` — Main enemy chassis, mechanical mounts
- **High-Alloy Edge:** `#414e6c` / `(65, 78, 108)` — Chamfered armor highlights, metal rims

### Player Spacecraft (Pale Titanium & Cyan)
- **Titanium Highlight:** `#f8fafc` / `(248, 250, 252)` — Sunlight glint on player hull
- **Titanium Plating:** `#dae2ec` / `(218, 226, 236)` — Primary pale hull armor
- **Titanium Shade:** `#9fb3c8` / `(159, 179, 200)` — Underside bevel and panel shade
- **Titanium Seam:** `#334e68` / `(51, 78, 104)` — Structural cuts, wing roots

### Emissive Neon Energy Accents
- **Electric Cyan (Player/Weapons):**
  - Core: `#ffffff` / `(255, 255, 255)`
  - Bright Aura: `#00f0ff` / `(0, 240, 255)`
  - Mid Beam: `#00a0e6` / `(0, 160, 230)`
- **Neon Magenta / Violet (Exhaust / Reflectors / VFX):**
  - Reflector Core: `#ff0080` / `(255, 0, 128)`
  - Gleam Highlight: `#ff50b4` / `(255, 80, 180)`
  - Violet Conduit: `#9b00ff` / `(155, 0, 255)`
  - Deep Violet Base: `#4b0578` / `(75, 5, 120)`
- **Hostile Red / Crimson (Enemy Cores & Hazard):**
  - Pupil Star: `#ffffff` / `(255, 255, 255)`
  - Radiant Laser Red: `#ff143c` / `(255, 20, 60)`
  - Core Body: `#be0028` / `(190, 0, 40)`

---

## 2. Asset Manifest & Specifications

| Asset Name | Relative Path | Resolution | Mode | Description |
| :--- | :--- | :---: | :---: | :--- |
| **Player Ship** | `assets/player/player_ship.png` | 48x32 | RGBA | Pale metal dart fuselage, cyan cockpit, magenta jet |
| **Player Animated** | `assets/player/player_ship_sheet.png` | 192x32 | RGBA | 4 frames with pulsing thruster flame & spark tail |
| **Basic Spike Drone** | `assets/enemies/enemy_drone_basic.png` | 32x32 | RGBA | Octagonal dark metal sphere, 8 spikes, glowing red core |
| **Basic Drone Pulse** | `assets/enemies/enemy_drone_basic_sheet.png`| 128x32| RGBA | 4 frames with pulsating ocular sensor |
| **Fast Interceptor** | `assets/enemies/enemy_fast.png` | 32x32 | RGBA | Sharp triangle wedge facing -X, magenta rims, red eye |
| **Fast Interceptor Sheet**| `assets/enemies/enemy_fast_sheet.png` | 128x32 | RGBA | 4 frames with flashing core and twin micro-jets |
| **Heavy Dreadnought** | `assets/enemies/enemy_heavy.png` | 48x48 | RGBA | Massive armored octagonal chassis, concentric reactor |
| **Heavy Dread Sheet** | `assets/enemies/enemy_heavy_sheet.png`| 192x48 | RGBA | 4 frames with cooling vents and pulsating reactor |
| **Reflector 45°** | `assets/environment/reflector_angled_45.png`| 32x32 | RGBA | Diagonal neon magenta mirror prism on industrial base |
| **Reflector 135°**| `assets/environment/reflector_angled_135.png`| 32x32 | RGBA | Inverted diagonal neon magenta mirror prism |
| **Reflector Bar (H)**| `assets/environment/reflector_bar_h.png` | 32x16 | RGBA | Horizontal neon mirror bar with end-brackets |
| **Reflector Bar (V)**| `assets/environment/reflector_bar_v.png` | 16x32 | RGBA | Vertical neon mirror bar with end-brackets |
| **Cyan Laser Bolt** | `assets/vfx/projectile_laser.png` | 20x8 | RGBA | Electric cyan needle bolt with trailing comet tail |
| **Impact Spark Sheet**| `assets/vfx/impact_spark_sheet.png` | 128x32 | RGBA | 4-frame starburst, shock diamond, spark dispersion |
| **Ricochet Flash** | `assets/vfx/ricochet_flash.png` | 32x32 | RGBA | Angular 4-point cross flash for mirror bounce contact |
| **Enemy Explosion** | `assets/vfx/enemy_explode_sheet.png` | 128x32 | RGBA | 4-frame red core collapse & dark metal shard scatter |
| **Showcase Composite**| `assets/showcase_pack_preview.png` | 360x200 | RGBA | Assembled visual target validation composition |

---

## 3. Engine Import Rules (Godot 4.7.2)

To preserve crisp pixel edges and prevent blurry filtering:
1. **Texture Filter:** All 2D sprites must have `texture_filter = 1` (`TEXTURE_FILTER_NEAREST`).
2. **Project Stretch Mode:**
   - In `project.godot`:
     ```ini
     [display]
     window/stretch/mode="canvas_items"
     window/stretch/aspect="keep" ; or "expand"
     ```
3. **Integer Scaling:** If scaling the viewport up to 1080p, pixel graphics scale cleanly at 3x or 4x without fractional subpixel shimmering.
