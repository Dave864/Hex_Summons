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
func get_area_indexes(start: int, hm: HexMap) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			hm.get_tile_at(start) \
			.map_coordinate.get_cube_coord()
	)
	tile_ids.append(start)
	for d in range(1, distance + 1):
		for n in range(6):
			var coord: Vector3 = HexUtil.cube_at_distance(start_coord, d, n)
			if hm.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, hm.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids


# Calls get_area_indexes as CardinalAreas do not require a direction.
func get_dir_area_indexes(
	start: int,
	_dir: int,
	hm: HexMap
) -> Array:
	return get_area_indexes(start, hm)


# Modifies a RangeDisplay hex matrix so that it reflects the details of this CardinalArea.
func update_range_display(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	d_matrix: DisplayMatrix
) -> void:
	var center_coord: Vector3 = HexUtil.index_to_cube(
			int(center_point.y * d_matrix.get_col_count() + center_point.x),
			d_matrix.get_col_count()
	)
	_update_hex_matrix(d_matrix, center_point, outline_type, fill_type)
	for d in range(1, distance + 1):
		for n in 6:
			var coord: Vector3 = HexUtil.cube_at_distance(center_coord, d, n)
			var index: Vector2 = HexUtil.cube_to_offset(coord)
			if _is_index_in_matrix(index, d_matrix):
				_update_hex_matrix(d_matrix, index, outline_type, fill_type)
