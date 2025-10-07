class_name WispEffect
extends Resource
"""
Defines a bonus effect a wisp has. This applies some kind of modifier to
a specified character stat.
"""


# The stat of the target that is affected by this effect.
export(Resource) var stat_affected = null
# How the targeted stat is modified.
export(Constants.Operation) var operation = Constants.Operation.SET
# The method that determines the strength of this effect. Should either be
# a flat_value_calculation or percentage_calculation.
export(Resource) var calculation_method = null


# Determines the numerical result of this effect on a target set of character stats.
func effect_on_character(target_stats: CharacterStats) -> int:
	assert(
			(
				calculation_method is FlatValueCalcultion
				or calculation_method is PercentageCalculation
			),
			"WispEffect calculation_method is not FlatValueCalculation or PercentageCalculation"
	)
	return calculation_method.process_operation(
			target_stats.get_stat(Stat.Type.ATTACK),
			1.0,
			stat_affected.type,
			operation
	)
