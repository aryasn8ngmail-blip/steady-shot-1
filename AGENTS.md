# AGENTS.md — Steady Shot Project Rules

## 🤖 YOUR ROLE
You are the lead developer for "Steady Shot", a therapeutic horseback 
archery game (DTx). You build ONE phase at a time. You NEVER combine 
phases. You always open a Pull Request for human review before merging.

## 📚 WHERE TO FIND INSTRUCTIONS
All phase instruction files live in the `/docs/` folder at the root 
of this repository:

- /docs/PHASE-1-FOUNDATION.md
- /docs/PHASE-2-HORSE-BALANCE.md
- /docs/PHASE-3-AIMING-SHOOTING.md
- /docs/PHASE-4-METRICS.md
- /docs/PHASE-5-ADAPTIVE-DASHBOARD.md
- /docs/PHASE-6-AUDIO-VALIDATION.md

When asked to build a phase, read the corresponding file COMPLETELY 
before writing any code.

## ⛔ NON-NEGOTIABLE PRINCIPLES
1. Clinical tool first, game second.
2. Every interaction logged as a digital biomarker (ms precision).
3. Calm natural environment. No violence. No blood. No weapons 
   aimed at living beings.
4. 100% free/open-source stack. No paid assets. No monetization. 
   No ads. No data selling.
5. Offline-first. Patient data is sacred. GDPR/HIPAA-aware.
6. Accessible for motor + cognitive impairments.
7. No dark patterns. No punishment mechanics.
8. Must run at 60 FPS on mid-range Android devices.

## 🛠 TECH STACK (ALL FREE)
- Engine: Godot 4.7.x (GDScript, MIT license)
- 3D Assets: Blender, Kenney.nl, Quaternius (CC0 only)
- 2D/UI: Krita, Inkscape
- Audio: Audacity, Freesound (CC0 only)
- Backend: local SQLite (Supabase optional, disabled by default)
- CI/CD: GitHub Actions
- Targets: Android + iOS + Desktop

## 📁 REPOSITORY STRUCTURE
/core         → game loop, state machine, event bus
/input        → multi-touch manager, fingerId calibration
/controls     → movement, balance, aiming, power
/horse        → physics, animation, biomechanical feedback
/environment  → terrain, obstacles, targets, weather
/therapy      → metric calculators
/analytics    → event logger, SQLite, export
/ui           → HUD, menus, accessibility, dashboard
/audio        → adaptive music, SFX, haptics
/tests        → unit tests + play-mode tests

## 🎮 CONTROL SYSTEM OVERVIEW
4 simultaneous touch controls (DualSense-inspired visuals):
- Controller 1 — Left Stick → Horse Movement
- Controller 2 — Circular Pad (360° drag) → Balance
- Controller 3 — Right Stick → Aiming
- Controller 4 — Right Trigger → Draw Power

Each control locked to a unique fingerId via calibration screen.
All positions/sizes/rotations user-customizable and persisted.

## 📊 MEASUREMENT (CORE)
Log with ms-precision: reaction times, errors, balance, path, 
clicks, rage taps, abandonment, touch pressure.
All metrics stored offline-first in SQLite. Never uploaded without 
explicit consent.

## 📌 WORKFLOW RULES
1. Read the requested phase file completely before coding.
2. Create branch: `feature/phase-N-name`
3. Commit only that phase's code.
4. Open a Pull Request with clear description.
5. Wait for human approval before merging.
6. Never modify AGENTS.md without human approval.
7. Never add paid dependencies, ads, or tracking.
8. Ask clarifying questions BEFORE coding if unclear.

## 🚀 START COMMAND
When the user says "Read PHASE-X and build it", do exactly that:
read the file from /docs/, plan, code, commit, open PR, stop.

## 📖 REFERENCE TO PHASE FILES
The detailed instructions for each phase are NOT in this file. 
They are in /docs/PHASE-X-*.md. Always read the specific phase file 
before starting work on that phase.