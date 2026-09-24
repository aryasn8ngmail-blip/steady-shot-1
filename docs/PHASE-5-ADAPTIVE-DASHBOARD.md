\# PHASE 5 — Adaptive Difficulty, Therapist Dashboard, Reports



\## GOAL

Make the game adapt to the patient, give therapists a full analytics 

dashboard, and provide complete accessibility.



\## DELIVERABLES



\### 1. Adaptive Difficulty Engine (/therapy/adaptive)

\- Real-time adjustment based on:

&#x20; \* Recent accuracy (last 10 trials)

&#x20; \* RT trend (slope over last 20 trials)

&#x20; \* Balance stability (variance)

&#x20; \* Frustration signals (rage taps, abandonment)

\- 3 poor trials in a row → reduce difficulty

\- Stable high performance → increase difficulty

\- NEVER punish. ALWAYS encourage.

\- Log every difficulty change with reason



\### 2. Therapist Dashboard (/ui/dashboard, web)

Free stack: HTML + Chart.js + Supabase (or local server)

Charts:

\- RT trend over weeks

\- Error rate trend

\- Balance stability trend

\- Aim accuracy heatmap

\- Correlation with PHQ-9 / GAD-7 (manual entry)

\- Session-by-session comparison

\- Patient list with anonymized IDs

\- Export to CSV



\### 3. PDF Session Report (/analytics/pdf)

\- Auto-generated per session

\- Summary metrics, charts, therapist notes

\- Export from dashboard

\- Library: reportlab (Python) or equivalent free tool



\### 4. Accessibility Modes (/ui/accessibility)

\- One-hand mode (sequential controls)

\- Left/right hand mirror

\- High contrast

\- Dyslexia-friendly font

\- Colorblind palettes (deuteranopia, protanopia, tritanopia)

\- Calm Mode (no time pressure)

\- Voice guidance (free TTS)

\- Adjustable: sensitivity, dead zone, haptic intensity, 

&#x20; aim smoothing, balance difficulty



\## ACCEPTANCE CRITERIA

\- Difficulty adapts smoothly, never jarring

\- Dashboard works offline + online

\- PDF opens correctly on Android + Desktop

\- All accessibility modes functional

\- Tested by at least 1 therapist for usability

\- All unit tests pass



\## DO NOT

\- Do NOT skip accessibility — it is clinical, not optional

\- Do NOT add monetization

\- Do NOT sell data



\## DEPENDENCIES

Phases 1–4 merged.



\## BRANCH NAME

`feature/phase-5-adaptive-dashboard`

