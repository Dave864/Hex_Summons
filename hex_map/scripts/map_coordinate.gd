@tool
class_name MapCoordinate
extends Marker3D
"""
Keeps track of the current location in a hex map. Tracks the tile index and
cube coordinate.
"""


# The index position of the map tile when it is part of a collection of tiles.
var _tile_index: int = -1: get = get_tile_index, set = set_tile_index
# The cube coordinates of the map tile.
#     -z
# +y   |  +x
#   \ / \ /
#    |   |
#   / \ / \
# -x   |  -y
#     +z
var _cube_coord: Vector3 = Vector3.ZERO: get = get_cube_coord, set = set_cube_coord


# Get the index value of the MapTile.
func get_tile_index() -> int:
	return _tile_index


# Set the index value of the MapTile.
func set_tile_index(value: int):
	_tile_index = value


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3) -> void:
	_cube_coord = value
