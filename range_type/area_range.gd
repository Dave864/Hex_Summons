@abstract
class_name AreaRange
extends Resource
## Describes the function signatures for area ranges.


## Returns the reach of the AreaRange. Used when determining which tiles are
## affected by tile heights.
@abstract func get_reach() -> int


## Base function for area ranges that define a general area around a starting
## point.
@abstract func get_area_indexes(start: int, hm: HexMap) -> Array[int]


## Base function for area ranges that define an area emitted in a direction from
## starting point.
@abstract func get_dir_area_indexes(
	start: int,
	dir: int,
	hm: HexMap
) -> Array[int]


## Base function for area ranges that take modifies a RangeDisplay hex matrix
## so that it reflects the details of this AreaRange.
@abstract func update_range_display(
	_center_point: Vector2,
	_outline_type: int,
	_fill_type: int,
	_d_matrix: DisplayMatrix
) -> void


## Checks if a matrix index is within the bounds of the specified RangeDisplay
## hex matrix.
func _is_index_in_matrix(matrix_index: Vector2, d_matrix: DisplayMatrix) -> bool:
	return (
		matrix_index.y >=0 
		and matrix_index.y < d_matrix.get_row_count()
		and matrix_index.x >= 0
		and matrix_index.x < d_matrix.get_col_count()
	)


## Updates the details of the RangeDisplay matrix array at the given index.
func _update_hex_matrix(
	d_matrix: DisplayMatrix,
	matrix_index: Vector2,
	outline_details: int,
	fill_details: int
) -> void:
	d_matrix.set_details(matrix_index, outline_details, fill_details)
