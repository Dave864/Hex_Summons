class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# Contains the actions associated with the enemy character.
var _actions: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $Stats
	stats.max_cur_health()
	_actions = $Actions.get_children()


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY


# Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	for action in _actions:
		action.set_emission_map_index(_index)
