\# PHASE 2 — Horse, Movement, Balance Controller



\## GOAL

Implement horse movement (Controller 1) and balance system 

(Controller 2) with realistic biomechanical feedback.



\## DELIVERABLES



\### 1. Horse Movement (/horse)

\- Controller 1 (Left Analog Stick) drives horizontal heading + speed

\- Magnitude = speed, direction = heading

\- Dead zone 12% (adjustable via settings)

\- Procedural gallop animation synced to speed

\- Camera follows with spring-damper (not rigid) — configurable 

&#x20; stiffness + damping

\- Idle: breathing animation



\### 2. Balance System (/controls/balance)

\- Controller 2 (Circular Pad, 360° drag)

\- Horse generates imbalance forces from:

&#x20; \* Terrain slope and bumps

&#x20; \* Jumping over obstacles

&#x20; \* Sudden target appearance (startle)

&#x20; \* Rapid aim direction changes (from Phase 3)

\- Hidden balance meter drifts off-center based on forces

\- User drags knob in opposite direction to recenter

\- Drag distance = corrective force magnitude

\- If imbalance exceeds threshold:

&#x20; \* Horse stumbles, camera shakes + tilts

&#x20; \* Rider loses posture (animation)

&#x20; \* Auto-recovery over 1.5s

\- NO death, NO punishment, NO game over

\- Haptic vibration scales with imbalance severity



\### 3. Rider Shake Triggers (/horse/rider)

\- New target appears → brief startle shake (200ms)

\- Aim direction changes rapidly → torso rotates, weight shifts, 

&#x20; balance meter drifts

\- Jump → vertical camera shake + balance spike

\- Stumble → strong shake + screen tilt + recovery animation

\- All with paired haptics



\### 4. Basic Environment (/environment)

\- One biome: meadow + forest edge

\- Calm palette: muted greens, warm earth, soft sky

\- One obstacle (rock or log) with jump animation

\- One floating glowing target (non-violent)

\- Ambient particles: dust, grass sway



\### 5. Unit Tests (/tests)

\- Balance drift calculation

\- Corrective force application

\- Recovery timing after disturbance

\- Camera spring-damper stability



\## ACCEPTANCE CRITERIA

\- Riding feels natural and alive (subjective test with 3 users)

\- Balance knob correctly counters drift

\- Rider shakes visibly on target change and aim change

\- Haptics fire at the right moments (no false positives)

\- 60 FPS maintained on mid-range Android

\- All unit tests pass



\## DO NOT

\- Do NOT implement aiming or shooting yet

\- Do NOT add metrics yet

\- Do NOT add adaptive difficulty yet



\## DEPENDENCIES

Phase 1 must be merged and stable.



\## BRANCH NAME

`feature/phase-2-horse-balance`

