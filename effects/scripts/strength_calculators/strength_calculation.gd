class_name StrengthCalculation
extends Object
## Base class that is used to define the strength of an effect.


## Defines the minimum value for strength after resistsnaces are applied.
const MIN_STRENGTH: int = 1


## Determines the strength of the effect for a given character.
func base_strength(
		source_stats: AllStats,
		action_potency: Potency
) -> float:
	return _strength_scalar(_get_strength_potency(source_stats, action_potency))


## Determines the effectiveness of an action on a given target.
func efficacy(
	source_stats: AllStats,
	target_stats: StatModifiers,
	action_potency: Potency
) -> float:
	var b_str: float = base_strength(source_stats, action_potency)
	var resisted_strength: float = _calculate_resisted_strength(
			source_stats,
			target_stats,
			action_potency
	)
	# 0.0 means not effective, 1.0 means fully effective.
	return clampf(resisted_strength / b_str, 0.0, 1.0)


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
			return MIN_STRENGTH


## Determines the value that will be used to change the stat to be the desired
## value.
func _set_operation(
	target_strength: float,
	efficacy_percent: float,
	stat_value: int
) -> int:
	var diff: float = target_strength - stat_value
	if diff >= 0.0:
		return type_convert(diff * efficacy_percent, TYPE_INT)
	else:
		return -type_convert(diff * efficacy_percent, TYPE_INT)


## Determines the value to increase the target stat by.
func _increase_operation(
	base_strength_value: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return type_convert(base_strength_value * efficacy_percent, TYPE_INT)


## Determines the value to decrease the target stat by.
func _decrease_operation(
	base_strength_value: float,
	efficacy_percent: float,
	_stat_value: int
) -> int:
	return -type_convert(base_strength_value * efficacy_percent, TYPE_INT) 


## Determines the strength of the effect for a given character when resisted
## by the target.
func _calculate_resisted_strength(
	source_stats: AllStats,
	target_stats: CharacterStatModifiers,
	action_potency: Potency
) -> int:
	var strength_values: OffensiveStats = _get_strength_potency(
			source_stats,
			action_potency
	)
	var res_values: DefensiveStats = target_stats.get_defensive()
	_apply_resistance(strength_values, res_values)
	return _strength_scalar(strength_values)


## Combines the potency strength data into a single value.
func _strength_scalar(strength_data: OffensiveStats) -> int:
	var total_strength: int = strength_data.get_attack()
	for element: Element.Type in Element.Type.values():
		total_strength += strength_data.get_magic(element)
	return total_strength


## Determines the raw potency values for a given character.
func _get_strength_potency(
		character_stats: AllStats,
		action_potency: Potency
) -> OffensiveStats:
	var strength := OffensiveStats.new(
		int(action_potency.attack_potency * character_stats.get_attack())
	)
	for element: Element.Type in Element.Type.values():
		var magic_value := int(
			action_potency.get_elemental_potency(element)
			* character_stats.get_magic(element)
		)
		strength.set_magic(element, magic_value)
	return strength


## Applies resistance values to the strength.
func _apply_resistance(
	strength: OffensiveStats,
	resistance: DefensiveStats
) -> void:
	var resisted_attack: int = _bind_resistance(
			strength.get_attack(),
			resistance.get_defense()
	)
	strength.set_attack(resisted_attack)
	for element: Element.Type in Element.Type.values():
		var resisted_magic: int = _bind_resistance(
			strength.get_magic(element),
			resistance.get_res(element)
		)
		strength.set_magic(element, resisted_magic)


## Calculates the result of resistance, binding the result to be no lower than
## zero.
func _bind_resistance(strength: int, resistance: int) -> int:
	return clampi(strength - resistance, MIN_STRENGTH, strength)
