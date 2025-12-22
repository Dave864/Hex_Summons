class_name StrengthCalculation
extends Resource
## Base class that is used to define the strength of an effect.


## Determines the strength of the effect for a given character.
func base_strength(
		source_stats: Dictionary[],
		action_potency: Potency
) -> float:
	return _strength_scalar(_get_strength_potency(source_stats, action_potency))


## Determines the effectiveness of an action on a given target.
func efficacy(
	source_stats: Dictionary[],
	target_stats: CharacterStatModifiers,
	action_potency: Potency
) -> float:
	var b_str: float = base_strength(source_stats, action_potency)
	var resisted_strength: float = _calculate_resisted_strength(
			source_stats,
			target_stats,
			action_potency
	)
	# 0.0 means not effective, 1.0 means fully effective.
	return clamp(resisted_strength / b_str, 0.0, 1.0)


## Runs the specified operation on a given stat using the provided strength
## and efficacy.
func process_operation(
	strength: float,
	efficacy_percent: float,
	stat_value: int,
	operation: int
) -> int:
	match operation:
		Stat.Operation.SET:
			return _set_operation(strength, efficacy_percent, stat_value)
		Stat.Operation.INCREASE:
			return _increase_operation(strength, efficacy_percent, stat_value)
		Stat.Operation.DECREASE:
			return _decrease_operation(strength, efficacy_percent, stat_value)
		_:
			return 0


## Determines the value that will be used to change the stat to be the desired value.
func _set_operation(
	target_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	var diff: float = target_strength - stat_value
	if diff >= 0.0:
		return convert(diff * efficacy_percent, TYPE_INT)
	else:
		return -convert(diff * efficacy_percent, TYPE_INT)


## Determines the value to increase the target stat by.
func _increase_operation(
	base_strength_value: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return convert(base_strength_value * efficacy_percent, TYPE_INT)


## Determines the value to decrease the target stat by.
func _decrease_operation(
	base_strength_value: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return -convert(base_strength_value * efficacy_percent, TYPE_INT) 


## Determines the strength of the effect for a given character when resisted
## by the target.
func _calculate_resisted_strength(
	source_stats: Dictionary[],
	target_stats: CharacterStatModifiers,
	action_potency: Potency
) -> float:
	var strength_values: Dictionary[String, Variant] = _get_strength_potency(
			source_stats,
			action_potency
	)
	var res_values: Dictionary[String, Variant] = target_stats.get_defensive()
	_apply_resistance(strength_values, res_values)
	return _strength_scalar(strength_values)


## Combines the potency strength data into a single value.
func _strength_scalar(strength_data: Dictionary[String, Variant]) -> float:
	var total_strength: float = strength_data[Stat.ATTACK]
	for v: float in strength_data[Stat.MAGIC].values():
		total_strength += v
	return total_strength


## Determines the raw potency values for a given character.
func _get_strength_potency(
		character_stats: Dictionary[String, Variant],
		action_potency: Potency
) -> Dictionary[String, Variant]:
	var p_vals: Dictionary[String, Variant] = {}
	p_vals[Stat.ATTACK] = (
			action_potency.attack_potency \
			* character_stats[Stat.ATTACK]
	)
	p_vals[Stat.MAGIC] = {}
	for element in Element.Type.values():
		var elem_pot: float = action_potency.get_elemental_potency(element)
		var c_stat: int = character_stats[Stat.MAGIC][element]
		p_vals[Stat.MAGIC][element] = elem_pot + c_stat
	return p_vals


## Applies resistance values to the strength.
func _apply_resistance(
	strength: Dictionary[String, Variant],
	resistance: Dictionary[String, Variant]
) -> void:
	strength[Stat.ATTACK] = _bind_resistance(
			strength[Stat.ATTACK],
			resistance[Stat.DEFENSE]
	)
	for element in Element.Type.values():
		strength[Stat.MAGIC][element] = _bind_resistance(
				strength[Stat.MAGIC][element],
				resistance[Stat.RESISTANCE][element]
		)


## Calculates the result of resistance, binding the result to be no lower than zero.
func _bind_resistance(strength: float, resistance: float) -> float:
	return clamp(strength - resistance, 0.0, strength)
