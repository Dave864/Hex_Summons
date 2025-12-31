class_name SummonCharacterAction
extends UserCharacterAction
## The logic for what happens when a Summon character is in the
## 'Action' state.
##
## The Character executes the provided action and then goes to the 'Wait'
## state.


## The wisps in the summon pool are returned back to the player characters
## active in the encounter.
func _spend_resource_for_action(action: Action) -> void:
	var wisp_cost: WispCost = action.get_node_or_null("WispCost")
	if wisp_cost != null:
		WispController.pay_cost_from_active_summon(
				character.summon_wisp_pool,
				wisp_cost
		)
