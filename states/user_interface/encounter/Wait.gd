extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Wait` state.
Hides the options and suboptions menus. Goes to the 'Select' state when a player
turn starts.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(WAIT)
	encounter_ui.sub_options.visible = false
	encounter_ui.options.visible = false


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
