extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Think` state.
The Enemy Character waits foe the Ecnounter scene to determine the actions to 
take and then starts the logic chain.
"""


# Reference to the CharacterAI node of this character.
export(NodePath) var ai_reference = null

# The action the character will execute.
var _action: Action = null
# The index the action will target.
var _target_index: int = -1
# The index the enemy will end their movement on.
var _move_end_index: int = -1
# Stores the distance map of the source range at the end of character movement.
var _source_d_map: Dictionary = {}

# The CharacterAI node.
onready var _ai_node: CharacterAI = get_node(ai_reference)


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_ai_node.update_distance_map()
	var action_chain: Array = _ai_node.determine_action_chain()
	if action_chain.size() <= 1:
		_process_action_chain(action_chain)
		return
	_action = action_chain[0][1]
	_target_index = action_chain[0][2]
	_move_end_index = _ai_node.get_move_dest_id()
	if _action != null and _action.emit_from_center:
		_orient_to_closest_target()
	elif _action != null:
		_place_closest_to_target()
	_process_action_chain(action_chain)


# Called by the state machine before changing the active state. Use this
# function to clean up the state.
func exit() -> void:
	_action = null
	_source_d_map.clear()


# Orients the action emission to the closest valid target.
func _orient_to_closest_target() -> void:
	var target_tile: MapTile = _ai_node.h_map.get_tile_at(_target_index)
	_action.set_emission_map_index(ec.map_coordinate.get_index())
	var char_pos: Vector3 = ec.translation
	_action.set_emission_pos(char_pos)
	var char_pt: Vector2 = Vector2(char_pos.x, char_pos.z)
	var tile_pt: Vector2 = Vector2(
			target_tile.translation.x,
			target_tile.translation.z
	)
	var vector_dir: Vector2 = (tile_pt - char_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	_action.set_emission_direction(emission_dir)
	# No need to fix orientation for non-cardinal effect ranges.
	if not _action.get_is_cardinal() or _fix_orientation():
		# execute action
		pass
	else:
		# Something went wrong
		pass


# Adjusts the orientation of an effect emitted from caster to make sure it is
# in a direction the player can reach. Returns if the direction was set.
func _fix_orientation() -> bool:
	var c_cube: Vector3 = HexUtil.index_to_cube(
			ec.map_coordinate.get_index(),
			_ai_node.h_map.get_x_count()
	)
	for i in 6:
		var dir: int = posmod(_action.get_emission_direction() + i, 6)
		var dir_cube: Vector3 = HexUtil.CUBE_DIRECTION_VECTORS[dir] + c_cube
		var dir_index: int = HexUtil.cube_to_index(
				dir_cube,
				_ai_node.h_map.get_x_count()
		)
		if _ai_node.h_map.is_valid_cube(dir_cube) and _source_d_map.has(dir_index):
			_action.set_emission_direction(dir)
			return true
	return false


# Places the effect emission so that the effect area hits the closest
# target. Emission is not placed if no valid tile could be found.
func _place_closest_to_target() -> void:
	_get_source_range()
	if _action.dead_range.get_reach() > 0:
		_source_d_map.erase(_move_end_index)
	var closest_index: int = _ai_node.h_map.range_finder.get_closest_in_area(
			_target_index,
			_source_d_map
	)
	if closest_index >= 0:
		_action.set_emission_map_index(closest_index)
		var em_pos: Vector3 = (
			_ai_node.h_map.get_tile_at(closest_index).get_character_position()
		)
		_action.set_emission_pos(em_pos)


# Gets the tile ids of all tiles within the source range. Accounts for dead range.
func _get_source_range() -> Array:
	_source_d_map = _ai_node.h_map.range_finder.get_distance_map(
			_move_end_index,
			_action.source_ignore_heights,
			_action.source_range.get_reach()
	)
	var dead_indexes: Array = _action.dead_range.get_area_indexes(
			_move_end_index,
			_ai_node.h_map
	)
	for index in dead_indexes:
		if index != _move_end_index and _source_d_map.has(index):
			_source_d_map.erase(index)
	return _source_d_map.keys()


# Processes the action change determined by the character AI.
func _process_action_chain(action_chain: Array) -> void:
	if action_chain.size() > 0:
		if action_chain.back()[0] == MOVE:
			print("Go to move")
			state_machine.transition_to(MOVE, {"command_chain": action_chain})
		elif action_chain.back()[0] == ACTION:
			print("Go to action")
			state_machine.transition_to(ACTION, {"command_chain": action_chain})
	else:
		ec.emit_turn_ended()
		state_machine.transition_to(WAIT)
