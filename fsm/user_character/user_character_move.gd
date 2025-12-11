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
## Flag indicating that the selector is currently paused.
var _selector_paused: bool = false


## Set the starting point for the path.
func enter(_msg: Dictionary = {}) -> void:
	character.hm_move_path.create_segmented_bezier_path(_msg["travel_path"])
	_movement_active = true
	
	SignalBus.connect(
			"selector_paused",
			Callable(self, "_on_SignalBus_selector_paused")
	)


## Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	_weight += delta * Constants.MOVE_SPEED
	character.hm_move_path.move_offset(_weight)
	# Only update the movement position if the movement has not ended.
	# This is to prevent the character from being moved to an undesired location
	# after the movement_ended signal has been caught.
	if _movement_active:
		character.position = character.hm_move_path.get_current_pos()
	elif _selector_paused:
		state_machine.transition_to(STANDBY)


## Called by the state machine before changing the active state.
## Resets the interpolation weight and next_point_index.
func exit() -> void:
	_weight = 0.0
	_selector_paused = false
	character.hm_move_path.reset_path()
	SignalBus.disconnect(
			"selector_paused",
			Callable(self, "_on_SignalBus_selector_paused")
	)
	SignalBus.emit_selector_required(character.map_coordinate.get_tile_index())


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	character.hm_move_path.connect(
			"movement_finished",
			Callable(self, "_on_HexMapMovementCurve_movement_finished")
	)


## Marks the selector as paused for use by this class.
func _on_SignalBus_selector_paused() -> void:
	_selector_paused = true


## Resets the movement path when movement has finished.
func _on_HexMapMovementCurve_movement_finished(final_position: Vector3) -> void:
	_movement_active = false
	character.hm_move_path.reset_path()
	character.position = final_position
	state_machine.transition_to(STANDBY)
