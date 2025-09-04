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
# Name of the Action node that represents only movement
const MOVE_ACTION_NAME: String = "Empty"

export(NodePath) var actions_ref = null

var h_map: HexMap = null
# Distance map of all tiles in the HexMap. Tracks the travel and tile distances.
var d_map: Dictionary = {}

var _character: Character = null
# Tracks allies and opponents by their instance ids
var _allies: Dictionary = {}
var _opponents: Dictionary = {}
var _targets: Array = []
# Threat trackers for allies and opponents
var _a_ttr: ThreatTracker = null
var _o_ttr: ThreatTracker = null
# Tracks the index of the final movement tile.
var _move_dest_id: int = -1 setget , get_move_dest_id

onready var _actions: Array = get_node(actions_ref).get_children()


# Returns the index of the movement destination.
func get_move_dest_id() -> int:
	return _move_dest_id


# Regenerates the distance map for the character's current position.
func update_distance_map() -> void:
	var char_index: int = _character.map_coordinate.get_index()
	if !d_map.has(char_index) or d_map[char_index]["travel"] > 0:
		d_map = h_map.range_finder.get_distance_map(char_index, true)


# Determines the actions that need to be taken for the character based on the
# current state of the map.
func determine_action_chain() -> Array:
	randomize()
	var ab: ActionBehavior = null
	for action in _actions:
		ab = action.get_node_or_null("ActionBehavior")
		assert(
				ab != null,
				"Action {0} is missing an ActionBehavior node." \
				.format([action.name])
		)
		_targets = (
			_allies.values() 
			if ab.target == ActionBehavior.Target.ALLIES
			else _opponents.values()
		)
		if not ab.conditions_met(_character, _targets, d_map):
			print("action {0} conditions not met.".format([action.name]))
			continue
		var details: Array = _determine_action_details(action, ab)
		if details.size() == 0:
			print("action {0} out of range of all targets.".format([action.name]))
			continue
		# Empty actions default to movement.
		if action.name == MOVE_ACTION_NAME:
			print("Default move")
			return[
				[MOVE, details[0]]
			]
		else:
			print("execute acton {0}".format([action.name]))
			"""
			TODO: Add logic to isolate the targets that will be hit by the action
			"""
			var active_targets: Array = _targets
			return [
				[ACTION, action, details[1], active_targets],
				[MOVE, details[0]]
			]
	return _default_chain()


# Obtains the necessary references to run the AI logic.
func connect_encounter_details(
	h_map_ref: HexMap,
	character: Character,
	opponents: Array,
	allies: Array
) -> void:
	h_map = h_map_ref
	_character = character
	for o in opponents:
		_opponents[o.get_instance_id()] = o
	for a in allies:
		_allies[a.get_instance_id()] = a
	_o_ttr = ThreatTracker.new(_character.get_instance_id(), opponents)
	_a_ttr = ThreatTracker.new(_character.get_instance_id(), allies)


func _ready() -> void:
	_check_for_required_parameters()


# Goes through all relevant target indexes and determines the movement
# path for the character and emission index of the action for the
# first target that is within range. Returns these details as an array:
# [movement_path, target_index]
# Returns an empty array if no targets are within range.
func _determine_action_details(
	action: Action,
	ab: ActionBehavior
) -> Array:
	var details: Array = []
	var target_indexes: Array = _get_sorted_target_indexes(ab)
	var movement: int = (
		0 if ab.movement_behavior == ActionBehavior.Movement.STAND
		else _character.stats.get_movement_range() 
	)
	if action.name == MOVE_ACTION_NAME:
		details.append(_calc_move_path(target_indexes[0], ab.movement_behavior))
		return details
	# The number of spaces that can be moved in the direction defined by
	# ab.movement_bahavior while still remaining in range of target.
	var m_path: PoolVector3Array
	for t_index in target_indexes:
		m_path = _get_move_path(
				action,
				ab,
				t_index,
				movement
		)
		if m_path.size() == 0:
			continue
		# Maybe add logic to randomize the tolerance?
		details.append(m_path)
		# Determine true target index to account for movement behavior
		var true_target: int = h_map.range_finder.get_closest_id_path(
				_move_dest_id,
				t_index,
				action.source_range.get_reach(),
				action.source_ignore_heights
		)[-1]
		details.append(true_target)
		break
	return details


