class_name PercentageCalculation
extends StrengthCalculation
## A strength calculation that uses the percentage of a given number.


@export_range(0.0, 5.0, 0.01) var percentage: float = 1.0


## Determines the value that will be used to change the stat to be the desired value.
func _set_operation(
	_target_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	var diff: float = (stat_value * percentage) - stat_value
	if diff >= 0.0:
		return convert(diff * efficacy_percent, TYPE_INT)
	else:
		return -convert(diff * efficacy_percent, TYPE_INT)


## Determines the value to increase the target stat by.
func _increase_operation(
	_base_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	return convert(stat_value * percentage * efficacy_percent, TYPE_INT)


## Determines the value to increase the target stat by.
func _decrease_operation(
	_base_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	return -convert(stat_value * percentage * efficacy_percent, TYPE_INT)
