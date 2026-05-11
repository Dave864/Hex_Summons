class_name ActionEffectSnapshot
extends Object
## A copy of the details stored by an ActionEffect.


## The target of this effect.
var target: ActionEffect.Target
## The stat impacted by this effect.
var stat_affected: Stat.Type = Stat.Type.CUR_HEALTH
## How the targeted stat is modified.
var operation: Stat.Operation = Stat.Operation.SET
## Indicates how resistance will impact this effect.
var resistance_effect: ActionEffect.ResEffect
## The maximum number of turns this effect can last after application.
var max_turn_duration: int

## How many turns does this effect last after application when adjusted for
## resistances.
var turn_duration: int
## The id of the character that cast this action.
var caster_id: int
## The type of the character that cast this action.
var caster_type: Character.Type

## The method that determines the strength of this effect.
var _calculation_method: StrengthCalculation
## A recording of the values of the character stats.
var _stats_snapshot: AllStats
## The potency of the action the parent effect is assigned to.
var _action_potency: Potency


## Creates a snapshot from the ActionEffect.
func _init(original_effect: ActionEffect) -> void:
	target = original_effect.target
	stat_affected = original_effect.stat_affected
	operation = original_effect.operation
	resistance_effect = original_effect.resistance_effect
	max_turn_duration = original_effect.max_turn_duration
	caster_id = original_effect.caster_id
	caster_type = original_effect.caster_type
	_calculation_method = original_effect._calculation_method
	_stats_snapshot = original_effect._stats_snapshot
	_action_potency = original_effect._action_potency


## Determines the numerical result of the effect on the stat of the target.
func effect_on_target(target_stats: StatModifiers) -> int:
	var base_str: float = _calculation_method.base_strength(
			_stats_snapshot,
			_action_potency
	)
	var efficacy: float = _calculation_method.efficacy(
			_stats_snapshot,
			target_stats,
			_action_potency
	)
	turn_duration = (
		int(round(max_turn_duration * efficacy))
		if resistance_effect == ActionEffect.ResEffect.DURATION 
		else max_turn_duration
	)
	# Efficacy is used for both strength and duration resistance, so needs to
	# be set to 1.0 when strength is not resisted.
	efficacy = efficacy if resistance_effect == ActionEffect.ResEffect.STRENGTH else 1.0
	return _calculation_method.process_operation(
			base_str,
			efficacy,
			stat_affected,
			operation
	)
