class_name HealthEffectsHandler
extends Node
"""
Tracks the effects that modify the health stat. Health can be immediately changed
or changed over time.
"""


export(NodePath) var character_stat_ref = null

var _c_stats: CharacterStats = null
# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percent_change_bus: EffectBus


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_c_stats = get_node(character_stat_ref)
	_flat_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH, false, false)
	# Percent changes to health are with respect to max health, not current
	# value of health.
	_percent_change_bus = EffectBus.new(Stat.Type.MAX_HEALTH, true, false)


# Connects the effects of an action to this manager.
func _on_HitBox_area_entered(hit_box: ActionHitBox) -> void:
	print("health affected")
	var effects: Array = hit_box.get_effects()
	for effect in effects:
		_flat_change_bus.add_effect(effect)
		_percent_change_bus.add_effect(effect)
	var f_change: float = _flat_change_bus.process_immediate_effects(_c_stats)
	var p_change: float = _percent_change_bus.process_immediate_effects(_c_stats)
	_c_stats.set_cur_health(int(f_change + p_change))


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(character_stat_ref != null, "No reference to character stats provided.")
