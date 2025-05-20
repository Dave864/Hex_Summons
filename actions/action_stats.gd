class_name ActionStats
extends Resource
"""
Describes the common details of a character action. These include range details,
targets, and potency.
"""


enum Target {SELF, ALLIES, OPPONENTS}

# The potency values of given elemental alignment values.
# The index is the alignment value.
const ELEMENTAL_POTENCY: Array = [0.0, 1.0, 1.5, 2.0, 2.33, 2.66, 3.0]

# The target the action affects.
export(Target) var target = Target.OPPONENTS
# The percentage of a character's attack to use for potency calculations.
export(float, 0.0, 3.0) var attack_potency = 1.0
# The elemental alignment of the action, used for potency calculations.
export(int, 0, 6) var earth_alignment = 0
export(int, 0, 6) var fire_alignment = 0
export(int, 0, 6) var water_alignment = 0
export(int, 0, 6) var wind_alignment = 0
export(int, 0, 6) var light_alignment = 0
export(int, 0, 6) var dark_alignment = 0
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


# Gets the potency value of an element.
func get_elemental_potency(element: int) -> float:
	match element:
		ElementalStat.Element.EARTH:
			return ELEMENTAL_POTENCY[earth_alignment]
		ElementalStat.Element.FIRE:
			return ELEMENTAL_POTENCY[fire_alignment]
		ElementalStat.Element.WATER:
			return ELEMENTAL_POTENCY[water_alignment]
		ElementalStat.Element.WIND:
			return ELEMENTAL_POTENCY[wind_alignment]
		ElementalStat.Element.LIGHT:
			return ELEMENTAL_POTENCY[light_alignment]
		ElementalStat.Element.DARK:
			return ELEMENTAL_POTENCY[dark_alignment]
		_:
			return 0.0


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
