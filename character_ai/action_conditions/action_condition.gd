class_name ActionCondition
extends Node
## Base class that describes a condition that must be met in order for an action
## to be considered for use by a CharacterAI.


## Virtual function. Checks if the condition has been met given the current
## state of the characters and map.
func is_met(
	_character: Character,
	_targets: Array,
	_distance_map: DistanceMap
) -> bool:
	return true
