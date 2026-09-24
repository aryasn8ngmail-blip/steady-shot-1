# FloatingTarget.gd
# Non-violent floating glowing target that emits startle event on appearance and hovers calmly.
extends Node3D

class_name FloatingTarget

signal target_activated(position: Vector3)

@export var hover_amplitude: float = 0.25
@export var hover_frequency: float = 1.5
@export var is_active: bool = true

var time_passed: float = 0.0
var base_y: float = 0.0

func _ready() -> void:
	base_y = position.y
	_setup_mesh()
	if is_active:
		activate_target()

func _setup_mesh() -> void:
	if get_node_or_null("TargetMesh") != null:
		return

	var mesh_inst: MeshInstance3D = MeshInstance3D.new()
	mesh_inst.name = "TargetMesh"
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color("#F5A623") # yellow color
	mat.emission_enabled = true
	mat.emission = Color("#F5A623")
	mat.emission_energy_multiplier = 0.5
	sphere.material = mat

	mesh_inst.mesh = sphere
	add_child(mesh_inst)

func activate_target() -> void:
	is_active = true
	visible = true
	target_activated.emit(global_position)
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_target_spawned(global_position)

func _process(delta: float) -> void:
	if not is_active:
		return

	time_passed += delta
	position.y = base_y + sin(time_passed * hover_frequency) * hover_amplitude
	rotation.y += delta * 0.5
