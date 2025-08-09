class_name CharacterAI
extends Node
"""
Node that determines the actions a character should take given the current
state of the encounter. Requires references to all characters, the HexMap, and
the actions available.
"""


# Names of the different actions an enemy can take. Matches the corresponding
# state name in EnemyCharacterState. Declared here because referencing the
# constants directly from EnemyCharacterState results in a cyclic reference.
const ACTION: String = "Action"
const MOVE: String = "Move"

export(NodePath) var actions_ref = null

var _char_id: int = -1
var _actions: Array = []
# This variable should be of type HexMap. Defining the type here results in
# an issue where the class "HexMap" could be found in global scope, but the
# script couldn't be loaded.
var _h_map = null
var _d_map: Dictionary = {}
var _players: Dictionary = {}
var _enemies: Dictionary = {}
var _p_ttr: ThreatTracker = null
var _e_ttr: ThreatTracker = null


# Regenerates the distance map for the character's current position.
func update_distance_map() -> void:
	var char_index: int = _enemies[_char_id].map_coordinate.get_index()
	if !_d_map.has(char_index) or _d_map[char_index]["travel"] > 0:
		_d_map = _h_map.range_finder.get_distance_map(char_index, true)


# Determines the actions that need to be taken for the character based on the
# current state of the map.
func determine_action_chain() -> Array:
	# Go through each action and execute the first one that is available
	# with valid targets in range.
	var actionBehavior: ActionBehavior = null
	var targets: Array
	for action in _actions:
		actionBehavior = action.get_node_or_null("ActionBehavior")
		assert(
				actionBehavior != null,
				"Action {s} is missing an ActionBehavior node." \
				.format([action.name])
		)
		match actionBehavior.target_behavior:
			ActionBehavior.Target.ALLIES:
				targets = _enemies.values()
			ActionBehavior.Target.OPPONENTS:
				targets = _players.values()
			_:
				targets = []
			
		if !actionBehavior.conditions_met(_enemies[_char_id], targets, _d_map):
			continue
		var target_index: int = _determine_target_index(action)
		# Check if target is in range of action
		# Determine move path if action is in range
		# Determine orientation for action
	return _default_chain()


# Obtains the necessary references to run the AI logic.
func connect_encounter_details(
	h_map,
	char_id: int,
	players: Array,
	enemies: Array
) -> void:
	_h_map = h_map
	_char_id = char_id
	for p in players:
		_players[p.get_instance_id()] = p
	for e in enemies:
		_enemies[e.get_instance_id()] = e
	_p_ttr = ThreatTracker.new(_char_id, players)
	_e_ttr = ThreatTracker.new(_char_id, enemies)


func _ready() -> void:
	_check_for_required_parameters()
	_actions = get_node(actions_ref).get_children()


# Default behaviour. The character moves as close as it can to the closest
# target character with the highest threat.
func _default_chain() -> Array:
	var action_chain: Array = []
	var movement_range: Array = (
		_h_map.range_finder.get_character_travesible_tiles(
				_enemies[_char_id],
				_players.values()
		)
	)
	var target_ids: Array = _determine_player_threat_order()
	var target_index: int = _players[target_ids[0]].map_coordinate.get_index()
	var path: PoolVector3Array = (
		_h_map.range_finder.get_character_point_path_toward(
				_enemies[_char_id],
				target_index,
				_enemies.values(),
				_players.values(),
				movement_range
		)
	)
	action_chain.push_front([MOVE, path])
	return action_chain


# Determines the index of the tile the character will target.
func _determine_target_index(action: Action) -> int:
	var action_behavior: ActionBehavior = action.get_node("ActionBehavior")
	if action_behavior.target_group():
		pass
	var target_ids: Array = _determine_player_threat_order()
	return _players[target_ids[0]].map_coordinate.get_index()


# Gets the threat order of player characters.
func _determine_player_threat_order() -> Array:
	var danger_players: Array = _players.keys()
	danger_players.sort_custom(self, "_sort_player_danger")
	return danger_players


# Gets the threat order of enemy characters.
func _determine_enemy_threat_order() -> Array:
	var danger_enemies: Array = _enemies.keys()
	danger_enemies.sort_custom(self, "_sort_enemy_danger")
	return danger_enemies


# Sorts players by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the targets distance
# from the observer.
func _sort_player_danger(p_a: int, p_b: int) -> bool:
	var dis_a: float = _d_map[_players[p_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_players[p_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _p_ttr.get_threat_values()[p_a]["value"] / dis_a
	var threat_b: float = _p_ttr.get_threat_values()[p_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts enemies by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the targets distance
# from the observer.
func _sort_enemy_danger(e_a: int, e_b: int) -> bool:
	var dis_a: float = _d_map[_enemies[e_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_enemies[e_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _e_ttr.get_threat_values()[e_a]["value"] / dis_a
	var threat_b: float = _e_ttr.get_threat_values()[e_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts group centers by their distances from the character, closest ones being
# first.
func _sort_group_center(center_a: Vector3, center_b: Vector3) -> bool:
	var index_a: int = HexUtil.cube_to_index(center_a, _h_map.get_x_count())
	var index_b: int = HexUtil.cube_to_index(center_b, _h_map.get_x_count())
	return _d_map[index_a]["travel"] < _d_map[index_b]["travel"]


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			actions_ref != null,
			"EnemyAI Missing reference to actions."
	)
