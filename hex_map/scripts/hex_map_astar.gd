class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


# The cost function that should be used when calculating distance.
var _cost_func: FuncRef = null
# The function that should be used when adding another item to the closest path.
var _add_path_item_func: FuncRef = null
# Tracks how many tiles are along the x-axis of the hex map this object represents.
var _x_count: int = 0


# Gets the distances from the starting point to all tiles within a given reach.
# A negative reach indicates that all map tiles should be looked at. The use_tile
# flag indicates that the tile distance should be used instead of travel distance.
# Each entry has the travel distance and tile distance stored in a dictionary.
# Reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html#dijkstra
func get_distance_map(start_id: int, use_tile: bool, reach: int = -1) -> Dictionary:
	var frontier: PQueue = PQueue.new()
	var id_distances: Dictionary = {}

	frontier.push(0.0, start_id)
	id_distances[start_id] = {"travel": 0.0, "tile": 0}
	while not frontier.empty():
		var current: Array = frontier.min()
		frontier.pop_min()
		for next_id in get_point_connections(current[1]):
			if is_point_disabled(next_id):
				continue
			var dist: Dictionary = id_distances[current[1]]
			var travel_dist: float = _travel_dist(current[1], next_id) + dist["travel"]
			var tile_dist: int = int(_cube_dist(start_id, next_id))
			if (
				(
					not id_distances.has(next_id)
					or travel_dist < id_distances[next_id]["travel"]
				)
				and (reach < 0 or tile_dist <= reach)
				and (use_tile or travel_dist <= reach)
			):
				id_distances[next_id] = {"travel": travel_dist, "tile": tile_dist}
				frontier.push(travel_dist, next_id)
	frontier.free()
	return id_distances


# Finds the point in the area that is closest to start. The area is a dicitonary
# whose keys are the map tile ids and values are the various distances to the
# tiles from some point, which may not be the same as start. Returns -1 if no
# closest index could be found.
# Reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html#dijkstra
func get_closest_in_area(start_id: int, area_d_map: Dictionary) -> int:
	if area_d_map.size() == 0:
		return -1
	if area_d_map.size() == 1:
		return area_d_map.keys()[0]
	var frontier: PQueue = PQueue.new()
	var id_distances: Dictionary = {}
	var closest: Array = [INF, -1]
	# Used to stop when all area_d_map ids have been checked.
	var checked_count: int = 0
	frontier.push(0.0, start_id)
	id_distances[start_id] = 0
	while not frontier.empty() and checked_count < area_d_map.size():
		var current: Array = frontier.min()
		frontier.pop_min()
		if area_d_map.has(current[1]):
			checked_count += 1
			if current[0] < closest[0]:
				closest = current
			continue
		for next_id in get_point_connections(current[1]):
			if is_point_disabled(next_id):
				continue
			var tile_dist: int = int(_cube_dist(start_id, next_id))
			if (
				not id_distances.has(next_id)
				or tile_dist < id_distances[next_id]
			):
				id_distances[next_id] = tile_dist
				frontier.push(tile_dist, next_id)
	frontier.free()
	id_distances.clear()
	return closest[1]


# Finds the point in the area that is farthest from target. The area is a
# dicitonary whose keys are the map tile ids and values are the various
# distances to the tiles from some point, which may not be the same as taregt.
# Returns -1 if no farthest index could be found.
func get_farthest_in_area(target_id: int, area_d_map: Dictionary) -> int:
	if area_d_map.size() == 0:
		return -1
	if area_d_map.size() == 1:
		return area_d_map.keys()[0]
	var farthest_pt: int = -1
	var farthest_d: float = 0.0
	for id in area_d_map.keys():
		if is_point_disabled(id):
			continue
		var dist: float = _compute_cost(id, target_id)
		if dist > farthest_d:
			farthest_d = dist
			farthest_pt = id
	return farthest_pt


# Gets the shortest id path from start to target that is within the maximum
# distance.
func get_closest_id_path(
	source_id: int,
	target_id: int,
	max_dist: int
) -> PoolIntArray:
	_add_path_item_func =  funcref(self, "_add_id")
	return PoolIntArray(_get_closest_path(source_id, target_id, max_dist))


