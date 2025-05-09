class_name PlayerCharacter
extends Character
"""
Handles actions specific to player characters.
"""


# Indicates that the selector needs to be activated again.
# warning-ignore:unused_signal
signal selector_required(initial_position)

# The current player class; determines stat adjusters and abilities.
var _player_class: PlayerClass
# References to the various attacks and spells the character has access to.
var _techniques: Array
var _spells: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	TODO: Implement logic for loading the details of the currently set player class
	from data outside of encounter scene.
	"""
	_player_class = $Class
	_techniques = _player_class.techniques
	_spells = _player_class.spells
	stats = _player_class.stats


# Get the techniques associated with the character
func get_techniques() -> Array:
	return _techniques


# Get the spells associated with the character
func get_spells() -> Array:
	return _spells


# Returns the type of the character, PLAYER.
func get_type() -> int:
	return Constants.MapOccupants.PLAYER


# Emits the 'selector_required' signal.
func emit_selector_required(initial_position: Vector3) -> void:
	emit_signal("selector_required", initial_position)


# Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	for technique in _techniques:
		technique.set_emission_map_index(_index)
	for spell in _spells:
		spell.set_emission_map_index(_index)
