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


# Highlight the specified tiles as movement for the given player character.
func highlight_character_movement(
	tile_indexes: Array,
	pc: PlayerCharacter
) -> void:
	for i in tile_indexes:
		var tile: MapTile = _map_tiles[i]
		if tile.get_current_occupant() == null:
			tile.set_selection_type(MapTile.SelectionType.RANGE)
		elif tile.get_current_occupant().name == pc.name:
			tile.set_selection_type(MapTile.SelectionType.PLAYER)
		else:
			tile.set_selection_type(MapTile.SelectionType.ALLY)


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for tile in _map_tiles:
		tile.set_selection_type(MapTile.SelectionType.NONE)
