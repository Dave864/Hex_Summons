@tool
@abstract
class_name SpawnArea
extends Marker3D
## Base class that defines an area where EncounterSpawn nodes can be created.


## Name of the raycast node for detecting where to place an EncounterSpawn.
const Y_RAYCAST_NAME := "Y_RAYCAST"
## The length of the raycast.
const Y_RAYCAST_LENGTH := 10.0
## Name of the mesh used for debugging.
const DEBUG_MESH_NAME := "DebugMesh"

## File paths to the possible enemy selections for this zone.
@export_dir var enemies : Array[String]
## The number of EncounterSpawn nodes that can be active at once.
@export_range(1, 50) var spawn_limit := 1
@export_group("Encounter Spawn Distance Range", "spawn_distance")
## The minimum distance that must be traveled before an EncounterSpawner appears.
@export_range(1.0, 10.0, 0.01) var spawn_distance_min := 1.0:
	set(value):
		spawn_distance_min = value
		if spawn_distance_max < spawn_distance_min:
			spawn_distance_max = value
## The maximum distance that can be traveled before an EncounterSpawner appears.
@export_range(1.0, 10.0, 0.01) var spawn_distance_max := 3.0:
	set(value):
		spawn_distance_max = value
		if spawn_distance_min > spawn_distance_max:
			spawn_distance_min = value

## The distance the avatar must travel before an EncounterSpawn node is made.
var _spawn_distance := 0.0:
	get:
		return pow(_spawn_distance, 2.0)
## The distance traveled by the avatar.
var _travel_distance := 0.0
## Raycast used to determine where on the y-axis to place the EncounterSpawn node.
var _y_cast: RayCast3D = null
## The terrain zone this spawn area is part of.
var _terrain_zone: TerrainZone = null
## The currently active EncounterSpawn nodes.
var _active_spawners: Array[int] = []
## The mesh used to visualize the covered area.
var _debug_mesh: MeshInstance3D = null


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node(Y_RAYCAST_NAME):
		_y_cast = get_node(Y_RAYCAST_NAME)
	else:
		_y_cast = RayCast3D.new()
		add_child(_y_cast)
		if Engine.is_editor_hint():
			_y_cast.set_owner(get_tree().edited_scene_root)
		_y_cast.name = Y_RAYCAST_NAME
		_y_cast.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
		_y_cast.set_collision_mask_value(Constants.MAP_LAYER, true)
	_instance_debug_mesh()


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


## Creates a mesh used to visualize the range of this SpawnArea.
func _instance_debug_mesh() -> void:
	if has_node(DEBUG_MESH_NAME):
		_debug_mesh = get_node(DEBUG_MESH_NAME) as MeshInstance3D
	else:
		_debug_mesh = MeshInstance3D.new()
		add_child(_debug_mesh)
		_debug_mesh.name = DEBUG_MESH_NAME
		if Engine.is_editor_hint():
			_y_cast.set_owner(get_tree().edited_scene_root)
	if Engine.is_editor_hint():
		_update_debug_mesh()
	else:
		_debug_mesh.hide()


## Updates the debug mesh to match the current dimensions.
@abstract func _update_debug_mesh() -> void


## Determines where an EncounterSpawner should be placed.
func _determine_spawn_global_position() -> Vector3:
	var xz_pos := _determine_xz_position()
	return Vector3(xz_pos.x, _determine_y_position(xz_pos), xz_pos.y)


## Determines the xz position got EncounterSpawn.
@abstract func _determine_xz_position() -> Vector2


## Determines the y position for EncounterSpawn based on the xz posiiton.
func _determine_y_position(xz_position: Vector2) -> float:
	_y_cast.position = Vector3(xz_position.x, 0.0, xz_position.y)
	# Check up
	_y_cast.target_position.y = Y_RAYCAST_LENGTH
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point().y
	# Check down
	_y_cast.target_position.y = -Y_RAYCAST_LENGTH
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point().y
	return 0.0


## TODO: Updates the population counts of the various enemy types.
func _simulate_environment() -> void:
	pass


## Handles the creation and placement of encounter spawners.
func _process_spawning() -> void:
	if _terrain_zone == null:
		printerr("No TerrainZone has been assigned.")
		return
	if _travel_distance >= _spawn_distance:
		_spawn_distance = randf_range(spawn_distance_min, spawn_distance_max)
		_travel_distance = 0.0
		var spawner := EncounterSpawnFight.new(
				SceneController.get_avatar_reference(),
				_terrain_zone.select_random_map_path(),
				enemies
		)
		spawner.global_position = _determine_spawn_global_position()
		add_child(spawner)
		_active_spawners.append(spawner.get_instance_id())
		spawner.connect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)
		await spawner.spawn()


## Removes the despawned EncounterSpawn node from the tracker.
func _on_EncounterSpawn_despawned(instance_id: int) -> void:
	_active_spawners.erase(instance_id)
