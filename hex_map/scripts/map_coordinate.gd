tool
class_name MapCoordinate
extends Position3D
"""
Keeps track of the current location in a hex map. Tracks the tile index and
cube coordinate.
"""


# The index position of the map tile when it is part of a collection of tiles.
var _map_index: int = -1 setget set_map_index, get_map_index
# The cube coordinates of the map tile.
#     -z
# +y   |  +x
#   \ / \ /
#    |   |
#   / \ / \
# -x   |  -y
#     +z
var _cube_coord: Vector3 = Vector3.ZERO setget set_cube_coord, get_cube_coord


# Get the index value of the MapTile.
func get_map_index() -> int:
	return _map_index


# Set the index value of the MapTile.
func set_map_index(value: int):
	_map_index = value


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3) -> void:
	_cube_coord = value


func _on_Character_area_entered(map_tile: Area) -> void:
	set_map_index(map_tile.map_coordinate.get_map_index())
	set_cube_coord(map_tile.map_coordinate.get_cube_coord())
