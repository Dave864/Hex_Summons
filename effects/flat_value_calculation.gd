class_name FlatValueCalcultion
extends StrengthCalculation
"""
A strength calculation that simply sets the strength to a given value.
"""


export(int, 0, 1000) var flat_value = 0


# Determines the value that the target stat will be set to. If this effect is
# resisted, the value will be closer to that of the original stat.
func _set_operation(
	base_strength: float,
	percentage: float,
	stat_value: int
) -> int:
	if base_strength - stat_value >= 0.0:
		stat_value += convert(flat_value * percentage, TYPE_INT)
	else:
		stat_value -= convert(flat_value * percentage, TYPE_INT)
	return stat_value


# Increases the value specified stat of the target character by the value of
# the potency.
func _increase_operation(
	_base_strength: float,
	percentage: float,
	stat_value: int
) -> int:
	return stat_value + convert(flat_value * percentage, TYPE_INT)


# Descreases the value specified stat of the target character by the value of
# the potency.
func _decrease_operation(
	_base_strength: float,
	percentage: float,
	stat_value: int
) -> int:
	return stat_value - convert(flat_value * percentage, TYPE_INT)
