extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Pause` state.
Disables all interactable UI elements until they are needed.
"""


# Virtual function. Called by the state machine upon changing the active state. 
# The `msg` parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.toggle_options()
	
	# This signal is used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
			encounter_ui,
			"set_FSM_to_standby",
			self,
			"_on_EncounterUI_set_FSM_to_standby"
	)


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine before changing the active 
# state. Use this function to clean up the state.
func exit() -> void:
	encounter_ui.toggle_options()
	encounter_ui.disconnect(
			"set_FSM_to_standby",
			self,
			"_on_EncounterUI_set_FSM_to_standby"
	)


# Wait for the EncounterUI object to recieve signal that the selector is required.
func _on_EncounterUI_set_FSM_to_standby() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(STANDBY)
