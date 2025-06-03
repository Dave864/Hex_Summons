extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Move` state.
The Enemy Character moves from tile to tile along a preset path and then 
proceeds to the next command in the given chain. Goes to the 'Wait' 
state if movement is the last command.
"""


# The reference to the movement path.
var _movement_path: HexMapMovementPath = null
# Flag indicating if the movement is active.
var _movement_active: bool = false
## The index of the end point in the travel path.
#var next_point_index: int = 1
# The current interpolation weight.
var _weight: float = 0.0
# The list of commands the enemy will execute.
var _command_chain: Array = []


# Set the starting point for the path.
func enter(_msg := {}) -> void:
	_command_chain = _msg["command_chain"]
#	travel_path = command_chain.pop_back()[1]
	_movement_path = _command_chain.pop_back()[1]
	_movement_active = true
	ErrorUtil.connect_signal(
			_movement_path,
			"movement_finished",
			self,
			"_on_MovementPath_movement_ended"
	)


# Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	_weight += delta * Constants.MOVE_SPEED
	_movement_path.move_offset(_weight)
	# Only update the movement position if the movement has not ended.
	# This is to prevent the character from being moved to an undesired location
	# after the movement_ended signal has been caught.
	if _movement_active:
		ec.translation = _movement_path.get_current_pos()


# Called by the state machine before changing the active state.
# Resets the interpolation weight an next_point_index.
func exit() -> void:
	_movement_path = null
	_weight = 0.0


# Checks the command chain to determine what state to go to next.
func _move_to_next_state() -> void:
	if _command_chain.size() > 0:
		if _command_chain.back()[0] == MOVE:
			print("Go to move")
#			state_machine.transition_to(MOVE, {"command_chain": command_chain})
		elif _command_chain.back()[0] == ACTION:
			print("Go to action")
#			state_machine.transition_to(ACTION, {"command_chain": command_chain})
	else:
		ec.emit_enemy_turn_ended()
		state_machine.transition_to(WAIT)


func _on_MovementPath_movement_ended(final_position: Vector3) -> void:
	_movement_active = false
	_movement_path.disconnect(
			"movement_finished",
			self,
			"_on_MovementPath_movement_ended"
	)
	_movement_path.reset_path()
	ec.translation = final_position
	_move_to_next_state()
