class_name Effect
extends Node
"""
Defines an effect of either an action or a status. Effects apply some kind of
modifier to a specified character stat.
"""


enum Modifier {INCREASE, DECREASE, SET}

export(Resource) var stat_affected = null
export(Modifier) var modifier = Modifier.INCREASE
export(Resource) var strength_calculation = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


# Applies the effect to the specified character.
func apply_effect_to_target(source: Character, target: Character) -> void:
	match modifier:
		Modifier.INCREASE:
			return
		Modifier.DECREASE:
			return
		Modifier.SET:
			return


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			stat_affected != null,
			ErrorUtil.missing_required_parameter(name, "stat_affected")
	)
	assert(
			stat_affected is Stat or stat_affected is ElementalStat,
			"Error: Effect %s stat_affected is neither a Stat or ElementalStat." % [name]
	)
	assert(
			strength_calculation != null,
			ErrorUtil.missing_required_parameter(name, "strength_calculation")
	)
	assert(
			strength_calculation is StrengthCalculation,
			(
				"Error: Effect %s strength_calculation is not a "
				+ "StrengthCalculation resource." % [name]
			)
	)
