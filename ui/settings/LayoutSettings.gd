# LayoutSettings.gd
extends Control

@onready var selected_control_option: OptionButton = $Panel/VBox/SelectedControlOption
@onready var scale_slider: HSlider = $Panel/VBox/ScaleSlider
@onready var rotation_slider: HSlider = $Panel/VBox/RotationSlider
@onready var opacity_slider: HSlider = $Panel/VBox/OpacitySlider
@onready var mirror_button: Button = $Panel/VBox/MirrorButton
@onready var reset_button: Button = $Panel/VBox/ResetButton
@onready var recalibrate_button: Button = $Panel/VBox/RecalibrateButton
@onready var preset_option: OptionButton = $Panel/VBox/PresetOption
@onready var save_preset_button: Button = $Panel/VBox/SavePresetButton

@onready var l_stick_node: Control = $Canvas/LStick
@onready var balance_pad_node: Control = $Canvas/BalancePad
@onready var r_stick_node: Control = $Canvas/RStick
@onready var trigger_node: Control = $Canvas/Trigger

var current_control_name: String = "l_stick"
var is_dragging: bool = false
var drag_start_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	selected_control_option.add_item("Left Stick", 0)
	selected_control_option.add_item("Balance Pad", 1)
	selected_control_option.add_item("Right Stick", 2)
	selected_control_option.add_item("Trigger", 3)
	selected_control_option.item_selected.connect(_on_control_selected)

	scale_slider.value_changed.connect(_on_scale_changed)
	rotation_slider.value_changed.connect(_on_rotation_changed)
	opacity_slider.value_changed.connect(_on_opacity_changed)

	mirror_button.pressed.connect(_on_mirror_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	recalibrate_button.pressed.connect(_on_recalibrate_pressed)
	save_preset_button.pressed.connect(_on_save_preset_pressed)
	preset_option.item_selected.connect(_on_preset_selected)

	_load_presets_ui()
	_apply_loaded_settings()

func _load_presets_ui() -> void:
	preset_option.clear()
	preset_option.add_item("Select Saved Layout", 0)
	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		var saved_layouts: Dictionary = sm.settings.get("saved_layouts", {})
		var idx: int = 1
		for layout_name in saved_layouts:
			preset_option.add_item(String(layout_name), idx)
			idx += 1

func _apply_loaded_settings() -> void:
	if not has_node("/root/SettingsManager"):
		return
	var sm = get_node("/root/SettingsManager")

	_apply_control_config("l_stick", l_stick_node, sm)
	_apply_control_config("balance_pad", balance_pad_node, sm)
	_apply_control_config("r_stick", r_stick_node, sm)
	_apply_control_config("trigger", trigger_node, sm)

	_update_sliders_for_current()

func _apply_control_config(c_name: String, node: Control, sm: Node) -> void:
	var cfg: Dictionary = sm.get_control_config(c_name)
	var pos_dict: Dictionary = cfg.get("position", {"x": 0.5, "y": 0.5})
	var viewport_size: Vector2 = get_viewport_rect().size
	node.position = Vector2(float(pos_dict.get("x", 0.5)) * viewport_size.x, float(pos_dict.get("y", 0.5)) * viewport_size.y)
	node.scale = Vector2.ONE * float(cfg.get("scale", 1.0))
	node.rotation_degrees = float(cfg.get("rotation", 0.0))
	node.modulate = Color(1, 1, 1, float(cfg.get("opacity", 0.85)))

func _save_current_control_config() -> void:
	if not has_node("/root/SettingsManager"):
		return
	var sm = get_node("/root/SettingsManager")
	var node: Control = _get_node_by_name(current_control_name)
	if node == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var cfg: Dictionary = {
		"position": {"x": clamp(node.position.x / viewport_size.x, 0.0, 1.0), "y": clamp(node.position.y / viewport_size.y, 0.0, 1.0)},
		"scale": node.scale.x,
		"rotation": node.rotation_degrees,
		"opacity": node.modulate.a
	}
	sm.set_control_config(current_control_name, cfg)

func _get_node_by_name(c_name: String) -> Control:
	match c_name:
		"l_stick": return l_stick_node
		"balance_pad": return balance_pad_node
		"r_stick": return r_stick_node
		"trigger": return trigger_node
	return null

func _update_sliders_for_current() -> void:
	var node: Control = _get_node_by_name(current_control_name)
	if node != null:
		scale_slider.value = node.scale.x
		rotation_slider.value = node.rotation_degrees
		opacity_slider.value = node.modulate.a

func _on_control_selected(idx: int) -> void:
	match idx:
		0: current_control_name = "l_stick"
		1: current_control_name = "balance_pad"
		2: current_control_name = "r_stick"
		3: current_control_name = "trigger"
	_update_sliders_for_current()

func _on_scale_changed(val: float) -> void:
	var node: Control = _get_node_by_name(current_control_name)
	if node != null:
		node.scale = Vector2.ONE * clamp(val, 0.6, 1.6)
		_save_current_control_config()

func _on_rotation_changed(val: float) -> void:
	var node: Control = _get_node_by_name(current_control_name)
	if node != null:
		node.rotation_degrees = val
		_save_current_control_config()

func _on_opacity_changed(val: float) -> void:
	var node: Control = _get_node_by_name(current_control_name)
	if node != null:
		node.modulate = Color(1, 1, 1, clamp(val, 0.2, 1.0))
		_save_current_control_config()

func _on_mirror_pressed() -> void:
	if not has_node("/root/SettingsManager"):
		return
	var sm = get_node("/root/SettingsManager")
	var controls: Array[String] = ["l_stick", "balance_pad", "r_stick", "trigger"]
	
	for c_name in controls:
		var cfg: Dictionary = sm.get_control_config(c_name)
		if cfg.has("position") and cfg["position"].has("x"):
			cfg["position"]["x"] = clamp(1.0 - float(cfg["position"]["x"]), 0.0, 1.0)
			sm.set_control_config(c_name, cfg)

	_apply_loaded_settings()

func _on_reset_pressed() -> void:
	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		sm.reset_to_default_layout()
		_apply_loaded_settings()

func _on_recalibrate_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/calibration/CalibrationScreen.tscn")

func _on_save_preset_pressed() -> void:
	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		var preset_name: String = "Layout_" + str(Time.get_unix_time_from_system())
		sm.save_named_layout(preset_name)
		_load_presets_ui()

func _on_preset_selected(idx: int) -> void:
	if idx <= 0:
		return
	var layout_name: String = preset_option.get_item_text(idx)
	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		if sm.load_named_layout(layout_name):
			_apply_loaded_settings()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			var node: Control = _get_node_by_name(current_control_name)
			if node != null:
				var m_pos: Vector2 = event.position
				var local_pos: Vector2 = node.get_global_transform().affine_inverse() * m_pos
				var node_rect := Rect2(Vector2.ZERO, node.size)
				if node_rect.has_point(local_pos):
					is_dragging = true
					drag_start_offset = m_pos - node.position
		else:
			is_dragging = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_dragging:
			var node: Control = _get_node_by_name(current_control_name)
			if node != null:
				node.position = event.position - drag_start_offset
				_save_current_control_config()