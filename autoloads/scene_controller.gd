extends Node
## Global node that manages the details of transitioning between scenes.


## The path to the Encounter scene.
const ENCOUNTER_SCENE_PATH := "res://encounter/Encounter.tscn"
## The path to the Overworld scene.
const OVERWORLD_SCENE_PATH := "res://overworld/Overworld.tscn"

## The last tracked position of the OverworldAvatar.
var prior_avatar_position: Vector3 = Vector3.INF

## Reference to the OverworldAvatar.
var _overworld_avatar: OverworldAvatar = null
## The squared distance the tracked avatar traveled in the last frame.
var _last_frame_distance: float = 0.0
## The path to the map to use for the next encounter.
var _encounter_map_path: String = ""
## The paths to the enemies to use for the next encounter.
var _encounter_enemy_paths: Array[String] = []


## Updates the last tracked position for the currently tracked OverworldAvatar.
func _physics_process(_delta: float) -> void:
	if _overworld_avatar == null:
		return
	_last_frame_distance = prior_avatar_position.distance_squared_to(
			_overworld_avatar.position
	)
	prior_avatar_position = _overworld_avatar.position


## Sets the reference to the OverworldAvatar.
func set_avatar_reference(avatar_reference: OverworldAvatar) -> void:
	_overworld_avatar = avatar_reference


## Gets the distance traveled by the avatar in the last frame.
func get_last_squared_distance() -> float:
	return _last_frame_distance


## Triggers a scene change to the Encounter scene, passing along the map and
## enemy details.
func change_scene_to_encounter(
	map_path: String,
	enemy_paths: Array[String]
) -> void:
	_encounter_map_path = map_path
	_encounter_enemy_paths = enemy_paths
