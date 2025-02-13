extends SelectorState
"""
The logic for what happens when the Selector is in the 'Pause' state.
The Selector is inactive and hidden until either the end of a player turn or
the need for another tile selection arises. When a player's turn ends, the
Selector goes into the 'Wait' state. If the Selector is needed again to select
something, it goes back to the 'Select' state.
"""


# 
func enter(_msg: Dictionary = {}) -> void:
	_set_state_machine_bus(PAUSE)
	selector.snap_to_position = false
	selector.selector_shape.hide()
	var e: int = SignalBus.connect(
		"player_turn_ended",
		self,
		"_on_SignalBus_player_turn_ended"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# player_turn_ended SignalBus signal to the 
	# _on_SignalBus_player_turn_ended method.
	if e != OK:
		ErrorMessage.signal_connect_failed(
			e, 
			"player_turn_ended",
			"SignalBus",
			"Selector",
			"Pause",
			"_on_SignalBus_player_turn_ended"
		)


# 
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	pass


# Transition to the 'Wait' state when the current player's turn has ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	pass
