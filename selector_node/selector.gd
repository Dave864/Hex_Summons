class_name Selector
extends Node
"""
Moves around the map based on mouse movement and detects when a MapTile has been
passed over.
"""


# Signal for the encounter node that specifies which area of tiles to highlight.
# warning-ignore:unused_signal
signal effect_selector_required(effect_area, ignore_height)
# Signal that indicates a move tile has been selected.
# warning-ignore:unused_signal
signal move_tile_selected(map_tile)
# warning-ignore:unused_signal
signal target_selected(selection_area)

# Flag that indicates when the player is changing to a new action mode.
# Used to override the snap position behavior to allow for the selector
# to be moved to the current player's position when changing player actions.
var player_action_change: bool = false
# The MapTile that was last passed over.
var tile_hovered: MapTile = null

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The collision are for the selector
onready var collision_area: Area = $CollisionArea


func _ready() -> void:
	pass


# Move the collision area to the mouse position.
func move_to_mouse_position() -> void:
	collision_area.translation = mouse_position.get_mouse_position()


# Move the collision area to the specified position.
func move_to_position(position: Vector3) -> void:
	collision_area.translation = position