# Determines the indexes of the tiles the character can target.
func _get_sorted_target_indexes(ab: ActionBehavior) -> Array:
	if ab.target_group():
		return _get_group_target_indexes(ab.get_group_condition(), ab.target_focus)
	var target_indexes: Array
	if ab.target_focus == ActionBehavior.TargetFocus.CLOSEST:
		_targets.sort_custom(self, "_sort_character_dist")
		for t in _targets:
			target_indexes.append(t.map_coordinate.get_index())
		return target_indexes
	if ab.target_focus == ActionBehavior.TargetFocus.FARTHEST:
		_targets.sort_custom(self, "_sort_character_dist")
		for t in _targets:
			target_indexes.append(t.map_coordinate.get_index())
		target_indexes.invert()
		return target_indexes
	if ab.target == ActionBehavior.Target.OPPONENTS:
		target_indexes = _determine_opponent_index_threat_order()
		return target_indexes
	else:
		target_indexes = _determine_ally_index_threat_order()
		return target_indexes


# Gets the target index based on a group condition.
func _get_group_target_indexes(gc: GroupCondition, target_focus: int) -> Array:
	var groups: Dictionary = gc.find_group_index_centers(h_map.get_x_count())
	match target_focus:
		ActionBehavior.TargetFocus.CLOSEST:
			var sorted_centers: Array = groups.keys()
			sorted_centers.sort_custom(self, "_sort_group_center_dist")
			return sorted_centers
		ActionBehavior.TargetFocus.FARTHEST:
			var sorted_centers: Array = groups.keys()
			sorted_centers.sort_custom(self, "_sort_group_center_dist")
			sorted_centers.invert()
			return sorted_centers
		_:
			var sorted_group_data: Array = []
			for center in groups.keys():
				sorted_group_data.append([center, groups[center]])
			sorted_group_data.sort_custom(self, "_sort_group_center_threat")
			var sorted_centers: Array = []
			for gd in sorted_group_data:
				sorted_centers.append(gd[0])
			return sorted_centers


# Gets the threat order of opponent characters.
func _determine_opponent_index_threat_order() -> Array:
	var danger_opponents: Array = _opponents.keys()
	danger_opponents.sort_custom(self, "_sort_opponent_danger")
	var indexes: Array = []
	for o in danger_opponents:
		indexes.append(_opponents[o].map_coordinate.get_index())
	return indexes


# Gets the threat order of ally characters.
func _determine_ally_index_threat_order() -> Array:
	var danger_allies: Array = _allies.keys()
	danger_allies.sort_custom(self, "_sort_ally_danger")
	var indexes: Array = []
	for a in danger_allies:
		indexes.append(_allies[a].map_coordinate.get_index())
	return indexes


# Determines the movement path required for the character to be at the
# maximum range of an action given a specific movement direction.
# Returns an empty array if target is out of range.
func _get_move_path(
	action: Action,
	ab: ActionBehavior,
	target_index: int,
	movement: int
) -> PoolVector3Array:
	"""
	TODO: Add logic to account for dead ranges.
	"""
	var move_dir: int = ab.movement_behavior
	var move_dist: int = 0
	# Check if target is within the effect distance from the character.
	var e_step: Array = _effect_step(target_index, action, move_dir, movement)
	if e_step[0] >= 0:
		move_dist = (
				e_step[0] if e_step[0] == 0 or not ab.randomize_move_dist
				else randi() % e_step[0]
		)
		return _calc_move_path(target_index, move_dir, move_dist)
	# Check if target is within effect + source distance from character.
	var s_step: Array = _source_step(e_step[1], action, move_dir, movement)
	if s_step[0] >= 0:
		move_dist = (
				s_step[0] if s_step[0] == 0 or not ab.randomize_move_dist
				else randi() % s_step[0]
		)
		return _calc_move_path(target_index, move_dir, move_dist)
	var m_step: Array = _move_step(s_step[1], movement)
	if m_step.size() == 0:
		return PoolVector3Array([])
	# Character should always move forward when they are required to move to be
	# in range of target.
	move_dir = (
			ActionBehavior.Movement.TOWARD if move_dir == ActionBehavior.Movement.AWAY
			else move_dir
	)
	move_dist = (
				m_step[0] if movement + m_step[0] == 0 or not ab.randomize_move_dist
				else randi() % movement + m_step[0]
	)
	return _calc_move_path(m_step[1], move_dir, move_dist)


