class_name Selector
extends Area
"""
Moves around the map based on mouse movement and detects when a MapTile has been
passed over.
"""


# warning-ignore:unused_signal
signal move_tile_selected(map_tile)
# warning-ignore:unused_signal
signal target_selected(selection_area)

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

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The mesh that represents the Selector
onready var selector_shape: MeshInstance = $SelectorShape


# Set the position of the selector.
func set_to_position(position: Vector3) -> void:
	translation = position_relative_to_selector_shape(position)


# Move the Selector to the mouse position.
func move_to_mouse_position() -> void:
	translation = mouse_position.get_mouse_position()


# Snap the position of the Selector shape mesh to the last hovered over tile.
func position_selector_shape() -> void:
	var new_position: Vector3 = snap_position - translation
	selector_shape.translation = position_relative_to_selector_shape(new_position)


# Adjusts the provided position to account for the position of the selector shape. 
func position_relative_to_selector_shape(position: Vector3) -> Vector3:
	return Vector3(position.x, position.y + Constants.SELECTOR_DISPLACEMENT, position.z)
