class_name EffectBus
extends Object
"""
Data structure used to keep track of effects and their durations. Provides logic
to evaluate the result of the effects.
"""


var _affected_stat: int
var _is_percentage_calc: bool
var _is_set_op: bool
var _effect_bus: Dictionary = {}


# Looks at all aspects of an effect and adds aspects to the end of the bus if 
# they target the affected stat. Updates prior instances of the same effect aspect.
func add_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	for aspect in effect.get_aspects():
		if (
			aspect.stat_affected != _affected_stat
			or (
				_is_percentage_calc
				and not aspect.calclulation_method is PercentageCalculation
			)
			or (
				!_is_percentage_calc
				and aspect.calclulation_method is PercentageCalculation
			)
			or (
				_is_set_op and aspect.operation != Constants.Operation.SET
			)
			or (
				!_is_set_op and aspect.operation == Constants.Operation.SET
			)
		):
			continue
		# Stores effect and current turn duration.
		_effect_bus[effect_id] = [aspect, 0]


# Removes the effect from the bus if it exists.
func remove_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	_effect_bus.erase(effect_id)


# Removes all effects from the bus.
func clear() -> void:
	for id in _effect_bus.keys():
		_effect_bus.erase(id)


# Updates the duration for all effects in the bus. Removes effects whose duration
# have expired.
func progress_duration(turn_count: int = 1) -> void:
	for id in _effect_bus.keys():
		_effect_bus[id][1] += turn_count
		if _effect_bus[id][0].turn_duration <= _effect_bus[id][1]:
			_effect_bus.erase(id)


# Determines the final value of the affected stat after applying effects with a
# turn count of 0. Uses the provided character stats as reference. Does not
# update the character stats.
func process_immediate_effects(char_stats: CharacterStats) -> int:
	var final_stat_value: int = 0
	var check_final_value: bool = false
	for id in _effect_bus.keys():
		var effect: EffectAspect = _effect_bus[id][0]
		if effect.turn_duration == 0:
			check_final_value = true
			final_stat_value += effect.effect_on_target(char_stats)
	if check_final_value:
		# Stats should never go below zero.
		final_stat_value = convert(
				clamp(final_stat_value, 0.0, final_stat_value),
				TYPE_INT
		)
	return final_stat_value


# Determines the final value of the affected stat after applying all of
# the effects. Uses the provided character stats as reference. Does not
# update the character stats.
func process_all_effects(char_stats: CharacterStats) -> int:
	var final_stat_value: int = 0
	for id in _effect_bus.keys():
		final_stat_value += _effect_bus[id][0].effect_on_target(char_stats)
	if _effect_bus.keys().size() > 0:
		# Stats should never go below zero.
		final_stat_value = convert(
				clamp(final_stat_value, 0.0, final_stat_value),
				TYPE_INT
		)
	return final_stat_value


# Called when an instance of this object is created.
func _init(affected_stat: int, is_percentage_calc: bool, is_set_op: bool):
	_affected_stat = affected_stat
	_is_percentage_calc = is_percentage_calc
	_is_set_op = is_set_op
