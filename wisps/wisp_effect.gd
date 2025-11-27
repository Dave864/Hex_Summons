class_name WispEffect
extends Resource
## Defines a bonus effect a wisp has.
##
## This applies some of modifier to a specified character stat.


## The stat of the target that is affected by this effect.
@export var stat_affected: Resource = null
## How the targeted stat is modified.
@export var operation = Constants.Operation.SET # (Constants.Operation)
## The method that determines the strength of this effect. Should either be
## a flat_value_calculation or percentage_calculation.
@export var calculation_method: Resource = null


## Determines the numerical result of this effect on a target set of character stats.
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
