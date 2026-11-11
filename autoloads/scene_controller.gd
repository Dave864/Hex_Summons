extends Node
## Global node that manages the details of transitioning between scenes.


## The path format to an enemy scene.
const ENEMY_PATH_FORMAT := Constants.ENEMY_CHAR_FOLDER + "{0}.tscn"
## The path to the Encounter scene.
const ENCOUNTER_SCENE_PATH := "res://encounter/Encounter.tscn"
## The path to the Overworld scene.
const OVERWORLD_SCENE_PATH := "res://overworld/Overworld.tscn"
## The path format to town landmark zones.
const LANDMARK_TOWN_SCENE_PATH_FORMAT := "res://landmark_zones/towns/{0}.tscn"
## The path format to dungeon landmark zones.
const LANDMARK_DUNGEON_SCENE_PATH_FORMAT := (
		"res://landmark_zones/dungeons/{0}.tscn"
)

## The last tracked position of the OverworldAvatar.
var prior_avatar_position: Vector3 = Vector3.INF
## Name of the landmark the player is in.
var landmark_active: String = ""
## The direction the player enters of exits a landmark from.
var landmark_transition_direction := Vector2.ZERO
## The path to the scene currently being loaded.
var load_scene_path: String = ""
## The connections between landmarks and landmark zones.
var map_connections: TransitionConnections = preload(
		"res://landmark_zones/map_connections.tres"
)

## The path to the map to use for the next encounter.
var _encounter_map_path: String = ""
## The paths to the enemies to use for the next encounter.
var _encounter_enemy_paths: PackedStringArray = []
## Pre loaded loading screen.
var _loading_screen: PackedScene = preload(
		"res://user_interface/LoadingScreen/LoadingScreen.tscn"
)


## Obtains the current active scene.
func _ready() -> void:
	pass


## Updates the last tracked position for the currently tracked OverworldAvatar.
func _physics_process(_delta: float) -> void:
	pass


## Returns the path to the currently set encounter map.
func get_encounter_map_path() -> String:
	return _encounter_map_path


## Returns the paths to the currently set encounter enemies.
func get_encounter_enemy_paths() -> PackedStringArray:
	return _encounter_enemy_paths


## Gets the zone connected to the active landmark.
func get_active_landmark_zone() -> String:
	if not map_connections.landmark_to_zone.has(landmark_active):
		printerr("No connected zone for landmark {0}.".format([landmark_active]))
		return ""
	return map_connections.landmark_to_zone[landmark_active]


## Gets the landmark connected to the specified zone. 
func get_zone_landmark(zone: String) -> String:
	if not map_connections.zone_to_landmark.has(zone):
		printerr("No connected landmark for zone {0}.".format([zone]))
		return ""
	return map_connections.zone_to_landmark[zone]


## Sets the active landmark to none (empty String).
func reset_landmark() -> void:
	landmark_active = ""
	landmark_transition_direction = Vector2.ZERO


## Triggers a scene change to the Encounter scene, passing along the map and
## enemy details.
func change_scene_to_encounter(
	map_path: String,
	enemy_names: PackedStringArray
) -> void:
	_encounter_map_path = map_path
	_encounter_enemy_paths.clear()
	_encounter_enemy_paths.resize(enemy_names.size())
	for i: int in enemy_names.size():
		_encounter_enemy_paths[i] = ENEMY_PATH_FORMAT.format([enemy_names[i]])
	_load_scene.call_deferred(ENCOUNTER_SCENE_PATH)


## Triggers a scene change to the Overworld scene.
func change_scene_to_overworld() -> void:
	_load_scene.call_deferred(OVERWORLD_SCENE_PATH)


## Triggers a scene change to a landmark's connected zone.
func change_scene_to_connected_zone(landmark: String) -> void:
	if not map_connections.landmark_to_zone.has(landmark):
		printerr("Landmark {0} has no connected zone.".format([landmark]))
		return
	var zone: String = map_connections.landmark_to_zone[landmark]
	landmark_active = landmark
	if not change_scene_to_landmark_zone(zone):
		printerr(
				"No scene detected for landmark {0} mapped zone {1}".format(
					[landmark, zone]
				)
		)


## Triggers a scene change to a specified landmark zone. Returns if a scene
## exists for the zone.
func change_scene_to_landmark_zone(zone: String) -> bool:
	var zone_scene_path := LANDMARK_TOWN_SCENE_PATH_FORMAT.format([zone])
	if FileAccess.file_exists(zone_scene_path):
		_load_scene.call_deferred(zone_scene_path)
		return true
	zone_scene_path = LANDMARK_DUNGEON_SCENE_PATH_FORMAT.format(zone)
	if FileAccess.file_exists(zone_scene_path):
		_load_scene.call_deferred(zone_scene_path)
		return true
	return false


## Triggers a scene change to the specified path.
func change_to_scene(scene_path: String) -> void:
	_load_scene.call_deferred(scene_path)


## Triggers the load screen to be created.
func _load_scene(scene_path: String) -> void:
	load_scene_path = scene_path
	get_tree().change_scene_to_packed(_loading_screen)
