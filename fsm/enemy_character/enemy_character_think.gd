class_name EnemyCharacterThink
extends EnemyCharacterState
## The logic for what happens when an Enemy Character is in the `Think` state.
##
## The Enemy Character waits foe the Ecnounter scene to determine the actions to 
## take and then starts the logic chain.


## Reference to the CharacterAI node of this character.
@export var ai_node: CharacterAI = null

## The action the character will execute.
var _action: Action = null
## The index the action will target.
var _target_index: int = -1
## The index the enemy will end their movement on.
var _move_end_index: int = -1


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	ai_node.update_distance_map()
	var action_chain: Array[Array] = ai_node.determine_action_chain()
	
	if action_chain.size() <= 1:
		_process_action_chain(action_chain)
		return
	_action = action_chain[0][1]
	_target_index = action_chain[0][2]
	var possible_targets: Array[Character] = action_chain[0][3]
	_move_end_index = ai_node.get_move_dest_id()
	if _action != null and _action.stats.emit_from_caster:
		action_chain[0][3] = _orient_to_target(possible_targets)
	elif _action != null:
		action_chain[0][3] = _place_on_target(possible_targets)
	_process_action_chain(action_chain)


## Called by the state machine before changing the active state. Use this
## function to clean up the state.
func exit() -> void:
	_action = null


## Orients the action emission to target. Returns the targets the action will hit.
func _orient_to_target(possible_targets: Array[Character]) -> Array:
	var target_tile: MapTile = ai_node.h_map.get_tile_at(_target_index)
	_action.set_emission_map_index(_move_end_index)
	var char_pos: Vector3 = (
		ai_node.h_map.get_tile_at(_move_end_index).get_character_position()
	)
	_action.set_emission_pos(char_pos)
	var char_pt: Vector2 = Vector2(char_pos.x, char_pos.z)
	var tile_pt: Vector2 = Vector2(
			target_tile.position.x,
			target_tile.position.z
	)
	var vector_dir: Vector2 = (tile_pt - char_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	_action.set_emission_direction(emission_dir)
	return _get_targets(possible_targets)


## Places the effect emission on target. Returns the targets that the action will
## hit.
func _place_on_target(possible_targets: Array[Character]) -> Array:
	_action.set_emission_map_index(_target_index)
	var em_pos: Vector3 = (
		ai_node.h_map.get_tile_at(_target_index).get_character_position()
	)
	_action.set_emission_pos(em_pos)
	return _get_targets(possible_targets)


## Gets the targets that will be hit by the action.
func _get_targets(possible_targets: Array[Character]) -> Array[Character]:
	var targets: Array[Character] = []
	var effect_area: Array[int]
	var p_t_set: Dictionary[int, Character] = {}
	for pt: Character in possible_targets:
		p_t_set[pt.get_instance_id()] = pt
	if _action.stats.effect_range is DirectionalAreaRange:
		effect_area = _action.stats.effect_range.get_dir_area_indexes(
				_target_index,
				_action.get_emission_direction(),
				ai_node.h_map
		)
	else:
		effect_area = _action.stats.effect_range.get_area_indexes(
				_target_index,
				ai_node.h_map
		)
	var map_tile: MapTile = null
	var c: Character = null
	for tile_id: int in effect_area:
		map_tile = ai_node.h_map.get_tile_at(tile_id)
		c = map_tile.occupant.get_current_occupant()
		if c != null and p_t_set.has(c.get_instance_id()):
			targets.append(c)
	return targets


## Processes the action change determined by the character AI.
func _process_action_chain(action_chain: Array[Array]) -> void:
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
