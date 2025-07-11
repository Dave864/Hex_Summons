class_name EffectsTracker
extends Node
"""
Manages all of the effect handlers for a character. Receives Action hit box
collision data and passes it along to the relevant handlers.
"""


export(NodePath) var character_stat_ref = null

var _c_stats: CharacterStats = null


# Progress the duration of all effects in all handlers by the specified turn step.
func progress_duration(turn_step: int = 1) -> void:
	for e_handler in get_children():
		e_handler.progress_duration(turn_step)


# Process the effects on all handlers.
func process_effects() -> void:
	for e_handler in get_children():
		e_handler.process_effects()


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_c_stats = get_node(character_stat_ref)
	for e_handler in get_children():
		e_handler.set_character_stats(_c_stats)


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(character_stat_ref != null, "No reference to character stats provided.")


# Connects the effects of an action to this manager.
func _on_HitBox_area_entered(hit_box: ActionHitBox) -> void:
	var effects: Array = hit_box.get_effects()
	for e_handler in get_children():
		e_handler.apply_effects(effects)
