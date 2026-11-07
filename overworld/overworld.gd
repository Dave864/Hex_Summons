class_name Overworld
extends Node
## The area that the player traverses when traveling between points of note.
##
## Contains terrain meshes and TerrainZones. Handles the placing of the avatar
## for the player character when transitioning to this scene.


## The player avatar for traversing through the overworld.
@export var player_avatar: OverworldAvatar = null

## The map landmarks.
var _landmarks: Array[Landmark] = []


## Places the player avatar at the last recorded position.
func _ready() -> void:
	_obtain_landmarks()
	var start_position := SceneController.prior_avatar_position
	if SceneController.landmark_active != "":
		var landmark := _find_active_landmark()
		if landmark != null:
			player_avatar.global_position = landmark.get_spawn_point()
			SceneController.reset_landmark()
			return
	elif start_position.is_finite():
		player_avatar.position = start_position
		return
	printerr("No valid position for player found.")


## Records the last current position.
func _exit_tree() -> void:
	SceneController.prior_avatar_position = player_avatar.position


## Gets the landmarks currently set.
func _obtain_landmarks() -> void:
	for landmark: Node in $Landmarks.get_children():
		if landmark is Landmark:
			_landmarks.append(landmark)


## Gets the landmark marked as active by the SceneController. Returns null if
## there is no landmark matching the tracked name.
func _find_active_landmark() -> Landmark:
	for landmark: Landmark in _landmarks:
		if landmark.name == SceneController.landmark_active:
			return landmark
	printerr(
			"No Landmark named {0} is present.".format(
				[SceneController.landmark_active]
			)
	)
	return null
