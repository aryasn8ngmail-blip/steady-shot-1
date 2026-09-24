# PHASE 3 — Aiming & Draw Power

## GOAL
Implement aiming (Controller 3) and draw-power trigger 
(Controller 4), both with DualSense-style visuals.

## DELIVERABLES

### 1. Aiming (/controls/aiming)
- Controller 3 (Right Analog Stick, DualSense-style)
- Drives bow horizontal + vertical aim
- Crosshair appears when aiming, hidden when idle (fade 200ms)
- Smoothing filter (adjustable 0–100% in settings)
- Rapid aim movement → rider torso rotates + balance drifts 
  (feeds Phase 2 balance system)
- Aim movement causes slight camera sway (horseback realism)

### 2. Draw Power (/controls/draw_power)
- Controller 4 (Right Trigger, DualSense-style with radial fill)
- Press-and-hold to draw bow
- Hold duration = shot power (0.2s to 2.0s window)
- Over-draw (>2.0s) → arm fatigue → aim wobble increases
- Release to fire arrow
- Arrow physics: gravity drop, speed scales with power
- Haptic pulse on release (intensity scales with power)

### 3. Target System (/environment/targets)
- Floating glowing crystals / orbs / lanterns
- Placed at varying distances (10m to 50m), heights, angles
- Targets appear/disappear dynamically on a timer
- Valid targets (shoot these) + distractors (don't shoot)
- Target appearance triggers rider startle shake (Phase 2)
- Distractors critical for d-prime measurement (Phase 4)

### 4. Non-Violent Feedback (/audio + /ui)
- Hit → soft chime + gentle glow burst + positive haptic
- Miss → soft "try again" tone, no punishment
- No blood, no damage numbers, no aggression

### 5. Unit Tests (/tests)
- Aim smoothing filter behavior
- Arrow trajectory physics
- Over-draw fatigue calculation
- Target spawn/despawn logic

## ACCEPTANCE CRITERIA
- All 4 controls work simultaneously with 4 fingers
- Aim feels smooth, not jittery
- Over-draw fatigue is noticeable but fair
- Rider reacts visibly to aim change
- Non-violent, calm feedback throughout
- 60 FPS maintained
- All unit tests pass

## DO NOT
- Do NOT add metrics yet
- Do NOT add adaptive difficulty yet
- Do NOT add therapist dashboard yet

## DEPENDENCIES
Phase 1 + Phase 2 merged.

## BRANCH NAME
`feature/phase-3-aiming-shooting`