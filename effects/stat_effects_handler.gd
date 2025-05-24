class_name StatEffectsHandler
extends Object
"""
Collection of EffectBuses that hold all of the effects that are applied to a given
stat. Contains separate buses for effects that set values, effects that change by
a flat amount, and effects that change by a percentage amount.
"""


var _affected_stat: Resource
var _setter_bus: EffectBus
var _flat_change_bus: EffectBus
var _percentage_change_bus: EffectBus


# Called when an instance of this object is created.
func _init(affected_stat: Resource):
	assert(
			affected_stat is Stat or affected_stat is ElementalStat,
			"Error: Attempting to create a StatEffectHandler for a non stat resource."
	)
	_affected_stat = affected_stat
	_setter_bus = EffectBus.new(affected_stat)
	_flat_change_bus = EffectBus.new(affected_stat)
	_percentage_change_bus = EffectBus.new(affected_stat)


# Updates the duration for all effects.
func progress_duration(turn_count: int = 1) -> void:
	_setter_bus.progress_duration(turn_count)
	_flat_change_bus.progress_duration(turn_count)
	_percentage_change_bus.progress_duration(turn_count)


# Determines the final value of the affected stat after applying all of the effects.
# Uses the provided character stats as reference. Character stats are updated.
func process_effects(character_stats: CharacterStats) -> void:
	var final_value: int = _setter_bus.process_last_effect(character_stats)
