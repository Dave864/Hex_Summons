class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


# Tracks how many tiles are along the x-axis of the hex map this object represents.
var _x_count: int = 0


# Gets the distances from the starting point to all tiles within a given reach.
# A negative reach indicates that all map tiles should be looked at. Specifying
# get_all determines whether to include tiles that are outside of reach of not.
# Each entry has the travel distance and tile distance stored in an array.
# Travel distance is at index 0, tile distance is at index 1.
# Reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html#dijkstra
func get_distance_map(start_id: int, get_all: bool, reach: int = -1) -> Dictionary:
	var frontier: PQueue = PQueue.new()
	var id_distances: Dictionary = {}
	
	frontier.push(0.0, start_id)
	id_distances[start_id] = [0.0, 0]
	while not frontier.empty():
		var current: Array = frontier.min()
		frontier.pop_min()
		
		for next_id in get_point_connections(current[1]):
			if is_point_disabled(next_id):
				continue
			var cur_dist: Array = id_distances[current[1]]
			var travel_dist: float = _travel_dist(current[1], next_id) + cur_dist[0]
			var tile_dist: int = int(_cube_dist(start_id, next_id))
			if (
				(
					not id_distances.has(next_id)
					or travel_dist < id_distances[next_id][0]
				)
				and (reach < 0 or tile_dist <= reach)
				and (get_all or travel_dist <= reach)
			):
				id_distances[next_id] = [travel_dist, tile_dist]
				frontier.push(travel_dist, next_id)
	
	frontier.free()
	return id_distances


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
				tile.map_coordinate.get_index(),
				tile.get_character_position(),
				1.0
		)
		set_point_disabled(tile.map_coordinate.get_index())
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
					tile.map_coordinate.get_index(),
					neighbor.map_coordinate.get_index()
			)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u: int, v: int) -> float:
	return _travel_dist(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u: int, v: int) -> float:
	return min(0, _travel_dist(u, v) - 1)


# Calculates the travel distance between two tiles. Uses the cube distance and 
# height difference.
func _travel_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = get_point_position(start_index)
	var end_pos: Vector3 = get_point_position(end_index)
	# Record height difference as units of tile unit height.
	var height_diff: float = abs(start_pos.y - end_pos.y) / Constants.HEX_TILE_UNIT_HEIGHT
	# Height differences of 1 tile height are seen as the same height.
	# Halve height difference to keep consistent with cube distance.
	height_diff = height_diff / 2.0 if height_diff > 1.0 else 0.0
	var cube_dist: float = _cube_dist(start_index, end_index)
	return cube_dist + height_diff


# Calculates the cube distance between two tiles.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_cube: Vector3 = HexUtil.index_to_cube(start_index, _x_count)
	var end_cube: Vector3 = HexUtil.index_to_cube(end_index, _x_count)
	var diff: Vector3 = start_cube - end_cube
	return (abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2.0
