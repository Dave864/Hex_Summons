class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# Indicates that the action chain for an enemy character needs to be determined.
# warning-ignore:unused_signal
signal enemy_actions_required()

# Contains the actions associated with the enemy character.
var _actions: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
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


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var stats_path: String = "Stats"
	var actions_path: String = "Actions"
	assert(
			get_node_or_null(stats_path) != null,
			"EnemyCharacter does not have a Stats node."
	)
	assert(
			get_node(stats_path) is CharacterStats,
			"EnemyCharacter Stats node is not of CharacterStats."
	)
	assert(
			get_node_or_null(actions_path) != null,
			"EnemyCharacter does not have an Action node."
	)
