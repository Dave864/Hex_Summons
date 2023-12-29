tool
class_name RangeFinder
extends AStar
"""
A collection of calculations and algorithms used for various map actions that
depend on getting a range of tiles or paths to tiles.
"""


var _z_count: int setget set_z_count
var _x_count: int setget set_x_count
var _map_tiles: Array = [] setget set_map_tiles


func _init(x_value: int, z_value: int, initial_map: Array = []):
	_x_count = x_value
	_z_count = z_value
	set_map_tiles(initial_map)


func set_z_count(value: int):
	_z_count = value


func set_x_count(value: int):
	_x_count = value


func set_map_tiles(new_map: Array):
	_map_tiles = new_map
	refresh_astar_connections()


# Recalculates the astar connnections for the map in its current state.
func refresh_astar_connections():
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < _map_tiles.size():
		reserve_space(_map_tiles.size())
	
	# Add the tiles to the astar map.
	for tile in _map_tiles:
		# Do not add tile if it is occupied or inactive.
		if tile.is_active() and tile.get_occupant() != null:
			add_point(tile.get_index(), tile.translation)
	
	# Set up the connections for the astar map.
	for tile in _map_tiles:
		# Skip over inactive or occupied tiles.
		if tile.is_active() and tile.get_occupant() == null:
			for neighbor in tile.get_adjacent():
				# Do not connect inactive or occupied tiles.
				if (
					neighbor != null or 
					!tile.is_active() or 
					tile.get_occupant() != null
				):
					connect_points(
						tile.get_index(), 
						neighbor.get_index()
					)


# Calculate the points along the path from the tile at the start index to the
# tile at the end index. The points are returned as an array of Vector3's.
func calculate_path(start_index: int, end_index: int) -> PoolVector3Array:
	return get_point_path(start_index, end_index)


func _compute_cost(u, v):
	return _cube_dist(u, v)


func _estimate_cost(u, v):
	return min(0, _cube_dist(u, v) - 1)


# Calculates the distance between two tiles based on their cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = _index_to_cube(start_index)
	var end_pos: Vector3 = _index_to_cube(end_index)
	var diff: Vector3 = start_pos - end_pos
	return (abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2.0


# Converts the index to the corresponding cube coordinate.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
func _index_to_cube(index: int) -> Vector3:
	var z_pos: int = int(floor(float(index) / float(_x_count)))
	var x_pos: int = index % _x_count
	var x_cube: int = int(x_pos - (z_pos - (z_pos & 1)) / 2.0)
	var y_cube: int = z_pos
	return Vector3(x_cube, y_cube, -x_cube - y_cube)


# Converts the cube coordinates to the corresponding index.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
func _cube_to_index(coord: Vector3) -> int:
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * _x_count) + x_pos
