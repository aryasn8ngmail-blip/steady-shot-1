\# PHASE 1 — Foundation, Multi-Touch Manager, Controller Layout



\## GOAL

Set up the Godot 4 project skeleton, multi-touch input manager, 

4-finger calibration screen, and a fully customizable controller 

layout system with DualSense-style visuals.



\## DELIVERABLES



\### 1. Project Skeleton

\- Godot 4.7.x project, MIT license

\- README.md, .gitignore

\- Folder structure: /core /input /controls /horse /environment 

&#x20; /therapy /analytics /ui /audio /tests

\- GitHub Actions CI: lint GDScript + run unit tests



\### 2. MultiTouchManager (/input)

\- Autoload singleton `MultiTouchManager.gd`

\- Detects up to 5 simultaneous touches via InputEventScreenTouch/Drag

\- Each touch assigned a persistent fingerId

\- Signals: touch\_started(fingerId, position), touch\_moved, 

&#x20; touch\_ended, control\_activated(control\_name, fingerId)

\- Handles screen coordinate normalization (0–1) for cross-device 

&#x20; compatibility



\### 3. 4-Finger Calibration Screen (/ui/calibration)

\- Scene: CalibrationScreen.tscn

\- Shows 4 glowing zones (L-stick, R-stick, Balance pad, Trigger)

\- User places each finger on its zone one at a time

\- System locks fingerId → control mapping

\- Stored in user://settings.json

\- Recalibration button in settings

\- Visual + haptic confirmation on lock

\- Timeout protection (if no touch for 10s, show hint)



\### 4. Controller Layout Settings (/ui/settings)

CRITICAL FEATURE. Scene: LayoutSettings.tscn

User must be able to:

\- Drag any controller to any position

\- Resize each controller (0.6× to 1.6×)

\- Rotate controller base (0°–360°)

\- Adjust opacity (0.2–1.0)

\- Mirror layout (left-hand / right-hand mode)

\- Save/load named layouts (e.g., "My Phone", "Tablet", "Left Hand")

\- Reset to default DualSense-style layout

\- Live preview while adjusting

\- Positions stored as normalized coords (0–1)



\### 5. DualSense-Style Visuals (/ui/controls)

Reusable scenes with calm, soft, therapeutic look:



\*\*AnalogStick.tscn\*\*

\- Circular base (matte dark gray #2A2E35)

\- Rim glow (cyan #5FD3F3 at 30% idle → 100% active)

\- Concave cap (#3A3F47) with subtle radial texture

\- Dead zone shown as faint inner ring

\- On touch: cap depresses 2px, micro-haptic



\*\*Trigger.tscn\*\*

\- Curved trigger silhouette, rounded edges

\- Base: matte light gray (#E5E7EB) with soft inner shadow

\- Radial fill meter (amber #F5A623 → #F76B1C)

\- On press: visual depression, haptic scales with power

\- On release: quick pulse, arc resets



\*\*BalancePad.tscn\*\*

\- Circular pad (matte finish, 200px)

\- Center knob (concave cap like sticks)

\- 360° drag, optional spring-back to center

\- Rim color shifts: cyan (balanced) → amber → muted red (imbalanced)

\- Haptic frequency scales with imbalance



\### 6. Settings Persistence (/core)

\- JSON file: user://settings.json

\- Contains: fingerId map, controller positions, sizes, rotations, 

&#x20; opacity, accessibility flags, saved layouts

\- Auto-load on launch

\- Schema versioned (for future migrations)



\### 7. Unit Tests (/tests)

\- Test MultiTouchManager signal emission

\- Test settings save/load round-trip

\- Test coordinate normalization

\- Test fingerId persistence



\## ACCEPTANCE CRITERIA

\- 4 fingers can be placed simultaneously and each drives its control

\- User can drag every controller to a new position and it persists 

&#x20; after app restart

\- Visuals clearly resemble DualSense but calm/soft (no RGB rainbow)

\- No crashes on rapid multi-touch (test 100 touches/sec)

\- 60 FPS on mid-range Android

\- All unit tests pass

\- CI runs on every PR



\## DO NOT

\- Do NOT build gameplay yet (no horse, no aiming)

\- Do NOT add metrics yet

\- Do NOT add audio yet

\- Do NOT skip tests



\## BRANCH NAME

`feature/phase-1-foundation`



\## PR CHECKLIST

\- \[ ] Code compiles in Godot 4.7.x

\- \[ ] All tests pass

\- \[ ] No hardcoded paths

\- \[ ] All coordinates normalized

\- \[ ] README updated with setup instructions

\- \[ ] Screenshots of the 4 controls included

