extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Standby' state.
The Player Character waits for player input and then goes to the appropriate
state.
"""


# Hit when the Selector selects a map tile destination.
func _on_SignalBus_tile_selected(path):
	state_machine.transition_to(MOVE, {"travel_path": path})


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(STANDBY)
	var e: int = SignalBus.connect(
		"tile_selected", 
		self, 
		"_on_SignalBus_tile_selected"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# tile_selected SignalBus signal to the _on_SignalBus_tile_selected method.
	if e != OK:
		printerr(
			"ERROR CODE %d\n" + \
			"Failed to connect 'tile_selected' signal from " + \
			"SignalBus autoload to PlayerCharacter Standby node method" + \
			"'_on_SignalBus_tile_selected'." % \
			[e]
		)


# Called by the state machine before changing the active state. 
# Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect("tile_selected", self, "_on_SignalBus_tile_selected")
