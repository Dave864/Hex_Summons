extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Think` state.
The Enemy Character determines what sequence of commands to take and then starts
the logic chain.
"""


# Records the sequence of commands the enemy should take this turn.
var command_chain: Array = []
var hm_astar: HexMapAStar = null


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(THINK)
	command_chain = []
	
	"""
	TODO: Implement logic for determining what actions to take.
	For now, the enemy character moves as close as it can to the closest player
	character.
	"""
	hm_astar = _msg["hm_astar"]
	var players: Array = _msg["players"]
	var player_distances: Array = []
	for p in players:
		var p_data: Array = [
			p, 
			hm_astar.calculate_distance_from_character(ec, p.get_index_at())
		]
		player_distances.append(p_data)
		
	player_distances.sort_custom(ArraySorters, "sort_distance_to_character_asc")
	command_chain.push_front(
			[
				MOVE, 
				hm_astar.get_point_path_toward(ec, player_distances[0][0].get_index_at())
			]
	)
	# Pause for a little bit to give the EncounterUI a chance to get ready.
	# Workaround for bug where not moving the player causes the UI to not appear.
	yield(get_tree().create_timer(0.1), "timeout")
	state_machine.transition_to(MOVE, {"command_chain": command_chain})


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Resets the interpolation weight an next_point_index.
func exit() -> void:
	pass
