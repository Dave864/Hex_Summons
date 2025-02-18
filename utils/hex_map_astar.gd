class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
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


# Get the indices of the tiles that are within movement range of a character.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-obstacles
func determine_move_range(c: Character) -> Array:
	var movement: int = c.stats.get_mvmt()
	var visited: Dictionary = {}
	var fringes: Array = []
	# Start with the character's position
	fringes.append([_map_tiles[c.get_index_at()]]) 
	visited[c.get_index_at()] = _map_tiles[c.get_index_at()]

	# Get the tiles within movement range
	for i in range(1, movement + 1):
		fringes.append([])
		for tile in fringes[i - 1]:
			for neighbor in tile.get_adjacent():
				if (
					neighbor != null and
					!visited.has(neighbor.get_index()) and 
					neighbor.is_active() and
					neighbor.can_character_pass(c.get_type())
				):
					visited[neighbor.get_index()] = neighbor
					fringes[i].append(neighbor)
	return visited.keys()


# Determines the path to the point closest to the specified ID for a given character.
# Takes a character, the id of the desired destination tile, and an array of tiles
# the character can traverse to. The array is calculated if not provided.
func get_point_path_toward(
	c: Character,
	dest_id: int,
	movement_array: Array = []
) -> PoolVector3Array:
	if movement_array.size() == 0:
		movement_array = determine_move_range(c)
	
	_update_astar_disabled(c.get_type())
	# reenable destination tile to allow a path to be found
	set_point_disabled(dest_id, false)
	
	var true_dest_id: int = dest_id
	while true:
		var path_to_dest: PoolIntArray = get_id_path(c.get_index_at(), dest_id)
		
		# Determine the last point in the path that is within a character's
		# movement range.
		var i: int = path_to_dest.size() - 1
		while true and i > 0:
			if not path_to_dest[i] in movement_array:
				true_dest_id = path_to_dest[i - 1]
				i -= 1
			else:
				break
		
		# Check if the true destination, the last tile in the available move, is
		# occupied by an ally other than itself. Disable that tile and recalculate
		# the shortest path if so.
		var dest_occupant: Character = _map_tiles[true_dest_id].get_current_occupant()
		if (
			dest_occupant != null
			and dest_occupant.name != c.name
			and dest_occupant.get_type() == c.get_type()
		):
			set_point_disabled(true_dest_id, true)
		else:
			break
	
	_disconnect_area(movement_array)
	var point_path: PoolVector3Array = get_point_path(c.get_index_at(), true_dest_id)
	_full_reset()
	
	return point_path


# Calculates the distance from a given character to a specified destination.
func calculate_distance_from_character(c: Character, dest_id: int) -> int:
	_update_astar_disabled(c.get_type())
	# reenable destination tile to allow a path to be found
	set_point_disabled(dest_id, false)
	return get_id_path(c.get_index_at(), dest_id).size()


func _init(
	x_value: int,
	z_value: int,
	hex_map_tiles: Array,
	players: Array,
	enemies: Array
) -> void:
	_players = players # Passed by reference
	_enemies = enemies # Passed by reference
	set_x_count(x_value)
	set_z_count(z_value)
	set_map_tiles(hex_map_tiles)


# Determines the astar connnections for the current set of map tiles.
func _establish_astar_connections() -> void:
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < _map_tiles.size():
		reserve_space(_map_tiles.size())
	
	# Add the tiles to the astar map.
	for tile in _map_tiles:
		if tile.is_active():
			"""
			TODO: weight will need to be updated when different tile types
			are eventually created
			"""
			add_point(tile.get_index(), tile.translation, 1.0)
	
	_reconnect_nodes()


# Helper for update_astar_disabled. Updates the astar disabled flag for the tiles
# occupied by the specific character type.
func _update_character_astar_disabled(characters: Array, active_type: int) -> void:
	for c in characters:
		set_point_disabled(c.get_index_at(), active_type != c.get_type())


# Update the disabled status of astar points to account for the specified
# character type. Points that have characters of the opposite type will
# be disabled, while all other points are enabled.
func _update_astar_disabled(active_character_type: int) -> void:
	_update_character_astar_disabled(_enemies, active_character_type)
	_update_character_astar_disabled(_players, active_character_type)


# Disconnects a part of a map from the rest. The part to disconnect is represented
# as an array of ids.
func _disconnect_area(tiles_to_disconnect: Array) -> void:
	for id in tiles_to_disconnect:
		var tile: MapTile = _map_tiles[id]
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				if (
						neighbor != null 
						and not neighbor.get_index() in tiles_to_disconnect
				):
					disconnect_points(tile.get_index(), neighbor.get_index())


# Reestablish the connections in the astar map.
func _reconnect_nodes() -> void:
	for tile in _map_tiles:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(tile.get_index(), neighbor.get_index())


# Reset the disabled flag for all connections in the astar map.
func _reset_disabled() -> void:
	for tile in _map_tiles:
		if tile.is_active():
			set_point_disabled(tile.get_index(), false)


# Fully reset the connection map. This will reestablish all connections and
# reenable all nodes.
func _full_reset():
	_reconnect_nodes()
	_reset_disabled()


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
	"""
	TODO: add logic to account for height difference in tiles
	"""
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
