@tool
class_name RangeDisplay
extends Panel
## Displays the range data of an action.


@export_group("Display Matrix Dimensions")
## The number of rows of hexes in the display.
@export_range(1, 20) var row_count: int = 9:
	set = set_row_count
## The number of hexes in each row.
@export_range(1, 20) var col_count: int = 8:
	set = set_col_count
@export_group("Hex Dimensions")
## The distance from the center of a hex to a vertex in pixels.
@export_range(1.0, 10.0, 1.0) var hex_radius: float = 4.0:
	set = set_hex_radius
## The width of the outline hex border in pixels. Does not expand the area of
## the hexes.
@export_range(0.0, 10.0, 1.0) var outline_width: float = 1.0:
	set = set_outline_width
## The amount of space between each hex in pixels.
@export_range(0.0, 5.0, 1.0) var hex_spacing: float = 0.0:
	set = set_hex_spacing
@export_group("Panel Dimensions")
## The width of the border area aound the matrix of hexes.
@export_range(0.0, 10.0, 0.1) var border_width: float = 2.0:
	set = set_border_width

## The middle row of the display.
var _mid_row: int = int(round(row_count / 2.0)) - 1
## The hex that an action emanates from.
var _emission_index: Vector2 = Vector2(1, _mid_row)
## The action whose range is being displayed.
var _action: Action = null
## Matrix of the hexes in the display.
var _d_matrix: DisplayMatrix = null
## Tracks the order in which tiles should be drawn.
var _draw_order: Dictionary[String, Array] = {
	"empty": [],
	"source_tile": [],
	"effect_overlap": [],
	"effect_tile": [],
	"etc": [],
}
## The vertex positions for a base hex at origin. Drawn behind inner hexes.
var _origin_base_pts: PackedVector2Array = []
## The horizontal numerical diameter of a base hex.
var _horizontal_radius: int = 0
## The vertex positions for a hex fill at origin. Drawn over a base hex to
## simulate a border.
var _origin_inner_pts: PackedVector2Array = []


func _ready() -> void:
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	_origin_base_pts = _init_origin_vertices()
	_horizontal_radius = int(_origin_base_pts[5].x - _origin_base_pts[1].x)
	_origin_inner_pts = _init_origin_vertices(outline_width)


func _init() -> void:
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	_origin_base_pts = _init_origin_vertices()
	_origin_inner_pts = _init_origin_vertices(outline_width)


func _draw() -> void:
	for details: Array in _draw_order["empty"]:
		_draw_hex_base(_get_color(details[1].fill), details[0])
	for details: Array in _draw_order["source_tile"]:
		_draw_hex_base(_get_color(details[1].fill), details[0])
	for details: Array in _draw_order["effect_overlap"]:
		_draw_full_hex(details[1], details[0])
	for details: Array in _draw_order["effect_tile"]:
		_draw_hex_base(_get_color(details[1].fill), details[0])
	for details: Array in _draw_order["etc"]:
		_draw_full_hex(details[1], details[0])


## Sets the number of rows in the display. Redraws the display.
func set_row_count(rc: int) -> void:
	row_count = (
			rc + 1 if rc % 2 == 0 and row_count < rc
			else rc - 1 if rc % 2 == 0 and row_count > rc
			else rc
	)
	_mid_row = int(round(row_count / 2.0)) - 1
	_emission_index = Vector2(1, _mid_row)
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	if Engine.is_editor_hint():
		_set_min_size()


## Sets the number of hexes in a row for the display. Redraws the display.
func set_col_count(cc: int) -> void:
	col_count = cc
	_d_matrix = DisplayMatrix.new(row_count, col_count)
	if Engine.is_editor_hint():
		_set_min_size()


## Sets the radius of a hex, the distance from center to a vertex. Redraws the
## display.
func set_hex_radius(r: float) -> void:
	hex_radius = r
	if Engine.is_editor_hint():
		_set_min_size()


