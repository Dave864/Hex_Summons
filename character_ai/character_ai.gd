class_name CharacterAI
extends Object
"""
Object that determines the actions a character should take given the current
state of the encounter. Requires references to all characters, the HexMap, and
the actions available.
"""


var _character: Character = null
# This variable should be of type HexMap. Defining the type here results in
# an issue where the class "HexMap" could be found in global scope, but the
# script couldn't be loaded.
var _h_map = null
var _d_map: Dictionary = {}
var _players: Array = []
var _enemies: Array = []
var _threat_tracker: ThreatTracker = null


# Regenerates the distance map for the character's current position.
func update_distance_map() -> void:
	var char_index: int = _character.map_coordinate.get_index()
	_d_map = _h_map.range_finder.get_distance_map(char_index, true)


# Determines the actions that need to be taken for the character based on the
# current state of the map.
func determine_action_chain() -> Array:
	return []


# Initializes the object.
func _init(
	h_map,
	character: Character,
	players: Array,
	enemies: Array
) -> void:
	_h_map = h_map
	_character = character
	_players = players
	_enemies = enemies
	_threat_tracker = ThreatTracker.new(
			_character.get_instance_id(),
			_players,
			_enemies
	)
