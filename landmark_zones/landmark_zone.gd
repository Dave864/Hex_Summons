class_name LandmarkZone
extends Node3D
## Game area for an overworld landmark.
##
## Manages the placement of player avatar when entering from overworld or title
## screen.


## The player character avatar.
@export var player_avatar: CharacterBody3D = null
## The point that the character enters the zone from the overworld.
@export var overworld_entry_point: Marker3D = null


## Places the player avatar at the entry point or some designated start position.
func _ready() -> void:
	if SceneController.get_active_landmark_zone() == name:
		player_avatar.global_position = overworld_entry_point.global_position


## Transitions to the overworld. Sets active landmark to be the one connected
## to this zone.
func _on_exit_zone_body_entered(_body: Node3D) -> void:
	SceneController.landmark_active = SceneController.get_zone_landmark(name)
	SceneController.change_scene_to_overworld()
