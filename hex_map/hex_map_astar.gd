class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


var _heights: PoolIntArray
var _x_count: int
var _z_count: int


func _init(hex_map_tiles: Array, x_count: int, z_count: int) -> void:
	_x_count = x_count
	_z_count = z_count
	
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < hex_map_tiles.size():
		reserve_space(hex_map_tiles.size())
	_heights.resize(hex_map_tiles.size())
	
	# Add the tiles to the astar map.
	for i in hex_map_tiles.size():
		var tile: MapTile = hex_map_tiles[i]
		if tile.is_active():
			# Record the height of the tile
			_heights[i] = tile.height
			"""
			TODO: weight will need to be updated when different tile types
			are eventually created
			"""
			add_point(tile.get_index(), tile.character_position(), 1.0)
	
	_reconnect_nodes(hex_map_tiles)


## Get the indices of the tiles that are within movement range of a character.
## Reference: https://www.redblobgames.com/grids/hexagons/#range-obstacles
#func get_move_area(c: Character) -> Array:
#	var movement: int = c.stats.get_mvmt()
#	var map_area: Array = get_tiles_in_area(c.get_index_at(), movement, c.get_type())
#	return get_traversable_tiles(c.get_index_at(), movement, map_area)


## Get the indices of the tiles that are within the specified cardinal range
## of the character.
#func get_cardinal_area(
#	c: Character,
#	r: CardinalRange,
#	ignore_heights: bool = false
#) -> PoolIntArray:
#	var tile_indices: PoolIntArray = []
#	var td: PoolRealArray = []
#	# Set initial size to maximum possible amount
#	tile_indices.resize((r.area_distance - r.dead_distance) * 6)
#	td.resize(6)
#	td.fill(0.0)
#	var cube_origin: Vector3 = _index_to_cube(c.get_index_at())
#
#	for i in range(1, r.area_distance - r.dead_distance + 1):
#		var step: float = float(r.dead_distance + i)
#		var n_0: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.UPPER_LEFT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		var n_1: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.UPPER_RIGHT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		var n_2: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.RIGHT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		var n_3: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.BOTTOM_RIGHT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		var n_4: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.BOTTOM_LEFT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		var n_5: int = _get_cardinal_area_helper(
#			cube_origin,
#			step,
#			MapTile.NeighborPosition.LEFT,
#			c.stats.movement,
#			td,
#			ignore_heights
#		)
#		if n_0 >= 0:
#			tile_indices.append(n_0)
#		if n_1 >= 0:
#			tile_indices.append(n_1)
#		if n_2 >= 0:
#			tile_indices.append(n_2)
#		if n_3 >= 0:
#			tile_indices.append(n_3)
#		if n_4 >= 0:
#			tile_indices.append(n_4)
#		if n_5 >= 0:
#			tile_indices.append(n_5)
#
#	return tile_indices


# Determines the path to the point within an area closest to the start.
func get_point_path_toward(
	start_id: int,
	dest_id: int,
	movement_area: Array = []
) -> PoolVector3Array:
	# reenable destination tile to allow a path to be found when target tile 
	# has an opponent.
	set_point_disabled(dest_id, false)
	
	var tile_indices: PoolIntArray = []
	tile_indices.resize(movement_area.size())
	for t in movement_area.size():
		tile_indices[t] = movement_area[t].get_index()
	
	var true_dest_id: int = dest_id
	while true:
		var path_to_dest: PoolIntArray = get_id_path(start_id, dest_id)
		
		# Determine the last point in the path that is within the movement 
		# range. A tile occupied by an opponent is not considered within
		# movement range.
		var i: int = path_to_dest.size() - 1
		while true and i > 0:
#			var occupant: Character = _map_tiles[path_to_dest[i]].get_current_occupant()
			if (
				not path_to_dest[i] in movement_area
#				or (occupant != null and occupant.get_type() != c.get_type())
			):
				true_dest_id = path_to_dest[i - 1]
				i -= 1
			else:
				break
		
