class_name Selector
extends Node
"""
Handles the selection of map tiles for player movement and actions.
"""


# The MapTile that was last passed over.
var tile_hovered: MapTile = null
# Describes which hex vertex is the top with respect to the camera
var top_vertex: int = 0
# Reference to the active player character.
var active_player: PlayerCharacter = null
# Reference to the player characters in the current encounter.
var players_ref: Array = []
# Reference to the enemy characer in the current encounter.
var enemies_ref: Array = []
# Reference to the HexMap of the current encounter map.
var hex_map: HexMap = null

# Reference to a function that will update the map tile highlights. Different
# states will use different logic for updating the highlights.
var _update_selection_func: Callable: set = set_update_selection_func


# Sets the _update_selection_func.
func set_update_selection_func(new_func: Callable) -> void:
	_update_selection_func = new_func


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
		_update_selection_func.call(new_tile)


# Updates the relative top vertex when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(new_top_vertex: int) -> void:
	top_vertex = new_top_vertex
