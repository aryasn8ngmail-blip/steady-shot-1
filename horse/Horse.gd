# Horse.gd
# Controls horse physics, speed, heading driven by Left Stick (Controller 1), procedural gallop animation, and idle breathing.
extends Node3D

class_name Horse

signal speed_changed(speed: float)
signal heading_changed(heading: Vector3)
signal jump_started()

@export var max_speed: float = 12.0
@export var acceleration: float = 8.0
@export var deceleration: float = 10.0
@export var turn_speed: float = 4.0
@export var dead_zone: float = 0.12

# Node references
@export var body_mesh_node: Node3D = null

var current_speed: float = 0.0
var target_speed: float = 0.0
var move_direction: Vector3 = Vector3.FORWARD
var target_direction: Vector3 = Vector3.FORWARD

# Procedural animation parameters
var gallop_phase: float = 0.0
var breath_phase: float = 0.0
var is_jumping: bool = false
var is_stumbling: bool = false

# Left stick input vector
var stick_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	if has_node("/root/EventBus"):
		var eb: Node = get_node("/root/EventBus")
		eb.horse_stumbled.connect(_on_stumbled)
		eb.horse_recovered.connect(_on_recovered)

func set_stick_input(input: Vector2) -> void:
	stick_input = input

func _process(delta: float) -> void:
	_update_movement(delta)
	_animate_procedural(delta)

func _update_movement(delta: float) -> void:
	var raw_mag: float = stick_input.length()

	if raw_mag < dead_zone:
		target_speed = 0.0
	else:
		var remapped_mag: float = (raw_mag - dead_zone) / (1.0 - dead_zone)
		target_speed = remapped_mag * max_speed

		# Direction in 3D XZ plane (stick_input.x = right/left, stick_input.y = forward/back)
		var input_dir: Vector3 = Vector3(stick_input.x, 0.0, stick_input.y).normalized()
		if input_dir.length_squared() > 0.001:
			target_direction = input_dir

	# Adjust current speed toward target
	if target_speed > current_speed:
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, target_speed, deceleration * delta)

	# Reduce speed if stumbling
	if is_stumbling:
		current_speed = move_toward(current_speed, 1.5, deceleration * 1.5 * delta)

	# Turn smoothly toward target direction if moving
	if current_speed > 0.1 and target_direction.length_squared() > 0.001:
		move_direction = move_direction.slerp(target_direction, turn_speed * delta).normalized()
		look_at(global_position + move_direction, Vector3.UP)

	# Translate horse in world
	global_position += move_direction * current_speed * delta

	speed_changed.emit(current_speed)
	heading_changed.emit(move_direction)

func trigger_jump() -> void:
	if is_jumping or is_stumbling:
		return
	is_jumping = true
	jump_started.emit()
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_jump_requested()

	# Reset jump state after jump duration
	var timer: SceneTreeTimer = get_tree().create_timer(0.8)
	timer.timeout.connect(func(): is_jumping = false)

func _animate_procedural(delta: float) -> void:
	if body_mesh_node == null:
		return

	if current_speed > 0.2:
		# Procedural gallop animation synced to speed
		var stride_frequency: float = 2.5 + (current_speed / max_speed) * 3.5
		gallop_phase += delta * stride_frequency * TAU

		var vertical_bob: float = sin(gallop_phase) * 0.15 * (current_speed / max_speed)
		var pitch_bob: float = cos(gallop_phase) * 0.08

		if is_jumping:
			vertical_bob += 0.5 * sin(clamp(gallop_phase, 0.0, PI))

		body_mesh_node.position.y = vertical_bob
		body_mesh_node.rotation.x = pitch_bob
	else:
		# Idle breathing animation
		gallop_phase = 0.0
		breath_phase += delta * 1.5
		var breath_y: float = sin(breath_phase) * 0.03
		var breath_pitch: float = cos(breath_phase * 0.5) * 0.015

		body_mesh_node.position.y = breath_y
		body_mesh_node.rotation.x = breath_pitch

func _on_stumbled() -> void:
	is_stumbling = true

func _on_recovered() -> void:
	is_stumbling = false
