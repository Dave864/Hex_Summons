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
# The position the SelectorShape locks to.
var snap_position: Vector3 = Vector3.ZERO
# The MapTile that was last passed over
var tile: MapTile = null

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The mesh that represents the Selector
onready var selector_shape: MeshInstance = $SelectorShape
# The Animation player for the Selector
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_Selector_area_entered(map_tile: Area):
	# Don't snap to position if map_tile is disabled or inactive.
	if (
		snap_to_position and
		map_tile.is_active() and
		map_tile.get_movement_active()
	):
		snap_position = map_tile.translation
		tile = map_tile
