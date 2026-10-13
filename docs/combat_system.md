# VECTOR//BREAK — Combat System Architecture

## 1. Core Mechanics & Mathematical Reflection

### Mathematical Vector Bounce
Energy projectiles calculate physical reflection using collision normals via Godot's native Vector2 bounce formula:
$$\vec{v}_{\text{reflected}} = \vec{v} - 2(\vec{v} \cdot \vec{n})\vec{n}$$
* **Ricochet Combo Multiplier:** Each reflection increments `ricochet_combo` by 1.
* **Score Scaling:** Hitting an enemy with a ricocheted projectile multiplies points awarded:
  $$\text{Points} = \text{base\_score} \times \text{ricochet\_combo} \times \text{global\_combo}$$
* **Reflector Group:** Reflectors belong to `"reflective"`, invoke `on_ricochet(point, normal)`, and pulse with intense neon luminescence.

---

## 2. Enemy AI Archetypes

All enemies extend `EnemyBase` (`scripts/enemy_base.gd`) and share:
* Health tracking with `take_damage(amount, combo, hit_point)`.
* Hit flash visual modulation.
* Animated explosion and spark debris cleanup.
* GameManager score dispatching.

### A. Basic Drone (`scripts/enemy_drone.gd`)
* **Behavior:** Sinusoidal vertical bobbing while moving leftward; subtly drifts vertically toward the player's altitude to apply forward pressure.
* **HP:** 50 | **Speed:** 65 | **Score:** 100

### B. Chaser (`scripts/enemy_chaser.gd`)
* **Behavior:** Highly mobile seeker unit. Continuously recalculates vector to the player ship and accelerates forward.
* **Combat Role:** Forces the player to keep moving and avoid camping behind reflectors.
* **HP:** 40 | **Speed:** 150 | **Damage:** 15 contact damage with 1.0s player i-frames.

### C. Striker (`scripts/enemy_striker.gd`)
* **Behavior:** Long-range artillery craft. Maintains mid-range standoff distance ($x \approx 850\text{--}1050$).
* **Attack:** Charges for 0.8s with a bright warning telegraph line, then fires an aimed hostile energy bolt.
* **Counterplay:** Player can dodge, duck behind reflectors, or kill the striker during its charge window.
* **HP:** 60 | **Speed:** 50 | **Damage:** 20 projectile damage.

### D. Dasher (`scripts/enemy_dasher.gd`)
* **Behavior:** Aggressive skirmisher. Tracks player vertically, initiates a high-visibility telegraph (pulsing orange/yellow glow for 0.6s), then charges at 450 px/s along the locked trajectory.
* **Recovery:** Stalls for 1.2s post-charge, completely vulnerable to retaliatory ricochet shots.
* **HP:** 45 | **Dash Speed:** 450 | **Damage:** 25 contact damage.

### E. Heavy Shielded Construct (`scripts/enemy_heavy.gd`)
* **Behavior:** Slow, armored fortress ($HP = 150$).
* **Frontal Energy Shield:** Direct shots hitting its front quadrant ($|angle| < 60^\circ$) are absorbed or deflected for 0 damage with a shield spark effect!
* **Counterplay:** The player *must* bounce projectiles off reflectors above or below to strike its vulnerable rear or flanks!

---

## 3. Boss Encounter: Commander Serin ("The Gatekeeper")

`scripts/boss_serin.gd` & `scenes/boss_serin.tscn`:
* **HP:** 500
* **Phase 1 (100% – 65% HP):**
  * Vertical sinusoidal patrol.
  * Triple aimed energy volleys telegraphed with sound and laser lines.
* **Phase 2 (65% – 30% HP):**
  * Deploys twin orbiting reflective barrier drones that deflect player shots.
  * Fires ricochet energy volleys off the arena walls.
  * Player must thread trick shots between the orbiting barrier gaps.
* **Phase 3 (< 30% HP):**
  * Overcharge desperation mode.
  * Telegraphed horizontal dash charges across the arena + omnidirectional radial burst pulses.
* **Victory Event:** Triggers dramatic death sequence and emits `boss_defeated`.

---

## 4. Environmental Hazards & Obstacles

* **Moving Reflector (`scenes/moving_reflector.tscn`):** Vertical moving reflector that shifts ricochet vectors in real time.
* **Laser Gate Hazard (`scenes/laser_gate.tscn`):** Timed obstacle cycling between 2.0s dormant warning (faint dashed beam) and 1.5s active lethal beam (dealing periodic damage to ships passing through).

---

## 5. Round & Wave Progression

`scripts/round_manager.gd`:
* **Round 1:** Recon Wave (Basic Drones + Chasers).
* **Round 2:** Infiltration (Strikers, Dashers, Moving Reflectors).
* **Round 3:** Armored Bulwark (Heavy Shielded enemies requiring flank ricochets).
* **Round 4:** Boss Encounter (Commander Serin).
* Tracks wave completion, enemy count, and mission timer.
* Emits `round_victory` and `round_defeat` events.
