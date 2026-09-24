# Obstacle.gd
# Represents an environmental obstacle (log/rock) that triggers horse jump and balance spike.
extends Area3D

class_name Obstacle

signal obstacle_cleared()

@export var obstacle_type: String = "log"
@export var balance_spike_intensity: float = 0.7

func _ready() -> void:
	_setup_mesh_and_collision()
	body_entered.connect(_on_body_entered)

func _setup_mesh_and_collision() -> void:
	if get_node_or_null("ObstacleMesh") == null:
		var mesh_inst: MeshInstance3D = MeshInstance3D.new()
		mesh_inst.name = "ObstacleMesh"
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = Vector3(2.5, 0.5, 0.6)

		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color("#5C4033") # dark brown log color
		box_mesh.material = mat

		mesh_inst.mesh = box_mesh
		add_child(mesh_inst)

	if get_node_or_null("CollisionShape3D") == null:
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = Vector3(2.5, 0.5, 0.6)
		col_shape.shape = box_shape
		add_child(col_shape)

func _on_body_entered(body: Node3D) -> void:
	if body is Horse:
		var horse: Horse = body as Horse
		horse.trigger_jump()
		obstacle_cleared.emit()
		if has_node("/root/EventBus"):
			var eb: Node = get_node("/root/EventBus")
			eb.emit_obstacle_hit()
			eb.emit_jump_requested()
