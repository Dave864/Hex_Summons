class_name Selector
extends Node
"""
Moves around the map based on mouse movement or joystick input and detects
when a MapTile has been passed over.
"""


# Indicates a tile has been selected for movement.
signal move_tile_selected(tile_selected)
# Indicates that a given action needs the effect area displayed.
signal effect_area_required(action)

# The MapTile that was last passed over.
var tile_hovered: MapTile = null
# Describes which hex vertex is the top with respect to the camera
var top_vertex: int = 0
# Reference to the player characters in the current encounter.
var players_ref: Array = []
# Reference to the enemy characer in the current encounter.
var enemies_ref: Array = []
# Reference to the HexMap of the current encounter map.
var map_tiles: Array = []
# Reference to the map's range finder.
var range_finder: RangeFinder = null

# Reference to a function that will update the map tile highlights. Different
# states will use different logic for updating the highlights.
var _update_selection_func: FuncRef = null setget set_update_selection_func


# Sets the _update_selection_func.
func set_update_selection_func(new_func: FuncRef) -> void:
	_update_selection_func = new_func


# Emits the move_tile_selected signal.
func emit_move_tile_selected(tile_selected: MapTile) -> void:
	emit_signal("move_tile_selected", tile_selected)


# Emits the effect_area_required.
func emit_effect_area_required(action: Action) -> void:
	emit_signal("effect_area_required", action)


func _ready() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"top_vertex_changed",
			self,
			"_on_SignalBus_top_vertex_changed"
	)


# Gets the tile that the mouse last hovered over.
func _on_MapTile_mouse_hovered(new_tile: MapTile) -> void:
	if _update_selection_func != null:
		_update_selection_func.call_func(new_tile)


# Updates the relative top vertex when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(new_top_vertex: int) -> void:
	top_vertex = new_top_vertex
