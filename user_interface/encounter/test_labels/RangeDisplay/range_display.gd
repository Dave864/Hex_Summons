tool
class_name RangeDisplay
extends Panel
"""
Test UI node that is meant to check the feasability of drawing the range data
of actions on a specific UI element.
"""


const INDEX: String = "Index"
const OUTLINE: String = "Outline"
const FILL: String = "Fill"

enum DetailMarker {
	EMPTY,
	CASTER,
	SOURCE_RANGE,
	EFFECT_RANGE,
	EFFECT_SOURCE
}

export(NodePath) var action_ref
export(int, 5, 15) var row_count = 9 setget set_row_count
export(int, 5, 15) var col_count = 8 setget set_col_count
export(float, 1.0, 10.0) var hex_radius = 4.0 setget set_hex_radius
export(float, 0.5, 5.0) var outline_width = 1.0 setget set_outline_width
export(float, 0.0, 3.0) var hex_spacing = 0.0 setget set_hex_spacing

var _action: Action = null

var _mid_row: int = int(round(row_count / 2.0)) - 1
# References to the range details of an action.
var _source_range: AreaRange = null
var _dead_range: AreaRange = null
var _effect_range: AreaRange = null
var _emit_from_center: bool = false
# Matrix that represents the hexes in the display.
var _hex_matrix: Array = []


func set_row_count(rc: int) -> void:
	row_count = (
			rc + 1 if rc % 2 == 0 and row_count < rc
			else rc - 1 if rc % 2 == 0 and row_count > rc
			else rc
	)
	_mid_row = int(round(row_count / 2.0)) - 1
	if Engine.is_editor_hint():
		update()


func set_col_count(cc: int) -> void:
	col_count = cc
	if Engine.is_editor_hint():
		update()


func set_hex_radius(r: float) -> void:
	hex_radius = r
	if Engine.is_editor_hint():
		update()


func set_outline_width(ow: float) -> void:
	outline_width = ow
	if Engine.is_editor_hint():
		update()


func set_hex_spacing(hs: float) -> void:
	hex_spacing = hs
	if Engine.is_editor_hint():
		update()


# Redraws the range display for the given action.
func update_range_display(action: Action) -> void:
	_source_range = action.source_range
	_dead_range = action.dead_range
	_effect_range = action.effect_range
	_emit_from_center = action.emit_from_center
	_reset_hex_matrix()
	update()


func _ready() -> void:
	_create_hex_matrix()
	_set_caster_hex()
	if not Engine.is_editor_hint():
		_action = get_node(action_ref)
		update_range_display(_action)
		_determine_source_hexes()


func _draw() -> void:
	# Determine the configuration of tiles for the source range minus dead range.
	_draw_range()


# Creates an empty hex matrix with row_count rows and col_count columns.
func _create_hex_matrix() -> void:
	for row in row_count:
		var row_array: Array = []
		for col in col_count:
			var hex_details: Dictionary = {
				INDEX: HexNodeRef.new(Vector2(col, row), row_count, col_count),
				OUTLINE: DetailMarker.EMPTY,
				FILL: DetailMarker.EMPTY
			}
			row_array.append(hex_details)
		_hex_matrix.append(row_array)


# Rests the current hex matrix so that the display is empty.
func _reset_hex_matrix() -> void:
	for row in row_count:
		for col in col_count:
			_hex_matrix[row][col][OUTLINE] = DetailMarker.EMPTY
			_hex_matrix[row][col][FILL] = DetailMarker.EMPTY


# Sets the details for the hex that represents the caster.
func _set_caster_hex() -> void:
	_hex_matrix[_mid_row][1][OUTLINE] = DetailMarker.CASTER
	_hex_matrix[_mid_row][1][FILL] = DetailMarker.CASTER


func _determine_source_hexes() -> void:
	_source_range.populate_range_display_matrix(
			Vector2(1, _mid_row),
			DetailMarker.EMPTY,
			DetailMarker.SOURCE_RANGE,
			_hex_matrix
	)
	_set_caster_hex()


func _determine_effect_hexes() -> void:
	if _effect_range is CardinalArea:
		pass
	elif _effect_range is RingArea:
		pass
	elif _effect_range is ConeArea:
		pass
	elif _effect_range is ColumnArea:
		pass


# Draws the array of hexagons that display the range of the action.
func _draw_range() -> void:
	_set_min_size()
	var center: Vector2 = Vector2.ZERO
	for row in row_count:
		center.y = hex_radius * 1.5 * (row + 1) + (row * hex_spacing)
		center.x = (
				hex_radius * HexUtil.HEX_EDGE_RATIO * 2 if row % 2 == 0
				else hex_radius * HexUtil.HEX_EDGE_RATIO * 3 + (hex_spacing / 2)
		)
		_draw_hex(row, 0, center)
		for col in range(1, col_count):
			center.x += hex_radius * HexUtil.HEX_EDGE_RATIO * 2 + hex_spacing
			_draw_hex(row, col, center)


# Draw the hex centered at the coordinate using the details of the hex_matrix.
func _draw_hex(row: int, col: int, coord: Vector2) -> void:
	var matrix_cell: Dictionary = _hex_matrix[row][col]
	_draw_hex_outline(_determine_color(matrix_cell[OUTLINE]), coord)
	_draw_hex_fill(_determine_color(matrix_cell[FILL]), coord)


# Determines the color to use based on the detail marker.
func _determine_color(detail_marker: int) -> Color:
	var c: Color
	match detail_marker:
		DetailMarker.CASTER:
			c = Color.aqua
		DetailMarker.SOURCE_RANGE:
			c = Color.blue
		DetailMarker.EFFECT_RANGE:
			c = Color.orange
		DetailMarker.EFFECT_SOURCE:
			c = Color.yellow
		_:
			c = Color.gray
	return c


# Draw a colored outline of a hexagon.
func _draw_hex_outline(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_colored_polygon(hex_vertices, color)


# Draws a filled colored hexagon.
func _draw_hex_fill(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center, outline_width)
	draw_colored_polygon(hex_vertices, color)


# Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(center: Vector2, outline_offset: float = 0.0) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	var top_vertex: Vector2 = Vector2(0.0, hex_radius - outline_offset)
	for i in 6:
		hex_vertices.append(top_vertex.rotated(i * PI / 3) + center)
	return hex_vertices


# Sets the minimum size for the display panel so that the drawn elements are
# always within its bounds. 
func _set_min_size() -> void:
	var x_size: float = hex_radius * 2 * col_count
	var y_size: float = hex_radius * 2 * row_count
	set_custom_minimum_size(Vector2(x_size, y_size))
