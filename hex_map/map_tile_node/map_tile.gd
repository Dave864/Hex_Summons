tool
class_name MapTile
extends Area
"""
Represents an individual map tile.
"""


# References the MapTile nodes that are adjacent to this one.
#  0  /\  1
#  5 |  | 2
#  4  \/  3
var _adjacent_tiles: Array = [null, null, null, null, null, null]
# The index position of the map tile when it is part 
# of a collection of tiles.
var _index: int = -1 setget set_index, get_index
# The cube coordinates of the map tile.
#     -z
# +y   |  +x
#   \ / \ /
#    |   |
#   / \ / \
# -x   |  -y
#     +z
var _cube_coord: Vector3 = Vector3.ZERO setget set_cube_coord, get_cube_coord


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Gets the adjacent tile of the specified position.
func get_adjacent_tile(position: int) -> Spatial:
	return _adjacent_tiles[position]


# Gets the adjacent tile of the specified position.
func set_adjacent_tile(position: int, map_tile: Area):
	_adjacent_tiles[position] = map_tile


# Get the index value of the MapTile.
func get_index() -> int:
	return _index


# Set the index value of the MapTile.
func set_index(value: int):
	_index = value


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3):
	_cube_coord = value


# Checks whether the Map Tile is an active element of the map.
func is_active() -> bool:
	return visible
