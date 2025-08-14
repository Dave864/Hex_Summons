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

var _character: Character = null
var _actions: Array = []
var _h_map: HexMap = null
var _d_map: Dictionary = {}
var _allies: Dictionary = {}
var _opponents: Dictionary = {}
var _a_ttr: ThreatTracker = null
var _o_ttr: ThreatTracker = null


# Regenerates the distance map for the character's current position.
func update_distance_map() -> void:
	var char_index: int = _character.map_coordinate.get_index()
	if !_d_map.has(char_index) or _d_map[char_index]["travel"] > 0:
		_d_map = _h_map.range_finder.get_distance_map(char_index, true)


# Determines the actions that need to be taken for the character based on the
# current state of the map.
func determine_action_chain() -> Array:
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
				targets = _allies.values()
			ActionBehavior.Target.OPPONENTS:
				targets = _opponents.values()
			_:
				targets = []
			
		if not ab.conditions_met(_character, targets, _d_map):
			continue
		var target_index: int = _determine_target_index(ab)
		print(target_index)
		# Check if target is in range of action
		var movement: int = (
			0 if ab.movement_behavior == ActionBehavior.Movement.STAND
			else _character.stats.get_movement_range() 
		)
		if not _action_in_range(
				action,
				target_index,
				_character.map_coordinate.get_index(),
				movement
		):
			continue
		# Determine orientation for action? Orientation could also be determined
		# in Action state
	return _default_chain()


# Obtains the necessary references to run the AI logic.
func connect_encounter_details(
	h_map: HexMap,
	character: Character,
	opponents: Array,
	allies: Array
) -> void:
	_h_map = h_map
	_character = character
	for o in opponents:
		_opponents[o.get_instance_id()] = o
	for a in allies:
		_allies[a.get_instance_id()] = a
	_o_ttr = ThreatTracker.new(_character.get_instance_id(), opponents)
	_a_ttr = ThreatTracker.new(_character.get_instance_id(), allies)


func _ready() -> void:
	_check_for_required_parameters()
	_actions = get_node(actions_ref).get_children()


# Default behaviour. The character moves as close as it can to the closest
# target character with the highest threat.
func _default_chain() -> Array:
	var action_chain: Array = []
	var movement_range: Array = (
		_h_map.range_finder.get_character_travesible_tiles(
				_character,
				_opponents.values()
		)
	)
	var target_ids: Array = _determine_opponent_threat_order()
	var target_index: int = _opponents[target_ids[0]].map_coordinate.get_index()
	var path: PoolVector3Array = (
		_h_map.range_finder.get_character_point_path_toward(
				_character,
				target_index,
				_opponents.values(),
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
	var target_ids: Array = _determine_opponent_threat_order()
	return _opponents[target_ids[0]].map_coordinate.get_index()


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


# Gets the threat order of opponent characters.
func _determine_opponent_threat_order() -> Array:
	var danger_opponents: Array = _opponents.keys()
	danger_opponents.sort_custom(self, "_sort_opponent_danger")
	return danger_opponents


# Gets the threat order of ally characters.
func _determine_ally_threat_order() -> Array:
	var danger_allies: Array = _allies.keys()
	danger_allies.sort_custom(self, "_sort_ally_danger")
	return danger_allies


# Determines if the action is in range of the target.
func _action_in_range(
	action: Action,
	target_index: int,
	source_index: int,
	movement: int
) -> bool:
	# Process movement
	var move_step: int = _h_map.range_finder.get_character_closest_point_toward(
			_character,
			target_index,
			_opponents.values(),
			movement
	)
	# Process action source range
	var source_step: int
	# Process action effect range
	var effect_step: int
	return false


# Sorts players by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_opponent_danger(o_a: int, o_b: int) -> bool:
	var dis_a: float = _d_map[_opponents[o_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_opponents[o_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _o_ttr.get_threat_values()[o_a]["value"] / dis_a
	var threat_b: float = _o_ttr.get_threat_values()[o_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts enemies by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_ally_danger(a_a: int, a_b: int) -> bool:
	var dis_a: float = _d_map[_allies[a_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = _d_map[_allies[a_b].map_coordinate.get_index()]["travel"]
	var threat_a: float = _a_ttr.get_threat_values()[a_a]["value"] / dis_a
	var threat_b: float = _a_ttr.get_threat_values()[a_b]["value"] / dis_b
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
			_a_ttr.get_threat_values()[c.get_instance_id()]["value"]
			if c.get_type() == _character.get_type()
			else _o_ttr.get_threat_values()[c.get_instance_id()]["value"]
		)
		threat_a += raw_threat / dis
	var threat_b: float = 0.0
	for c in group_b[1]:
		var dis : float = _d_map[c.map_coordinate.get_index()]["travel"]
		var raw_threat: float = (
			_a_ttr.get_threat_values()[c.get_instance_id()]["value"]
			if c.get_type() == _character.get_type()
			else _o_ttr.get_threat_values()[c.get_instance_id()]["value"]
		)
		threat_b += raw_threat / dis
	return threat_a > threat_b


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			actions_ref != null,
			"EnemyAI Missing reference to actions."
	)
