class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


var _x_count: int


# Get the area that can be reached in a specific map section starting from a
# given point in said section. This takes into account the tile heights.
# Will return an empty array if the start tile is not in the map section.
func get_traversable_ids(start_id: int, reach: int, map_section_ids: Array) -> Array:
	var ids_in_range: Array = []
	set_area_disabled(map_section_ids, false)
	for id in map_section_ids:
		var total_distance: float = distance(start_id, id)
		if total_distance <= reach:
			ids_in_range.append(id)
	set_area_disabled(map_section_ids)
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


# Disconnects a part of a map from the rest. The part to disconnect is an array
# of MapTiles.
func disconnect_area(tiles_to_disconnect: Array) -> void:
	for tile in tiles_to_disconnect:
		if !tile.is_active():
			continue
		for neighbor in tile.get_all_adjacent():
			if (
				neighbor != null 
				and not neighbor in tiles_to_disconnect
			):
				disconnect_points(
						tile.map_coordinate.get_map_index(),
						neighbor.map_coordinate.get_map_index()
				)


# Fully reset the connection map for the given section of map.
func section_reset(map_tiles: Array):
	connect_area(map_tiles)
	set_area_disabled(map_tiles)


# Establish the connections in the astar map for the specified area.
func connect_area(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			for neighbor in tile.get_all_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(
							tile.map_coordinate.get_map_index(),
							neighbor.map_coordinate.get_map_index()
					)


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
	for i in hex_map_tiles.size():
		var tile: MapTile = hex_map_tiles[i]
		if tile.is_active():
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
	
	connect_area(hex_map_tiles)


# Virtual Astar function. Called when computing the cost between two
# connected points.
func _compute_cost(u: int, v: int) -> float:
	return _cube_dist(u, v)


# Virtual Astar function. Called when estimating the cost between a point 
# and the path's ending point.
func _estimate_cost(u: int, v: int) -> float:
	return min(0, _cube_dist(u, v) - 1)


# Calculates the distance between two tiles based on their cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
func _cube_dist(start_index: int, end_index: int) -> float:
	var start_pos: Vector3 = get_point_position(start_index)
	var end_pos: Vector3 = get_point_position(end_index)
	var diff: Vector3 = start_pos - end_pos
	var height_diff: float = abs(start_pos.y - end_pos.y)
	# Height differences of 1 are seen as the same height
	height_diff = 0.0 if height_diff <= 1.0 else height_diff
	return (abs(diff.x) + abs(diff.z) + abs(height_diff)) / 2.0
