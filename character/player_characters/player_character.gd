class_name PlayerCharacter
extends Character
"""
Handles actions specific to player characters.
"""


var level: int = 1
# The current player class; determines stat adjusters and abilities.
#var player_class

# References to the various attacks and spells the character has access to.
onready var _techniques: Array = $Techniques.get_children() setget , get_techniques
onready var _spells: Array = $Spells.get_children() setget , get_spells


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Get the techniques associated with the character
func get_techniques() -> Array:
	return _techniques


# Get the spells associated with the character
func get_spells() -> Array:
	return _spells


# Returns the type of the character, PLAYER.
func get_type() -> int:
	return Constants.MapOccupants.PLAYER
