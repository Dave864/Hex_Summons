class_name CardinalArea
extends AreaRange
"""
Describes an area whose area is constrained by the six directions of a hexagon.
"""


# How many tiles out the range will reach.
export(int, 1, 1000) var distance = 1


# Returns the reach of the CardinalArea. Used when determining which tiles are
# affected by tile heights.
func get_reach() -> int:
	return distance


# Determines which map tiles are in the cardinal area positioned at the start index.
# Does not account for tile heights.
func determine_area_indexes(start: int, map_tiles: Tiles) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	tile_ids.append(start)
	for d in range(1, distance + 1):
		for n in range(6):
			var coord: Vector3 = HexUtil.cube_at_distance(start_coord, d, n)
			if map_tiles.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, map_tiles.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids


# Modifies a RangeDisplay hex matrix so that it reflects the details of this CardinalArea.
func populate_range_display_matrix(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	hex_matrix: DisplayMatrix
) -> void:
	var center_coord: Vector3 = HexUtil.index_to_cube(
			int(center_point.y * hex_matrix.get_col_count() + center_point.x),
			hex_matrix.get_col_count()
	)
	_update_hex_matrix(hex_matrix, center_point, outline_type, fill_type)
	for d in range(1, distance + 1):
		for n in 6:
			var coord: Vector3 = HexUtil.cube_at_distance(center_coord, d, n)
			var index: Vector2 = HexUtil.cube_to_offset(coord)
			if _is_index_in_matrix(index, hex_matrix):
				_update_hex_matrix(hex_matrix, index, outline_type, fill_type)
