extends SelectorState
"""
The logic for what happens when the Selector is in the 'Pause' state.
The Selector is inactive and hidden until either the end of a player turn or
the need for another tile selection arises. When a player's turn ends, the
Selector goes into the 'Wait' state. If the Selector is needed again to select
something, it goes back to the 'Select' state.
"""


# Connect to the player_turn_ended signal to see if the player turn ends.
func enter(_msg: Dictionary = {}) -> void:
	_set_state_machine_bus(PAUSE)
	selector.snap_to_position = false
	selector.selector_shape.hide()
	
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_ended",
		self,
		"_on_SignalBus_player_turn_ended"
	)
	
	ErrorUtil.connect_signal(
		SignalBus,
		"selector_required",
		self,
		"_on_SignalBus_selector_required"
	)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
		"player_turn_ended", 
		self, 
		"_on_SignalBus_player_turn_ended"
	)
	SignalBus.disconnect(
		"selector_required",
		self,
		"_on_SignalBus_selector_required"
	)


# Transition to the 'Wait' state when the current player's turn has ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	state_machine.transition_to(WAIT)


# Transition to the 'Select' state when the selector is needed again.
func _on_SignalBus_selector_required() -> void:
	state_machine.transition_to(SELECT)