#		# Check if the true destination, the last tile in the available move, is
#		# occupied by an ally other than itself. Disable that tile and recalculate
#		# the shortest path if so.
#		var dest_occupant: Character = _map_tiles[true_dest_id].get_current_occupant()
#		if (
#			dest_occupant != null
#			and dest_occupant.name != c.name
#			and dest_occupant.get_type() == c.get_type()
#		):
#			set_point_disabled(true_dest_id, true)
#		else:
#			break
	
	_disconnect_area(movement_area)
	var point_path: PoolVector3Array = get_point_path(start_id, true_dest_id)
	_full_reset(movement_area)
	
	return point_path


# Calculates the distance from a given start to a specified destination.
func calculate_distance(start_id: int, dest_id: int) -> int:
	return get_id_path(start_id, dest_id).size()


## Get the map section that is in a specified "radius" from a given point.
## This is the same as determining all tiles that can be reached when all
## tiles are the same height.
#func get_tiles_in_area(
#	start_index: int,
#	radius: int,
#	c_type: int = Constants.MapOccupants.EMPTY
#) -> Array:
#	var visited: Dictionary = {}
#	var fringes: Array = []
#	# Start with the character's position
#	fringes.append([_map_tiles[start_index]]) 
#	visited[start_index] = _map_tiles[start_index]
#
#	# Get all possible tiles within the radius
#	for i in range(1, radius + 1):
#		fringes.append([])
#		for tile in fringes[i - 1]:
#			for neighbor in tile.get_adjacent():
#				if (
#					neighbor != null and
#					!visited.has(neighbor.get_index()) and 
#					neighbor.is_active() and
#					neighbor.can_character_pass(c_type)
#				):
#					visited[neighbor.get_index()] = neighbor
#					fringes[i].append(neighbor)
#	return visited.keys()


## Get the area that can be reached in a specific map section starting from a
## given point in said section. This takes into account the tile heights.
## Will return an empty array if the start tile is not in the map section.
#func get_traversable_tiles(start_tile: int, movement: int, map_section: Array) -> Array:
#	var tiles_in_range: Array = []
#	_disconnect_area(map_section)
#	for tiles in map_section:
#		var tile_index: int = tiles.get_index()
#		var path: PoolIntArray = get_id_path(start_tile, tile_index)
#		var total_distance: float = 0.0
#		for i in range(1, path.size()):
#			total_distance += _compute_cost(path[i - 1], path[i])
#		if total_distance <= movement:
#			tiles_in_range.append(tile_index)
#	_reconnect_nodes()
#	return tiles_in_range


## Helper function for get_cardinal_area. 
## Determines the index of the map tile that is a number of steps away from a 
## given tile at the specified cube coordinates. Determines if the located tile
## is within traversal range based on the provided max_distance when taking into 
## account tile heights. Returns -1 if the found index is invalid.
#func _get_cardinal_area_helper(
#	cube_origin: Vector3,
#	step: float,
#	dir: int,
#	max_distance: float,
#	travel_distances: Array,
#	ignore_heights: bool
#) -> int:
#	var index: int = _cube_to_index(_cube_at_distance(cube_origin, step, dir))
#	if _map_tiles[index] != null and _map_tiles[index].is_active():
#		if not ignore_heights:
#			var prev: int = _cube_to_index(_cube_at_distance(cube_origin, step - 1, dir))
#			travel_distances[dir] += _compute_cost(prev, index)
#			if travel_distances[dir] > max_distance:
#				index = -1
#	else:
#		index = -1
#	return index


## Determines the astar connnections for the current set of map tiles.
#func _establish_astar_connections() -> void:
#	# Empty out the current astar map and resize if necessary.
#	clear()
#	if get_point_capacity() < _map_tiles.size():
#		reserve_space(_map_tiles.size())
#
#	# Add the tiles to the astar map.
#	for tile in _map_tiles:
#		if tile.is_active():
#			"""
#			TODO: weight will need to be updated when different tile types
#			are eventually created
#			"""
#			add_point(tile.get_index(), tile.character_position(), 1.0)
#
#	_reconnect_nodes()


