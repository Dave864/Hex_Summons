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
var _h_map: HexMap = null
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
	var character: EnemyCharacter = _enemies[_char_id]
	var ab: ActionBehavior = null
	var targets: Array
	for action in _actions:
		ab = action.get_node_or_null("ActionBehavior")
		assert(
				ab != null,
				"Action {s} is missing an ActionBehavior node." \
				.format([action.name])
		)
		match ab.target:
			ActionBehavior.Target.ALLIES:
				targets = _enemies.values()
			ActionBehavior.Target.OPPONENTS:
				targets = _players.values()
			_:
				targets = []
			
		if not ab.conditions_met(_enemies[_char_id], targets, _d_map):
			continue
		var target_index: int = _determine_target_index(ab)
		print(target_index)
		# Check if target is in range of action
		var movement: int = (
			0 if ab.movement_behavior == ActionBehavior.Movement.STAND
			else character.stats.get_movement_range() 
		)
		if not _action_in_range(
				action,
				target_index,
				character.map_coordinate.get_index(),
				movement
		):
			continue
		# Determine move path if action is in range
		# Determine orientation for action? Orientation could also be determined
		# in Action state
	return _default_chain()


# Obtains the necessary references to run the AI logic.
func connect_encounter_details(
	h_map: HexMap,
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
func _determine_target_index(ab: ActionBehavior) -> int:
	if ab.target_group():
		print("Find group target")
		return _group_target_index(ab.get_group_condition(), ab.target_focus)
	var target_ids: Array = _determine_player_threat_order()
	return _players[target_ids[0]].map_coordinate.get_index()


# Gets the target index based on a group condition.
func _group_target_index(gc: GroupCondition, target_focus: int) -> int:
	var groups: Dictionary = gc.find_group_index_centers(_h_map.get_x_count())
	match target_focus:
		ActionBehavior.TargetFocus.CLOSEST:
			var sorted_centers: Array = groups.keys()
			sorted_centers.sort_custom(self, "_sort_group_center_dist")
			return sorted_centers[0]
		ActionBehavior.TargetFocus.FARTHEST:
			var sorted_centers: Array = groups.keys()
			sorted_centers.sort_custom(self, "_sort_group_center_dist")
			return sorted_centers[-1]
		_:
			var sorted_centers: Array = []
			for center in groups.keys():
				sorted_centers.append([center, groups[center]])
			sorted_centers.sort_custom(self, "_sort_group_center_threat")
			return sorted_centers[0][0]


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


# Determines if the action is in range of the target.
func _action_in_range(
	action: Action,
	target: int,
	source: int,
	movement: int
) -> bool:
	# Process movement
	# Process action source range
	# Process action effecct range
	return false


# Sorts players by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_player_danger(p_a: int, p_b: int) -> bool:
	var dis_a: float = _d_map[_players[p_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_players[p_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _p_ttr.get_threat_values()[p_a]["value"] / dis_a
	var threat_b: float = _p_ttr.get_threat_values()[p_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts enemies by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_enemy_danger(e_a: int, e_b: int) -> bool:
	var dis_a: float = _d_map[_enemies[e_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_enemies[e_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _e_ttr.get_threat_values()[e_a]["value"] / dis_a
	var threat_b: float = _e_ttr.get_threat_values()[e_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts group centers by their distances from the character, closest ones being
# first.
func _sort_group_center_dist(center_a: int, center_b: int) -> bool:
	return _d_map[center_a]["travel"] < _d_map[center_b]["travel"]


# Sorts group centers by their distances and threat values. Threat value is used
# as the determining factor, but threat value is affected by the center's distance
# from the observer.
func _sort_group_center_threat(group_a: Array, group_b: Array) -> bool:
	var threat_a: float = 0.0
	for c in group_a[1]:
		var dis : float = _d_map[c.map_coordinate.get_index()]["travel"]
		var raw_threat: float = (
			_e_ttr.get_threat_values()[c.get_instance_id()]["value"]
			if c.get_type() == Character.Type.ENEMY
			else _p_ttr.get_threat_values()[c.get_instance_id()]["value"]
		)
		threat_a += raw_threat / dis
	var threat_b: float = 0.0
	for c in group_b[1]:
		var dis : float = _d_map[c.map_coordinate.get_index()]["travel"]
		var raw_threat: float = (
			_e_ttr.get_threat_values()[c.get_instance_id()]["value"]
			if c.get_type() == Character.Type.ENEMY
			else _p_ttr.get_threat_values()[c.get_instance_id()]["value"]
		)
		threat_b += raw_threat / dis
	return threat_a > threat_b


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			actions_ref != null,
			"EnemyAI Missing reference to actions."
	)
