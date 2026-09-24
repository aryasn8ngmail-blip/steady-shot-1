# test_multi_touch_and_settings.gd
extends SceneTree

var passed_tests := 0
var failed_tests := 0

func _init() -> void:
	print("--- Running Steady Shot Unit Tests ---")
	test_coordinate_normalization()
	test_settings_round_trip()
	test_finger_mapping_persistence()
	test_multi_touch_signals()
	test_preset_saving_and_loading()
	
	print("--- Test Summary: Passed: %d, Failed: %d ---" % [passed_tests, failed_tests])
	if failed_tests > 0:
		quit(1)
	else:
		quit(0)

func assert_true(condition: bool, message: String) -> void:
	if condition:
		passed_tests += 1
		print("[PASS] %s" % message)
	else:
		failed_tests += 1
		print("[FAIL] %s" % message)

func assert_equal(a, b, message: String) -> void:
	if a == b:
		passed_tests += 1
		print("[PASS] %s" % message)
	else:
		failed_tests += 1
		print("[FAIL] %s (Expected %s, got %s)" % [message, str(b), str(a)])

func test_coordinate_normalization() -> void:
	var mt_script = load("res://input/MultiTouchManager.gd")
	var mt = mt_script.new()
	root.add_child(mt)

	var screen_pos := Vector2(640.0, 360.0)
	var norm_pos = mt.normalize_position(screen_pos)
	assert_true(norm_pos.x >= 0.0 and norm_pos.x <= 1.0, "Normalized X is within 0-1 bounds")
	assert_true(norm_pos.y >= 0.0 and norm_pos.y <= 1.0, "Normalized Y is within 0-1 bounds")

	var denorm_pos = mt.denormalize_position(norm_pos)
	assert_equal(denorm_pos, screen_pos, "Denormalization round-trip matches original screen coordinate")

	mt.queue_free()

func test_settings_round_trip() -> void:
	var sm_script = load("res://core/SettingsManager.gd")
	var sm = sm_script.new()
	root.add_child(sm)

	sm.load_settings()
	var initial_version = sm.settings.get("schema_version", 0)
	assert_equal(initial_version, 1, "Settings schema version is 1")

	var custom_config = {"position": {"x": 0.5, "y": 0.5}, "scale": 1.2, "rotation": 45.0, "opacity": 0.9}
	sm.set_control_config("l_stick", custom_config)

	var loaded_config = sm.get_control_config("l_stick")
	assert_equal(loaded_config["scale"], 1.2, "Control scale setting updated and saved successfully")

	sm.queue_free()

func test_finger_mapping_persistence() -> void:
	var sm_script = load("res://core/SettingsManager.gd")
	var sm = sm_script.new()
	root.add_child(sm)

	sm.set_finger_for_control("trigger", 3)
	var mapped_control = sm.get_control_for_finger(3)
	assert_equal(mapped_control, "trigger", "fingerId 3 mapped to trigger control")

	sm.queue_free()

func test_multi_touch_signals() -> void:
	var mt_script = load("res://input/MultiTouchManager.gd")
	var mt = mt_script.new()
	root.add_child(mt)

	var signal_received := false
	mt.touch_started.connect(func(finger_id, _pos):
		if finger_id == 2:
			signal_received = true
	)

	var touch_event = InputEventScreenTouch.new()
	touch_event.index = 2
	touch_event.pressed = true
	touch_event.position = Vector2(100, 100)
	mt._input(touch_event)

	assert_true(signal_received, "MultiTouchManager touch_started signal emitted on screen touch event")
	assert_true(mt.is_finger_active(2), "MultiTouchManager registers touch 2 as active")

	mt.queue_free()

func test_preset_saving_and_loading() -> void:
	var sm_script = load("res://core/SettingsManager.gd")
	var sm = sm_script.new()
	root.add_child(sm)

	sm.save_named_layout("TestTabletPreset")
	var loaded = sm.load_named_layout("TestTabletPreset")
	assert_true(loaded, "Named layout preset saved and loaded successfully")

	sm.queue_free()