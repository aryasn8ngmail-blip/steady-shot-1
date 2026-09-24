# AnalogStick.gd
extends Control

signal value_changed(vector: Vector2)

@export var control_name: String = "l_stick"
@export var base_color: Color = Color("#2A2E35")
@export var rim_glow_idle: Color = Color(0.37, 0.83, 0.95, 0.3)
@export var rim_glow_active: Color = Color(0.37, 0.83, 0.95, 1.0)
@export var cap_color: Color = Color("#3A3F47")

var is_active: bool = false
var current_finger_id: int = -1
var stick_vector: Vector2 = Vector2.ZERO
var cap_offset: Vector2 = Vector2.ZERO

const BASE_RADIUS := 70.0
const CAP_RADIUS := 35.0
const DEAD_ZONE := 0.15

func _ready() -> void:
	if has_node("/root/MultiTouchManager"):
		var mt = get_node("/root/MultiTouchManager")
		mt.touch_started.connect(_on_touch_started)
		mt.touch_moved.connect(_on_touch_moved)
		mt.touch_ended.connect(_on_touch_ended)

func _draw() -> void:
	var center := size / 2.0
	var rim_color := rim_glow_active if is_active else rim_glow_idle
	draw_circle(center, BASE_RADIUS + 4.0, rim_color)
	draw_circle(center, BASE_RADIUS, base_color)
	draw_arc(center, BASE_RADIUS * DEAD_ZONE, 0, TAU, 32, Color(1, 1, 1, 0.15), 1.5)
	
	var depressed_radius := CAP_RADIUS - (2.0 if is_active else 0.0)
	var cap_center := center + cap_offset
	draw_circle(cap_center, depressed_radius, cap_color)
	draw_circle(cap_center, depressed_radius * 0.7, cap_color.lightened(0.1))

func _on_touch_started(finger_id: int, norm_pos: Vector2) -> void:
	if is_active:
		return
	var viewport_size := get_viewport_rect().size
	var screen_pos := norm_pos * viewport_size
	var local_pos := get_global_transform().affine_inverse() * screen_pos
	var center := size / 2.0
	
	if local_pos.distance_to(center) <= BASE_RADIUS:
		is_active = true
		current_finger_id = finger_id
		_update_stick_pos(local_pos)
		Input.vibrate_handheld(10)

func _on_touch_moved(finger_id: int, norm_pos: Vector2) -> void:
	if is_active and finger_id == current_finger_id:
		var viewport_size := get_viewport_rect().size
		var screen_pos := norm_pos * viewport_size
		var local_pos := get_global_transform().affine_inverse() * screen_pos
		_update_stick_pos(local_pos)

func _on_touch_ended(finger_id: int, _norm_pos: Vector2) -> void:
	if is_active and finger_id == current_finger_id:
		is_active = false
		current_finger_id = -1
		cap_offset = Vector2.ZERO
		stick_vector = Vector2.ZERO
		value_changed.emit(stick_vector)
		queue_redraw()

func _update_stick_pos(local_pos: Vector2) -> void:
	var center := size / 2.0
	var delta := local_pos - center
	if delta.length() > BASE_RADIUS:
		delta = delta.normalized() * BASE_RADIUS
	
	cap_offset = delta
	var norm_dist := delta.length() / BASE_RADIUS
	if norm_dist < DEAD_ZONE:
		stick_vector = Vector2.ZERO
	else:
		var remapped := (norm_dist - DEAD_ZONE) / (1.0 - DEAD_ZONE)
		stick_vector = delta.normalized() * remapped
	
	value_changed.emit(stick_vector)
	queue_redraw()