class_name StrengthCalculation
extends Resource
"""
Base class that is used to define the strength of an effect.
"""


export(Resource) var action_potency = null


# Determines the value that the target stat will be set to. If this effect is
# resisted, the value will be closer to that of the original stat.
func set_operation(
	source_stats: CharacterStats,
	target_stats: CharacterStats,
	stat_affected: Resource,
	resisted: bool
) -> int:
	var base_strength: float = _calculate_strength(source_stats)
	var resisted_strength: float = (
			_calculate_resisted_strength(source_stats, target_stats) if resisted
			else base_strength
	)
	# How far should the target value shift towards the original potency.
	# 0.0 means it does not shift, 1.0 means it shifts fully.
	var percentage: float = clamp(base_strength / resisted_strength, 0.0, 1.0)
	var stat_value: int = _get_target_stat_value(target_stats, stat_affected)
	if base_strength - stat_value >= 0.0:
		stat_value += convert(base_strength * percentage, TYPE_INT)
	else:
		stat_value -= convert(base_strength * percentage, TYPE_INT)
	return stat_value


# Increases the value specified stat of the target character by the value of
# the potency.
func increase_operation(
	source_stats: CharacterStats,
	target_char: Character,
	stat_affected: Resource,
	resisted: bool
) -> int:
	return 0


# Descreases the value specified stat of the target character by the value of
# the potency.
func decrease_operation(
	source_stats: CharacterStats,
	target_char: Character,
	stat_affected: Resource,
	resisted: bool
) -> int:
	return 0


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


# Updates the value of the target character's stat.
func _set_target_stat_value(
	target_stats: CharacterStats,
	stat: Resource,
	value: int
) -> void:
	if stat is Stat:
		target_stats.update_modifier(stat.Type, value)
	elif stat is ElementalStat:
		target_stats.update_elemental_modifier(stat.Type, stat.Element, value)
	else:
		printerr("A non Stat or ElementalStat resource was provided.")


# Gets the value of the target character's stat.
func _get_target_stat_value(target_stats: CharacterStats, stat: Resource) -> int:
	if stat is Stat:
		return target_stats.get_calculated_stat(stat.Type)
	elif stat is ElementalStat:
		return target_stats.get_calculated_elemental_stat(stat.Type, stat.Element)
	else:
		printerr("A non Stat or ElementalStat resource was requested.")
		return 0


# Determines the raw potency values for a given character.
func _get_potency_values(character_stats: CharacterStats) -> Dictionary:
	var pv: Dictionary = character_stats.get_offensive()
	pv[Constants.ATTACK] *= action_potency.attack_potency
	for element in ElementalStat.Element:
		pv[Constants.MAGIC][element] *= (
				action_potency.get_elemental_potency(element)
		)
	return pv


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
