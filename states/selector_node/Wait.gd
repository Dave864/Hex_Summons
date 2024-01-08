extends SelectorState
"""
The logic for what happens when the Selector is in the 'Wait' state.
The selector hides its shape and disables the snap position functionality
until the encounter is ready to recieve new player selections.
"""


# Hide the selector shape and disable the ability to snap to tile positions
func enter(_msg: Dictionary = {}):
	_set_state_machine_bus(WAIT)
	selector.snap_to_position = false
	selector.selector_shape.hide()
	var e: int = SignalBus.connect(
		"player_turn_started",
		self,
		"_on_SignalBus_player_turn_started"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# player_turn_started SignalBus signal to the 
	# _on_SignalBus_player_turn_started method.
	if e != OK:
		printerr(
			"ERROR CODE %d\n" + \
			"Failed to connect `player_turn_started` signal from the " + \
			"SignalBus to the Selector Wait node method" + \
			"`_on_SignalBus_player_turn_started`." % \
			[e]
		)


# Called by the state machine before changing the active state. 
# Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
		"player_turn_started",
		self,
		"_on_SignalBus_player_turn_started"
	)


# Set the position of the selector to the player whose turn has started and move
# to the `Select` state.
func _on_SignalBus_player_turn_started(player: PlayerCharacter):
	selector.current_player = player
	selector.snap_to_character()
	state_machine.transition_to(SELECT)
