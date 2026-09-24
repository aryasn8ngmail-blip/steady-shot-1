# BalancePad.gd
extends Control

signal balance_changed(vector: Vector2, imbalance_score: float)

@export var control_name: String = "balance_pad"
@export var pad_radius: float = 100.0
@export var spring_back: bool = true

@export var cyan_balanced: Color = Color("#5FD3F3")
@export var amber_warning: Color = Color("#F5A623")
@export var red_imbalanced: Color = Color("#E53E3E")

var is_active: bool = false
var current_finger_id: int = -1
var balance_vector: Vector2 = Vector2.ZERO
var knob_offset: Vector2 = Vector2.ZERO
var imbalance_amount: float = 0.0

const KNOB_RADIUS := 35.0

func _ready() -> void:
	if has_node("/root/MultiTouchManager"):
		var mt = get_node("/root/MultiTouchManager")
		mt.touch_started.connect(_on_touch_started)
		mt.touch_moved.connect(_on_touch_moved)
		mt.touch_ended.connect(_on_touch_ended)

func _draw() -> void:
	var center := size / 2.0
	var current_rim_color := cyan_balanced.lerp(amber_warning, clamp(imbalance_amount * 2.0, 0.0, 1.0))
	if imbalance_amount > 0.5:
		current_rim_color = amber_warning.lerp(red_imbalanced, clamp((imbalance_amount - 0.5) * 2.0, 0.0, 1.0))

	draw_circle(center, pad_radius + 4.0, current_rim_color)
	draw_circle(center, pad_radius, Color("#2A2E35"))
	
	var knob_center := center + knob_offset
	draw_circle(knob_center, KNOB_RADIUS, Color("#3A3F47"))
	draw_circle(knob_center, KNOB_RADIUS * 0.7, Color("#3A3F47").lightened(0.1))

func _on_touch_started(finger_id: int, norm_pos: Vector2) -> void:
	if is_active:
		return
	var viewport_size := get_viewport_rect().size
	var screen_pos := norm_pos * viewport_size
	var local_pos := get_global_transform().affine_inverse() * screen_pos
	var center := size / 2.0
	
	if local_pos.distance_to(center) <= pad_radius:
		is_active = true
		current_finger_id = finger_id
		_update_balance(local_pos)

func _on_touch_moved(finger_id: int, norm_pos: Vector2) -> void:
	if is_active and finger_id == current_finger_id:
		var viewport_size := get_viewport_rect().size
		var screen_pos := norm_pos * viewport_size
		var local_pos := get_global_transform().affine_inverse() * screen_pos
		_update_balance(local_pos)

func _on_touch_ended(finger_id: int, _norm_pos: Vector2) -> void:
	if is_active and finger_id == current_finger_id:
		is_active = false
		current_finger_id = -1
		if spring_back:
			knob_offset = Vector2.ZERO
			balance_vector = Vector2.ZERO
			imbalance_amount = 0.0
		balance_changed.emit(balance_vector, imbalance_amount)
		queue_redraw()

func _update_balance(local_pos: Vector2) -> void:
	var center := size / 2.0
	var delta := local_pos - center
	if delta.length() > pad_radius:
		delta = delta.normalized() * pad_radius
	
	knob_offset = delta
	imbalance_amount = delta.length() / pad_radius
	balance_vector = delta / pad_radius
	
	if imbalance_amount > 0.2:
		var haptic_ms := int(lerp(5.0, 40.0, imbalance_amount))
		Input.vibrate_handheld(haptic_ms)

	balance_changed.emit(balance_vector, imbalance_amount)
	queue_redraw()