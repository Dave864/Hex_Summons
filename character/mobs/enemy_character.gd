class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $Stats


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY
