# MultiTouchManager.gd
# Autoload singleton handling multi-touch input and fingerId mapping
extends Node

signal touch_started(finger_id: int, normalized_position: Vector2)
signal touch_moved(finger_id: int, normalized_position: Vector2)
signal touch_ended(finger_id: int, normalized_position: Vector2)
signal control_activated(control_name: String, finger_id: int)

# Active touches map: finger_id (int) -> normalized_position (Vector2)
var active_touches: Dictionary = {}
const MAX_TOUCHES := 5

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch_event(event)
	elif event is InputEventScreenDrag:
		_handle_drag_event(event)

func _handle_touch_event(event: InputEventScreenTouch) -> void:
	var finger_id: int = event.index
	var norm_pos: Vector2 = normalize_position(event.position)

	if event.pressed:
		if active_touches.size() < MAX_TOUCHES or active_touches.has(finger_id):
			active_touches[finger_id] = norm_pos
			touch_started.emit(finger_id, norm_pos)
			_check_control_activation(finger_id)
	else:
		if active_touches.has(finger_id):
			active_touches.erase(finger_id)
			touch_ended.emit(finger_id, norm_pos)

func _handle_drag_event(event: InputEventScreenDrag) -> void:
	var finger_id: int = event.index
	var norm_pos: Vector2 = normalize_position(event.position)

	if active_touches.has(finger_id):
		active_touches[finger_id] = norm_pos
		touch_moved.emit(finger_id, norm_pos)

func normalize_position(screen_pos: Vector2) -> Vector2:
	var viewport = get_viewport()
	var viewport_size := Vector2(1280, 720)
	if viewport != null and viewport.get_visible_rect().size.x > 0:
		viewport_size = viewport.get_visible_rect().size
	
	return Vector2(
		clamp(screen_pos.x / viewport_size.x, 0.0, 1.0),
		clamp(screen_pos.y / viewport_size.y, 0.0, 1.0)
	)

func denormalize_position(norm_pos: Vector2) -> Vector2:
	var viewport = get_viewport()
	var viewport_size := Vector2(1280, 720)
	if viewport != null and viewport.get_visible_rect().size.x > 0:
		viewport_size = viewport.get_visible_rect().size

	return Vector2(
		norm_pos.x * viewport_size.x,
		norm_pos.y * viewport_size.y
	)

func _check_control_activation(finger_id: int) -> void:
	if has_node("/root/SettingsManager"):
		var settings = get_node("/root/SettingsManager")
		var control_name: String = settings.get_control_for_finger(finger_id)
		if control_name != "":
			control_activated.emit(control_name, finger_id)

func is_finger_active(finger_id: int) -> bool:
	return active_touches.has(finger_id)

func get_finger_position(finger_id: int) -> Vector2:
	return active_touches.get(finger_id, Vector2.ZERO)