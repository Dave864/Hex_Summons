class_name PlayerCharacter
extends Character
"""
Handles actions specific to player characters.
"""


var level: int = 1
# The current player class; determines stat adjusters and abilities.
#var player_class


# Returns the type of the character, PLAYER.
func get_type() -> int:
	return Constants.MapOccupants.PLAYER


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
