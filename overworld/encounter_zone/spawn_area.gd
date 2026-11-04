@tool
@abstract
class_name SpawnArea
extends Marker3D
## Base class that defines an area where EncounterSpawn nodes can be created. This
## area must be placed fully above the ground otherwise EncounterSpawn will not be
## placed properly.


## Name of variable timer used for determining when to create EncounterSpawn
## nodes.
const SPAWN_TIMER_NAME := "SpawnTimer"
## Name of the raycast node for detecting where to place an EncounterSpawn.
const Y_RAYCAST_NAME := "Y_RayCast"
## The length of the raycast.
const Y_RAYCAST_LENGTH := 10.0
## Name of the gizmo used for debugging.
const GIZMO_NAME := "AreaGizmo"
## The color to use for the gizmo.
const GIZMO_COLOR := Color.RED

## Names of the possible enemy selections for this zone.
@export var enemies : PackedStringArray
## The number of EncounterSpawn nodes that can be active at once.
@export_range(0, 50) var spawn_limit := 1
## The likelihood that an EncounterSpawn will roam as opposed to travel.
@export_range(0.0, 1.0, 0.01) var roam_chance := 0.5
@export_group("Encounter Spawn Time", "time_trigger")
## The minimum time in seconds that can pass before an EncounterSpawner appears.
@export_range(0.01, 300.0, 0.01, "exp", "suffix:s") var time_trigger_min := 1.0:
	set(value):
		time_trigger_min = value
		if _spawn_timer != null:
			_spawn_timer.lower_time = value
		if time_trigger_max < time_trigger_min:
			time_trigger_max = value
## The maximum time in seconds that can pass before an EncounterSpawner appears.
@export_range(0.01, 300.0, 0.01, "exp", "suffix:s") var time_trigger_max := 3.0:
	set(value):
		time_trigger_max = value
		if _spawn_timer != null:
			_spawn_timer.upper_time = time_trigger_max
		if time_trigger_min > time_trigger_max:
			time_trigger_min = value

## Variable timer used to determine when to create an EncounterSpawn.
var _spawn_timer: VariableTimer = null
## Raycast used to determine where on the y-axis to place the EncounterSpawn
## node.
var _y_cast: RayCast3D = null
## The terrain zone this spawn area is part of.
var _terrain_zone: TerrainZone = null
## The currently active EncounterSpawn nodes.
var _active_spawners: Array[int] = []

## The spawner for a random encounter.
@onready var _enc_spawn: PackedScene = preload(
		"res://overworld/encounter_spawn/EncounterSpawn.tscn"
)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance_timer()
	_instance_y_raycast()
	_instance_gizmo()


## Update the ecosystem based on how far the avatar has traveled.
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_simulate_environment()


## Updates the terrain zone this spawn area is in.
func set_terrain_zone(new_zone: TerrainZone) -> void:
	_terrain_zone = new_zone


## Creates a timer for determining when to spawn another EncounterSpawn.
func _instance_timer() -> void:
	if has_node(SPAWN_TIMER_NAME):
		_spawn_timer = get_node(SPAWN_TIMER_NAME) as VariableTimer
	else:
		_spawn_timer = VariableTimer.new()
		add_child(_spawn_timer)
		if Engine.is_editor_hint():
			_spawn_timer.set_owner(get_tree().edited_scene_root)
		_spawn_timer.name = SPAWN_TIMER_NAME
	if not _spawn_timer.timeout.is_connected(_process_spawning):
		_spawn_timer.timeout.connect(_process_spawning)
	_spawn_timer.lower_time = time_trigger_min
	_spawn_timer.upper_time = time_trigger_max


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


## Gets the reference to the area gizmo, or creates one if none is present.
@abstract func _instance_gizmo() -> void


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
	if Engine.is_editor_hint() or _active_spawners.size() >= spawn_limit:
		return
	if _terrain_zone == null:
		printerr("No TerrainZone has been assigned.")
		return
	var spawner: EncounterSpawn = _enc_spawn.instantiate()
	spawner.init_start_terrain_zone(_terrain_zone)
	spawner.init_encounter_details(
			_terrain_zone.select_random_map_path(),
			enemies
	)
	var roam_offset: float = 0.0
	if randf() <= roam_chance:
		_define_roam_area(spawner)
		roam_offset = spawner.roam_area.radius
		add_child(spawner.roam_area)
		spawner.roam_area.position = _random_area_position(roam_offset)
		spawner.roam_area.global_rotation = global_rotation
		spawner.roam_area.add_child(spawner)
		spawner.global_position = spawner.roam_area.get_next_point()
	else:
		add_child(spawner)
		spawner.global_position = _determine_spawn_global_position(roam_offset)
	_active_spawners.append(spawner.get_instance_id())
	spawner.despawned.connect(_on_EncounterSpawn_despawned)


## Define a roam area for an EncounterSpawn.
@abstract func _define_roam_area(spawner: EncounterSpawn) -> void


## Removes the despawned EncounterSpawn node from the tracker.
func _on_EncounterSpawn_despawned(instance_id: int) -> void:
	_active_spawners.erase(instance_id)
