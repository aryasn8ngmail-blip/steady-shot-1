# SettingsManager.gd
# Manages schema-versioned settings persistence (user://settings.json)
extends Node

const SETTINGS_PATH := "user://settings.json"
const CURRENT_SCHEMA_VERSION := 1

var settings: Dictionary = {}

var default_settings: Dictionary = {
	"schema_version": CURRENT_SCHEMA_VERSION,
	"finger_map": {
		"l_stick": -1,
		"r_stick": -1,
		"balance_pad": -1,
		"trigger": -1
	},
	"accessibility": {
		"mirrored_layout": false
	},
	"controls": {
		"l_stick": {
			"position": {"x": 0.18, "y": 0.72},
			"scale": 1.0,
			"rotation": 0.0,
			"opacity": 0.85
		},
		"balance_pad": {
			"position": {"x": 0.38, "y": 0.72},
			"scale": 1.0,
			"rotation": 0.0,
			"opacity": 0.85
		},
		"r_stick": {
			"position": {"x": 0.82, "y": 0.72},
			"scale": 1.0,
			"rotation": 0.0,
			"opacity": 0.85
		},
		"trigger": {
			"position": {"x": 0.82, "y": 0.35},
			"scale": 1.0,
			"rotation": 0.0,
			"opacity": 0.85
		}
	},
	"saved_layouts": {}
}

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		settings = default_settings.duplicate(true)
		save_settings()
		return

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		settings = default_settings.duplicate(true)
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result == OK and typeof(json.data) == TYPE_DICTIONARY:
		settings = json.data
		_migrate_if_needed()
	else:
		settings = default_settings.duplicate(true)
		save_settings()

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(settings, "\t"))
		file.close()

func _migrate_if_needed() -> void:
	var version: int = settings.get("schema_version", 0)
	if version < CURRENT_SCHEMA_VERSION:
		settings["schema_version"] = CURRENT_SCHEMA_VERSION
		save_settings()

func get_control_config(control_name: String) -> Dictionary:
	var controls: Dictionary = settings.get("controls", {})
	if controls.has(control_name):
		return controls[control_name]
	return default_settings["controls"].get(control_name, {}).duplicate(true)

func set_control_config(control_name: String, config: Dictionary) -> void:
	if not settings.has("controls"):
		settings["controls"] = {}
	settings["controls"][control_name] = config
	save_settings()

func get_finger_map() -> Dictionary:
	return settings.get("finger_map", {})

func set_finger_for_control(control_name: String, finger_id: int) -> void:
	if not settings.has("finger_map"):
		settings["finger_map"] = {}
	settings["finger_map"][control_name] = finger_id
	save_settings()

func get_control_for_finger(finger_id: int) -> String:
	var finger_map: Dictionary = get_finger_map()
	for control_name in finger_map:
		if int(finger_map[control_name]) == finger_id:
			return control_name
	return ""

func reset_to_default_layout() -> void:
	settings["controls"] = default_settings["controls"].duplicate(true)
	settings["accessibility"]["mirrored_layout"] = false
	save_settings()

func save_named_layout(layout_name: String) -> void:
	if not settings.has("saved_layouts"):
		settings["saved_layouts"] = {}
	var current_layout = {
		"controls": settings.get("controls", {}).duplicate(true),
		"mirrored_layout": settings.get("accessibility", {}).get("mirrored_layout", false)
	}
	settings["saved_layouts"][layout_name] = current_layout
	save_settings()

func load_named_layout(layout_name: String) -> bool:
	var saved_layouts: Dictionary = settings.get("saved_layouts", {})
	if not saved_layouts.has(layout_name):
		return false

	var layout_data: Dictionary = saved_layouts[layout_name]
	if layout_data.has("controls"):
		settings["controls"] = layout_data["controls"].duplicate(true)
	if layout_data.has("mirrored_layout"):
		if not settings.has("accessibility"):
			settings["accessibility"] = {}
		settings["accessibility"]["mirrored_layout"] = layout_data["mirrored_layout"]

	save_settings()
	return true