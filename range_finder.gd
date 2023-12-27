tool
class_name RangeFinder
extends Node
"""
A collection of calculations and algorithms used for various map actions that
depend on getting a range of tiles or paths to tiles.
"""


var _z_count: int = 3 setget set_z_count
var _x_count: int = 2 setget set_x_count
# All the tiles in the map. Set by parent HexMap node.
var _map_tiles: Array = [] setget set_map_tiles
# Used for pathfinding
var _astar_map: AStarHexMap = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _notification(what):
	match what:
		# When set as child of HexMap node, update the x and z counts to be the
		# values of the x and z counts of the HexMap node.
		NOTIFICATION_PARENTED:
			var hex_map: Spatial = get_parent()
			set_x_count(hex_map.x_count)
			set_z_count(hex_map.z_count)
			_astar_map = AStarHexMap.new(_x_count, _z_count)


# Converts the cube coordinates to the corresponding index.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
func _cube_to_index(coord: Vector3) -> int:
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * _x_count) + x_pos


# Calculates the distance between two tiles based on their cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = _map_tiles[start_index].get_cube_coord()
	var end_pos: Vector3 = _map_tiles[end_index].get_cube_coord()
	var diff: Vector3 = start_pos - end_pos
	return (abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2.0


func set_z_count(value: int):
	_z_count = value
	_astar_map = AStarHexMap.new(_x_count, _z_count)


func set_x_count(value: int):
	_x_count = value
	_astar_map = AStarHexMap.new(_x_count, _z_count)


func set_map_tiles(new_map: Array):
	_map_tiles = new_map
	_astar_map.clear()
	if _astar_map.get_point_capacity() < _map_tiles.size():
		_astar_map.reserve_space(_map_tiles.size())
	
	# Add the tiles to the astar map
	for tile in _map_tiles:
		_astar_map.add_point(tile.get_index(), tile.translation)
	
	# Set up the connections for the astar map
	for tile in _map_tiles:
		for neighbor in tile.get_adjacent():
			if neighbor != null:
				_astar_map.connect_points(
					tile.get_index(), 
					neighbor.get_index()
				)


# Calculate the points along the path from the tile at the start index to the
# tile at the end index. The points are returned as an array of Vector3's.
func calculate_path(start_index: int, end_index: int) -> PoolVector3Array:
	return _astar_map.get_point_path(start_index, end_index)
