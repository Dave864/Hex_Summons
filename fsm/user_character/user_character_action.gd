@abstract
class_name UserCharacterAction
extends UserCharacterState
## The logic for what happens when a Character controlled by the user is in the
## 'Action' state.
##
## The Character executes the provided action and then goes to the 'Wait'
## state.


## Virtual function. Called by the state machine upon changing the active state. 
## The `msg` parameter is a dictionary with arbitrary data the state can use to 
## initialize itself.
func enter(msg := {}) -> void:
	var action: Action = msg["action"]
	var targets: Array = msg["targets"]
	_change_target_state(targets, true)
	await action.execute_action()
	_change_target_state(targets, false)
	character.emit_turn_ended()
	_spend_resource_for_action(action)
	state_machine.transition_to(WAIT)


## Changes the state of the targets.
func _change_target_state(targets: Array, active: bool) -> void:
	for t in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()


## Triggers any logic that spends resources associated with an action.
@abstract func _spend_resource_for_action(action: Action) -> void
