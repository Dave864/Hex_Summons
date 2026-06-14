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


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance_y_raycast()
	_instance_debug_mesh()
	_update_spawn_distance()


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


## Determines where an EncounterSpawner should be placed.
func _determine_spawn_global_position() -> Vector3:
	var xz_pos := _determine_xz_position()
	return Vector3(xz_pos.x, _determine_y_position(xz_pos), xz_pos.y)


## Determines the global xz position got EncounterSpawn.
@abstract func _determine_xz_position() -> Vector2


## Determines the global y position for EncounterSpawn based on the xz posiiton.
func _determine_y_position(xz_position: Vector2) -> float:
	_y_cast.global_position = Vector3(
		xz_position.x,
		_determine_raycast_y_pos(),
		xz_position.y
	)
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point().y
	printerr("Ground not found.")
	return 0.0


## Determines the global y position the raycast should be placed at.
@abstract func _determine_raycast_y_pos() -> float


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
		_update_spawn_distance()
		_travel_distance = 0.0
		var spawner := EncounterSpawnFight.new(
				SceneController.get_avatar_reference(),
				_terrain_zone.select_random_map_path(),
				enemies
		)
		add_child(spawner)
		spawner.global_position = _determine_spawn_global_position()
		_active_spawners.append(spawner.get_instance_id())
		spawner.connect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)
		spawner.spawn()


## Resets the spawn distance to a new random value.
func _update_spawn_distance() -> void:
	_distance_trigger = randf_range(distance_trigger_min, distance_trigger_max)


## Removes the despawned EncounterSpawn node from the tracker.
func _on_EncounterSpawn_despawned(instance_id: int) -> void:
	_active_spawners.erase(instance_id)
