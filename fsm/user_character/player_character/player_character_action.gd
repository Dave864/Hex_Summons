class_name PlayerCharacterAction
extends UserCharacterAction
## The logic for what happens when a Player Character is in the 'Action' state.
##
## The Player Character executes the provided action and then goes to the 'Wait'
## state.


func _spend_resource_for_action(action: Action) -> void:
	_activate_cooldown(action)
	_pay_wisp_cost(action)


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
		WispController.pay_cost_from_player(character.wisp_pool, wisp_cost)
