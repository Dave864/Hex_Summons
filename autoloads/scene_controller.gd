extends Node
## Global node that manages the details of transitioning between scenes.


## The path to the Encounter scene.
const ENCOUNTER_SCENE_PATH := "res://encounter/Encounter.tscn"
## The path to the Overworld scene.
const OVERWORLD_SCENE_PATH := "res://overworld/Overworld.tscn"

## The last tracked position of the OverworldAvatar.
var prior_avatar_position: Vector3 = Vector3.INF

## Pre loaded loading screen.
var _loading_screen: PackedScene = preload(
		"res://user_interface/LoadingScreen/LoadingScreen.tscn"
)
## The path to the scene currently being loaded.
var load_scene_path: String = ""
## Reference to the OverworldAvatar.
var _overworld_avatar: OverworldAvatar = null
## The squared distance the tracked avatar traveled in the last frame.
var _last_frame_distance: float = 0.0
## The path to the map to use for the next encounter.
var _encounter_map_path: String = ""
## The paths to the enemies to use for the next encounter.
var _encounter_enemy_paths: PackedStringArray = []


## Obtains the current active scene.
func _ready() -> void:
	pass


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


## Returns the path to the currently set encounter map.
func get_encounter_map_path() -> String:
	return _encounter_map_path


## Returns the paths to the currently set encounter enemies.
func get_encounter_enemy_paths() -> PackedStringArray:
	return _encounter_enemy_paths


## Triggers a scene change to the Encounter scene, passing along the map and
## enemy details.
func change_scene_to_encounter(
	map_path: String,
	enemy_paths: PackedStringArray
) -> void:
	_encounter_map_path = map_path
	_encounter_enemy_paths = enemy_paths
	_load_scene.call_deferred(ENCOUNTER_SCENE_PATH)


## Triggers a scene change to the Overworld scene.
func change_scene_to_overworld() -> void:
	_load_scene.call_deferred(OVERWORLD_SCENE_PATH)


## Triggers a scene change to the specified path.
func change_to_scene(scene_path: String) -> void:
	_load_scene.call_deferred(scene_path)


## Triggers the load screen to be created.
func _load_scene(scene_path: String) -> void:
	load_scene_path = scene_path
	get_tree().change_scene_to_packed(_loading_screen)
