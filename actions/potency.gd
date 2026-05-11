class_name Potency
extends Resource
## Describes the potency of an action.
##
## Potency determines what stats are used when
## determining the strength of an action's effect.


## The potency values of given elemental alignment values.
## The index is the alignment value.
const ELEMENTAL_POTENCY: Array[float] = [0.0, 1.0, 1.5, 2.0, 2.33, 2.66, 3.0]

## The percentage of a character's attack to use for potency calculations.
@export_range(0.0, 3.0, 0.01) var attack_potency: float = 1.0
## The elemental alignment of the action, used for potency calculations.
@export_range(0, 6) var earth_alignment: int = 0
@export_range(0, 6) var fire_alignment: int = 0
@export_range(0, 6) var water_alignment: int = 0
@export_range(0, 6) var wind_alignment: int = 0
@export_range(0, 6) var light_alignment: int = 0
@export_range(0, 6) var dark_alignment: int = 0


## Gets the potency value of an element.
func get_elemental_potency(element: Element.Type) -> float:
	match element:
		Element.Type.EARTH:
			return ELEMENTAL_POTENCY[earth_alignment]
		Element.Type.FIRE:
			return ELEMENTAL_POTENCY[fire_alignment]
		Element.Type.WATER:
			return ELEMENTAL_POTENCY[water_alignment]
		Element.Type.WIND:
			return ELEMENTAL_POTENCY[wind_alignment]
		Element.Type.LIGHT:
			return ELEMENTAL_POTENCY[light_alignment]
		Element.Type.DARK:
			return ELEMENTAL_POTENCY[dark_alignment]
		_:
			return 0.0