# Helper function for _get_move_tolerance. Determines if the character is within
# effect range of the target and gets the movement tolerance if so. Returns an
# array where the first element is the movement tolerance and the second element
# is the farthest point from the target to the character that can be reached using
# effect range. Tolerance is -1 if the character is outside effect range. 
func _effect_step(
	target_index: int,
	action: Action,
	move_dir: int,
	movement: int
) -> Array:
	var path: PoolIntArray = []
	var results: Array = [0, 0]
	path = h_map.range_finder.get_closest_id_path(
			target_index,
			_character.map_coordinate.get_index(),
			action.effect_range.get_reach(),
			action.effect_ignore_heights
	)
	var effect_stop: int = path[-1]
	if effect_stop == _character.map_coordinate.get_index():
		if move_dir == ActionBehavior.Movement.AWAY:
			results[0] = int(min(action.source_range.get_reach(), movement))
		else:
			results[0] = 0
	else:
		results[0] = -1
	results[1] = effect_stop
	return results


# Helper function for _get_move_tolerance. Determines if the character is within
# source range of the target and gets the movement tolerance if so. Returns an
# array where the first element is the movement tolerance and the second element
# is the farthest point from the target to the character that can be reached using
# source and effect range. Tolerance is -1 if the character is outside this range. 
func _source_step(
	effect_stop: int,
	action: Action,
	move_dir: int,
	movement: int
) -> Array:
	var source_stop: int
	var results: Array = [0, 0]
	# Source range not applied when action is emitted from center.
	if action.emit_from_center:
		source_stop = effect_stop
	else:
		var path: PoolIntArray = []
		path = h_map.range_finder.get_closest_id_path(
				effect_stop,
				_character.map_coordinate.get_index(),
				action.source_range.get_reach(),
				action.source_ignore_heights
		)
		source_stop = path[-1]
	if source_stop == _character.map_coordinate.get_index():
		if move_dir == ActionBehavior.Movement.AWAY:
			var base_tol: float = min(action.source_range.get_reach(), movement)
			var s_dist: float
			if action.source_ignore_heights:
				s_dist = d_map[source_stop]["tile"] - d_map[effect_stop]["tile"]
			else:
				s_dist = d_map[source_stop]["travel"] - d_map[effect_stop]["travel"]
			var s_tol: float = action.source_range.get_reach() - abs(s_dist)
			results[0] = int(min(base_tol, s_tol))
		else:
			results[0] = 0
	else:
		results[0] = -1
	results[1] = source_stop
	return results


# Helper function for _get_move_tolerance. Determines if the character is within
# movement range of the target after source + effect steps and gets the movement
# tolerance if so. Returns an array where the first element is the movement
# tolerance and the second element is the tile reached via movement. Returns
# an empty array if the character is outside this range.
func _move_step(source_stop: int, movement: int) -> Array:
	var move_stop: int = h_map.range_finder.get_character_closest_point_toward(
			_character,
			source_stop,
			_opponents.values(),
			movement
	)
	if source_stop == move_stop:
		return [d_map[source_stop]["travel"], move_stop]
	return []


# Calculates the movement path for the action chain. The move_override parameter
# is defaulted to -1 which indicates that the character's movement should be used.
func _calc_move_path(
	target_index: int,
	movement_behavior: int,
	move_override: int = -1
) -> PoolVector3Array:
	var move_path: PoolVector3Array = []
	match movement_behavior:
		ActionBehavior.Movement.TOWARD:
			move_path = _calculate_toward_path(target_index, move_override)
		ActionBehavior.Movement.AWAY:
			move_path = _calculate_away_path(target_index, move_override)
		_:
			var char_tile_index: int = _character.map_coordinate.get_index()
			var start_tile: MapTile = h_map.get_tile_at(char_tile_index)
			move_path.append(start_tile.get_character_position())
	return move_path


