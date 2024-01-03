tool
class_name RangeFinder
extends AStar
"""
A collection of calculations and algorithms used for various map actions that
depend on getting a range of tiles or paths to tiles.
"""


var _z_count: int setget set_z_count
var _x_count: int setget set_x_count
var _map_tiles: Array = [] setget set_map_tiles, get_map_tiles
var _current_range: Array = []
var _char_type: int setget set_char_type


func _init(
	x_value: int,
	z_value: int,
	current_char: int,
	initial_map: Array = []
):
	_x_count = x_value
	_z_count = z_value
	_char_type = current_char
	set_map_tiles(initial_map)


func set_z_count(value: int):
	_z_count = value


func set_x_count(value: int):
	_x_count = value


func set_map_tiles(new_map: Array):
	_map_tiles = new_map
	refresh_astar_connections(_char_type)


func get_map_tiles() -> Array:
	return _map_tiles


func set_char_type(type: int):
	_char_type = type


# Recalculates the astar connnections for the map in its current state.
func refresh_astar_connections(current_char: int):
	_char_type = current_char
	
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < _map_tiles.size():
		reserve_space(_map_tiles.size())
	
	# Add the tiles to the astar map.
	var tile_weight: float
	for tile in _map_tiles:
		# Only add tile if it is active
		if tile.is_active():
			# Set the weight to 50 if the tile is occupied by a character
			# of the opposing faction.
			tile_weight = 1.0 if tile.can_character_pass(_char_type) else 50.0
			add_point(tile.get_index(), tile.translation, tile_weight)
	
	# Set up the connections for the astar map.
	for tile in _map_tiles:
		# Set up connections for active tiles.
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(
						tile.get_index(), 
						neighbor.get_index()
					)


# Determine the astar connections for a map section centered on the character.
func astar_for_range(character: Character):
	# Reset movement flags for previous range.
	for tile in _current_range:
		tile.set_movement_active(false)
	
	_current_range = _get_tiles_in_range(character)
	
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < _current_range.size():
		reserve_space(_current_range.size())
	
	# Add the tiles to the astar map.
	var tile_weight: float
	for tile in _current_range:
		# Set the weight to 50 if the tile is occupied by a character
		# of the opposing faction.
		tile_weight = 1.0 if tile.can_character_pass(_char_type) else 50.0
		add_point(tile.get_index(), tile.translation, tile_weight)
	
	# Set up the connections for the astar map.
	for tile in _current_range:
		# Set up connections for active tiles.
		for neighbor in tile.get_adjacent():
			# Connect non empty and active neighbors.
			if neighbor != null and neighbor.get_movement_active():
				connect_points(
					tile.get_index(), 
					neighbor.get_index()
				)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u, v):
	return _cube_dist(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u, v):
	return min(0, _cube_dist(u, v) - 1)


# Get the tiles that are within reach of the character.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-obstacles
func _get_tiles_in_range(character: Character) -> Array:
	var movement: int = character.stats.get_mvmt()
	# Keeps track of which tiles have been visited.
	var visited: Dictionary = {}
	# An array of map tiles that can be reached within the movement value. 
	var fringes: Array = []
	fringes.append([_map_tiles[character.get_index_at()]])
	
	for i in range(1, movement + 1):
		fringes.append([])
		for tile in fringes[i - 1]:
			for neighbor in tile.get_adjacent():
				if (
					neighbor != null and
					!visited.has(neighbor.get_index()) and 
					neighbor.is_active()
				):
					visited[neighbor.get_index()] = neighbor
					neighbor.set_movement_active(true)
					fringes[i].append(neighbor)
	
	return visited.values()


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
