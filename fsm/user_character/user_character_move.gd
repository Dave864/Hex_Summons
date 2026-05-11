class_name UserCharacterMove
extends UserCharacterState
## The logic for what happens when a user controlled Character is in the `Move`
## state.
##
## The Character moves from tile to tile along a preset path.


## Flag indicating if the movement is active.
var _movement_active: bool = false
## The current interpolation weight.
var _weight: float = 0.0


## Set the starting point for the path.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	character.hm_move_path.create_segmented_bezier_path(_msg["travel_path"])
	_movement_active = true
	
	character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.connect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	_weight += delta * Constants.MOVE_SPEED
	character.hm_move_path.move_offset(_weight)
	# Only update the movement position if the movement has not ended.
	# This is to prevent the character from being moved to an undesired location
	# after the movement_ended signal has been caught.
	if _movement_active:
		SignalBus.emit_position_camera_focus(
				character.position,
				TrackingPoint.MovementType.SNAP
		)
		character.position = character.hm_move_path.get_current_pos()
		


## Called by the state machine before changing the active state.
## Resets the interpolation weight and next_point_index.
func exit() -> void:
	_weight = 0.0
	character.hm_move_path.reset_path()
	character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.disconnect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	character.hm_move_path.connect(
			"movement_finished",
			Callable(self, "_on_HexMapMovementCurve_movement_finished")
	)


## Goes to the "Action" state when an action is set to be executed.
func _on_SignalBus_character_action_executed(
	c: Character,
	action: Action,
	targets: Array
) -> void:
	if character.get_instance_id() == c.get_instance_id():
		state_machine.transition_to(
				ACTION,
				{"action": action, "targets": targets}
		)


## Resets the movement path when movement has finished.
func _on_HexMapMovementCurve_movement_finished(final_position: Vector3) -> void:
	_movement_active = false
	character.hm_move_path.reset_path()
	character.position = final_position
	SignalBus.emit_character_movement_finished()


## Hit when the character has finished their turn.
func _on_Character_turn_ended() -> void:
	state_machine.transition_to(WAIT)
