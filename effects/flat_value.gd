class_name FlatValue
extends StrengthCalculation
"""
A strength calculation that simply sets the strength to a given value.
"""


export(int, 0, 1000) var value = 0


# Returns the result of the calculation.
func get_strength() -> int:
	return value
