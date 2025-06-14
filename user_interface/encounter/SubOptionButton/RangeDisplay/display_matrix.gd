class_name DisplayMatrix
extends Object
"""
Matrix array that keeps track of the visual details for an action's various
ranges.
"""


enum Detail {
	EMPTY,
	CASTER,
	SOURCE_RANGE,
	EFFECT_RANGE,
	EFFECT_SOURCE
}

const INDEX: String = "Index"
const OUTLINE: String = "Outline"
const FILL: String = "Fill"

var _row_count: int = 0 setget , get_row_count
var _col_count: int = 0 setget , get_col_count
var _mid_row: int = 0
var _matrix: Array = []


# Gets the row count of the matrix.
func get_row_count() -> int:
	return _row_count


# Gets the column count of the matrix.
func get_col_count() -> int:
	return _col_count


# Gets the details at the given index.
func at(index: Vector2) -> Dictionary:
	return _matrix[index.y][index.x]


func neighbors_at(index: Vector2) -> HexNeighborRef:
	return _matrix[index.y][index.x][INDEX]


# Gets the outline details at the given index.
func outline_at(index: Vector2) -> int:
	return _matrix[index.y][index.x][OUTLINE]


# Gets the fill details at the given index.
func fill_at(index: Vector2) -> int:
	return _matrix[index.y][index.x][FILL]


# Set the outline detail for the given index.
func set_outline(index: Vector2, outline_detail: int) -> void:
	assert(
			outline_detail in Detail.values(),
			"Passed outline_detail is not valid."
	)
	_matrix[index.y][index.x][OUTLINE] = outline_detail


# Sets the fill detail for the given index.
func set_fill(index: Vector2, fill_detail: int) -> void:
	assert(
			fill_detail in Detail.values(),
			"Passed outline_detail is not valid."
	)
	_matrix[index.y][index.x][FILL] = fill_detail


# Sets the details for the given index.
func set_details(index: Vector2, outline_detail: int, fill_detail: int) -> void:
	set_outline(index, outline_detail)
	set_fill(index, fill_detail)


# Sets the details for the caster point.
func set_caster_details() -> void:
	_matrix[_mid_row][1][OUTLINE] = Detail.CASTER
	_matrix[_mid_row][1][FILL] = Detail.CASTER


# Sets the details for the emission point.
func set_emission_details(emission_index: Vector2) -> void:
	_matrix[emission_index.y][emission_index.x][OUTLINE] = Detail.EFFECT_SOURCE


# Resets the matrix so that the display is empty.
func reset_display() -> void:
	for row in _row_count:
		for col in _col_count:
			_matrix[row][col][OUTLINE] = Detail.EMPTY
			_matrix[row][col][FILL] = Detail.EMPTY


# Initializes this DisplayMatrix.
func _init(row_count: int, col_count: int):
	_row_count = row_count
	_col_count = col_count
	_mid_row = int(round(_row_count / 2.0)) - 1
	for row in _row_count:
		var row_array: Array = []
		for col in _col_count:
			var hex_details: Dictionary = {
				INDEX: HexNeighborRef.new(Vector2(col, row), row_count, col_count),
				OUTLINE: Detail.EMPTY,
				FILL: Detail.EMPTY
			}
			row_array.append(hex_details)
		_matrix.append(row_array)
