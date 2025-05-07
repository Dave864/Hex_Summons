extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Wait` state.
Hides the options and suboptions menus. Goes to the 'Select' state when a player
turn starts.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.hide()
	encounter_ui.options.hide()
	encounter_ui.active_player_stats.hide()
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
		encounter_ui,
		"set_FSM_to_standby",
		self,
		"_on_EncounterUI_set_FSM_to_standby"
	)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	encounter_ui.disconnect(
		"set_FSM_to_standby",
		self,
		"_on_EncounterUI_set_FSM_to_standby"
	)


# Wait for the EncounterUI object to recieve signal that user input needs to
# be obtained.
func _on_EncounterUI_set_FSM_to_standby() -> void:
	state_machine.transition_to(STANDBY)
