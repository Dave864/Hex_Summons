class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# AStar object used to determine ranges and paths for various commands
#var hm_astar: HexMapAStar = null


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
