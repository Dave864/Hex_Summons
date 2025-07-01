tool
class_name RangeDisplay
extends Panel
"""
Test UI node that is meant to check the feasability of drawing the range data
of actions on a specific UI element.
"""


export(int, 5, 15) var row_count = 9 setget set_row_count
export(int, 5, 15) var col_count = 8 setget set_col_count
export(float, 1.0, 10.0) var hex_radius = 4.0 setget set_hex_radius
export(float, 0.5, 5.0) var outline_width = 1.0 setget set_outline_width
export(float, 0.0, 3.0) var hex_spacing = 0.0 setget set_hex_spacing

var _mid_row: int = int(round(row_count / 2.0)) - 1
var _emission_index: Vector2 = Vector2(1, _mid_row)
var _action: Action = null
# Matrix that represents the hexes in the display.
var _d_matrix: DisplayMatrix = null
# Tracks the order in which tiles should be drawn.
var _draw_order: Dictionary = {
	"empty": [],
	"source_tile": [],
	"effect_overlap": [],
	"effect_tile": [],
	"etc": [],
}
# The vertex positions for a hex at origin.
var _origin_pts: PoolVector2Array = []
var _origin_fill_pts: PoolVector2Array = []


func set_row_count(rc: int) -> void:
	row_count = (
			rc + 1 if rc % 2 == 0 and row_count < rc
			else rc - 1 if rc % 2 == 0 and row_count > rc
			else rc
	)
	_mid_row = int(round(row_count / 2.0)) - 1
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	if Engine.is_editor_hint():
		update()


func set_col_count(cc: int) -> void:
	col_count = cc
	_d_matrix = DisplayMatrix.new(row_count, col_count)
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
func update_action(action: Action) -> void:
	_action = action
	_update_display_details()
	update()


func _ready() -> void:
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	_origin_pts = _init_origin_vertices()
	_origin_fill_pts = _init_origin_vertices(outline_width)


func _init() -> void:
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	_origin_pts = _init_origin_vertices()
	_origin_fill_pts = _init_origin_vertices(outline_width)


func _draw() -> void:
	for details in _draw_order["empty"]:
		_draw_hex_fill(_get_color(details[1][DisplayMatrix.FILL]), details[0])
	for details in _draw_order["source_tile"]:
		_draw_hex_fill(_get_color(details[1][DisplayMatrix.FILL]), details[0])
	for details in _draw_order["effect_overlap"]:
		_draw_hex(details[1], details[0])
	for details in _draw_order["effect_tile"]:
		_draw_hex_fill(_get_color(details[1][DisplayMatrix.FILL]), details[0])
	for details in _draw_order["etc"]:
		_draw_hex(details[1], details[0])


# Resets the drawing details for the display.
func _update_display_details() -> void:
	if not Engine.is_editor_hint():
		_d_matrix.reset_display()
		_clear_draw_order()
		_determine_source_hexes()
		_determine_effect_hexes()
		_set_caster_hex()
		_set_emission_hex()
		_update_draw_order()


# Determine the hex vertices that will be used as reference for creating hexes
# to draw.
func _init_origin_vertices(outline_offset: float = 0.0) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	var top_vertex: Vector2 = Vector2(0.0, hex_radius - outline_offset)
	for i in 6:
		hex_vertices.append(top_vertex.rotated(i * PI / 3))
	return hex_vertices


# Determine the hex colors that will represent the source range.
func _determine_source_hexes() -> void:
	_action.source_range.update_range_display(
			Vector2(1, _mid_row),
			DisplayMatrix.Detail.SOURCE_RANGE,
			DisplayMatrix.Detail.SOURCE_RANGE,
			_d_matrix
	)
	if _action.dead_range != null:
		_action.dead_range.update_range_display(
				Vector2(1, _mid_row),
				DisplayMatrix.Detail.EMPTY,
				DisplayMatrix.Detail.EMPTY,
				_d_matrix
		)


# Determine the hex colors that will represent the effect range.
func _determine_effect_hexes() -> void:
	if not _action.emit_from_center:
		# Determine the emission point.
		for x in range(2, col_count):
			var index: Vector2 = Vector2(x, _mid_row)
			if _d_matrix.fill_at(index) == DisplayMatrix.Detail.SOURCE_RANGE:
				_emission_index.x = x
	_action.effect_range.update_range_display(
			_emission_index,
			DisplayMatrix.Detail.EFFECT_RANGE,
			DisplayMatrix.Detail.EFFECT_RANGE,
			_d_matrix
	)


