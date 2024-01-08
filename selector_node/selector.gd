class_name Selector
extends Area
"""
Moves around the map based on mouse movement and detects when a MapTile has been
passed over.
"""


signal tile_selected(map_tile)

# Reference to the map tiles in the current scene
export(NodePath) var map = null

# Flag that indicates whether to snap to a new position when found
var snap_to_position: bool = true
# Flag that indicates when the player is changing to a new action mode.
# Used to override the snap position behavior to allow for the selector
# to be moved to the current player's position when changing player actions.
var player_action_change: bool = false
# The position the SelectorShape locks to.
var snap_position: Vector3 = Vector3.ZERO
# The MapTile that was last passed over.
var tile: MapTile = null
# The player that is currently active.
var current_player: PlayerCharacter = null

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The mesh that represents the Selector
onready var selector_shape: MeshInstance = $SelectorShape
# The Animation player for the Selector
onready var animation_player: AnimationPlayer = $AnimationPlayer


# Set the position of the selector to the position of the current player.
func snap_to_character():
	translation = Vector3(
		current_player.translation.x,
		0.125,
		current_player.translation.z
	)
