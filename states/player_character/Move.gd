extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Move' state.
The Player Character moves from tile to tile along a preset path.
"""


var travel_path: PoolVector3Array


# Set the path_points and start movement.
func enter(_msg := {}) -> void:
	StateMachineBus.encounter_states["PlayerCharacter"] = "Move"
	travel_path = _msg["travel_path"]
	follow_path()
	state_machine.transition_to("Standby")


# Moves the character along to the points of the path.
func follow_path():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	for point in travel_path:
		tween.tween_property(pc, "translation", point, pc.movement_time)
