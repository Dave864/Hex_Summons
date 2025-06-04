extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the `Move` state.
The Player Character moves from tile to tile along a preset path.
"""


# The reference to the movement path.
var _movement_path: HexMapMovementPath = null
# Flag indicating if the movement is active.
var _movement_active: bool = false
# The current interpolation weight.
var _weight: float = 0.0

var _completed_path: bool = false
var _selector_paused: bool = false


# Set the starting point for the path.
func enter(_msg: Dictionary = {}) -> void:
	_movement_path = _msg["travel_path"]
	_movement_active = true
	
	ErrorUtil.connect_signal(
			_movement_path,
			"movement_finished",
			self,
			"_on_MovementPath_movement_finished"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"selector_paused",
			self,
			"_on_SignalBus_selector_paused"
	)


# Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	_weight += delta * Constants.MOVE_SPEED
	_movement_path.move_offset(_weight)
	# Only update the movement position if the movement has not ended.
	# This is to prevent the character from being moved to an undesired location
	# after the movement_ended signal has been caught.
	if _movement_active:
		pc.translation = _movement_path.get_current_pos()
	elif _selector_paused:
		state_machine.transition_to(STANDBY)


# Called by the state machine before changing the active state.
# Resets the interpolation weight and next_point_index.
func exit() -> void:
	_weight = 0.0
	_selector_paused = false
	_movement_path = null
	SignalBus.disconnect("selector_paused", self, "_on_SignalBus_selector_paused")
	SignalBus.emit_selector_required(pc.translation)


func _on_SignalBus_selector_paused() -> void:
	_selector_paused = true


func _on_MovementPath_movement_finished(final_position: Vector3) -> void:
	_movement_active = false
	_movement_path.disconnect(
			"movement_finished",
			self,
			"_on_MovementPath_movement_finished"
	)
	_movement_path.reset_path()
	pc.translation = final_position
	state_machine.transition_to(STANDBY)
