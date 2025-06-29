extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Wait` state.
Hides the options and suboptions menus. Goes to the 'Select' state when a player
turn starts.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.deactivate()
	encounter_ui.options.hide()
	encounter_ui.active_player_stats.hide()
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_started",
		self,
		"_on_SignalBus_player_turn_started"
	)
	encounter_ui.emit_is_waiting()


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
		"player_turn_started",
		self,
		"_on_SignalBus_player_turn_started"
	)


# Wait for the EncounterUI object to recieve signal that user input needs to
# be obtained.
func _on_SignalBus_player_turn_started(character: PlayerCharacter) -> void:
	if not _state_is_active():
		return
	encounter_ui.set_focused_player(character)
	state_machine.transition_to(STANDBY)
