class_name PointArea
extends RadialAreaRange
## Describes an area range that is a single point.


## A point has no reach, so it returns zero.
func get_reach() -> int:
	return 0


## Returns the starting point.
func get_area_indexes(start: int, _hm: HexMap) -> Array[int]:
	return [start]


## Modifies a RangeDisplay hex matrix so that it reflects the details of this
## PointArea.
func update_range_display(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	d_matrix: DisplayMatrix
) -> void:
	d_matrix.set_details(center_point, outline_type, fill_type)
