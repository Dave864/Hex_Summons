extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Action` state.
The Enemy Character executes a given action and then proceeds to the next command
in the given chain. Goes to the 'Wait' state if the action is the last command.
"""


# The list of commands the enemy will execute.
var _command_chain: Array = []
# The details of the action to execute
var _action_details = null


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_command_chain = _msg["command_chain"]
	_action_details = _command_chain.pop_back()[1]
	_move_to_next_state()


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Resets the interpolation weight an next_point_index.
func exit() -> void:
	pass


# Checks the command chain to determine what state to go to next.
func _move_to_next_state() -> void:
	if _command_chain.size() > 0:
		if _command_chain.back()[0] == MOVE:
			print("Go to move")
			state_machine.transition_to(MOVE, {"command_chain": _command_chain})
		elif _command_chain.back()[0] == ACTION:
			print("Go to action")
			state_machine.transition_to(ACTION, {"command_chain": _command_chain})
	else:
		ec.emit_turn_ended()
		state_machine.transition_to(WAIT)
