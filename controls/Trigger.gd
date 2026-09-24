# Trigger.gd
extends Control

signal power_changed(value: float)

@export var control_name: String = "trigger"
@export var base_color: Color = Color("#E5E7EB")
@export var fill_start_color: Color = Color("#F5A623")
@export var fill_end_color: Color = Color("#F76B1C")

var is_pressed: bool = false
var current_finger_id: int = -1
var power_level: float = 0.0
var release_pulse_timer: float = 0.0

func _ready() -> void:
	if has_node("/root/MultiTouchManager"):
		var mt = get_node("/root/MultiTouchManager")
		mt.touch_started.connect(_on_touch_started)
		mt.touch_moved.connect(_on_touch_moved)
		mt.touch_ended.connect(_on_touch_ended)

func _process(delta: float) -> void:
	if release_pulse_timer > 0.0:
		release_pulse_timer -= delta
		queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, base_color, true, -1.0)
	draw_rect(rect, Color(0, 0, 0, 0.1), false, 2.0)
	
	if power_level > 0.0:
		var fill_height := rect.size.y * power_level
		var fill_rect := Rect2(Vector2(0, rect.size.y - fill_height), Vector2(rect.size.x, fill_height))
		var fill_color := fill_start_color.lerp(fill_end_color, power_level)
		draw_rect(fill_rect, fill_color, true)

	if is_pressed:
		draw_rect(rect, Color(0, 0, 0, 0.08), true)

	if release_pulse_timer > 0.0:
		var pulse_alpha := release_pulse_timer / 0.2
		draw_rect(rect, Color(1, 1, 1, pulse_alpha * 0.4), true)

func _on_touch_started(finger_id: int, norm_pos: Vector2) -> void:
	if is_pressed:
		return
	var viewport_size := get_viewport_rect().size
	var screen_pos := norm_pos * viewport_size
	var local_pos := get_global_transform().affine_inverse() * screen_pos
	var my_rect := Rect2(Vector2.ZERO, size)
	
	if my_rect.has_point(local_pos):
		is_pressed = true
		current_finger_id = finger_id
		_update_power(local_pos)

func _on_touch_moved(finger_id: int, norm_pos: Vector2) -> void:
	if is_pressed and finger_id == current_finger_id:
		var viewport_size := get_viewport_rect().size
		var screen_pos := norm_pos * viewport_size
		var local_pos := get_global_transform().affine_inverse() * screen_pos
		_update_power(local_pos)

func _on_touch_ended(finger_id: int, _norm_pos: Vector2) -> void:
	if is_pressed and finger_id == current_finger_id:
		is_pressed = false
		current_finger_id = -1
		power_level = 0.0
		release_pulse_timer = 0.2
		power_changed.emit(0.0)
		queue_redraw()

func _update_power(local_pos: Vector2) -> void:
	power_level = clamp(1.0 - (local_pos.y / size.y), 0.0, 1.0)
	var haptic_ms := int(lerp(5.0, 30.0, power_level))
	Input.vibrate_handheld(haptic_ms)
	power_changed.emit(power_level)
	queue_redraw()