class_name EffectBus
extends Object
"""
Data structure used to keep track of effects and their durations. Provides logic
to evaluate the result of the effects.
"""


var _affected_stat: int
var _effect_bus: Dictionary = {}


# Called when an instance of this object is created.
func _init(affected_stat: int):
	_affected_stat = affected_stat


# Adds a new effect to the end of the bus if it targets the affected stat.
# Updates prior instances of the same effect object.
func add_effect(effect: Effect) -> void:
	if effect.stat_affected != _affected_stat:
		return
	var effect_id: int = effect.get_instance_id()
	# Stores effect and current turn duration.
	_effect_bus[effect_id] = [effect, 0]


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


# Determines the final value of the affected stat after applying all of the effects.
# Uses the provided character stats as reference. Does not update the character stats.
func process_effects(char_stats: CharacterStats) -> int:
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
