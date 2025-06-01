class_name HexMapAStar
extends AStar
"""
Custom AStar implementation designed to handle the calculations for hex grid
pathfinding and area-finding.
"""


var _heights: PoolIntArray
var _x_count: int
var _z_count: int


# Get the area that can be reached in a specific map section starting from a
# given point in said section. This takes into account the tile heights.
# Will return an empty array if the start tile is not in the map section.
func get_traversable_ids(start_tile: int, reach: int, map_section: Array) -> Array:
	var ids_in_range: Array = []
	disconnect_area(map_section)
	for tiles in map_section:
		var tile_index: int = tiles.get_index()
		var path: PoolIntArray = get_id_path(start_tile, tile_index)
		var total_distance: float = 0.0
		for i in range(1, path.size()):
			total_distance += _compute_cost(path[i - 1], path[i])
		if total_distance <= reach:
			ids_in_range.append(tile_index)
	reconnect_area(map_section)
	return ids_in_range


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func update_astar_disabled_for_characters(characters: Array, disabled: bool) -> void:
	for c in characters:
		set_point_disabled(c.get_index_at(), disabled)


# Disconnects a part of a map from the rest. The part to disconnect is an array
# of MapTiles.
func disconnect_area(tiles_to_disconnect: Array) -> void:
	for tile in tiles_to_disconnect:
		if tile.is_active():
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
func full_reset(map_tiles: Array):
	reconnect_area(map_tiles)
	reset_disabled(map_tiles)


# Reestablish the connections in the astar map for the specified area.
func reconnect_area(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			for neighbor in tile.get_all_adjacent():
				# Connect non empty and active neighbors.
				if neighbor != null and neighbor.is_active():
					connect_points(
							tile.map_coordinate.get_map_index(),
							neighbor.map_coordinate.get_map_index()
					)


# Reset the disabled flag for the specified connections in the astar map.
func reset_disabled(map_tiles: Array) -> void:
	for tile in map_tiles:
		if tile.is_active():
			set_point_disabled(tile.map_coordinate.get_map_index(), false)


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
			add_point(
					tile.map_coordinate.get_map_index(),
					tile.character_position(),
					1.0
			)
	
	reconnect_area(hex_map_tiles)


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
	var height_diff: float = abs(_heights[start_index] - _heights[end_index])
	# Height differences of 1 are seen as the same height
	height_diff = 0.0 if height_diff <= 1.0 else height_diff
	var start_pos: Vector3 = HexUtil.index_to_cube(start_index, _x_count)
	var end_pos: Vector3 = HexUtil.index_to_cube(end_index, _x_count)
	var diff: Vector3 = start_pos - end_pos
	return (abs(diff.x) + abs(diff.y) + abs(diff.z) + abs(height_diff)) / 2.0