# Default behaviour. The character moves as close as it can to the closest
# target character with the highest threat.
func _default_chain() -> Array:
	var action_chain: Array = []
	var target_indexes: Array = _determine_opponent_index_threat_order()
	action_chain.push_front([MOVE, _calculate_toward_path(target_indexes[0])])
	return action_chain


# Calculates the movement path to the destination. The move_override parameter
# is defaulted to -1 which indicates that the character's movement should be used.
func _calculate_toward_path(dest: int, move_override: int = -1) -> PoolVector3Array:
	var movement_range: Array = (
		h_map.range_finder.get_character_travesible_tiles(
				_character,
				_opponents.values(),
				move_override
		)
	)
	_move_dest_id = h_map.range_finder.get_character_closest_point_toward(
			_character,
			dest,
			_opponents.values(),
			move_override
	)
	return h_map.range_finder.get_character_point_path(
			_character,
			_move_dest_id,
			_opponents.values(),
			movement_range
	)


# Calculates the movement path away from the target. The move_override parameter
# is defaulted to -1 which indicates that the character's movement should be used.
func _calculate_away_path(
		target: int,
		move_override: int = -1
) -> PoolVector3Array:
	var movement_range: Array = (
		h_map.range_finder.get_character_travesible_tiles(
				_character,
				_opponents.values(),
				move_override
		)
	)
	var movement_d_map: Dictionary = {}
	for i in movement_range:
		movement_d_map[i] = d_map[i]
	_move_dest_id = h_map.range_finder.get_character_farthest_point_away(
			_character,
			target,
			_opponents.values(),
			movement_d_map
	)
	return h_map.range_finder.get_character_point_path(
			_character,
			_move_dest_id,
			_opponents.values(),
			movement_range
	)


# Sorts characters by their distances, with the lower distances being first.
func _sort_character_dist(c_a: Character, c_b: Character) -> bool:
	var dis_a: float = d_map[c_a.map_coordinate.get_index()]["travel"]
	var dis_b: float = d_map[c_b.map_coordinate.get_index()]["travel"]
	return dis_a < dis_b


# Sorts players by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_opponent_danger(o_a: int, o_b: int) -> bool:
	var dis_a: float = d_map[_opponents[o_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = d_map[_opponents[o_b].map_coordinate.get_index()]["travel"]
	dis_a = clamp(dis_a, 1.0, dis_a)
	dis_b = clamp(dis_b, 1.0, dis_b)
	var threat_a: float = _o_ttr.get_threat_values()[o_a]["value"] / dis_a
	var threat_b: float = _o_ttr.get_threat_values()[o_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts enemies by their distances and threat values. Threat value is used as
# the determining factor, but threat value is affected by the target's distance
# from the observer.
func _sort_ally_danger(a_a: int, a_b: int) -> bool:
	var dis_a: float = d_map[_allies[a_a].map_coordinate.get_index()]["travel"]
	var dis_b: float = d_map[_allies[a_b].map_coordinate.get_index()]["travel"]
	dis_a = clamp(dis_a, 1.0, dis_a)
	dis_b = clamp(dis_b, 1.0, dis_b)
	var threat_a: float = _a_ttr.get_threat_values()[a_a]["value"] / dis_a
	var threat_b: float = _a_ttr.get_threat_values()[a_b]["value"] / dis_b
	return threat_a > threat_b


# Sorts group centers by their distances from the character, closest ones being
# first.
func _sort_group_center_dist(center_a: int, center_b: int) -> bool:
	return d_map[center_a]["travel"] < d_map[center_b]["travel"]


# Sorts group centers by their distances and threat values. Threat value is used
# as the determining factor, but threat value is affected by the center's distance
# from the observer.
func _sort_group_center_threat(group_a: Array, group_b: Array) -> bool:
	var threat_a: float = 0.0
	for c in group_a[1]:
		var dis : float = d_map[c.map_coordinate.get_index()]["travel"]
		var raw_threat: float = (
			_a_ttr.get_threat_values()[c.get_instance_id()]["value"]
			if c.get_type() == _character.get_type()
			else _o_ttr.get_threat_values()[c.get_instance_id()]["value"]
		)
		threat_a += raw_threat / dis
	var threat_b: float = 0.0
	for c in group_b[1]:
		var dis : float = d_map[c.map_coordinate.get_index()]["travel"]
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
