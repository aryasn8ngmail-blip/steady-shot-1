# BalanceController.gd
# Manages balance mechanics, force accumulation, drift, user correction, stumble triggers, and auto-recovery.
extends Node

class_name BalanceController

signal imbalance_updated(imbalance_vector: Vector2, severity: float)
signal stumbled()
signal recovered()

@export var max_drift_speed: float = 1.5
@export var corrective_multiplier: float = 2.5
@export var stumble_threshold: float = 0.85
@export var recovery_duration: float = 1.5
@export var damping: float = 1.2

var imbalance_vector: Vector2 = Vector2.ZERO
var disturbance_force: Vector2 = Vector2.ZERO
var user_corrective_vector: Vector2 = Vector2.ZERO
var is_stumbling: bool = false
var recovery_timer: float = 0.0
var previous_aim: Vector2 = Vector2.ZERO

func _ready() -> void:
	if has_node("/root/EventBus"):
		var eb: Node = get_node("/root/EventBus")
		eb.target_spawned.connect(_on_target_spawned)
		eb.aim_changed.connect(_on_aim_changed)
		eb.jump_requested.connect(_on_jump_requested)

func _process(delta: float) -> void:
	if is_stumbling:
		_process_recovery(delta)
		return

	# Apply user correction (dragging knob counteracts disturbance)
	# User drags knob in opposite direction to drift, so adding user_corrective_vector opposes imbalance
	var net_force: Vector2 = disturbance_force - (user_corrective_vector * corrective_multiplier)

	# Integrate drift over time
	imbalance_vector += net_force * delta * max_drift_speed

	# Apply damping towards center when no net forces
	if disturbance_force.length() < 0.05 and user_corrective_vector.length() < 0.05:
		imbalance_vector = imbalance_vector.move_toward(Vector2.ZERO, damping * delta)

	# Decay external transient disturbance forces back to zero
	disturbance_force = disturbance_force.move_toward(Vector2.ZERO, 2.0 * delta)

	var severity: float = clamp(imbalance_vector.length(), 0.0, 1.0)

	# Emit balance updates
	imbalance_updated.emit(imbalance_vector, severity)
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_imbalance_changed(imbalance_vector, severity)

	# Haptic feedback scaling with severity
	if severity > 0.15:
		var haptic_ms: int = int(lerp(10.0, 50.0, severity))
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_haptic_requested(haptic_ms, severity)

	# Check stumble condition
	if severity >= stumble_threshold:
		trigger_stumble()

func apply_terrain_slope(slope_vector: Vector2, delta: float) -> void:
	if is_stumbling:
		return
	disturbance_force += slope_vector * 0.8 * delta

func apply_impulse(impulse: Vector2) -> void:
	if is_stumbling:
		return
	disturbance_force += impulse

func set_user_correction(corrective_vector: Vector2) -> void:
	user_corrective_vector = corrective_vector

func trigger_stumble() -> void:
	if is_stumbling:
		return
	is_stumbling = true
	recovery_timer = recovery_duration
	stumbled.emit()
	if has_node("/root/EventBus"):
		var eb: Node = get_node("/root/EventBus")
		eb.emit_horse_stumbled()
		eb.emit_haptic_requested(150, 1.0)

func _process_recovery(delta: float) -> void:
	recovery_timer -= delta
	# Smoothly reduce imbalance back to zero over recovery duration
	var t: float = clamp(recovery_timer / recovery_duration, 0.0, 1.0)
	imbalance_vector = imbalance_vector * t
	var severity: float = clamp(imbalance_vector.length(), 0.0, 1.0)

	imbalance_updated.emit(imbalance_vector, severity)
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_imbalance_changed(imbalance_vector, severity)

	if recovery_timer <= 0.0:
		is_stumbling = false
		imbalance_vector = Vector2.ZERO
		disturbance_force = Vector2.ZERO
		recovered.emit()
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_horse_recovered()

func _on_target_spawned(_pos: Vector3) -> void:
	# Startle impulse on new target appearance
	apply_impulse(Vector2(randf_range(-0.4, 0.4), randf_range(0.3, 0.6)))

func _on_aim_changed(aim_vector: Vector2) -> void:
	# Impulse from rapid aim changes
	var aim_delta: Vector2 = aim_vector - previous_aim
	if aim_delta.length() > 0.2:
		apply_impulse(aim_delta * 0.5)
	previous_aim = aim_vector

func _on_jump_requested() -> void:
	# Jump causes a vertical/balance disturbance spike
	apply_impulse(Vector2(randf_range(-0.3, 0.3), -0.7))
