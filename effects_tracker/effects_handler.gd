class_name EffectsHandler
extends Node
"""
Base class for handler that tracks the effects that are currently active on
a character.
"""


var _c_stats: CharacterStats = null setget set_character_stats


# Sets the reference to the character stats.
func set_character_stats(c_stats: CharacterStats) -> void:
	_c_stats = c_stats


# Virtual function. Updates the duration for all effects.
func progress_duration(_turn_step: int = 1) -> void:
	pass


# Virtual function. Applies the effects currently active on the character.
func process_effects() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Virtual function. Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	pass
