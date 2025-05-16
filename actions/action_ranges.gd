class_name ActionRanges
extends Resource
"""
Defines the various ranges associated with an action.
"""


# The area specifying the possible tiles for effect emmision.
export var area_range: Resource = null
# The area that is ignored when determining the possible tiles for effect emmision.
export var dead_range: Resource = null
# The area specifying the tiles affected by the effect.
export var effect_range: Resource = null
# Flag that denotes if the emission is fixed to the center of the area.
export(bool) var emit_from_center = true
# Flag that denotes if the effect should include the casting character tile.
export(bool) var effect_ignores_caster = true
# Flag that denotes if the possible source of the emmision is affected by tile heights.
export(bool) var area_ignore_heights = false
# Flag that denotes if the emission area is affected by tile heights.
export(bool) var effect_ignore_heights = false
