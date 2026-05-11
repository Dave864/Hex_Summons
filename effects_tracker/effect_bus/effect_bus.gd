@abstract
class_name EffectBus
extends Object
## Data structure used to keep track of effects and their durations.
##
## Provides logic to evaluate the result of the effects.


## The stat that is impacted by the tracked effects.
var _affected_stat: Stat.Type
## Tracks the effects and their turn duration.
var _effect_bus: Dictionary[int, EntryData] = {}


## Called when an instance of this object is created.
func _init(affected_stat: Stat.Type):
	_affected_stat = affected_stat


## Adds the action effect to the bus if it targets the tracked stat and is of
## the same operation type. Updates prior instances of the same effect.
func add_effect(effect: ActionEffect) -> void:
	if (
		effect.stat_affected != _affected_stat
		or not _is_tracked_strength_calculation(effect)
	):
		return
	var effect_id: int = effect.get_instance_id()
	effect.update_stats_snapshot()
	# Stores effect and current turn duration.
	_effect_bus[effect_id] = EntryData.new(effect)


## Removes the effect from the bus if it exists.
func remove_effect(effect: ActionEffect) -> void:
	var effect_id: int = effect.get_instance_id()
	_effect_bus.erase(effect_id)


## Removes all effects from the bus.
func clear() -> void:
	for id in _effect_bus.keys():
		_effect_bus.erase(id)


## Updates the duration for all effects in the bus. Removes effects whose duration
## have expired.
func progress_duration(turn_step: int = 1) -> void:
	var active_count: int = 0
	for id in _effect_bus.keys():
		_effect_bus[id].turn_active_count += turn_step
		active_count = _effect_bus[id].turn_active_count
		if _effect_bus[id].effect.turn_duration <= active_count:
			_effect_bus.erase(id)


## Determines the amount the affected stat changes after applying effects with a
## turn count of 0. Uses the provided character stats as reference. Removes
## immediate effects from the bus. Does not update the character stats.
func process_immediate_effects(char_stats: CharacterStatModifiers) -> int:
	var change_amt: int = 0
	for id: int in _effect_bus.keys():
		var effect: ActionEffectSnapshot = _effect_bus[id].effect
		if effect.turn_duration == 0:
			change_amt += effect.effect_on_target(char_stats)
			_effect_bus.erase(id)
	return change_amt


## Determines the amount the affected stat changes after applying all of
## the effects. Uses the provided character stats as reference. Does not
## update the character stats.
func process_all_effects(char_stats: CharacterStatModifiers) -> int:
	var change_amt: int = 0
	for id: int in _effect_bus.keys():
		change_amt += _effect_bus[id].effect.effect_on_target(char_stats)
	return change_amt


## Returns the current number of effects in the bus.
func size() -> int:
	return _effect_bus.size()


## Virtual function. Checks if the effect matches the bus's tracked strength
## calculation.
@abstract func _is_tracked_strength_calculation(effect: ActionEffect) -> bool


## Describes the specific details stored in a single entry in the bus.
class EntryData:
	## Reference to the ActionEffect node.
	var effect: ActionEffectSnapshot = null
	## The number of turns the effect has been active for.
	var turn_active_count: int = 0
	
	
	## Creates a new instance of EntryData, tracking the given ActionEffect.
	func _init(new_effect: ActionEffect) -> void:
		effect = ActionEffectSnapshot.new(new_effect)
		turn_active_count = 0
