# EventBus.gd
# Global event bus singleton for decoupled communication across Steady Shot systems.
extends Node

signal target_spawned(position: Vector3)
signal aim_changed(aim_vector: Vector2)
signal jump_requested()
signal obstacle_hit()
signal imbalance_changed(imbalance_vector: Vector2, severity: float)
signal horse_stumbled()
signal horse_recovered()
signal haptic_requested(duration_ms: int, intensity: float)

func emit_target_spawned(pos: Vector3) -> void:
	target_spawned.emit(pos)

func emit_aim_changed(aim_vector: Vector2) -> void:
	aim_changed.emit(aim_vector)

func emit_jump_requested() -> void:
	jump_requested.emit()

func emit_obstacle_hit() -> void:
	obstacle_hit.emit()

func emit_imbalance_changed(imbalance_vector: Vector2, severity: float) -> void:
	imbalance_changed.emit(imbalance_vector, severity)

func emit_horse_stumbled() -> void:
	horse_stumbled.emit()

func emit_horse_recovered() -> void:
	horse_recovered.emit()

func emit_haptic_requested(duration_ms: int, intensity: float) -> void:
	haptic_requested.emit(duration_ms, intensity)
