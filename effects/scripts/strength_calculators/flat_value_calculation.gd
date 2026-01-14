class_name FlatValueCalculation
extends StrengthCalculation
## A strength calculation that simply sets the strength to a given value.


## The flat value to use.
var flat_value: int = 0:
	set(value):
		flat_value = clampi(value, 0, 1000)


## Initializes this object using the specified flat value.
func _init(value: int = 0) -> void:
	flat_value = value


## Determines the value that the target stat will be set to. If this effect is
## resisted, the value will be closer to that of the original stat.
func _set_operation(
	_target_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	var diff: float = flat_value - stat_value
	if diff >= 0.0:
		return convert(diff * efficacy_percent, TYPE_INT)
	else:
		return -convert(diff * efficacy_percent, TYPE_INT)


## Increases the value specified stat of the target character by the value of
## the potency.
func _increase_operation(
	_base_strength: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return convert(flat_value * efficacy_percent, TYPE_INT)


## Descreases the value specified stat of the target character by the value of
## the potency.
func _decrease_operation(
	_base_strength: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return -convert(flat_value * efficacy_percent, TYPE_INT)
