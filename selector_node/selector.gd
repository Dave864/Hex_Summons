class_name Selector
extends Node
"""
Moves around the map based on mouse movement or joystick input and detects
when a MapTile has been passed over.
"""


# Signal for the encounter node that specifies which tiles to highlight for effect
# range selection.
# warning-ignore:unused_signal
signal effect_selector_required(effect_range_tiles, ignore_height)
# Signal that indicates a move tile has been selected.
# warning-ignore:unused_signal
signal move_tile_selected(map_tile)
# warning-ignore:unused_signal
signal target_selected(selection_area)
# Indicates that the selector is being paused.
# warning-ignore:unused_signal
signal selector_paused()

# Reference to this node's FSM
export(NodePath) var fsm_path = null

var fsm: StateMachine = null
# The MapTile that was last passed over.
var tile_hovered: MapTile = null

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The collision are for the selector
onready var collision_area: Area = $CollisionArea


func _ready() -> void:
	_check_for_required_parameters()
	fsm = get_node(fsm_path)


# Move the collision area to the mouse position.
func move_to_mouse_position() -> void:
	collision_area.translation = mouse_position.get_mouse_position()


# Move the collision area to the specified position.
func move_to_position(position: Vector3) -> void:
	collision_area.translation = position


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		fsm_path != null,
		"EncounterUI has not set the path for the FSM."
	)
