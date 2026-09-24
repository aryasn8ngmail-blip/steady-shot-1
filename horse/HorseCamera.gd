# HorseCamera.gd
# Smooth spring-damper camera follower with configurable stiffness, damping, screen shake, and tilt.
extends Camera3D

class_name HorseCamera

@export var target_node: Node3D = null
@export var follow_offset: Vector3 = Vector3(0.0, 3.5, -6.0)
@export var stiffness: float = 40.0
@export var damping: float = 12.0

var current_velocity: Vector3 = Vector3.ZERO
var shake_trauma: float = 0.0
var tilt_angle: float = 0.0
var is_stumbling: bool = false
var startle_timer: float = 0.0

func _ready() -> void:
	if has_node("/root/EventBus"):
		var eb: Node = get_node("/root/EventBus")
		eb.target_spawned.connect(_on_target_spawned)
		eb.jump_requested.connect(_on_jump_requested)
		eb.horse_stumbled.connect(_on_horse_stumbled)
		eb.horse_recovered.connect(_on_horse_recovered)

func add_trauma(amount: float) -> void:
	shake_trauma = clamp(shake_trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	_update_spring_damper_follow(delta)
	_update_shake_and_tilt(delta)

func _update_spring_damper_follow(delta: float) -> void:
	if target_node == null:
		return

	# Target position in world space with offset relative to target rotation
	var desired_position: Vector3 = target_node.global_transform * follow_offset
	var displacement: Vector3 = global_position - desired_position

	# Spring-damper force calculation
	var spring_force: Vector3 = -stiffness * displacement
	var damping_force: Vector3 = -damping * current_velocity
	var acceleration: Vector3 = spring_force + damping_force

	current_velocity += acceleration * delta
	global_position += current_velocity * delta

	# Look towards target position
	var look_target: Vector3 = target_node.global_position + Vector3(0.0, 1.8, 0.0)
	look_at(look_target, Vector3.UP)

func _update_shake_and_tilt(delta: float) -> void:
	if startle_timer > 0.0:
		startle_timer -= delta

	if shake_trauma > 0.0:
		var shake_amount: float = shake_trauma * shake_trauma # non-linear trauma decay
		var offset_x: float = randf_range(-0.2, 0.2) * shake_amount
		var offset_y: float = randf_range(-0.2, 0.2) * shake_amount
		h_offset = offset_x
		v_offset = offset_y
		shake_trauma = move_toward(shake_trauma, 0.0, 1.2 * delta)
	else:
		h_offset = move_toward(h_offset, 0.0, 5.0 * delta)
		v_offset = move_toward(v_offset, 0.0, 5.0 * delta)

	# Screen tilt during stumble
	if is_stumbling:
		tilt_angle = move_toward(tilt_angle, deg_to_rad(12.0), 3.0 * delta)
	else:
		tilt_angle = move_toward(tilt_angle, 0.0, 2.0 * delta)

	rotation.z = tilt_angle

func _on_target_spawned(_pos: Vector3) -> void:
	startle_timer = 0.2
	add_trauma(0.25)

func _on_jump_requested() -> void:
	add_trauma(0.4)

func _on_horse_stumbled() -> void:
	is_stumbling = true
	add_trauma(0.85)

func _on_horse_recovered() -> void:
	is_stumbling = false
