\# PHASE 4 — Therapeutic Metrics Engine \& Data Logging



\## GOAL

Build the clinical measurement layer. Every interaction becomes 

a digital biomarker with ms precision.



\## DELIVERABLES



\### 1. Event Logger (/analytics)

\- Autoload `EventLogger.gd`

\- Every event → JSON with ms timestamp

\- Schema: {timestamp, event\_type, fingerId, position, pressure, 

&#x20; size, target\_id, reaction\_time, power, balance\_value, 

&#x20; aim\_angle, control\_name, session\_id}

\- Local SQLite (offline-first)

\- Optional encrypted Supabase sync (disabled by default)

\- Data anonymized by default, no PII without consent

\- Retention policy: configurable (default 90 days)



\### 2. Metric Calculators (/therapy)

Implement + unit-test each:



\*\*Reaction Speed:\*\*

\- Simple Reaction Time (SRT)

\- Choice Reaction Time (CRT)

\- Reaction Time Variability (RTV)

\- Shot Release Latency



\*\*Attention \& Targeting:\*\*

\- d-prime (hit rate vs false alarm rate)

\- Hit accuracy %

\- Aim path efficiency

\- Fixation duration

\- Distractor resistance score



\*\*Inhibitory Control:\*\*

\- Commission errors (shot at distractor)

\- Omission errors (missed valid target)

\- Stop-Signal Delay (on hold cue)

\- Over-draw count

\- Premature release count



\*\*Motor Coordination:\*\*

\- Balance deviation (avg distance from center)

\- Balance recovery time

\- Path deviation (horizontal drift)

\- Jump timing accuracy

\- Touch pressure variability



\*\*Emotional / Behavioral:\*\*

\- Clicks per task

\- Inter-trial pause

\- Session rhythm variability

\- Rage taps (rapid repeated taps same spot)

\- Abandonment events

\- Recovery time after error



\### 3. Session Report (/analytics/report)

\- End-of-session summary screen

\- Export: CSV, JSON, PDF

\- Anonymized by default

\- Therapist notes field



\### 4. Unit Tests (/tests/therapy)

\- Every metric calculator must have tests with known inputs 

&#x20; and expected outputs

\- Validate against published neuropsych literature

&#x20; (reference: Stroop, Go/No-Go, Stop-Signal Task)



\## ACCEPTANCE CRITERIA

\- Every metric calculated correctly (verified by tests)

\- Data persists across app restarts

\- Export works on Android + Desktop

\- No PII stored without consent

\- SQLite size stays under 100MB for 30-day use

\- All unit tests pass



\## DO NOT

\- Do NOT build therapist dashboard yet (Phase 5)

\- Do NOT add adaptive difficulty yet

\- Do NOT sync to cloud by default



\## DEPENDENCIES

Phases 1, 2, 3 merged.



\## BRANCH NAME

`feature/phase-4-metrics`