## Sets the outline width of a hex. Redraws the display.
func set_outline_width(ow: float) -> void:
	outline_width = ow
	if Engine.is_editor_hint():
		_set_min_size()


## Sets the amount of space between hexes. Redraws the display.
func set_hex_spacing(hs: float) -> void:
	hex_spacing = hs
	if Engine.is_editor_hint():
		_set_min_size()


## Sets the width of the border around the display matrix.
func set_border_width(bw: float) -> void:
	border_width = bw
	if Engine.is_editor_hint():
		_set_min_size()


## Redraws the range display for the given action.
func update_action(action: Action) -> void:
	_action = action
	_emission_index = Vector2(1, _mid_row)
	_update_display_details()
	_set_min_size()
	queue_redraw()


## Determine the hex vertices that will be used as reference for creating hexes
## to draw.
func _init_origin_vertices(outline_offset: float = 0.0) -> PackedVector2Array:
	var half_step: float = (hex_radius - outline_offset) / 2.0
	var hex_vertices: PackedVector2Array = [
		Vector2(0.0, hex_radius - outline_offset), # Top
		Vector2(hex_radius - outline_offset, half_step), # Top right
		Vector2(hex_radius - outline_offset, -half_step), # Bottom right
		Vector2(0.0, -hex_radius + outline_offset), # Bottom
		Vector2(-hex_radius + outline_offset, -half_step), # Bottom left
		Vector2(-hex_radius + outline_offset, half_step), # Top left
	]
	return hex_vertices


## Resets the drawing details for the display.
func _update_display_details() -> void:
	if not Engine.is_editor_hint():
		_d_matrix.reset_display()
		_clear_draw_order()
		_determine_source_hexes()
		_determine_effect_hexes()
		_set_caster_hex()
		_set_emission_hex()
		_update_draw_order()


## Determine the hex colors that will represent the source range.
func _determine_source_hexes() -> void:
	_action.stats.source_range.update_range_display(
			Vector2(1, _mid_row),
			DisplayMatrix.Detail.SOURCE_RANGE,
			DisplayMatrix.Detail.SOURCE_RANGE,
			_d_matrix
	)
	_action.stats.dead_range.update_range_display(
			Vector2(1, _mid_row),
			DisplayMatrix.Detail.EMPTY,
			DisplayMatrix.Detail.EMPTY,
			_d_matrix
	)


## Determine the hex colors that will represent the effect range.
func _determine_effect_hexes() -> void:
	if not _action.stats.emit_from_caster:
		# Determine the emission point.
		for x: int in range(2, col_count):
			var index: Vector2 = Vector2(x, _mid_row)
			if _d_matrix.fill_at(index) == DisplayMatrix.Detail.SOURCE_RANGE:
				_emission_index.x = x
	_action.stats.effect_range.update_range_display(
			_emission_index,
			DisplayMatrix.Detail.EFFECT_RANGE,
			DisplayMatrix.Detail.EFFECT_RANGE,
			_d_matrix
	)


## Sets the details for the hex that represents the caster.
func _set_caster_hex() -> void:
	_d_matrix.set_caster_details()


## Sets the details for the hex that represents the emission point.
func _set_emission_hex() -> void:
	_d_matrix.set_emission_details(_emission_index)


## Determines the order to draw the hexes in order to trigger batching.
func _update_draw_order() -> void:
	var center := Vector2.ZERO
	for row: int in row_count:
		center.y = hex_radius + border_width
		center.y += roundf(hex_radius * 1.5) * row + (row * hex_spacing)
		center.x = border_width
		center.x += hex_radius if row % 2 == 0 else hex_radius * 2
		var draw_data: DisplayMatrix.HexDetails = (
			_d_matrix.at(Vector2(0, row))
		)
		_determine_draw_step(draw_data, center)
		for col: int in range(1, col_count):
			draw_data = _d_matrix.at(Vector2(col, row))
			center.x += hex_radius * 2 + hex_spacing
			_determine_draw_step(draw_data, center)


