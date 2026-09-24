# MainGame.gd
# Main gameplay controller scene integrating Phase 1 touch controls overlay with Phase 2 Horse, Balance, Rider, Camera, and Meadow Environment.
extends Node

class_name MainGame

@export var horse: Horse = null
@export var rider: Rider = null
@export var horse_camera: HorseCamera = null
@export var balance_controller: BalanceController = null
@export var meadow_environment: MeadowEnvironment = null

@export var l_stick: Control = null
@export var balance_pad: Control = null
@export var r_stick: Control = null
@export var trigger: Control = null

func _ready() -> void:
	_setup_control_connections()
	_apply_settings_layout()

func _setup_control_connections() -> void:
	if l_stick != null:
		l_stick.connect("value_changed", Callable(self, "_on_l_stick_changed"))

	if balance_pad != null:
		balance_pad.connect("balance_changed", Callable(self, "_on_balance_pad_changed"))

	if r_stick != null:
		r_stick.connect("value_changed", Callable(self, "_on_r_stick_changed"))

	if balance_controller != null:
		balance_controller.imbalance_updated.connect(_on_imbalance_updated)

func _process(delta: float) -> void:
	# Calculate terrain slope and pass to balance controller
	if horse != null and meadow_environment != null and balance_controller != null:
		var slope: Vector2 = meadow_environment.get_terrain_slope_at(horse.global_position)
		balance_controller.apply_terrain_slope(slope, delta)

func _on_l_stick_changed(vector: Vector2) -> void:
	if horse != null:
		horse.set_stick_input(vector)

func _on_balance_pad_changed(vector: Vector2, _imbalance_score: float) -> void:
	if balance_controller != null:
		balance_controller.set_user_correction(vector)

func _on_r_stick_changed(vector: Vector2) -> void:
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_aim_changed(vector)

func _on_imbalance_updated(imbalance_vector: Vector2, severity: float) -> void:
	if balance_pad != null and "imbalance_amount" in balance_pad:
		balance_pad.imbalance_amount = severity
		balance_pad.queue_redraw()

func _apply_settings_layout() -> void:
	if not has_node("/root/SettingsManager"):
		return
	var sm: Node = get_node("/root/SettingsManager")
	var viewport_size: Vector2 = get_window().size

	_apply_control_config("l_stick", l_stick, sm, viewport_size)
	_apply_control_config("balance_pad", balance_pad, sm, viewport_size)
	_apply_control_config("r_stick", r_stick, sm, viewport_size)
	_apply_control_config("trigger", trigger, sm, viewport_size)

func _apply_control_config(c_name: String, node: Control, sm: Node, viewport_size: Vector2) -> void:
	if node == null:
		return
	var cfg: Dictionary = sm.get_control_config(c_name)
	var pos_dict: Dictionary = cfg.get("position", {"x": 0.5, "y": 0.5})
	node.position = Vector2(float(pos_dict.get("x", 0.5)) * viewport_size.x, float(pos_dict.get("y", 0.5)) * viewport_size.y)
	node.scale = Vector2.ONE * float(cfg.get("scale", 1.0))
	node.rotation_degrees = float(cfg.get("rotation", 0.0))
	node.modulate = Color(1, 1, 1, float(cfg.get("opacity", 0.85)))
