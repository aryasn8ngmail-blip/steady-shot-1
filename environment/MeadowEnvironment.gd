# MeadowEnvironment.gd
# Meadow biome environment manager with calm colors, terrain slope generation, and ambient particles.
extends Node3D

class_name MeadowEnvironment

@export var grass_color: Color = Color("#4A7C59") # muted green
@export var earth_color: Color = Color("#8B6D51") # warm earth
@export var sky_color: Color = Color("#A8C5DA")   # soft sky

@export var target_node: FloatingTarget = null
@export var obstacle_node: Obstacle = null

var noise: FastNoiseLite = FastNoiseLite.new()
var terrain_time: float = 0.0

func _ready() -> void:
	noise.seed = 42
	noise.frequency = 0.05

func get_terrain_slope_at(world_pos: Vector3) -> Vector2:
	# Calculate terrain gradient/slope at position using noise
	var sample_dist: float = 0.5
	var h_center: float = noise.get_noise_2d(world_pos.x, world_pos.z)
	var h_x: float = noise.get_noise_2d(world_pos.x + sample_dist, world_pos.z)
	var h_z: float = noise.get_noise_2d(world_pos.x, world_pos.z + sample_dist)

	var slope_x: float = (h_x - h_center) / sample_dist
	var slope_z: float = (h_z - h_center) / sample_dist

	return Vector2(slope_x, slope_z)

func _process(delta: float) -> void:
	terrain_time += delta
