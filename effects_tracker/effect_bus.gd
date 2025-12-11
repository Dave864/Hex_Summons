class_name EffectBus
extends Object
## Data structure used to keep track of effects and their durations.
##
## Provides logic to evaluate the result of the effects.


var _affected_stat: int
var _is_percentage_calc: bool
var _is_set_op: bool
var _effect_bus: Dictionary = {}


## Called when an instance of this object is created.
func _init(affected_stat: int, is_percentage_calc: bool, is_set_op: bool):
	_affected_stat = affected_stat
	_is_percentage_calc = is_percentage_calc
	_is_set_op = is_set_op


## Looks at all aspects of an effect and adds aspects to the end of the bus if 
## they target the affected stat. Updates prior instances of the same effect aspect.
func add_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	for aspect in effect.get_aspects():
		if (
			aspect.stat_affected != _affected_stat
			or (
				_is_percentage_calc
				and not aspect.calculation_method is PercentageCalculation
			)
			or (
				!_is_percentage_calc
				and aspect.calculation_method is PercentageCalculation
			)
			or (
				_is_set_op and aspect.operation != Stat.Operation.SET
			)
			or (
				!_is_set_op and aspect.operation == Stat.Operation.SET
			)
		):
			continue
		aspect.update_current_stats()
		# Stores effect and current turn duration.
		_effect_bus[effect_id] = [aspect, 0]


## Removes the effect from the bus if it exists.
func remove_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	_effect_bus.erase(effect_id)


## Removes all effects from the bus.
func clear() -> void:
	for id in _effect_bus.keys():
		_effect_bus.erase(id)


## Updates the duration for all effects in the bus. Removes effects whose duration
## have expired.
func progress_duration(turn_step: int = 1) -> void:
	for id in _effect_bus.keys():
		_effect_bus[id][1] += turn_step
		if _effect_bus[id][0].turn_duration <= _effect_bus[id][1]:
			_effect_bus.erase(id)


## Determines the amount the affected stat changes after applying effects with a
## turn count of 0. Uses the provided character stats as reference. Removes
## immediate effects from the bus. Does not update the character stats.
func process_immediate_effects(char_stats: PlayerStatModifiers) -> int:
	var change_amt: int = 0
	for id in _effect_bus.keys():
		var effect: EffectAspect = _effect_bus[id][0]
		if effect.turn_duration == 0:
			change_amt += effect.effect_on_target(char_stats)
			_effect_bus.erase(id)
	return change_amt


## Determines the amount the affected stat changes after applying all of
## the effects. Uses the provided character stats as reference. Does not
## update the character stats.
func process_all_effects(char_stats: PlayerStatModifiers) -> int:
	var change_amt: int = 0
	for id in _effect_bus.keys():
		change_amt += _effect_bus[id][0].effect_on_target(char_stats)
	return change_amt


## Returns the current number of effects in the bus.
func size() -> int:
	return _effect_bus.size()
