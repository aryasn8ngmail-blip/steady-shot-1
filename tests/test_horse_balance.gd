# test_horse_balance.gd
# Unit tests for Phase 2: Horse, Movement, Balance Controller, Camera Stability, and Recovery.
extends SceneTree

var passed_tests: int = 0
var failed_tests: int = 0

func _init() -> void:
	print("--- Running Steady Shot Phase 2 Unit Tests ---")
	test_balance_drift_calculation()
	test_corrective_force_application()
	test_recovery_timing_after_disturbance()
	test_camera_spring_damper_stability()

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

func test_balance_drift_calculation() -> void:
	var bc_script = load("res://controls/balance/BalanceController.gd")
	var bc = bc_script.new()
	root.add_child(bc)

	var initial_imbalance: float = bc.imbalance_vector.length()
	assert_equal(initial_imbalance, 0.0, "Initial balance vector is ZERO")

	# Apply external disturbance impulse
	bc.apply_impulse(Vector2(0.5, 0.5))
	bc._process(0.1)

	var drifted_imbalance: float = bc.imbalance_vector.length()
	assert_true(drifted_imbalance > 0.0, "Disturbance force correctly causes balance drift")

	bc.queue_free()

func test_corrective_force_application() -> void:
	var bc_script = load("res://controls/balance/BalanceController.gd")
	var bc = bc_script.new()
	root.add_child(bc)

	# Set initial imbalance vector
	bc.imbalance_vector = Vector2(0.5, 0.0)
	bc.disturbance_force = Vector2(0.5, 0.0)

	# Apply user corrective force in opposite direction (drag knob counteracts drift)
	bc.set_user_correction(Vector2(0.5, 0.0))
	bc._process(0.1)

	# Net force = 0.5 - (0.5 * 2.5) = -0.75, so vector should move toward zero or reverse
	assert_true(bc.imbalance_vector.x < 0.5, "User corrective force reduces/counteracts balance drift")

	bc.queue_free()

func test_recovery_timing_after_disturbance() -> void:
	var bc_script = load("res://controls/balance/BalanceController.gd")
	var bc = bc_script.new()
	root.add_child(bc)

	# Trigger stumble state
	bc.trigger_stumble()
	assert_true(bc.is_stumbling, "BalanceController enters stumbling state")
	assert_equal(bc.recovery_timer, 1.5, "Recovery duration initialized to 1.5 seconds")

	# Process 1.0 second of recovery
	bc._process(1.0)
	assert_true(bc.is_stumbling, "Still recovering at 1.0s")

	# Process remaining 0.6 seconds of recovery (total 1.6s > 1.5s)
	bc._process(0.6)
	assert_true(not bc.is_stumbling, "Auto-recovery completes after 1.5s")
	assert_equal(bc.imbalance_vector, Vector2.ZERO, "Imbalance vector reset to ZERO after recovery")

	bc.queue_free()

func test_camera_spring_damper_stability() -> void:
	var hc_script = load("res://horse/HorseCamera.gd")
	var hc = hc_script.new()
	root.add_child(hc)

	var target = Node3D.new()
	root.add_child(target)
	target.global_position = Vector3(0, 0, 0)
	hc.target_node = target
	hc.global_position = Vector3(0, 3.5, -10.0) # Distanced from offset

	# Run multiple physics updates to simulate spring-damper convergence
	for i in range(60):
		hc._process(0.016)

	var final_dist: float = hc.global_position.distance_to(target.global_transform * hc.follow_offset)
	assert_true(final_dist < 0.5, "Spring-damper camera smoothly converges to target position without instability")

	hc.queue_free()
	target.queue_free()
