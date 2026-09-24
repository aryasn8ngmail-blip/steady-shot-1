\# PHASE 6 — Audio, Polish, Clinical Validation Prep



\## GOAL

Final polish + prepare for clinical pilot test.



\## DELIVERABLES



\### 1. Adaptive Audio (/audio)

\- Calm instrumental music (CC0 only)

\- Tempo adapts to user's breathing rhythm (optional breathing guide)

\- Natural sounds: hooves, wind, water, birds, leaves

\- Positive reinforcement sounds (soft chime, no aggression)

\- Haptic + audio pairing for every event

\- All audio CC0 / self-recorded



\### 2. Environment Expansion (/environment)

\- 4 biomes: forest → meadow → mountain → riverside

\- Time of day: soft morning/afternoon only

\- Muted greens, warm earth, soft sky blues

\- No dark or threatening imagery

\- Smooth transitions between biomes



\### 3. Performance \& Polish

\- Object pooling for targets, particles, arrows

\- Profiling on low-end Android (2GB RAM target)

\- Latency audit: input-to-render < 50ms

\- Multi-touch stress test: 4 touches @ 60 FPS for 10 min

\- Memory leak audit: 30-min session, no growth

\- Battery usage optimization



\### 4. Documentation

\- README.md (developer setup)

\- CLINICAL\_GUIDE.md (therapist guide)

\- THERAPIST\_MANUAL.md (session protocol)

\- ACCESSIBILITY.md

\- CONTRIBUTING.md

\- CHANGELOG.md



\### 5. Clinical Validation Prep

\- Compare logged metrics vs validated tests 

&#x20; (Stroop, Go/No-Go, Stop-Signal Task)

\- Pilot test protocol document

\- Consent form template

\- Data anonymization checklist

\- IRB / ethics review checklist



\## ACCEPTANCE CRITERIA

\- Runs 60 FPS on mid-range Android

\- No memory leaks after 30-min session

\- All docs complete

\- Ready for IRB / ethics review

\- All unit tests pass

\- APK size under 80MB



\## DO NOT

\- Do NOT add monetization

\- Do NOT add ads

\- Do NOT sell data

\- Do NOT ship without clinical review



\## DEPENDENCIES

Phases 1–5 merged.



\## BRANCH NAME

`feature/phase-6-audio-validation`

