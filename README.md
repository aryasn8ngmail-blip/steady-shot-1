# Steady Shot (DTx)

Steady Shot is a therapeutic horseback archery digital therapeutic (DTx) game built with Godot 4 (GDScript).

## Features (Phase 1 - Foundation)
- Multi-Touch Input Manager (`MultiTouchManager.gd`) with persistent `fingerId` tracking and coordinate normalization.
- Settings & Layout Persistence (`SettingsManager.gd`) saving to `user://settings.json`.
- DualSense-inspired therapeutic visual controls: `AnalogStick`, `Trigger`, and `BalancePad`.
- 4-Finger Calibration Screen (`CalibrationScreen.tscn`) with visual & haptic lock confirmations and inactivity timeouts.
- Custom Controller Layout Settings (`LayoutSettings.tscn`) supporting dragging, scaling (0.6x–1.6x), rotating (0°–360°), opacity, mirroring, and preset saving/loading.
- Unit testing suite for multi-touch signal emissions and settings persistence.

## Requirements
- Godot Engine 4.x (headless/GUI)

## Running Unit Tests
You can run the headless test suite using Godot CLI:
```bash
godot --headless -s tests/test_runner.gd
```
Alternatively, run with Python test harness:
```bash
python3 tests/run_tests.py
```

## License
MIT License
