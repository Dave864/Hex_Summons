@tool
class_name EncounterZone
extends Area3D
## Manages what maps and enemies will be used in an encounter when the
## OverworldAvatar is in this area.
##
## Simulates the ecosystem of the enemies in the zone, which determines which
## ones will be included in an encounter.


## The name of the node that records the spawn areas assigned to this zone.
const SPAWN_AREAS_NAME := "SpawnAreas"


## File paths to the possible enemy selections for this zone.
@export_dir var enemies : Array[String]
## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]
@export_group("Encounter Spawn Distances", "spawn")
@export_subgroup("Distance Range", "spawn_distance")
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
@export_subgroup("Position Range", "spawn_position")
## The minimum distance away from the overworld avatar an EncounterSpawner can
## be placed
@export_range(0.01, 3.0, 0.01) var spawn_position_min := 0.25:
	set(value):
		spawn_position_min = value
		if spawn_position_max < spawn_position_min:
			spawn_position_max = value
## The maximum distance away from the overworld avatar an EncounterSpawner can
## be placed
@export_range(0.01, 3.0, 0.01) var spawn_position_max := 0.5:
	set(value):
		spawn_position_max = value
		if spawn_position_max < spawn_position_min:
			spawn_position_min = value

## Reference to the overworld avatar.
var _overworld_avatar: OverworldAvatar = null
## The distance the avatar must travel before an EncounterSpawner is made.
var _spawn_distance := 0.0:
	get:
		return pow(_spawn_distance, 2.0)
## The distance traveled by the avatar.
var _travel_distance := 0.0


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	var body_entered_callable := Callable(self, "_on_EncounterZone_body_entered")
	if not is_connected("body_entered", body_entered_callable):
		connect("body_entered", body_entered_callable)
	var body_exited_callable := Callable(self, "_on_EncounterZone_body_exited")
	if not is_connected("body_exited", body_exited_callable):
		connect("body_exited", body_exited_callable)
	if get_shape_owners().size() == 0:
		var collision_shape := CollisionShape3D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.set_owner(get_tree().edited_scene_root)
		collision_shape.name = "CollisionShape3D"
		collision_shape.debug_color = Color.YELLOW
		collision_shape.debug_fill = false
		collision_shape.shape = BoxShape3D.new()
	if not has_node(SPAWN_AREAS_NAME):
		var spawn_areas := Node3D.new()
		add_child(spawn_areas)
		if Engine.is_editor_hint():
			spawn_areas.set_owner(get_tree().edited_scene_root)
		spawn_areas.name = SPAWN_AREAS_NAME


## Establishes the collision layers of a newly created zone.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)


## Update the ecosystem based on how far the avatar has traveled.
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_simulate_ecosystem()
	_process_spawning()


## Simulates the ecosystem of the enemies to determine the population levels.
func _simulate_ecosystem() -> void:
	pass


## Handles the spawning of encounter spawners.
func _process_spawning() -> void:
	if _overworld_avatar == null:
		return
	_travel_distance += SceneController.get_last_squared_distance()
	if _travel_distance >= _spawn_distance:
		_spawn_distance = randf_range(spawn_distance_min, spawn_distance_max)
		_travel_distance = 0.0
		var spawner := EncounterSpawnFight.new(
				_overworld_avatar,
				maps[0],
				enemies
		)
		spawner.position = _determine_spawn_position()
		add_child(spawner)
		await spawner.spawn()


## Determines where an encounter spawner should be placed relative to the
## overworld avatar.
func _determine_spawn_position() -> Vector3:
	var spawn_position := Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	).normalized()
	spawn_position *= randf_range(spawn_position_min, spawn_position_max)
	return spawn_position + _overworld_avatar.position


## Catches when the player avatar enters the zone.
func _on_EncounterZone_body_entered(avatar: OverworldAvatar) -> void:
	_overworld_avatar = avatar
	_spawn_distance = randf_range(spawn_distance_min, spawn_distance_max)
	_travel_distance = 0.0


## Catches when the player avatar exits the zone.
func _on_EncounterZone_body_exited(_avatar: OverworldAvatar) -> void:
	_overworld_avatar = null
