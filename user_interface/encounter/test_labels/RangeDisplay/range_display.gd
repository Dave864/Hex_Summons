class_name RangeDisplay
extends Panel
"""
Test UI node that is meant to check the feasability of drawing the range data
of actions on a specific UI element.
"""


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


func _draw() -> void:
	_draw_range()


# Draws the array of hexagons that display the range of the action.
func _draw_range() -> void:
	var center: Vector2 = Vector2.ZERO
	for row in range(1, 11):
		center.y = (Constants.DISPLAY_HEX_RADIUS * 2 + 0.5) * row
		center.x = (
				Constants.DISPLAY_HEX_RADIUS * 2 if row % 2 != 0
				else Constants.DISPLAY_HEX_RADIUS * 3
		)
		_draw_filled_hex(Color.gray, center)
		for col in 10:
			center.x += Constants.DISPLAY_HEX_RADIUS * 2 + 0.5
			_draw_filled_hex(Color.gray, center)


# Draw a colored outline of a hexagon.
func _draw_hex_outline(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_polyline(hex_vertices, color, Constants.DISPLAY_HEX_RADIUS / 2)


# Draws a filled colored hexagon.
func _draw_filled_hex(color: Color, center: Vector2) -> void:
	var hex_vertices: PoolVector2Array = _get_points_for_hex(center)
	draw_colored_polygon(hex_vertices, color)


# Gets the points for a hexagon centered at a given point.
func _get_points_for_hex(center: Vector2) -> PoolVector2Array:
	var hex_vertices: PoolVector2Array = []
	var top_vertex: Vector2 = Vector2(0.0, Constants.DISPLAY_HEX_RADIUS)
	for i in 7:
		hex_vertices.append(top_vertex.rotated(i * PI / 3) + center)
	return hex_vertices
