class_name EffectBus
extends Object
"""
Data structure used to keep track of effects and their durations. Provides logic
to evaluate the result of the effects.
"""


var _affected_stat: Resource
var _effect_bus: Dictionary = {}
var _bus_end: int


# Called when the node enters the scene tree for the first time.
func _init(affected_stat: Resource):
	assert(
			affected_stat is Stat or affected_stat is ElementalStat,
			"Error: Attempting to create an EffectBus for a non stat resource."
	)
	_affected_stat = affected_stat
	_bus_end = -1


# Adds a new effect to the end of the bus. Updates prior instances of the same
# effect object.
func add_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	# Stores effect and current turn duration.
	_effect_bus[effect_id] = [effect, 0]
	_bus_end = effect_id


# Removes the effect from the bus if it exists.
func remove_effect(effect: Effect) -> void:
	var effect_id: int = effect.get_instance_id()
	_effect_bus.erase(effect_id)
	if effect_id == _bus_end:
		_update_bus_end()


# Updates the duration for all effects in the bus. Removes effects whose duration
# have expired.
func progress_duration(turn_count: int = 1) -> void:
	for id in _effect_bus.keys():
		_effect_bus[id][1] += turn_count
		if _effect_bus[id][0].turn_duration <= _effect_bus[id][1]:
			_effect_bus.erase(id)
			_update_bus_end()


# Determines the final value of the affected stat after applying all of the effects.
# Uses the provided character stats as reference. Does not update the character stats.
func process_effects(base_stats: CharacterStats) -> int:
	var final_stat_value: int = -1
	for id in _effect_bus.keys():
		final_stat_value += _effect_bus[_bus_end][0].effect_on_target(base_stats)
	if _effect_bus.keys().size() > 0:
		# Stats should never go below zero.
		final_stat_value = convert(
				clamp(final_stat_value, 0.0, final_stat_value),
				TYPE_INT
		)
	return final_stat_value


# Determines the final value of the affected stat using only the most recent effect.
# Uses the provided character stats as reference. Does not update the character stats.
func process_last_effect(base_stats: CharacterStats) -> int:
	var final_stat_value: int = -1
	if _effect_bus.keys().size() > 0:
		final_stat_value = _effect_bus[_bus_end][0].effect_on_target(base_stats)
		# Stats should never go below zero.
		final_stat_value = convert(
				clamp(final_stat_value, 0.0, final_stat_value),
				TYPE_INT
		)
	return final_stat_value


# Updates the id of the end of the effect bus.
func _update_bus_end() -> void:
	var keys: Array = _effect_bus.keys()
	_bus_end = -1 if keys.size() == 0 else keys.back()
