extends Node
## Global node that manages the details of transitioning between an encounter
## and other scenes.


## The path to the Encounter scene.
const ENCOUNTER_SCENE_PATH := "res://encounter/Encounter.tscn"

## The last tracked position of the OverworldAvatar.
var prior_avatar_position: Vector3

## Reference to the OverworldAvatar.
var _overworld_avatar: OverworldAvatar = null
## The path to the map to use for the next encounter.
var _encounter_map_path: String = ""
## The paths to the enemies to use for the next encounter.
var _encounter_enemy_paths: Array[String] = []


## Updates the last tracked position for the currently tracked OverworldAvatar.
func _physics_process(_delta: float) -> void:
	if _overworld_avatar == null:
		return
	prior_avatar_position = _overworld_avatar.position


## Sets the reference to the OverworldAvatar.
func set_avatar_reference(avatar_reference: OverworldAvatar) -> void:
	_overworld_avatar = avatar_reference


## Triggers a scene change to the Encounter scene, passing along
func change_to_encounter(map_path: String, enemy_paths: Array[String]) -> void:
	_encounter_map_path = map_path
	_encounter_enemy_paths = enemy_paths
