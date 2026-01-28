class_name DisplayMatrix
extends Object
## Matrix array that keeps track of the visual details for an action's various
## ranges.


## Describes what is being displayed at each hex.
enum Detail {
	EMPTY,
	CASTER,
	SOURCE_RANGE,
	EFFECT_RANGE,
	EFFECT_SOURCE
}

## The number of rows in the display.
var _row_count: int = 0:
	get = get_row_count
## The number of columns in the display.
var _col_count: int = 0:
	get = get_col_count
## The index of the middle row of the display.
var _mid_row: int = 0
## The grid of hexes that are to be displayed.
var _matrix: Array[Array] = []


## Initializes this DisplayMatrix.
func _init(row_count: int, col_count: int):
	_row_count = row_count
	_col_count = col_count
	_mid_row = int(round(_row_count / 2.0)) - 1
	for row: int in _row_count:
		var row_array: Array[HexDetails] = []
		for col in _col_count:
			var hex_details := HexDetails.new()
			row_array.append(hex_details)
		_matrix.append(row_array)


## Gets the row count of the matrix.
func get_row_count() -> int:
	return _row_count


## Gets the column count of the matrix.
func get_col_count() -> int:
	return _col_count


## Gets the details at the given index.
func at(index: Vector2) -> HexDetails:
	return _matrix[index.y][index.x]


## Gets the outline details at the given index.
func outline_at(index: Vector2) -> Detail:
	return _matrix[index.y][index.x].outline


## Gets the fill details at the given index.
func fill_at(index: Vector2) -> Detail:
	return _matrix[index.y][index.x].fill


## Set the outline detail for the given index.
func set_outline(index: Vector2, outline_detail: Detail) -> void:
	_matrix[index.y][index.x].outline = outline_detail


## Sets the fill detail for the given index.
func set_fill(index: Vector2, fill_detail: Detail) -> void:
	_matrix[index.y][index.x].fill = fill_detail


## Sets the details for the given index.
func set_details(
	index: Vector2,
	outline_detail: Detail,
	fill_detail: Detail
) -> void:
	# Don't update effect outline if new outline is a source.
	if (
		outline_detail != Detail.SOURCE_RANGE
		or outline_at(index) != Detail.EFFECT_RANGE
	):
		set_outline(index, outline_detail)
	# Don't update source fill if new fill is an effect.
	if (
		fill_detail != Detail.EFFECT_RANGE
		or fill_at(index) != Detail.SOURCE_RANGE
	):
		set_fill(index, fill_detail)


## Sets the details for the caster point.
func set_caster_details() -> void:
	_matrix[_mid_row][1].outline = Detail.CASTER
	_matrix[_mid_row][1].fill = Detail.CASTER


## Sets the details for the emission point.
func set_emission_details(emission_index: Vector2) -> void:
	set_outline(emission_index, Detail.EFFECT_SOURCE)
	# Don't update fill if caster point.
	if fill_at(emission_index) != Detail.CASTER:
		set_fill(emission_index, Detail.EFFECT_SOURCE)


## Resets the matrix so that the display is empty.
func reset_display() -> void:
	for row in _row_count:
		for col in _col_count:
			_matrix[row][col].outline = Detail.EMPTY
			_matrix[row][col].fill = Detail.EMPTY


## The contents of a display hex. Contains the outline and fill details.
class HexDetails:
	## The details for the outline of the hex.
	var outline: Detail = Detail.EMPTY
	## The details for the interior of the hex.
	var fill: Detail = Detail.EMPTY
	
	
	## Resets the hex details to be empty.
	func empty() -> void:
		outline = Detail.EMPTY
		fill = Detail.EMPTY
