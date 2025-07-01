class_name RingArea
extends AreaRange
"""
Describes a range whose area encompasses all hexes within a defined distance.
"""


# How many tiles out from the cast point the area will reach.
export(int, 0, 1000) var radius = 0


# Returns the reach of the RingArea. Used when determining which tiles are
# affected by tile heights.
func get_reach() -> int:
	return radius


# Determines which map tiles are in the ring area positioned at the start index.
# Does not account for tile heights.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func determine_area_indexes(start: int, hm: HexMap) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			hm.get_tile_at(start) \
			.map_coordinate.get_cube_coord()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			if hm.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, hm.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids


# Calls determine_area_indexes as RingAreas do not require a direction.
func determine_directional_area_indexes(
	start: int,
	_dir: int,
	hm: HexMap
) -> Array:
	return determine_area_indexes(start, hm)


# Modifies a RangeDisplay hex matrix so that it reflects the details of this RingArea.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func update_range_display(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	d_matrix: DisplayMatrix
) -> void:
	var start_coord: Vector3 = HexUtil.index_to_cube(
			int(center_point.y * d_matrix.get_col_count() + center_point.x),
			d_matrix.get_col_count()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var cube_coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			var matrix_index: Vector2 = HexUtil.cube_to_offset(cube_coord)
			if _is_index_in_matrix(matrix_index, d_matrix):
				d_matrix.set_details(matrix_index, outline_type, fill_type)
