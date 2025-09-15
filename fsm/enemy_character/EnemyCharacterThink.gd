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
# Runs the AI logic in a separate thread.
var _ai_thread: Thread

# The CharacterAI node.
onready var _ai_node: CharacterAI = get_node(ai_reference)


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
#	# Run AI logic in separate thread to hopefully allow logic to run across
#	# multiple frames if needed.
#	_ai_thread = Thread.new()
#	_ai_thread.start(_ai_node, "update_distance_map")
#	_ai_thread.wait_to_finish()
#	_ai_thread = Thread.new()
#	_ai_thread.start(_ai_node, "determine_action_chain")
#	var action_chain: Array = _ai_thread.wait_to_finish()
	_ai_node.update_distance_map()
	var action_chain: Array = _ai_node.determine_action_chain()
	
	if action_chain.size() <= 1:
		_process_action_chain(action_chain)
		return
	_action = action_chain[0][1]
	_target_index = action_chain[0][2]
	var possible_targets: Array = action_chain[0][3]
	_move_end_index = _ai_node.get_move_dest_id()
	if _action != null and _action.emit_from_center:
		action_chain[0][3] = _orient_to_target(possible_targets)
	elif _action != null:
		action_chain[0][3] = _place_on_target(possible_targets)
	_process_action_chain(action_chain)


# Called by the state machine before changing the active state. Use this
# function to clean up the state.
func exit() -> void:
	_action = null
	_source_d_map.clear()


# Orients the action emission to target. Returns the targets the action will hit.
func _orient_to_target(possible_targets: Array) -> Array:
	var target_tile: MapTile = _ai_node.h_map.get_tile_at(_target_index)
	_action.set_emission_map_index(_move_end_index)
	var char_pos: Vector3 = (
		_ai_node.h_map.get_tile_at(_move_end_index).get_character_position()
	)
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
	return _get_targets(possible_targets)


# Places the effect emission on target. Returns the targets that the action will
# hit.
func _place_on_target(possible_targets: Array) -> Array:
	_action.set_emission_map_index(_target_index)
	var em_pos: Vector3 = (
		_ai_node.h_map.get_tile_at(_target_index).get_character_position()
	)
	_action.set_emission_pos(em_pos)
	return _get_targets(possible_targets)


# Gets the targets that will be hit by the action.
func _get_targets(possible_targets: Array) -> Array:
	var targets: Array = []
	var effect_area: Array 
	var p_t_set: Dictionary = {}
	for pt in possible_targets:
		p_t_set[pt.get_instance_id()] = pt
	if _action.emit_from_center:
		effect_area = _action.effect_range.get_dir_area_indexes(
				_target_index,
				_action.get_emission_direction(),
				_ai_node.h_map
		)
	else:
		effect_area = _action.effect_range.get_area_indexes(
				_target_index,
				_ai_node.h_map
		)
	var map_tile: MapTile = null
	var c: Character = null
	for tile_id in effect_area:
		map_tile = _ai_node.h_map.get_tile_at(tile_id)
		c = map_tile.occupant.get_current_occupant()
		if c != null and p_t_set.has(c.get_instance_id()):
			targets.append(c)
	return targets


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
