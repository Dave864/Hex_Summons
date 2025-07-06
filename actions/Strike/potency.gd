class_name Potency
extends Resource
"""
Describes the potency of an action. Potency determines what stats are used when
determining the strength of an action's effect.
"""


# The potency values of given elemental alignment values.
# The index is the alignment value.
const ELEMENTAL_POTENCY: Array = [0.0, 1.0, 1.5, 2.0, 2.33, 2.66, 3.0]

# The percentage of a character's attack to use for potency calculations.
export(float, 0.0, 3.0) var attack_potency = 1.0
# The elemental alignment of the action, used for potency calculations.
export(int, 0, 6) var earth_alignment = 0
export(int, 0, 6) var fire_alignment = 0
export(int, 0, 6) var water_alignment = 0
export(int, 0, 6) var wind_alignment = 0
export(int, 0, 6) var light_alignment = 0
export(int, 0, 6) var dark_alignment = 0


# Gets the potency value of an element.
func get_elemental_potency(element: int) -> float:
	match element:
		Constants.Element.EARTH:
			return ELEMENTAL_POTENCY[earth_alignment]
		Constants.Element.FIRE:
			return ELEMENTAL_POTENCY[fire_alignment]
		Constants.Element.WATER:
			return ELEMENTAL_POTENCY[water_alignment]
		Constants.Element.WIND:
			return ELEMENTAL_POTENCY[wind_alignment]
		Constants.Element.LIGHT:
			return ELEMENTAL_POTENCY[light_alignment]
		Constants.Element.DARK:
			return ELEMENTAL_POTENCY[dark_alignment]
		_:
			return 0.0
