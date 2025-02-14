tool
class_name HexMap
extends Spatial
"""
A representation of the overall battlemap. Exposes the necessary parameters
from the child nodes that are needed for other nodes to interact with the map.
"""


onready var _map_tiles: Array = $Tiles.get_children() setget , get_map_tiles


# Get the number of tiles along the X axis.
func get_x_count() -> int:
	return $Tiles.get_x_count()


# Get the number of tiles along the Z axis.
func get_z_count() -> int:
	return $Tiles.get_z_count()


# Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array:
	return _map_tiles


# Highlight the tiles at the specified indexes. Will not highlight tiles that 
# are occupied by allies.
func highlight_tiles(
	tile_indexes: Array, 
	current_character_type: int = Constants.MapOccupants.EMPTY
) -> void:
	for i in tile_indexes:
		var tile: MapTile = _map_tiles[i]
		tile.set_is_selectable(tile.can_character_pass(current_character_type))


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for tile in _map_tiles:
		tile.set_is_selectable(false)
