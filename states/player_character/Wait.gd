extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the `Wait` state.
The Player Character waits until it is reenabled.
"""


# Hit when the player character is selected to take its turn.
func _on_SignalBus_player_turn_started():
	state_machine.transition_to("Standby")


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	StateMachineBus.encounter_states["PlayerCharacter"] = "Wait"
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
			"Failed to connect 'player_turn_started' signal from " + \
			"SignalBus autoload to PlayerCharacter Wait node method" + \
			"'_on_SignalBus_player_turn_started'." % \
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
