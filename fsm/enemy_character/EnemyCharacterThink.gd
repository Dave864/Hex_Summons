extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Think` state.
The Enemy Character waits foe the Ecnounter scene to determine the actions to 
take and then starts the logic chain.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	var ai_node: CharacterAI = ec.get_node("CharacterAI")
	ai_node.update_distance_map()
	_process_action_chain(ai_node.determine_action_chain())


# Called by the state machine before changing the active state. Use this
# function to clean up the state.
func exit() -> void:
	pass


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
