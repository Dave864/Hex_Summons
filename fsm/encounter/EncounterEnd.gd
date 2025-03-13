extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `End` state.
Close the game.
TODO: Update this state to instead change to the appropriate scene.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
