class_name StrengthCalculation
extends Resource
"""
Base class that is used to define the strength of an effect.
"""


var _strength: int = 0


# Returns the result of the calculation.
func get_strength() -> int:
	return _strength
