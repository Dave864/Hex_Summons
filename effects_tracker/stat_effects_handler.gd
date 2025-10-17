class_name StatEffectsHandler
extends EffectsHandler
"""
Tracks the effects that modify the specified stat. This is used for attack,
defense, agility, magic, and resistance which follow the same rules for being changed.
These stats can be raised or lowered by a flat amount or by a percentage. Flat
changes are all applied first. The total percentage changes are applied after
the flat values.
"""


# Represents the stats that can be managed.
enum stat {
	ATTACK,
	DEFENSE,
	AGILITY,
	MAGIC_EARTH,
	MAGIC_FIRE,
	MAGIC_WATER,
	MAGIC_WIND,
	MAGIC_LIGHT,
	MAGIC_DARK,
	RES_EARTH,
	RES_FIRE,
	RES_WATER,
	RES_WIND,
	RES_LIGHT,
	RES_DARK,
}

# Maps the stat to the respective enum value in the Stat resource.
var _global_reference: Dictionary = {
	stat.ATTACK: Stat.Type.ATTACK,
	stat.DEFENSE: Stat.Type.DEFENSE,
	stat.AGILITY: Stat.Type.AGILITY,
	stat.MAGIC_EARTH: Stat.Type.MAGIC_EARTH,
	stat.MAGIC_FIRE: Stat.Type.MAGIC_FIRE,
	stat.MAGIC_WATER: Stat.Type.MAGIC_WATER,
	stat.MAGIC_WIND: Stat.Type.MAGIC_WIND,
	stat.MAGIC_LIGHT: Stat.Type.MAGIC_LIGHT,
	stat.MAGIC_DARK: Stat.Type.MAGIC_DARK,
	stat.RES_EARTH: Stat.Type.RES_EARTH,
	stat.RES_FIRE: Stat.Type.RES_FIRE,
	stat.RES_WATER: Stat.Type.RES_WATER,
	stat.RES_WIND: Stat.Type.RES_WIND,
	stat.RES_LIGHT: Stat.Type.RES_LIGHT,
	stat.RES_DARK: Stat.Type.RES_DARK,
}

# The stat that is represented.
@export var target_stat: stat = stat.ATTACK

# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percent_change_bus: EffectBus


# Updates the duration for all effects.
func progress_duration(turn_step: int = 1) -> void:
	_flat_change_bus.progress_duration(turn_step)
	_percent_change_bus.progress_duration(turn_step)


# Determines the final value of the affected stat after applying all of
# the effects. Character stats are updated.
func process_effects() -> void:
	# Remove modifier to prevent stat effects from accumulating.
	_c_stats.update_modifier(_global_reference[target_stat], 0)
	var f_change: int = _flat_change_bus.process_immediate_effects(_c_stats)
	_c_stats.update_modifier(_global_reference[target_stat], f_change)
	var p_change: int = _percent_change_bus.process_immediate_effects(_c_stats)
	_c_stats.update_modifier(_global_reference[target_stat], f_change + p_change)


# Adds relevant effects to this handler.
func apply_effects(effects: Array, _caster_id: int, _target_id: int) -> void:
	for effect in effects:
		_flat_change_bus.add_effect(effect)
		_percent_change_bus.add_effect(effect)
	process_effects()


# Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(_global_reference[target_stat], false, false)
	_percent_change_bus = EffectBus.new(_global_reference[target_stat], true, false)