# Helper for update_astar_disabled. Updates the astar disabled flag for the tiles
# occupied by a specific character type.
func _update_character_astar_disabled(characters: Array, disabled: bool) -> void:
	for c in characters:
		set_point_disabled(c.get_index_at(), disabled)


## Update the disabled status of astar points to account for the specified
## character type. Points that have characters of the opposite type will
## be disabled, while all other points are enabled.
#func _update_astar_disabled(active_character_type: int) -> void:
#	_update_character_astar_disabled(
#		_enemies, 
#		active_character_type != Constants.MapOccupants.ENEMY
#	)
#	_update_character_astar_disabled(
#		_players, 
#		active_character_type != Constants.MapOccupants.PLAYER
#	)


# Disconnects a part of a map from the rest. The part to disconnect is an array
# of MapTiles.
func _disconnect_area(tiles_to_disconnect: Array) -> void:
	for tile in tiles_to_disconnect:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				if (
						neighbor != null 
						and not neighbor.get_index() in tiles_to_disconnect
				):
					disconnect_points(tile.get_index(), neighbor.get_index())


# Reestablish the connections in the astar map.
func _reconnect_nodes(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(tile.get_index(), neighbor.get_index())


# Reset the disabled flag for all connections in the astar map.
func _reset_disabled(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			set_point_disabled(tile.get_index(), false)


# Fully reset the connection map. This will reestablish all connections and
# reenable all nodes.
func _full_reset(map_tiles: Array):
	_reconnect_nodes(map_tiles)
	_reset_disabled(map_tiles)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u: int, v: int) -> float:
	var height_diff: float = abs(_heights[v] - _heights[u])
	# Height differences of 1 are seen as the same height
	height_diff = 0.0 if height_diff <= 1.0 else height_diff
	return _cube_dist(u, v) + height_diff


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u: int, v: int) -> float:
	var height_diff: float = abs(_heights[v] - _heights[u])
	# Height differences of 1 are seen as the same height
	height_diff = 0.0 if height_diff <= 1.0 else height_diff
	return min(0, _cube_dist(u, v) + height_diff - 1)


# Calculates the distance between two tiles based on their cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = _index_to_cube(start_index)
	var end_pos: Vector3 = _index_to_cube(end_index)
	var diff: Vector3 = start_pos - end_pos
	return (abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2.0


# Get the cube coordinates of the tile a specified distance away from an origin
# point in a specific hexagonal cardinal direction.
# 0  /\  1
# 5 |  | 2
# 4  \/  3
# Reference: # https://www.redblobgames.com/grids/hexagons/#neighbors
func _cube_at_distance(origin: Vector3, distance: float, direction: int) -> Vector3:
	var dest: Vector3
	match direction:
		MapTile.NeighborPosition.UPPER_LEFT:
			dest = origin + Vector3(0.0, -distance, distance)
		MapTile.NeighborPosition.UPPER_RIGHT:
			dest = origin + Vector3(distance, -distance, 0.0)
		MapTile.NeighborPosition.RIGHT:
			dest = origin + Vector3(0.0, distance, -distance)
		MapTile.NeighborPosition.BOTTOM_RIGHT:
			dest = origin + Vector3(distance, 0.0, -distance)
		MapTile.NeighborPosition.BOTTOM_LEFT:
			dest = origin + Vector3(-distance, distance, 0.0)
		MapTile.NeighborPosition.LEFT:
			dest = origin + Vector3(-distance, 0.0, distance)
		_:
			dest = origin
	return dest


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
	# Use bitwise and to detect whether something is even (0) or odd (1), 
	# in order to catch negative numbers too.
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * _x_count) + x_pos
