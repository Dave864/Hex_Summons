class_name StatEffectsHandler
extends EffectsHandler
## Tracks the effects that modify the specified stat. This is used for attack,
## defense, agility, magic, and resistance which follow the same rules for being
## changed.
##
## These stats can be raised or lowered by a flat amount or by a percentage. Flat
## changes are all applied first. The total percentage changes are applied after
## the flat values.


## Represents the stats that can be managed by this handler. Does not include
## cur_health, max_health, or movement as those are managed by other handlers.
enum RelevantStat {
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

## Maps the RelevantStat value to the corresponding Stat.Type enum.
var _global_reference: Dictionary[RelevantStat, Stat.Type] = {
	RelevantStat.ATTACK: Stat.Type.ATTACK,
	RelevantStat.DEFENSE: Stat.Type.DEFENSE,
	RelevantStat.AGILITY: Stat.Type.AGILITY,
	RelevantStat.MAGIC_EARTH: Stat.Type.MAGIC_EARTH,
	RelevantStat.MAGIC_FIRE: Stat.Type.MAGIC_FIRE,
	RelevantStat.MAGIC_WATER: Stat.Type.MAGIC_WATER,
	RelevantStat.MAGIC_WIND: Stat.Type.MAGIC_WIND,
	RelevantStat.MAGIC_LIGHT: Stat.Type.MAGIC_LIGHT,
	RelevantStat.MAGIC_DARK: Stat.Type.MAGIC_DARK,
	RelevantStat.RES_EARTH: Stat.Type.RES_EARTH,
	RelevantStat.RES_FIRE: Stat.Type.RES_FIRE,
	RelevantStat.RES_WATER: Stat.Type.RES_WATER,
	RelevantStat.RES_WIND: Stat.Type.RES_WIND,
	RelevantStat.RES_LIGHT: Stat.Type.RES_LIGHT,
	RelevantStat.RES_DARK: Stat.Type.RES_DARK,
}

## The stat that is represented.
@export var target_stat: RelevantStat = RelevantStat.ATTACK

## Bus that keeps track of the flat change effects that affect the managed stat.
var _flat_change_bus: EffectBus
## Bus that keeps track of the percentage change effects that affect the
## managed stat.
var _percent_change_bus: EffectBus


## Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(
			_global_reference[target_stat],
			false,
			false
	)
	_percent_change_bus = EffectBus.new(
			_global_reference[target_stat],
			true,
			false
	)


## Updates the duration for all effects.
func progress_duration(turn_step: int = 1) -> void:
	_flat_change_bus.progress_duration(turn_step)
	_percent_change_bus.progress_duration(turn_step)


## Determines the final value of the affected stat after applying all of
## the effects. Character stats are updated.
func process_effects() -> void:
	# Remove modifier to prevent stat effects from accumulating.
	_c_stats.update_modifier(_global_reference[target_stat], 0)
	var f_change: int = _flat_change_bus.process_immediate_effects(_c_stats)
	_c_stats.update_modifier(_global_reference[target_stat], f_change)
	var p_change: int = _percent_change_bus.process_immediate_effects(_c_stats)
	_c_stats.update_modifier(_global_reference[target_stat], f_change + p_change)


## Adds relevant effects to this handler.
func apply_effects(effects: Array[Effect], _caster_id: int) -> void:
	for effect: Effect in effects:
		_flat_change_bus.add_effect(effect)
		_percent_change_bus.add_effect(effect)
	process_effects()
