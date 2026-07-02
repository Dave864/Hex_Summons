@tool
@abstract
class_name SpawnArea
extends Marker3D
## Base class that defines an area where EncounterSpawn nodes can be created. This
## area must be placed fully above the ground otherwise EncounterSpawn will not be
## placed properly.


## Name of the raycast node for detecting where to place an EncounterSpawn.
const Y_RAYCAST_NAME := "Y_RayCast"
## The length of the raycast.
const Y_RAYCAST_LENGTH := 10.0
## Name of the mesh used for debugging.
const DEBUG_MESH_NAME := "DebugMesh"

## File paths to the possible enemy selections for this zone.
@export_dir var enemies : PackedStringArray
## The number of EncounterSpawn nodes that can be active at once.
@export_range(1, 50) var spawn_limit := 1
## The likelihood that an EncounterSpawn will roam as opposed to travel.
@export_range(0.0, 1.0, 0.01) var roam_chance := 0.5
@export_group("Encounter Spawn Distance Trigger", "distance_trigger")
## The minimum distance that must be traveled before an EncounterSpawner appears.
@export_range(0.01, 10.0, 0.01) var distance_trigger_min := 1.0:
	set(value):
		distance_trigger_min = value
		if distance_trigger_max < distance_trigger_min:
			distance_trigger_max = value
## The maximum distance that can be traveled before an EncounterSpawner appears.
@export_range(0.01, 10.0, 0.01) var distance_trigger_max := 3.0:
	set(value):
		distance_trigger_max = value
		if distance_trigger_min > distance_trigger_max:
			distance_trigger_min = value

## The distance the avatar must travel before an EncounterSpawn node is made.
var _distance_trigger := 0.0:
	get:
		return pow(_distance_trigger, 2.0)
## The distance traveled by the avatar.
var _travel_distance := 0.0
## Raycast used to determine where on the y-axis to place the EncounterSpawn
## node.
var _y_cast: RayCast3D = null
## The terrain zone this spawn area is part of.
var _terrain_zone: TerrainZone = null
## The currently active EncounterSpawn nodes.
var _active_spawners: Array[int] = []
## The mesh used to visualize the covered area.
var _debug_mesh: MeshInstance3D = null

## The spawner that represents a monster.
@onready var _monster_spawn: PackedScene = preload(
		"res://overworld/encounter_spawn/EncounterSpawnMonster.tscn"
)
## The spawner that represents a predator.
## The spawner that represents a prey creature.


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance_y_raycast()
	_instance_debug_mesh()
	_update_distance_trigger()


## Update the ecosystem based on how far the avatar has traveled.
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_simulate_environment()
	if _active_spawners.size() < spawn_limit:
		_process_spawning()


## Updates the terrain zone this spawn area is in.
func set_terrain_zone(new_zone: TerrainZone) -> void:
	_terrain_zone = new_zone


## Creates raycast node for detecting where on the y-axis to place an
## EncounterSpawn.
func _instance_y_raycast() -> void:
	if has_node(Y_RAYCAST_NAME):
		_y_cast = get_node(Y_RAYCAST_NAME) as RayCast3D
	else:
		_y_cast = RayCast3D.new()
		add_child(_y_cast)
		if Engine.is_editor_hint():
			_y_cast.set_owner(get_tree().edited_scene_root)
		_y_cast.name = Y_RAYCAST_NAME
		_y_cast.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
		_y_cast.set_collision_mask_value(Constants.MAP_LAYER, true)
		_y_cast.target_position = Vector3(0.0, -Y_RAYCAST_LENGTH, 0.0)
	# Rotate raycast so that it is always pointing down regardless of the
	# rotation of this SpawnArea.
	_y_cast.global_rotation = Vector3.ZERO


## Creates a mesh used to visualize the range of this SpawnArea.
func _instance_debug_mesh() -> void:
	if has_node(DEBUG_MESH_NAME):
		_debug_mesh = get_node(DEBUG_MESH_NAME) as MeshInstance3D
	else:
		_debug_mesh = MeshInstance3D.new()
		add_child(_debug_mesh)
		_debug_mesh.name = DEBUG_MESH_NAME
		if Engine.is_editor_hint():
			_debug_mesh.set_owner(get_tree().edited_scene_root)
	if Engine.is_editor_hint():
		_update_debug_mesh()
	else:
		_debug_mesh.hide()


## Updates the debug mesh to match the current dimensions.
@abstract func _update_debug_mesh() -> void


## Creates a material for the debug mesh.
func _debug_mesh_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	# The material is unshaded to allow it to be visible regardless of shadows.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	return material


## Determines where an EncounterSpawner should be placed.
func _determine_spawn_global_position(roam_offset: float) -> Vector3:
	var area_pos := _random_area_position(roam_offset)
	# Apply global Euler rotation to match the area position to SpawnArea's
	# orientation.
	area_pos = area_pos.rotated(Vector3.UP, deg_to_rad(global_rotation.y))
	area_pos = area_pos.rotated(Vector3.RIGHT, deg_to_rad(global_rotation.x))
	area_pos = area_pos.rotated(Vector3.BACK, deg_to_rad(global_rotation.z))
	# Make the area position reference be the center of SpawnArea instead of
	# origin.
	area_pos += global_position
	return Vector3(area_pos.x, _determine_y_position(area_pos), area_pos.z)


## Gets a random position in the defined spawn area plane.
@abstract func _random_area_position(roam_offset: float) -> Vector3


## Determines the global y position for EncounterSpawn.
func _determine_y_position(raycast_position: Vector3) -> float:
	_y_cast.global_position = raycast_position
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point().y
	printerr("Ground not found.")
	return 0.0


## TODO: Updates the population counts of the various enemy types.
func _simulate_environment() -> void:
	pass


## Handles the creation and placement of encounter spawners.
func _process_spawning() -> void:
	if _terrain_zone == null:
		printerr("No TerrainZone has been assigned.")
		return
	_travel_distance += SceneController.get_last_squared_distance()
	if _travel_distance >= _distance_trigger:
		_update_distance_trigger()
		_travel_distance = 0.0
		var spawner: EncounterSpawn = _monster_spawn.instantiate()
		spawner.set_area_details(_terrain_zone, self)
		spawner.set_encounter_details(
				_terrain_zone.select_random_map_path(),
				enemies
		)
		var roam_offset: float = 0.0
		if randf() <= roam_chance:
			_define_roam_area(spawner)
			roam_offset = spawner.roam_area.radius
			add_child(spawner.roam_area)
			spawner.roam_area.global_rotation = global_rotation
			spawner.roam_area.add_child(spawner)
		else:
			add_child(spawner)
		spawner.global_position = _determine_spawn_global_position(roam_offset)
		_active_spawners.append(spawner.get_instance_id())
		spawner.connect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)


## Define a roam area for an EncounterSpawn.
@abstract func _define_roam_area(spawner: EncounterSpawn) -> void


## Resets the spawn distance trigger to a new random value.
func _update_distance_trigger() -> void:
	_distance_trigger = randf_range(distance_trigger_min, distance_trigger_max)


## Removes the despawned EncounterSpawn node from the tracker.
func _on_EncounterSpawn_despawned(instance_id: int) -> void:
	_active_spawners.erase(instance_id)
