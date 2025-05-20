class_name ActionStats
extends Resource
"""
Describes the common details of a character action. These include range details,
targets, and potency.
"""


enum Target {SELF, ALLIES, OPPONENTS}

# The target the action affects.
export(Target) var target = Target.OPPONENTS
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


#
func check_for_required_resources() -> void:
	assert(
			area_range != null,
			"Error: ActionStats missing defined area_range."
	)
	assert(
			area_range is CardinalArea or area_range is RingArea,
			"Error: ActionStats area_range is neither a CardinalArea or RingArea."
	)
	if dead_range != null:
		assert(
				dead_range is CardinalArea or dead_range is RingArea,
				"Error: ActionStats dead_range is neither a CardinalArea or RingArea."
		)
	assert(
			effect_range != null,
			"Error: ActionStats missing defined effect_range."
	)
	assert(
			effect_range is AreaRange,
			"Error: Action %s effect_range is not an AreaRange."
	)
