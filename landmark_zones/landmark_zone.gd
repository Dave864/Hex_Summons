class_name LandmarkZone
extends Node3D
## Game area for an overworld landmark.
##
## Manages the placement of player avatar when entering from overworld or title
## screen.


## The player character avatar.
@export var player_avatar: OverworldAvatar = null
## The point the character is placed if not entering this zone from Overworld.
@export var default_placement_point: Marker3D = null
## The points that the character can enter the zone from the overworld.
@export var overworld_entry_points: Array[Marker3D] = []


## Places the player avatar at the entry point or some designated start position.
func _ready() -> void:
	assert(player_avatar != null, "No player avatar has been specified.")
	assert(
			overworld_entry_points.size() > 0 and overworld_entry_points[0] != null,
			"No overworld_entry_point has been specified."
	)
	if (
			SceneController.landmark_active == ""
			and default_placement_point != null
	):
		player_avatar.global_position = default_placement_point.global_position
	elif SceneController.get_active_landmark_zone() == name:
		overworld_entry_points.sort_custom(_sort_closest_to_entry)
		player_avatar.global_position = overworld_entry_points[0].global_position
		player_avatar.set_facing_direction(
				SceneController.landmark_transition_direction
		)


## Returns which marker more closely matches the entry direction.
func _sort_closest_to_entry(a: Marker3D, b: Marker3D) -> bool:
	var direction_a := -Vector2(a.position.x, a.position.z).normalized()
	var direction_b := -Vector2(b.position.x, b.position.z).normalized()
	return (
			direction_a.dot(SceneController.landmark_transition_direction)
			> direction_b.dot(SceneController.landmark_transition_direction)
	)


## Returns which marker is closer to the player.
func _sort_closest_to_player(a: Marker3D, b: Marker3D) -> bool:
	var dist_a := a.global_position.distance_squared_to(
			player_avatar.global_position
	)
	var dist_b := b.global_position.distance_squared_to(
			player_avatar.global_position
	)
	return dist_a < dist_b


## Transitions to the overworld. Sets active landmark to be the one connected
## to this zone.
func _on_exit_zone_body_entered(_body: Node3D) -> void:
	SceneController.landmark_active = SceneController.get_zone_landmark(name)
	overworld_entry_points.sort_custom(_sort_closest_to_player)
	SceneController.landmark_transition_direction = Vector2(
			overworld_entry_points[0].global_position.x,
			overworld_entry_points[0].global_position.z
	).normalized()
	SceneController.change_scene_to_overworld()
