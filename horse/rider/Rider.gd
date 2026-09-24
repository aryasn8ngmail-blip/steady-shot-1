# Rider.gd
# Manages rider posture, biomechanical weight shifts, torso rotation, startle animation, and stumble posture loss.
extends Node3D

class_name Rider

@export var torso_mesh_node: Node3D = null

var is_startled: bool = false
var startle_timer: float = 0.0
var aim_vector: Vector2 = Vector2.ZERO
var balance_offset: Vector2 = Vector2.ZERO
var is_stumbling: bool = false
var posture_loss_amount: float = 0.0

func _ready() -> void:
	if has_node("/root/EventBus"):
		var eb: Node = get_node("/root/EventBus")
		eb.target_spawned.connect(_on_target_spawned)
		eb.aim_changed.connect(_on_aim_changed)
		eb.imbalance_changed.connect(_on_imbalance_changed)
		eb.horse_stumbled.connect(_on_horse_stumbled)
		eb.horse_recovered.connect(_on_horse_recovered)

func _process(delta: float) -> void:
	if is_startled:
		startle_timer -= delta
		if startle_timer <= 0.0:
			is_startled = false

	_update_rider_pose(delta)

func _update_rider_pose(delta: float) -> void:
	if torso_mesh_node == null:
		return

	# Torso rotation based on aim vector (x yaw, y pitch)
	var target_yaw: float = aim_vector.x * deg_to_rad(45.0)
	var target_roll: float = -balance_offset.x * deg_to_rad(30.0)
	var target_pitch: float = balance_offset.y * deg_to_rad(20.0)

	if is_startled:
		# Brief startle twitch/shake
		target_roll += randf_range(-0.15, 0.15)
		target_pitch += randf_range(-0.1, 0.1)

	if is_stumbling:
		# Posture loss during stumble (leaning forward/side heavily)
		posture_loss_amount = move_toward(posture_loss_amount, 1.0, 3.0 * delta)
		target_pitch += posture_loss_amount * deg_to_rad(35.0)
		target_roll += posture_loss_amount * deg_to_rad(25.0)
	else:
		posture_loss_amount = move_toward(posture_loss_amount, 0.0, 2.0 * delta)

	# Smoothly interpolate rotation
	torso_mesh_node.rotation.y = lerp_angle(torso_mesh_node.rotation.y, target_yaw, 8.0 * delta)
	torso_mesh_node.rotation.z = lerp_angle(torso_mesh_node.rotation.z, target_roll, 8.0 * delta)
	torso_mesh_node.rotation.x = lerp_angle(torso_mesh_node.rotation.x, target_pitch, 8.0 * delta)

func trigger_startle() -> void:
	is_startled = true
	startle_timer = 0.2 # 200ms startle duration

func _on_target_spawned(_pos: Vector3) -> void:
	trigger_startle()

func _on_aim_changed(aim: Vector2) -> void:
	aim_vector = aim

func _on_imbalance_changed(imb_vector: Vector2, _severity: float) -> void:
	balance_offset = imb_vector

func _on_horse_stumbled() -> void:
	is_stumbling = true

func _on_horse_recovered() -> void:
	is_stumbling = false
