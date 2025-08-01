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

var _char_id: int = -1
# This variable should be of type HexMap. Defining the type here results in
# an issue where the class "HexMap" could be found in global scope, but the
# script couldn't be loaded.
var _h_map = null
var _d_map: Dictionary = {}
var _players: Dictionary = {}
var _enemies: Dictionary = {}
var _threat_tracker: ThreatTracker = null


# Regenerates the distance map for the character's current position.
func update_distance_map() -> void:
	var char_index: int = _enemies[_char_id].map_coordinate.get_index()
	if !_d_map.has(char_index) or _d_map[char_index]["travel"] > 0:
		_d_map = _h_map.range_finder.get_distance_map(char_index, true)


# Determines the actions that need to be taken for the character based on the
# current state of the map.
func determine_action_chain() -> Array:
	"""
	TODO: Implement logic for determining what actions to take.
	For now, the enemy character moves as close as it can to the closest player
	character.
	"""
	var action_chain: Array = []
	var movement_range: Array = _h_map.range_finder.get_character_travesible_tiles(
			_enemies[_char_id],
			_players.values()
	)
	var path: PoolVector3Array = _h_map.range_finder.get_character_point_path_toward(
			_enemies[_char_id],
			_determine_closest_player_index(),
			_enemies.values(),
			_players.values(),
			movement_range
	)
	action_chain.push_front([MOVE, path])
	return action_chain


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
	_threat_tracker = ThreatTracker.new(
			_char_id,
			players,
			enemies
	)


# Gets the map index of the player character closest to the active enemy.
func _determine_closest_player_index() -> int:
	var player_distances: Array = []
	for p in _players.values():
		var travel_dist: float = _d_map[p.map_coordinate.get_index()]["travel"]
		player_distances.append([p, travel_dist])
	player_distances.sort_custom(ArraySorters, "sort_distance_to_character_asc")
	return player_distances[0][0].map_coordinate.get_index()
