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
func determine_area_indexes(start: int, map_tiles: Tiles) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			if map_tiles.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, map_tiles.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids


# Modifies a RangeDisplay hex matrix so that it reflects the details of this RingArea.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func populate_range_display_matrix(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	hex_matrix: Array
) -> void:
	var start_coord: Vector3 = HexUtil.index_to_cube(
			center_point.y * hex_matrix[0].size() + center_point.x,
			hex_matrix[0].size()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var cube_coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			var matrix_index: Vector2 = HexUtil.cube_to_offset(cube_coord)
			if (
				matrix_index.y >=0 
				and matrix_index.y < hex_matrix.size()
				and matrix_index.x >= 0
				and matrix_index.x < hex_matrix[0].size()
			):
				hex_matrix[matrix_index.y][matrix_index.x]["Outline"] = outline_type
				hex_matrix[matrix_index.y][matrix_index.x]["Fill"] = fill_type