# Sets the details for the hex that represents the caster.
func _set_caster_hex() -> void:
	_d_matrix.set_caster_details()


# Sets the details for the hex that represents the emission point.
func _set_emission_hex() -> void:
	_d_matrix.set_emission_details(_emission_index)


# Determines the order to draw the hexex in order to trigger batching.
func _update_draw_order() -> void:
	var center: Vector2 = Vector2.ZERO
	for row in row_count:
		center.y = hex_radius * 1.5 * (row + 1) + (row * hex_spacing)
		center.x = (
				hex_radius * HexUtil.HEX_EDGE_RATIO * 2 if row % 2 == 0
				else hex_radius * HexUtil.HEX_EDGE_RATIO * 3 + (hex_spacing / 2)
		)
		var draw_data: Dictionary = _d_matrix.at(Vector2(0, row))
		_determine_draw_step(draw_data, center)
		for col in range(1, col_count):
			draw_data = _d_matrix.at(Vector2(col, row))
			center.x += hex_radius * HexUtil.HEX_EDGE_RATIO * 2 + hex_spacing
			_determine_draw_step(draw_data, center)


# Clears out the current draw order.
func _clear_draw_order() -> void:
	_draw_order["empty"].clear()
	_draw_order["source_tile"].clear()
	_draw_order["effect_overlap"].clear()
	_draw_order["effect_tile"].clear()
	_draw_order["etc"].clear()


# Determines which part of the draw step the data should be part of.
func _determine_draw_step(draw_data: Dictionary, center: Vector2) -> void:
	if draw_data[DisplayMatrix.FILL] == DisplayMatrix.Detail.EMPTY:
		_draw_order["empty"].append([center, draw_data])
	elif (
		draw_data[DisplayMatrix.OUTLINE] == DisplayMatrix.Detail.EFFECT_RANGE
		and draw_data[DisplayMatrix.FILL] == DisplayMatrix.Detail.SOURCE_RANGE
	):
		_draw_order["effect_overlap"].append([center, draw_data])
	elif (
		draw_data[DisplayMatrix.FILL] == DisplayMatrix.Detail.SOURCE_RANGE
		and draw_data[DisplayMatrix.OUTLINE] == DisplayMatrix.Detail.SOURCE_RANGE
	):
		_draw_order["source_tile"].append([center, draw_data])
	elif draw_data[DisplayMatrix.FILL] == DisplayMatrix.Detail.EFFECT_RANGE:
		_draw_order["effect_tile"].append([center, draw_data])
	else:
		_draw_order["etc"].append([center, draw_data])


# Draw the hex centered at the coordinate using the details of the hex_matrix.
func _draw_hex(data: Dictionary, center: Vector2) -> void:
	var outline_color: Color = _get_color(data[DisplayMatrix.OUTLINE])
	var fill_color: Color = _get_color(data[DisplayMatrix.FILL])
	_draw_hex_outline(outline_color, center)
	if outline_color != fill_color:
		_draw_hex_fill(fill_color, center)


# Determines the color to use based on the detail marker.
func _get_color(detail_marker: int) -> Color:
	var c: Color
	match detail_marker:
		DisplayMatrix.Detail.CASTER:
			c = Color.aqua
		DisplayMatrix.Detail.SOURCE_RANGE:
			c = Color.blue
		DisplayMatrix.Detail.EFFECT_RANGE:
			c = Color.orange
		DisplayMatrix.Detail.EFFECT_SOURCE:
			c = Color.yellow
		_:
			c = Color.slategray
	return c


# Draw a colored outline of a hexagon.
func _draw_hex_outline(color: Color, center: Vector2) -> void:
	if _origin_pts.size() == 0:
		return
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center, _origin_pts)
	draw_colored_polygon(hex_vertices, color)


# Draws a filled colored hexagon.
func _draw_hex_fill(color: Color, center: Vector2) -> void:
	if _origin_fill_pts.size() == 0:
		return
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center, _origin_fill_pts)
	draw_colored_polygon(hex_vertices, color)


# Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(
	center: Vector2,
	origin_pts: PoolVector2Array
) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	for v in origin_pts:
		hex_vertices.append(v + center)
	return hex_vertices


# Sets the minimum size for the display panel so that the drawn elements are
# always within its bounds. 
func _set_min_size() -> void:
	var x_size: float = (
			hex_radius * 2 * col_count \
			+ (col_count * hex_spacing)
	)
	var y_size: float = (
			hex_radius * 1.5 * (row_count + 1) \
			+ (row_count * hex_spacing)
	)
	set_custom_minimum_size(Vector2(x_size, y_size))
