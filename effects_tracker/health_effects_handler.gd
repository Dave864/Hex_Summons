class_name HealthEffectsHandler
extends EffectsHandler
## Tracks the effects that modify the health stat.
##
## Health can be immediately changed or changed over time.


## Bus that keeps track of the flat change effects that affect the managed stat.
var _flat_change_bus: EffectBus
## Bus that keeps track of the percentage change effects that affect the
## managed stat.
var _percent_change_bus: EffectBus


## Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH)
	# Percent changes to health are with respect to max health, not current
	# value of health.
	_percent_change_bus = EffectBus.new(Stat.Type.MAX_HEALTH)


## Virtual function. Updates the duration for all effects.
func progress_duration(turn_step: int = 1) -> void:
	_flat_change_bus.progress_duration(turn_step)
	_percent_change_bus.progress_duration(turn_step)


## Applies the effects currently active on the character.
func process_effects() -> void:
	var f_change: float = _flat_change_bus.process_all_effects(_c_stats)
	var p_change: float = _percent_change_bus.process_all_effects(_c_stats)
	_c_stats.set_cur_health(int(f_change + p_change))


## Adds health changing effects to this handler. Processes immediate effects
func apply_effects(
	effects: Array[ActionEffect],
	caster_id: int
) -> void:
	for effect: ActionEffect in effects:
		if effect is PercentActionEffect:
			_percent_change_bus.add_effect(effect)
		else:
			_flat_change_bus.add_effect(effect)
	var f_change: float = _flat_change_bus.process_immediate_effects(_c_stats)
	var p_change: float = _percent_change_bus.process_immediate_effects(_c_stats)
	_c_stats.set_cur_health(int(f_change + p_change))
	SignalBus.emit_health_changed(
			caster_id,
			_c_stats.character_id,
			f_change + p_change
	)
