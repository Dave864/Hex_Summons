class_name SelectionTrackerPause
extends SelectionTrackerState
## The logic for what happens when the SelectionTracker is in the 'Pause' state.
##
## The Selector is inactive and hidden until either the end of a character turn
## or the need for another movement tile selection arises. When a character's
## turn ends, the SelectionTracker goes into the 'Wait' state. If the Selector
## is needed again to select a movement destination, it goes back to the
## 'Move' state.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	s_tracker.focused_character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.connect(
			"selector_required",
			Callable(self, "_on_SignalBus_selector_required")
	)
	SignalBus.emit_selector_paused()


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	s_tracker.focused_character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.disconnect(
			"selector_required",
			Callable(self, "_on_SignalBus_selector_required")
	)


## Transition to the 'Wait' state when the current character's turn has ended.
func _on_Character_turn_ended() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(WAIT)


## Transition to the 'SelectMove' state when the selector is needed again.
func _on_SignalBus_selector_required(_start_index: int) -> void:
	state_machine.transition_to(MOVE)
