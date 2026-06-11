class_name Overworld
extends Node
## The area that the player traverses when traveling between points of note.
##
## Contains terrain meshes and TerrainZones. Handles the placing of the avatar
## for the player character when transitioning to this scene.


## The player avatar for traversing through the overworld.
@export var player_avatar: OverworldAvatar = null


## Places the player avatar at the last recorded position.
func _ready() -> void:
	var start_position := SceneController.prior_avatar_position
	if start_position.is_finite():
		player_avatar.position = start_position
	SceneController.set_avatar_reference(player_avatar)


## Clears out the avatar reference in the SceneController.
func _exit_tree() -> void:
	SceneController.set_avatar_reference(null)
