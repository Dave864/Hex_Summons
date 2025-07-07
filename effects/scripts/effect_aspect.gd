class_name EffectAspect
extends Node
"""
Defines an aspect of an effect. This applies some kind of modifier to a
specified character stat.
"""


# Describes what changes when resistance is applied.
enum ResEffect {
	STRENGTH,
	DURATION,
}

# The stat of the target that is affected by this effect.
export(Resource) var stat_affected = null
# How the targeted stat is modified.
export(Constants.Operation) var operation = Constants.Operation.SET
# The method that determines the strength of this effect.
export(Resource) var calculation_method = null
# Flag that indicates if this effect is resisted by the target
export(bool) var resisted = true
# Indicates if resistance affects aspect strength or duration.
export(ResEffect) var resistance_effect = ResEffect.STRENGTH
# The maximum number of turns this effect can last afier application. A value
# of zero means the effect is applied immediately.
export(int, 0, 100) var max_turn_duration = 0

# How many turns does this effect last after application when adjusted for
# resistances.
var turn_duration: int = max_turn_duration

# The stats of the character that will apply this effect.
var _source_stats: CharacterStats = null setget set_source_stats
# The current values of the character stats.
var _current_stats: Dictionary = {}
# The potency of the action the parent effect is assigned to.
var _action_potency: Potency = null setget set_action_potency


# Updates the source character stats of this effect aspect.
func set_source_stats(new_source: CharacterStats) -> void:
	_source_stats = new_source
	update_current_stats()


# Updates the action potency data.
func set_action_potency(new_potency: Potency) -> void:
	_action_potency = new_potency


# Gets the current values of the source stats.
func update_current_stats() -> void:
	_current_stats = _source_stats.get_all()


# Determines the numerical result of the effect on a target set of character stats.
func effect_on_target(target_stats: CharacterStats) -> int:
	var b_str: float = calculation_method.base_strength(
			_current_stats,
			_action_potency
	)
	var eff: float = 1.0
	if resisted:
		eff = calculation_method.efficacy(
				_current_stats,
				target_stats,
				_action_potency
		)
	match resistance_effect:
		ResEffect.DURATION:
			turn_duration = int(round(max_turn_duration * eff))
			return int(b_str)
		ResEffect.STRENGTH:
			turn_duration = max_turn_duration
			return calculation_method.process_operation(
					b_str,
					eff,
					stat_affected,
					operation
			)
		_:
			turn_duration = max_turn_duration
			return 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	calculation_method.check_for_required_resources()


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			stat_affected != null,
			ErrorUtil.missing_required_parameter(name, "stat_affected")
	)
	assert(
			stat_affected is Stat,
			"Error: Effect %s stat_affected is not a Stat." % [name]
	)
	assert(
			calculation_method != null,
			ErrorUtil.missing_required_parameter(name, "strength_calculation")
	)
	assert(
			calculation_method is StrengthCalculation,
			"Error: Effect %s strength_calculation is not a StrengthCalculation resource." % [name]
	)
