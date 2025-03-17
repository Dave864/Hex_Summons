extends EncounterCameraState
"""
The logic for what happens when an EncounterCamera scene is in the `Reset` state.
The encounter camera is repositioned so that it is back at its starting orientation.
Goes to the 'Pan' state when repositioning is finished.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
