extends PlayerCharacterState
## The logic for what happens when a Player Character is in the 'Action' state.
## The Player Character executes the provided action and then goes to the 'Wait'
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
	pc.emit_turn_ended()
	_activate_cooldown(action)
	_pay_wisp_cost(action)
	state_machine.transition_to(WAIT)


## Changes the state of the targets.
func _change_target_state(targets: Array, active: bool) -> void:
	for t in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()


## Activates the cooldown of an action if present.
func _activate_cooldown(action: Action) -> void:
	var cooldown: Cooldown = action.get_node_or_null("Cooldown")
	if cooldown != null:
		cooldown.start_countdown()


## Updates the WispPool of the player character if the action requires paying
## a wisp cost.
func _pay_wisp_cost(action: Action) -> void:
	var wisp_cost: WispCost = action.get_node_or_null("WispCost")
	if wisp_cost != null:
		pass
