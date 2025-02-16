extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Action` state.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
