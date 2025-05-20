class_name Percentage
extends StrengthCalculation
"""
A strength calculation that uses the percentage of a given number.
"""


export(float, 0.0, 5.0) var value = 1.0


# Returns the result of the calculation.
func get_strength() -> int:
	return value
