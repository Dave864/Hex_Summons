tool
class_name CardinalRange
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
