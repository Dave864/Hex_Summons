class_name EffectAspect
extends Node
"""
Defines an aspect of an effect. This applies some kind of modifier to a
specified character stat.
"""


# The stat of the target that is affected by this effect.
export(Resource) var stat_affected = null
# How the targeted stat is modified.
export(Constants.Operation) var operation = Constants.Operation.SET
# The method that determines the strength of this effect.
export(Resource) var strength_calculation = null
# Flag that indicates if this effect is resisted by the target
export(bool) var resisted = true
# How many turns does this effect last after application. A value of zero means
# the effect is applied immediately.
export(int, 0, 100) var turn_duration = 0

# The stats of the character that will apply this effect.
var _source_stats: CharacterStats = null setget set_source_stats


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	strength_calculation.check_for_required_resources()


# Updates the source character stats of this effect.
func set_source_stats(new_source: CharacterStats) -> void:
	_source_stats = new_source


# Determines the numerical result of the effect on a target set of character stats.
func effect_on_target(target_stats: CharacterStats) -> int:
	return strength_calculation.process_operation(
			_source_stats,
			target_stats,
			stat_affected,
			resisted,
			operation
	)


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
			"Error: Effect %s strength_calculation is not a StrengthCalculation resource." % [name]
	)
