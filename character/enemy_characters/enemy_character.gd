class_name EnemyCharacter
extends Character
## Handles actions specific to enemy characters.


## Indicates that the action chain for an enemy character needs to be determined.
signal enemy_actions_required()

## Contains the actions associated with the enemy character.
var _actions: Array[Action]

## The default image to use for an enemy character's battle sprite.
@onready var _default_portait: Texture2D = preload(
		"res://character/enemy_characters/EnemyCharacter/" + \
		"EnemyBattlePortrait.atlastex"
)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	battle_portrait = (
		_default_portait if battle_portrait == null
		else battle_portrait
	)
	stats = $Stats
	stats.character_id = get_instance_id()
	stats.character_type = Type.ENEMY
	stats.max_cur_health()
	_connect_stats_to_effects_tracker()
	_connect_to_character_label()
	for action: Action in $Actions.get_children():
		_actions.append(action)
	_initialize_actions()


## Returns the type of the character, ENEMY.
func get_type() -> Type:
	return Type.ENEMY


## Emit the signal 'enemy_actions_required'
func emit_enemy_actions_required() -> void:
	emit_signal("enemy_actions_required")


## Initializes the action effects.
func _initialize_actions() -> void:
	for a: Action in _actions:
		a.source_stats = stats


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var stats_path: String = "Stats"
	var actions_path: String = "Actions"
	assert(
			get_node_or_null(stats_path) != null,
			"EnemyCharacter does not have a Stats node."
	)
	assert(
			get_node(stats_path) is CharacterStatModifiers,
			"EnemyCharacter Stats node is not of CharacterStatModifiers."
	)
	assert(
			get_node_or_null(actions_path) != null,
			"EnemyCharacter does not have an Action node."
	)
