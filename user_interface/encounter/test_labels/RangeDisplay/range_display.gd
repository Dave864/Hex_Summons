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

enum Detail {
	EMPTY,
	CASTER,
	SOURCE_RANGE,
	EFFECT_RANGE,
	EFFECT_SOURCE
}

export(NodePath) var action_ref
export(int, 5, 15) var row_count = 9 setget set_row_count
export(int, 5, 15) var col_count = 8

var _action: Action = null

var _mid_row: int = int(round(row_count / 2.0)) - 1
var _hex_radius = 3.0
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


# Redraws the range display for the given action.
func update_range_display(action: Action) -> void:
	_source_range = action.source_range
	_dead_range = action.dead_range
	_effect_range = action.effect_range
	_emit_from_center = action.emit_from_center
	update()


func _ready() -> void:
#	_action = get_node(action_ref)
#	update_range_display(_action)
	for row in row_count:
		var row_array: Array = []
		for col in col_count:
			var hex_details: Dictionary = {
				INDEX: HexNodeRef.new(Vector2(col, row), row_count, col_count),
				OUTLINE: Detail.EMPTY,
				FILL: Detail.EMPTY
			}
			row_array.append(hex_details)
		_hex_matrix.append(row_array)
	_hex_matrix[_mid_row][1][OUTLINE] = Detail.CASTER
	_hex_matrix[_mid_row][1][FILL] = Detail.CASTER


func _draw() -> void:
	# Determine the configuration of tiles for the source range minus dead range.
#	_draw_range()
	pass


func _determine_source_hexes() -> void:
	if _source_range is CardinalArea:
		pass
	else:
		pass
	
	if _dead_range == null:
		pass
	elif _dead_range is CardinalArea:
		pass
	else:
		pass


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
	for row in range(1, row_count + 1):
		center.y = _hex_radius * 2 * row
		center.x = _hex_radius * 2 if row % 2 != 0 else _hex_radius * 3
		_draw_filled_hex(Color.gray, center)
		for col in col_count - 1:
			center.x += _hex_radius * 2 + 0.5
			_draw_filled_hex(Color.gray, center)


# Draw a colored outline of a hexagon.
func _draw_hex_outline(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_polyline(hex_vertices, color, _hex_radius / 2)


# Draws a filled colored hexagon.
func _draw_filled_hex(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_colored_polygon(hex_vertices, color)


# Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(center: Vector2) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	var top_vertex: Vector2 = Vector2(0.0, _hex_radius)
	for i in 7:
		hex_vertices.append(top_vertex.rotated(i * PI / 3) + center)
	return hex_vertices


# Sets the minimum size for the display panel so that the drawn elements are
# always within its bounds. 
func _set_min_size() -> void:
	var x_size: float = _hex_radius * 2 * col_count
	var y_size: float = _hex_radius * 2 * row_count
	set_custom_minimum_size(Vector2(x_size, y_size))
