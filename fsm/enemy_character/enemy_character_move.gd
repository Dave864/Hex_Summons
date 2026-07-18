class_name EnemyCharacterMove
extends EnemyCharacterState
## The logic for what happens when an Enemy Character is in the `Move` state.
##
## The Enemy Character moves from tile to tile along a preset path and then 
## proceeds to the next command in the given chain. Goes to the 'Wait' 
## state if movement is the last command.


## Flag indicating if the movement is active.
var _movement_active: bool = false
## The current interpolation weight.
var _weight: float = 0.0
## The list of commands the enemy will execute.
var _command_chain: Array[Array] = []


## Set the starting point for the path.
func enter(_msg := {}) -> void:
	_command_chain = _msg["command_chain"]
	ec.hm_move_path.create_segmented_bezier_path(_command_chain.pop_back()[1])
	_movement_active = true


## Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	if _movement_active:
		_weight += delta * Constants.MOVE_SPEED
		ec.hm_move_path.move_offset(_weight)
		SignalBus.emit_position_camera_focus(
				ec.position,
				TrackingPoint.MovementType.SNAP
		)
	# This is to prevent the character from being moved to an undesired location
	# after the movement_ended signal has been caught.
	if _movement_active:
		ec.position = ec.hm_move_path.get_current_pos()
		ec.character_sprite.facing_direction = (
				ec.hm_move_path.get_current_direction()
		)


## Called by the state machine before changing the active state.
## Resets the interpolation weight an next_point_index.
func exit() -> void:
	_movement_active = false
	ec.hm_move_path.reset_path()
	_weight = 0.0


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	ec.hm_move_path.connect(
			"movement_finished",
			Callable(self, "_on_HexMapMovementCurve_movement_finished")
	)


## Checks the command chain to determine what state to go to next.
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


## Resets the path when movement along a curve has finished.
func _on_HexMapMovementCurve_movement_finished(final_position: Vector3) -> void:
	_movement_active = false
	ec.hm_move_path.reset_path()
	ec.position = final_position
	_move_to_next_state()
