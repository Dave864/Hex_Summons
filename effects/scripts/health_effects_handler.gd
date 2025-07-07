class_name HealthEffectsHandler
extends Node
"""
Tracks the effects that modify the health stat. Health can be immediately changed
or changed over time.
"""


export(NodePath) var character_stat_ref = null

var _character_stats: CharacterStats = null
# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percentage_change_bus: EffectBus


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_character_stats = get_node(character_stat_ref)
	_flat_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH, false, false)
	_percentage_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH, true, false)


# Connects the effects of an action to this manager.
func _on_HitBox_area_entered(hit_box: ActionHitBox) -> void:
	var effects: Array = hit_box.get_effects()
	for effect in effects:
		_flat_change_bus.add_effect(effect)
		_percentage_change_bus.add_effect(effect)


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(character_stat_ref != null, "No reference to character stats provided.")
