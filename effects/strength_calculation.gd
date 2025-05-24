class_name StrengthCalculation
extends Resource
"""
Base class that is used to define the strength of an effect.
"""


export(Resource) var action_potency = null


# Gets the needed details for the operation and then runs said operation on those
# values, returning the result.
func process_operation(
	source_stats: CharacterStats,
	target_stats: CharacterStats,
	stat_affected: Resource,
	resisted: bool,
	operation: int
) -> int:
	var base_strength: float = _calculate_strength(source_stats)
	var resisted_strength: float = (
			_calculate_resisted_strength(source_stats, target_stats) if resisted
			else base_strength
	)
	# How far should the target value shift towards the strength value.
	# 0.0 means it does not shift, 1.0 means it shifts fully.
	var shift_percentage: float = clamp(base_strength / resisted_strength, 0.0, 1.0)
	var stat_value: int = _get_stat_value(target_stats, stat_affected)
	
	match operation:
		Constants.Operation.SET:
			return _set_operation(base_strength, shift_percentage, stat_value)
		Constants.Operation.INCREASE:
			return _increase_operation(base_strength, shift_percentage, stat_value)
		Constants.Operation.DECREASE:
			return _decrease_operation(base_strength, shift_percentage, stat_value)
		_:
			return 0


# Determines the value that the target stat will be set to. If this effect is
# resisted, the value will be closer to that of the original stat.
func _set_operation(
	target_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	var diff: float = target_strength - stat_value
	if diff >= 0.0:
		stat_value += convert(diff * shift_percentage, TYPE_INT)
	else:
		stat_value -= convert(diff * shift_percentage, TYPE_INT)
	return stat_value


# Increases the value specified stat of the target character by the value of
# the potency.
func _increase_operation(
	base_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	return stat_value + convert(base_strength * shift_percentage, TYPE_INT)


# Descreases the value specified stat of the target character by the value of
# the potency.
func _decrease_operation(
	base_strength: float,
	shift_percentage: float,
	stat_value: int
) -> int:
	return stat_value - convert(base_strength * shift_percentage, TYPE_INT) 


func check_for_required_resources() -> void:
	assert(
			action_potency != null,
			"Error: StrengthCalculation missing defined action_potency."
	)
	assert(
			action_potency is Potency,
			"Error: StrengthCalculation action_potency is not Potency resource."
	)


# Determines the strength of the effect for a given character.
func _calculate_strength(source_stats: CharacterStats) -> float:
	return _convert_to_scalar(_get_potency_values(source_stats))


# Determines the strength of the effect for a given character when resisted by the target.
func _calculate_resisted_strength(
	source_stats: CharacterStats,
	target_stats: CharacterStats
) -> float:
	var strength_values: Dictionary = _get_potency_values(source_stats)
	var res_values: Dictionary = target_stats.get_defensive()
	_apply_resistance(strength_values, res_values)
	return _convert_to_scalar(strength_values)


# Combines the potency strength data into a single value.
func _convert_to_scalar(strength_data: Dictionary) -> float:
	var total_strength: float = strength_data[Constants.ATTACK]
	for v in strength_data[Constants.MAGIC].values():
		total_strength += v
	return total_strength


# Gets the value of the target character's stat.
func _get_stat_value(target_stats: CharacterStats, stat: Resource) -> int:
	if stat is Stat:
		return target_stats.get_calculated_stat(stat.Type)
	elif stat is ElementalStat:
		return target_stats.get_calculated_elemental_stat(stat.Type, stat.Element)
	else:
		printerr("A non Stat or ElementalStat resource was requested.")
		return 0


# Determines the raw potency values for a given character.
func _get_potency_values(character_stats: CharacterStats) -> Dictionary:
	var p_vals: Dictionary = character_stats.get_offensive()
	p_vals[Constants.ATTACK] *= action_potency.attack_potency
	for element in ElementalStat.Element:
		p_vals[Constants.MAGIC][element] *= (
				action_potency.get_elemental_potency(element)
		)
	return p_vals


# Applies resistance values to the strength.
func _apply_resistance(strength: Dictionary, resistance: Dictionary) -> void:
	strength[Constants.ATTACK] = _bind_resistance(
			strength[Constants.ATTACK],
			resistance[Constants.DEFENSE]
	)
	for element in ElementalStat.Element:
		strength[Constants.MAGIC][element] = _bind_resistance(
				strength[Constants.MAGIC][element],
				resistance[Constants.RESISTANCE][element]
		)


# Calculates the result of resistance, binding the result to be no lower than zero.
func _bind_resistance(strength: float, resistance: float) -> float:
	return clamp(strength - resistance, 0.0, strength)
