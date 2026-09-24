# CalibrationScreen.gd
extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var hint_label: Label = $VBox/HintLabel
@onready var zone_l_stick: Control = $Zones/LStickZone
@onready var zone_r_stick: Control = $Zones/RStickZone
@onready var zone_balance: Control = $Zones/BalanceZone
@onready var zone_trigger: Control = $Zones/TriggerZone
@onready var timeout_timer: Timer = $TimeoutTimer

var calibration_step: int = 0
var steps: Array[String] = ["l_stick", "r_stick", "balance_pad", "trigger"]
var step_names: Dictionary = {
	"l_stick": "Left Stick (Movement)",
	"r_stick": "Right Stick (Aiming)",
	"balance_pad": "Balance Pad",
	"trigger": "Trigger (Draw Power)"
}

func _ready() -> void:
	if has_node("/root/MultiTouchManager"):
		var mt = get_node("/root/MultiTouchManager")
		mt.touch_started.connect(_on_touch_started)

	timeout_timer.timeout.connect(_on_timeout)
	_start_step()

func _start_step() -> void:
	if calibration_step >= steps.size():
		_calibration_complete()
		return

	var current_control: String = steps[calibration_step]
	title_label.text = "4-Finger Calibration"
	hint_label.text = "Place a finger on the highlighted zone for: " + String(step_names.get(current_control, ""))
	_highlight_zone(current_control)
	timeout_timer.start(10.0)

func _highlight_zone(control_name: String) -> void:
	zone_l_stick.modulate = Color(1, 1, 1, 0.3)
	zone_r_stick.modulate = Color(1, 1, 1, 0.3)
	zone_balance.modulate = Color(1, 1, 1, 0.3)
	zone_trigger.modulate = Color(1, 1, 1, 0.3)

	match control_name:
		"l_stick": zone_l_stick.modulate = Color(0.37, 0.83, 0.95, 1.0)
		"r_stick": zone_r_stick.modulate = Color(0.37, 0.83, 0.95, 1.0)
		"balance_pad": zone_balance.modulate = Color(0.37, 0.83, 0.95, 1.0)
		"trigger": zone_trigger.modulate = Color(0.96, 0.65, 0.14, 1.0)

func _get_target_zone_node(control_name: String) -> Control:
	match control_name:
		"l_stick": return zone_l_stick
		"r_stick": return zone_r_stick
		"balance_pad": return zone_balance
		"trigger": return zone_trigger
	return null

func _on_touch_started(finger_id: int, norm_pos: Vector2) -> void:
	if calibration_step >= steps.size():
		return

	var current_control: String = steps[calibration_step]
	var zone_node := _get_target_zone_node(current_control)
	
	if zone_node != null:
		var viewport_size := get_viewport_rect().size
		var screen_pos := norm_pos * viewport_size
		var local_pos := zone_node.get_global_transform().affine_inverse() * screen_pos
		var zone_rect := Rect2(Vector2.ZERO, zone_node.size)
		
		if not zone_rect.has_point(local_pos):
			return

	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		sm.set_finger_for_control(current_control, finger_id)

	Input.vibrate_handheld(50)
	calibration_step += 1
	_start_step()

func _on_timeout() -> void:
	hint_label.text = "Hint: Touch and hold your finger inside the glowing circle!"

func _calibration_complete() -> void:
	timeout_timer.stop()
	title_label.text = "Calibration Complete!"
	hint_label.text = "All 4 fingers assigned successfully."
	await get_tree().create_timer(1.5).timeout
	if FileAccess.file_exists("res://ui/settings/LayoutSettings.tscn"):
		get_tree().change_scene_to_file("res://ui/settings/LayoutSettings.tscn")