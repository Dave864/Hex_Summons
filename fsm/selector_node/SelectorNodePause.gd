extends SelectorState
"""
The logic for what happens when the Selector is in the 'Pause' state.
The Selector is inactive and hidden until either the end of a player turn or
the need for another movement tile selection arises. When a player's turn ends, the
Selector goes into the 'Wait' state. If the Selector is needed again to select
a movement destination, it goes back to the 'SelectMove' state.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg: Dictionary = {}) -> void:
	ErrorUtil.connect_signal(
			selector.active_player,
			"turn_ended",
			self,
			"_on_PlayerCharacter_turn_ended"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"selector_required",
			self,
			"_on_SignalBus_selector_required"
	)
	SignalBus.emit_selector_paused()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.active_player.disconnect(
			"turn_ended",
			Callable(self, "_on_PlayerCharacter_turn_ended")
	)
	SignalBus.disconnect(
			"selector_required",
			Callable(self, "_on_SignalBus_selector_required")
	)


# Transition to the 'Wait' state when the current player's turn has ended.
func _on_PlayerCharacter_turn_ended() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(WAIT)


# Transition to the 'SelectMove' state when the selector is needed again.
func _on_SignalBus_selector_required(_start_index: int) -> void:
	state_machine.transition_to(SELECT_MOVE)
