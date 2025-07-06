class_name StrengthCalculation
extends Resource
"""
Base class that is used to define the strength of an effect.
"""


# Gets the needed details for the operation and then runs said operation on those
# values, returning the result.
func process_operation(
	source_stats: CharacterStats,
	target_stats: CharacterStats,
	action_potency: Potency,
	stat_affected: Resource,
	resisted: bool,
	operation: int
) -> int:
	var base_strength: float = _calculate_strength(source_stats, action_potency)
	var resisted_strength: float = (
			_calculate_resisted_strength(
					source_stats,
					target_stats,
					action_potency
			) if resisted
			else base_strength
	)
	# 0.0 means not effective, 1.0 means fully effective.
	var efficacy: float = clamp(base_strength / resisted_strength, 0.0, 1.0)
	var stat_value: int = _get_stat_value(target_stats, stat_affected)
	
	match operation:
		Constants.Operation.SET:
			return _set_operation(base_strength, efficacy, stat_value)
		Constants.Operation.INCREASE:
			return _increase_operation(base_strength, efficacy, stat_value)
		Constants.Operation.DECREASE:
			return _decrease_operation(base_strength, efficacy, stat_value)
		_:
			return 0


# Determines the value that will be used to change the stat to be the desired value.
func _set_operation(
	target_strength: float,
	efficacy: float,
	stat_value: int
) -> int:
	var diff: float = target_strength - stat_value
	if diff >= 0.0:
		return convert(diff * efficacy, TYPE_INT)
	else:
		return -convert(diff * efficacy, TYPE_INT)


# Determines the value to increase the target stat by.
func _increase_operation(
	base_strength: float,
	efficacy: float,
	_stat_value: int
) -> int:
	return convert(base_strength * efficacy, TYPE_INT)


# Determines the value to decrease the target stat by.
func _decrease_operation(
	base_strength: float,
	efficacy: float,
	_stat_value: int
) -> int:
	return -convert(base_strength * efficacy, TYPE_INT) 


# Determines the strength of the effect for a given character.
func _calculate_strength(
		source_stats: CharacterStats,
		action_potency: Potency
) -> float:
	return _convert_to_scalar(_get_potency_values(source_stats, action_potency))


# Determines the strength of the effect for a given character when resisted by the target.
func _calculate_resisted_strength(
	source_stats: CharacterStats,
	target_stats: CharacterStats,
	action_potency: Potency
) -> float:
	var strength_values: Dictionary = _get_potency_values(source_stats, action_potency)
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
	assert(stat is Stat , "A non Stat resource was requested.")
	return target_stats.get_calculated_stat(stat.type)


# Determines the raw potency values for a given character.
func _get_potency_values(
		character_stats: CharacterStats,
		action_potency: Potency
) -> Dictionary:
	var p_vals: Dictionary = character_stats.get_offensive()
	p_vals[Constants.ATTACK] *= action_potency.attack_potency
	for element in Constants.Element:
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
	for element in Constants.Element:
		strength[Constants.MAGIC][element] = _bind_resistance(
				strength[Constants.MAGIC][element],
				resistance[Constants.RESISTANCE][element]
		)


# Calculates the result of resistance, binding the result to be no lower than zero.
func _bind_resistance(strength: float, resistance: float) -> float:
	return clamp(strength - resistance, 0.0, strength)
