class_name AreaRange
extends Node
"""
Describes the function signatures for area ranges.
"""


# Returns the reach of the AreaRange. Used when determining which tiles are
# affected by tile heights.
func get_reach() -> int:
	return 0


# Base function for area ranges that define a general area around a starting
# point.
func determine_area_indexes(_start: int, _map_tiles: Tiles) -> Array:
	return []


# Base function for area ranges that define an area emitted in a direction from
# starting point.
func determine_directional_area_indexes(
	_start: int,
	_dir: int,
	_map_tiles: Tiles
) -> Array:
	return []


# Base function for area ranges that take modifies a RangeDisplay hex matrix
# so that it reflects the details of this AreaRange.
func populate_range_display_matrix(
	_center_point: Vector2,
	_outline_type: int,
	_fill_type: int,
	_hex_matrix: Array
) -> void:
	pass


# Checks if a matrix index is within the bounds of the specified RangeDisplay
# hex matrix.
func _is_index_in_matrix(matrix_index: Vector2, hex_matrix: Array) -> bool:
	return (
		matrix_index.y >=0 
		and matrix_index.y < hex_matrix.size()
		and matrix_index.x >= 0
		and matrix_index.x < hex_matrix[0].size()
	)


# Updates the details of the RangeDisplay matrix array at the given index.
func _update_hex_matrix(
	hex_matrix: Array,
	matrix_index: Vector2,
	outline_details: int,
	fill_details: int
) -> void:
	hex_matrix[matrix_index.y][matrix_index.x]["Outline"] = outline_details
	hex_matrix[matrix_index.y][matrix_index.x]["Fill"] = fill_details
