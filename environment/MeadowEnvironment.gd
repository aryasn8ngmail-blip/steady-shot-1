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

	if target_node == null:
		target_node = find_child("FloatingTarget", true, false) as FloatingTarget
		if target_node == null:
			target_node = get_node_or_null("FloatingTarget") as FloatingTarget

	if obstacle_node == null:
		obstacle_node = find_child("Obstacle", true, false) as Obstacle
		if obstacle_node == null:
			obstacle_node = get_node_or_null("Obstacle") as Obstacle

	_setup_ground_mesh()

func _setup_ground_mesh() -> void:
	if get_node_or_null("GroundMesh") != null:
		return

	var ground_instance: MeshInstance3D = MeshInstance3D.new()
	ground_instance.name = "GroundMesh"
	var plane_mesh: PlaneMesh = PlaneMesh.new()
	plane_mesh.size = Vector2(200.0, 200.0)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = grass_color
	mat.roughness = 0.8
	plane_mesh.material = mat

	ground_instance.mesh = plane_mesh
	add_child(ground_instance)

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
