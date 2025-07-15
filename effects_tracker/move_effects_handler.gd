class_name MoveEffectsHandler
extends EffectsHandler
"""
Tracks the effects that modify the movement stat. Movement can be changed or set.
Setting the value overrides all other changes. There should only be one effect,
"Ensnare", that sets the movement to a specific value.
"""


# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percent_change_bus: EffectBus
var _set_change_bus: EffectBus


# Updates the duration for all effects.
func progress_duration(turn_step: int = 1) -> void:
	_flat_change_bus.progress_duration(turn_step)
	_percent_change_bus.progress_duration(turn_step)
	_set_change_bus.progress_duration(turn_step)


# Determines the final value of movement after applying all of
# the effects. Character stats are updated.
func process_effects() -> void:
	var mod: int = 0
	_c_stats.update_modifier(Stat.Type.MOVEMENT, 0)
	if _set_change_bus.size() > 0:
		mod = _set_change_bus.process_all_effects(_c_stats)
	else:
		var f_change: int = _flat_change_bus.process_all_effects(_c_stats)
		_c_stats.update_modifier(Stat.Type.MOVEMENT, f_change)
		var p_change: int = _percent_change_bus.process_all_effects(_c_stats)
		mod = f_change + p_change
	_c_stats.update_modifier(Stat.Type.MOVEMENT, mod)


# Adds movement changing effects to this handler.
func apply_effects(effects: Array) -> void:
	for effect in effects:
		_flat_change_bus.add_effect(effect)
		_percent_change_bus.add_effect(effect)
		_set_change_bus.add_effect(effect)
	process_effects()


# Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(Stat.Type.MOVEMENT, false, false)
	_percent_change_bus = EffectBus.new(Stat.Type.MOVEMENT, true, false)
	_set_change_bus = EffectBus.new(Stat.Type.MOVEMENT, false, true)
