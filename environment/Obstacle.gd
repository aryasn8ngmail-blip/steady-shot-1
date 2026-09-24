# Obstacle.gd
# Represents an environmental obstacle (log/rock) that triggers horse jump and balance spike.
extends Area3D

class_name Obstacle

signal obstacle_cleared()

@export var obstacle_type: String = "log"
@export var balance_spike_intensity: float = 0.7

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Horse:
		var horse: Horse = body as Horse
		horse.trigger_jump()
		obstacle_cleared.emit()
		if has_node("/root/EventBus"):
			var eb: Node = get_node("/root/EventBus")
			eb.emit_obstacle_hit()
			eb.emit_jump_requested()
