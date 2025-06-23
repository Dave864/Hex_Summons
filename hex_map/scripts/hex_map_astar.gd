class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


# Tracks how many tiles are along the x-axis of the hex map this object represents.
var _x_count: int = 0


# Get the area that can be reached in a specific map section starting from a
# given point in said section. This takes into account the tile heights.
# Will return an empty array if the start tile is not in the map section.
func get_traversable_ids(start_id: int, reach: int, map_section_ids: Array) -> Array:
	var ids_in_range: Array = []
	for id in map_section_ids:
		if is_point_disabled(id):
			continue
		if distance(start_id, id) <= reach:
			ids_in_range.append(id)
	return ids_in_range


# Determines the travel distance from the start to the end.
func distance(start_index: int, end_index: int) -> float:
	var path: PoolIntArray = get_id_path(start_index, end_index)
	var dist: float = 0.0
	for i in range(1, path.size()):
		dist += _compute_cost(path[i - 1], path[i])
	return dist


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func update_astar_disabled_for_characters(characters: Array, disabled: bool) -> void:
	for c in characters:
		set_point_disabled(c.get_index_at(), disabled)


# Set the disabled flag for the specified area in the astar map.
func set_area_disabled(tile_ids: Array, disabled: bool = true) -> void:
	for id in tile_ids:
		set_point_disabled(id, disabled)


# Sets the disabled flag for all connections in the astar map.
func set_all_disabled(disabled: bool = true) -> void:
	for id in get_point_count():
		set_point_disabled(id, disabled)


func _init(hex_map_tiles: Array, x_count: int) -> void:
	_x_count = x_count
	# Empty out the current astar map and resize if necessary.
	clear()
	if get_point_capacity() < hex_map_tiles.size():
		reserve_space(hex_map_tiles.size())
	
	# Add the tiles to the astar map.
	for tile in hex_map_tiles:
		if !tile.is_active():
			continue
		"""
		TODO: weight will need to be updated when different tile types
		are eventually created
		"""
		add_point(
				tile.map_coordinate.get_map_index(),
				tile.get_character_position(),
				1.0
		)
		set_point_disabled(tile.map_coordinate.get_map_index())
	_connect_tiles(hex_map_tiles)


# Establish the connections in the astar map for the specified area.
func _connect_tiles(map_tiles: Array) -> void:
	for tile in map_tiles:
		if !tile.is_active():
			continue
		for neighbor in tile.get_all_adjacent():
			if neighbor == null or not neighbor.is_active():
				continue
			connect_points(
					tile.map_coordinate.get_map_index(),
					neighbor.map_coordinate.get_map_index()
			)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u: int, v: int) -> float:
	return _cube_dist(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u: int, v: int) -> float:
	return min(0, _cube_dist(u, v) - 1)


# Calculates the distance between two tiles. Uses the cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_cube: Vector3 = HexUtil.index_to_cube(start_index, _x_count)
	var end_cube: Vector3 = HexUtil.index_to_cube(end_index, _x_count)
	var diff: Vector3 = start_cube - end_cube
	
	var start_pos: Vector3 = get_point_position(start_index)
	var end_pos: Vector3 = get_point_position(end_index)
	# Record height difference as units of tile unit height.
	var height_diff: float = abs(start_pos.y - end_pos.y) / Constants.HEX_TILE_UNIT_HEIGHT
	# Height differences of 1 tile height are seen as the same height
	height_diff = height_diff if height_diff > 1.0 else 0.0
	return (abs(diff.x) + abs(diff.y) + abs(diff.z) + abs(height_diff)) / 2.0
