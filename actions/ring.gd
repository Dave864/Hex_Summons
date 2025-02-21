class_name Ring
extends ActionRange
"""
Describes an action range whose area encompasses all hexes within the defined distance.
"""


# How many tiles out from the cast point the action will affect.
export(int, 0, 1000) var distance = 0


# Draws the current area range of the action.
func _draw_area_range() -> void:
	if Engine.editor_hint:
		pass
