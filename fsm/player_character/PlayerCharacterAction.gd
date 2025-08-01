extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Action' state.
The Player Character executes the provided action and then goes to the 'Wait'
state.
"""


# Virtual function. Called by the state machine upon changing the active state. 
# The `msg` parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(msg := {}) -> void:
	var action: Action = msg["action"]
	var targets: Array = msg["targets"]
	_change_target_state(targets, true)
	yield(action.execute_action(), "completed")
	_change_target_state(targets, false)
	SignalBus.emit_player_turn_ended(pc)
	state_machine.transition_to(WAIT)


# Changes the state of the targets.
func _change_target_state(targets: Array, active: bool) -> void:
	for t in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()
