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
var _action: Action = null
# Matrix that represents the hexes in the display.
var _hex_matrix: DisplayMatrix = null
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
	_hex_matrix = DisplayMatrix.new(row_count, col_count)
	if Engine.is_editor_hint():
		update()


func set_col_count(cc: int) -> void:
	col_count = cc
	_hex_matrix = DisplayMatrix.new(row_count, col_count)
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
	_action = action
	update()


func _ready() -> void:
	_hex_matrix = DisplayMatrix.new(row_count, col_count)
	_origin_pts = _init_origin_vertices()
	_origin_fill_pts = _init_origin_vertices(outline_width)


func _draw() -> void:
	if not Engine.is_editor_hint():
		_hex_matrix.reset_display()
		_determine_source_hexes()
		_determine_effect_hexes()
	_draw_range()


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
	_action.source_range.populate_range_display_matrix(
			Vector2(1, _mid_row),
			DisplayMatrix.Detail.EMPTY,
			DisplayMatrix.Detail.SOURCE_RANGE,
			_hex_matrix
	)
	if _action.dead_range != null:
		_action.dead_range.populate_range_display_matrix(
				Vector2(1, _mid_row),
				DisplayMatrix.Detail.EMPTY,
				DisplayMatrix.Detail.EMPTY,
				_hex_matrix
		)


# Determine the hex colors that will represent the effect range.
func _determine_effect_hexes() -> void:
	var emission_index: Vector2 = Vector2(1, _mid_row)
	
	if not _action.emit_from_center:
		for x in range(2, col_count):
			var index: Vector2 = Vector2(x, _mid_row)
			if _hex_matrix.fill_at(index) == DisplayMatrix.Detail.SOURCE_RANGE:
				emission_index.x = x
	
	_action.effect_range.populate_range_display_matrix(
			emission_index,
			DisplayMatrix.Detail.EMPTY,
			DisplayMatrix.Detail.EFFECT_RANGE,
			_hex_matrix
	)
	
	_set_caster_hex()
	_set_emission_hex(emission_index)


# Sets the details for the hex that represents the caster.
func _set_caster_hex() -> void:
	_hex_matrix.set_caster_details()


# Sets the details for the hex that represents the emission point.
func _set_emission_hex(emission_point: Vector2) -> void:
	_hex_matrix.set_emission_details(emission_point)


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
	var outline_color: Color = _determine_color(_hex_matrix.outline_at(Vector2(col, row)))
	var fill_color: Color = _determine_color(_hex_matrix.fill_at(Vector2(col, row)))
	_draw_hex_outline(outline_color, coord)
	_draw_hex_fill(fill_color, coord)


# Determines the color to use based on the detail marker.
func _determine_color(detail_marker: int) -> Color:
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
