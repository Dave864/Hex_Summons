class_name RangeDisplay
extends Panel
"""
Test UI node that is meant to check the feasability of drawing the range data
of actions on a specific UI element.
"""


export(NodePath) var action_ref
var _action: Action = null

var hex_radius = 3.0
# References to the range details of an action.
var _source_range: AreaRange = null
var _dead_range: AreaRange = null
var _effect_range: AreaRange = null
var _emit_from_center: bool = false


# Redraws the range display for the given action.
func update_range_display(action: Action) -> void:
	_source_range = action.source_range
	_dead_range = action.dead_range
	_effect_range = action.effect_range
	_emit_from_center = action.emit_from_center
	update()


func _ready() -> void:
	_action = get_node(action_ref)
#	update_range_display(_action)


func _draw() -> void:
	# Determine the configuration of tiles for the source range minus dead range.
	_draw_range()


func _determine_source_hexes() -> void:
	if _source_range is CardinalArea:
		pass
	else:
		pass


func _determine_effect_hexes() -> void:
	pass


# Draws the array of hexagons that display the range of the action.
func _draw_range() -> void:
	var _row_count: int = 10
	var _col_count: int = 10
	_set_min_size(_row_count, _col_count)
	var center: Vector2 = Vector2.ZERO
	for row in range(1, _row_count + 1):
		center.y = hex_radius * 2 * row
		center.x = hex_radius * 2 if row % 2 != 0 else hex_radius * 3
		_draw_filled_hex(Color.gray, center)
		for col in _col_count - 1:
			center.x += hex_radius * 2 + 0.5
			_draw_filled_hex(Color.gray, center)


# Draw a colored outline of a hexagon.
func _draw_hex_outline(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_polyline(hex_vertices, color, hex_radius / 2)


# Draws a filled colored hexagon.
func _draw_filled_hex(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_colored_polygon(hex_vertices, color)


# Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(center: Vector2) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	var top_vertex: Vector2 = Vector2(0.0, hex_radius)
	for i in 7:
		hex_vertices.append(top_vertex.rotated(i * PI / 3) + center)
	return hex_vertices


# Sets the minimum size for the display panel so that the drawn elements are
# always within its bounds. 
func _set_min_size(row_count: int, col_count: int) -> void:
	var x_size: float = hex_radius * 2 * col_count
	var y_size: float = hex_radius * 2 * row_count
	set_custom_minimum_size(Vector2(x_size, y_size))
