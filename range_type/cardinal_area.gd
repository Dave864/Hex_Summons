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
	hex_matrix: Array
) -> void:
	var center_hex: HexNodeRef = hex_matrix[center_point.y][center_point.x]["Index"]
	var neighbor_indexes: Array = center_hex.get_neighbors()
	hex_matrix[center_point.y][center_point.x]["Outline"] = outline_type
	hex_matrix[center_point.y][center_point.x]["Fill"] = fill_type
	for d in distance:
		for i in 6:
			var hm_index: Vector2 = neighbor_indexes[i]
			# Only updates if index is not empty.
			if hm_index.x >= 0 and hm_index.y >= 0:
				var matrix_cell: Dictionary = hex_matrix[hm_index.y][hm_index.x]
				matrix_cell["Outline"] = outline_type
				matrix_cell["Fill"] = fill_type
				neighbor_indexes[i] = matrix_cell["Index"].get_neighbor(i)
