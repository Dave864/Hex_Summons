class_name Effect
extends Node
"""
Defines an effect of either an action or a status. Effects apply some kind of
modifier to a specified character stat.
"""


enum Operation {INCREASE, DECREASE, SET}

# The stat of the target that is affected by this effect.
export(Resource) var stat_affected = null
# How the targeted stat is modified.
export(Operation) var operation = Operation.SET
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


# Applies the effect to the specified character.
func apply_effect_to_target(target_stats: CharacterStats) -> void:
	match operation:
		Operation.INCREASE:
			return
		Operation.DECREASE:
			return
		Operation.SET:
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
