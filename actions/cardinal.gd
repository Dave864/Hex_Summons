tool
class_name Cardinal
extends ActionRange
"""
Describes an action range whose area is constrained by the six directions of a hexagon.
"""


enum EffectType {
	CONE,
	COLUMN,
}

# The "width" of the effect area.
export(int, 0, 6) var spread = 0
# How many tiles out from the cast point the action will affect.
export(int, 1, 1000) var distance = 1
export(EffectType) var effect_type


# Draws the current area range of the action.
func _draw_area_range() -> void:
	# Draw each arm extending from the character origin
	var center_pos: Vector2 = _center_offset()
	
	for i in range(6):
		var x_dis: float = 0.0
		var y_dis: float = 0.0
		match i:
			0:
				x_dis = -Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO
				y_dis = Constants.DISPLAY_HEX_RADIUS * 1.5
			1:
				x_dis = Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO
				y_dis = Constants.DISPLAY_HEX_RADIUS * 1.5
			2:
				x_dis = Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO * 2.0
			3:
				x_dis = Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO
				y_dis = -Constants.DISPLAY_HEX_RADIUS * 1.5
			4:
				x_dis = -Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO
				y_dis = -Constants.DISPLAY_HEX_RADIUS * 1.5
			5:
				x_dis = -Constants.DISPLAY_HEX_RADIUS * Constants.HEX_EDGE_RATIO * 2.0
		for j in range(area_distance):
			var v_center: Vector2 = Vector2(x_dis, y_dis) * (j + 1)
			v_center += center_pos
			_draw_hex_poly(v_center, _area_range_color, j < dead_distance)
	
	# Draw the character origin point
	_draw_hex_poly(center_pos, _character_origin_color)


func _draw_effect_range() -> void:
	pass
