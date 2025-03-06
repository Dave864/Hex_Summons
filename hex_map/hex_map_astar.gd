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
			add_point(tile.get_map_index(), tile.character_position(), 1.0)
	
	reconnect_area(hex_map_tiles)


# Get the area that can be reached in a specific map section starting from a
# given point in said section. This takes into account the tile heights.
# Will return an empty array if the start tile is not in the map section.
func get_traversable_tiles(start_tile: int, reach: int, map_section: Array) -> Array:
	var tiles_in_range: Array = []
	disconnect_area(map_section)
	for tiles in map_section:
		var tile_index: int = tiles.get_index()
		var path: PoolIntArray = get_id_path(start_tile, tile_index)
		var total_distance: float = 0.0
		for i in range(1, path.size()):
			total_distance += _compute_cost(path[i - 1], path[i])
		if total_distance <= reach:
			tiles_in_range.append(tile_index)
	reconnect_area(map_section)
	return tiles_in_range


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func update_astar_disabled_for_characters(characters: Array, disabled: bool) -> void:
	for c in characters:
		set_point_disabled(c.get_index_at(), disabled)


# Disconnects a part of a map from the rest. The part to disconnect is an array
# of MapTiles.
func disconnect_area(tiles_to_disconnect: Array) -> void:
	for tile in tiles_to_disconnect:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				if (
						neighbor != null 
						and not neighbor.get_map_index() in tiles_to_disconnect
				):
					disconnect_points(tile.get_map_index(), neighbor.get_map_index())


# Fully reset the connection map for the given section of map.
func full_reset(map_tiles: Array):
	reconnect_area(map_tiles)
	reset_disabled(map_tiles)


# Reestablish the connections in the astar map for the specified area.
func reconnect_area(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			for neighbor in tile.get_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(tile.get_map_index(), neighbor.get_map_index())


# Reset the disabled flag for the specified connections in the astar map.
func reset_disabled(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			set_point_disabled(tile.get_map_index(), false)


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