# Gets the shortest point path from start to target that is within the maximum
# distance.
func get_closest_point_path(
	source_id: int,
	target_id: int,
	max_dist: int
) -> PoolVector3Array:
	_add_path_item_func =  funcref(self, "_add_point")
	return PoolVector3Array(_get_closest_path(source_id, target_id, max_dist))


# Determines the travel distance from the start to the end.
func travel_distance(start_index: int, end_index: int) -> float:
	var path: PoolIntArray = get_id_path(start_index, end_index)
	var dist: float = 0.0
	for i in range(1, path.size()):
		dist += _compute_cost(path[i - 1], path[i])
	return dist


# Determines the tile distance from the start to the end.
func tile_distance(start_index: int, end_index: int) -> float:
	set_cost_to_tile()
	var dist: float = travel_distance(start_index, end_index)
	set_cost_to_travel()
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


# Sets the cost function for AStar to use the travel distance between tiles.
# This accounts for tile heights. This is the default.
func set_cost_to_travel() -> void:
	_cost_func = funcref(self, "_travel_dist")


# Sets the cost function for AStar to use the tile distances. This ignores tile
# heights.
func set_cost_to_tile() -> void:
	_cost_func = funcref(self, "_cube_dist")


func _init(hex_map_tiles: Array, x_count: int) -> void:
	_x_count = x_count
	set_cost_to_travel()
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


# Gets the closest path to the target given a range limit.
# Reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html#astar
func _get_closest_path(
	source_id: int,
	target_id: int,
	max_dist: int
) -> Array:
	var frontier: PQueue = PQueue.new()
	var distances: Dictionary = {}
	var came_from: Dictionary = {}
	frontier.push(0.0, source_id)
	distances[source_id] = {
		"travel": 0.0,
		"to_target": _compute_cost(source_id, target_id)
	}
	came_from[source_id] = -1
	while not frontier.empty():
		var cur: Array = frontier.min()
		var cur_dist: float = distances[cur[1]]["travel"]
		frontier.pop_min()
		# Exit loop early if target is reached
		if cur[1] == target_id:
			break
		for next_id in get_point_connections(cur[1]):
			if is_point_disabled(next_id):
				continue
			var travel_d: float = _compute_cost(cur[1], next_id) + cur_dist
			if (
				(
					not distances.has(next_id)
					or travel_d < distances[next_id]["travel"]
				)
				and travel_d <= max_dist
			):
				distances[next_id] = {
					"travel": travel_d,
					"to_target": _compute_cost(next_id, target_id)
				}
				came_from[next_id] = cur[1]
				frontier.push(distances[next_id]["to_target"], next_id)
	frontier.free()
	
	var closest_pt: int = -1
	for pt in came_from.keys():
		if (
			closest_pt < 0
			or distances[pt]["to_target"] < distances[closest_pt]["to_target"]
		):
			closest_pt = pt
	var path: Array = []
	while closest_pt > 0:
		path.append(_add_path_item_func.call_func(closest_pt))
		closest_pt = came_from[closest_pt]
	path.invert()
	return path


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u: int, v: int) -> float:
	return _cost_func.call_func(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u: int, v: int) -> float:
	return min(0, _cost_func.call_func(u, v) - 1)


# Calculates the travel distance between two tiles. Uses the cube distance and 
# height difference.
func _travel_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = get_point_position(start_index)
	var end_pos: Vector3 = get_point_position(end_index)
	# Record height difference as units of tile unit height.
	var height_diff: float = (
			abs(start_pos.y - end_pos.y) \
			/ Constants.HEX_TILE_UNIT_HEIGHT
	)
	# Height differences of 1 tile height are seen as the same height.
	# Halve height difference to keep consistent with cube distance.
	height_diff = height_diff / 2.0 if height_diff > 1.0 else 0.0
	var cube_dist: float = _cube_dist(start_index, end_index)
	return cube_dist + height_diff


# Calculates the cube distance between two tiles.
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_cube: Vector3 = HexUtil.index_to_cube(start_index, _x_count)
	var end_cube: Vector3 = HexUtil.index_to_cube(end_index, _x_count)
	return HexUtil.cube_dist(start_cube, end_cube) * get_point_weight_scale(end_index)


# One of the options for _add_path_item_func. Simplye returns the id passed.
func _add_id(id: int) -> int:
	return id


# One of the options for _add_path_item_func. Gets the position of the id.
func _add_point(id: int) -> Vector3:
	return get_point_position(id)
