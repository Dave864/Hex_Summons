class_name EmptyArea
extends RadialAreaRange
## Represents an empty area range.


## Returns zero as an empty area has no tiles.
func get_reach() -> int:
	return 0


## Returns an empty array to represent an empty area.
func get_area_indexes(_start: int, _hm: HexMap) -> Array[int]:
	return []


## Does nothing the the DisplayMatrix as an empty area has no tiles
## to show.
func update_range_display(
	_center_point: Vector2,
	_outline_type: int,
	_fill_type: int,
	_d_matrix: DisplayMatrix
) -> void:
	return
