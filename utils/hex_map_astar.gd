class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding.
"""


var _z_count: int setget set_z_count
var _x_count: int setget set_x_count
var _map_tiles: Array = [] setget set_map_tiles, get_map_tiles
var _players: Array
var _enemies: Array


func set_z_count(value: int) -> void:
	_z_count = value


func set_x_count(value: int) -> void:
	_x_count = value


func set_map_tiles(new_map: Array) -> void:
	_map_tiles = new_map
	_establish_astar_connections()


func get_map_tiles() -> Array:
	return _map_tiles


# Update the weight values of astar points to account for the specified
# character type. Points that have characters of the opposite type will
# have their weight increased, while the points occupied by the same type
# will be reset to their original values.
func update_astar_weights(active_character_type: int) -> void:
	_update_character_astar_weights(
		_enemies, 
		active_character_type == Constants.MapOccupants.ENEMY
	)
	_update_character_astar_weights(
		_players, 
		active_character_type == Constants.MapOccupants.PLAYER
	)


func _init(
	x_value: int,
	z_value: int,
	hex_map_tiles: Array,
	players: Array,
	enemies: Array
) -> void:
	_x_count = x_value
	_z_count = z_value
	_players = players # Passed by reference
	_enemies = enemies # Passed by reference
	set_map_tiles(hex_map_tiles)


# Determines the astar connnections for the current set of map tiles.
func _establish_astar_connections() -> void:
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < _map_tiles.size():
		reserve_space(_map_tiles.size())
	
	# Add the tiles to the astar map.
	var tile_weight: float
	for tile in _map_tiles:
		if tile.is_active():
			var index: int = tile.get_index()
			# TODO: weight will need to be updated when different tile types
			# are eventually created
			add_point(index, tile.translation, 1.0)
	
	# Set up the connections for the astar map.
	for tile in _map_tiles:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(
						tile.get_index(), 
						neighbor.get_index()
					)


# Helper for update_astar_weights. Updates the astar weights for the tiles
# occupied by the specific character type.
func _update_character_astar_weights(characters: Array, is_active_type: bool) -> void:
	var weight: float
	for c in characters:
		weight = get_point_weight_scale(c.get_index_at())
		if not is_active_type:
			weight += Constants.ASTAR_ADJUSTMENT_WEIGHT
		else:
			weight -= (
					Constants.ASTAR_ADJUSTMENT_WEIGHT if weight > Constants.ASTAR_ADJUSTMENT_WEIGHT 
					else 0.0
			)
		set_point_weight_scale(c.get_index_at(), weight)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u, v) -> float:
	return _cube_dist(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u, v) -> float:
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
