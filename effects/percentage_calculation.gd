class_name PercentageCalculation
extends StrengthCalculation
"""
A strength calculation that uses the percentage of a given number.
"""


export(float, 0.0, 5.0) var percentage = 1.0


# Determines the value that the target stat will be set to. If this effect is
# resisted, the value will be closer to that of the original stat.
func _set_operation(
	_target_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	var diff: float = (stat_value * percentage) - stat_value
	if diff >= 0.0:
		stat_value += convert(diff * shift_percentage, TYPE_INT)
	else:
		stat_value -= convert(diff * shift_percentage, TYPE_INT)
	return stat_value


# Increases the value specified stat of the target character by the value of
# the potency.
func _increase_operation(
	_base_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	return stat_value + convert(stat_value * percentage * shift_percentage, TYPE_INT)


# Descreases the value specified stat of the target character by the value of
# the potency.
func _decrease_operation(
	_base_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	return stat_value - convert(stat_value * percentage * shift_percentage, TYPE_INT)
