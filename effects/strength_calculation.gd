class_name StrengthCalculation
extends Resource
"""
Base class that is used to define the strength of an effect.
"""


export(Resource) var action_potency = null


# Determines the strength of the effect for a given character.
func calculate_effect_strength(
	source: Character,
	target: Character = null,
	resisted: bool = false
) -> float:
	var strength_values: Dictionary = _calculate_potency_values(source.stats)
	if resisted:
		var res_values: Dictionary = target.stats.get_defensive()
		_apply_resistance(strength_values, res_values)
	var total_strength: float = 0.0
	for v in strength_values.values():
		total_strength += v
	return total_strength


func check_for_required_resources() -> void:
	assert(
			action_potency != null,
			"Error: StrengthCalculation missing defined action_potency."
	)
	assert(
			action_potency is Potency,
			"Error: StrengthCalculation action_potency is not Potency resource."
	)


# Determines the raw potency values for a given character.
func _calculate_potency_values(character_stats: CharacterStats) -> Dictionary:
	var pv: Dictionary = character_stats.get_offensive()
	pv[Constants.ATTACK] *= action_potency.attack_potency
	pv[Constants.MAGIC][ElementalStat.Element.EARTH] *= (
			action_potency.get_elemental_potency(ElementalStat.Element.EARTH)
	)
	pv[Constants.MAGIC][ElementalStat.Element.FIRE]*= (
			action_potency.get_elemental_potency(ElementalStat.Element.FIRE)
	)
	pv[Constants.MAGIC][ElementalStat.Element.WATER]*= (
			action_potency.get_elemental_potency(ElementalStat.Element.WATER)
	)
	pv[Constants.MAGIC][ElementalStat.Element.WIND]*= (
			action_potency.get_elemental_potency(ElementalStat.Element.WIND)
	)
	return pv


# Applies resistance values to the strength.
func _apply_resistance(strength: Dictionary, resistance: Dictionary) -> void:
	strength[Constants.ATTACK] = _bind_resistance(
			strength[Constants.ATTACK],
			resistance[Constants.DEFENSE]
	)
	strength[Constants.MAGIC][ElementalStat.Element.EARTH] = _bind_resistance(
			strength[Constants.MAGIC][ElementalStat.Element.EARTH],
			resistance[Constants.RESISTANCE][ElementalStat.Element.EARTH]
	)
	strength[Constants.MAGIC][ElementalStat.Element.FIRE] = _bind_resistance(
			strength[Constants.MAGIC][ElementalStat.Element.FIRE],
			resistance[Constants.RESISTANCE][ElementalStat.Element.FIRE]
	)
	strength[Constants.MAGIC][ElementalStat.Element.WATER] = _bind_resistance(
			strength[Constants.MAGIC][ElementalStat.Element.WATER],
			resistance[Constants.RESISTANCE][ElementalStat.Element.WATER]
	)
	strength[Constants.MAGIC][ElementalStat.Element.WIND] = _bind_resistance(
			strength[Constants.MAGIC][ElementalStat.Element.WIND],
			resistance[Constants.RESISTANCE][ElementalStat.Element.WIND]
	)


# Calculates the result of resistance, binding the result to be no lower than zero.
func _bind_resistance(strength: float, resistance: float) -> float:
	return clamp(strength - resistance, 0.0, strength)
