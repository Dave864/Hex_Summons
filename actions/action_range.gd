tool
class_name ActionRange
extends CanvasItem
"""
Describes the common parameters for all actions, which are split into the 
catergories of either `CardinalActoin` or `RingAction`. Defines the attack bonus 
and area range.
"""


# The number of tiles from the character position that are affectable by the action.
export(int, 1, 1000) var area_distance = 1 setget set_area_distance, get_area_distance
# The number of tiles from the character position that are considered out of
# reach for the action. Should be always at least one less than the area_distance.
export(int, 0, 1000) var dead_distance = 0 setget set_dead_distance, get_dead_distance
# Indicates if the action's cast point is fixed to the character's position
# or is able to be defined within the action area.
export(bool) var fixed_to_character

var _area_range_color: Color = Color.blue
var _character_origin_color: Color = Color.aqua
var _effect_range_color: Color = Color.yellow
var _effect_origin_color: Color = Color.orangered


func set_area_distance(ad: int) -> void:
	area_distance = ad
	dead_distance = ad - 1 if dead_distance >= ad else dead_distance


func get_area_distance() -> int:
	return area_distance


func set_dead_distance(dd: int) -> void:
	dead_distance = area_distance - 1 if dd >= area_distance else dd


func get_dead_distance() -> int:
	return dead_distance


func _center_offset() -> Vector2:
	var x_offset: float = (
		(Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO * area_distance * 2.0)
		+ Constants.DISPLAY_HEX_RADIUS
	)
	var y_offset: float = (
		(Constants.DISPLAY_HEX_RADIUS * area_distance * 1.5)
		+ Constants.DISPLAY_HEX_RADIUS
	)
	return Vector2(x_offset, y_offset)


func _draw() -> void:
	_draw_area_range()
	_draw_effect_range()


# Virtual function. Draws the current area range of the action.
func _draw_area_range() -> void:
	pass


func _draw_effect_range() -> void:
	pass


# Draw a hex tile reference in the editor.
func _draw_hex_poly(position: Vector2, color: Color, outline_only: bool = false) -> void:
	var vertices_pos: PoolVector2Array = []
	vertices_pos.resize(6)
	
	# Get the position of the vertices
	var x_displacement: float = Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO
	vertices_pos[0] = Vector2(0.0, Constants.DISPLAY_HEX_RADIUS) + position
	vertices_pos[1] = Vector2(x_displacement, Constants.DISPLAY_HEX_RADIUS / 2.0) + position
	vertices_pos[2] = Vector2(x_displacement, -(Constants.DISPLAY_HEX_RADIUS / 2.0)) + position
	vertices_pos[3] = Vector2(0.0, -Constants.DISPLAY_HEX_RADIUS) + position
	vertices_pos[4] = Vector2(-x_displacement, -(Constants.DISPLAY_HEX_RADIUS / 2.0)) + position
	vertices_pos[5] = Vector2(-x_displacement, Constants.DISPLAY_HEX_RADIUS / 2.0) + position
	
	if outline_only:
		vertices_pos.resize(7)
		vertices_pos[6] = vertices_pos[0]
		var segment_colors: PoolColorArray = []
		segment_colors.resize(7)
		for i in range(7):
			segment_colors[i] = color
		draw_polyline_colors(vertices_pos, segment_colors, 2.0)
	else:
		draw_colored_polygon(vertices_pos, color)