## Clears out the current draw order.
func _clear_draw_order() -> void:
	_draw_order["empty"].clear()
	_draw_order["source_tile"].clear()
	_draw_order["effect_overlap"].clear()
	_draw_order["effect_tile"].clear()
	_draw_order["etc"].clear()


## Determines which part of the draw step the data should be part of.
func _determine_draw_step(
	draw_data: DisplayMatrix.HexDetails,
	center: Vector2
) -> void:
	if draw_data.fill == DisplayMatrix.Detail.EMPTY:
		_draw_order["empty"].append([center, draw_data])
	elif (
		draw_data.outline == DisplayMatrix.Detail.EFFECT_RANGE
		and draw_data.fill == DisplayMatrix.Detail.SOURCE_RANGE
	):
		_draw_order["effect_overlap"].append([center, draw_data])
	elif (
		draw_data.fill == DisplayMatrix.Detail.SOURCE_RANGE
		and draw_data.outline == DisplayMatrix.Detail.SOURCE_RANGE
	):
		_draw_order["source_tile"].append([center, draw_data])
	elif draw_data.fill == DisplayMatrix.Detail.EFFECT_RANGE:
		_draw_order["effect_tile"].append([center, draw_data])
	else:
		_draw_order["etc"].append([center, draw_data])


## Draw the hex centered at the coordinate using the details of the hex_matrix.
func _draw_full_hex(data: DisplayMatrix.HexDetails, center: Vector2) -> void:
	var outline_color: Color = _get_color(data.outline)
	var fill_color: Color = _get_color(data.fill)
	_draw_hex_base(outline_color, center)
	if outline_color != fill_color:
		_draw_hex_inner(fill_color, center)


## Determines the color to use based on the detail marker.
func _get_color(detail_marker: DisplayMatrix.Detail) -> Color:
	var c: Color
	match detail_marker:
		DisplayMatrix.Detail.CASTER:
			c = Color.AQUA
		DisplayMatrix.Detail.SOURCE_RANGE:
			c = Color.BLUE
		DisplayMatrix.Detail.EFFECT_RANGE:
			c = Color.ORANGE
		DisplayMatrix.Detail.EFFECT_SOURCE:
			c = Color.YELLOW
		_:
			c = Color.SLATE_GRAY
	return c


## Draw base colored base hexagon.
func _draw_hex_base(color: Color, center: Vector2) -> void:
	if _origin_base_pts.size() == 0:
		return
	var hex_vertices: PackedVector2Array = _get_points_for_hex(
			center,
			_origin_base_pts
	)
	draw_colored_polygon(hex_vertices, color)


## Draws an inner colored hexagon.
func _draw_hex_inner(color: Color, center: Vector2) -> void:
	if _origin_inner_pts.size() == 0:
		return
	var hex_vertices: PackedVector2Array = _get_points_for_hex(
			center,
			_origin_inner_pts
	)
	draw_colored_polygon(hex_vertices, color)


## Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(
	center: Vector2,
	origin_pts: PackedVector2Array
) -> PackedVector2Array:
	var hex_vertices: PackedVector2Array = []
	for v: Vector2 in origin_pts:
		hex_vertices.append(v + center)
	return hex_vertices


## Sets the minimum size for the display panel so that the drawn elements are
## always within its bounds. 
func _set_min_size() -> void:
	var x_size: float = (
			(2 * border_width) \
			+ (2 * hex_radius * col_count) \
			+ hex_radius + hex_spacing * (col_count - 1)
	)
	var y_size: float = (
			(2 * border_width) \
			+ hex_radius + roundf(hex_radius * 1.5) * row_count \
			+ hex_spacing * (row_count - 1) - 2
	)
	set_custom_minimum_size(Vector2(x_size, y_size))
	set_size(Vector2(x_size, y_size))
