class_name SummonButton
extends SubOptionButton
## SubOptionButton that describes a summon.
##
## Derived class of SubOptionButton. Displays the details of the spawn action of
## a summon, which is identical to a spell. Works with the Summon node of the
## encounter scene, as that organizes summon spawn actions differently compared
## to how spell actions are normally structured.


## Virtual function. Set the action detail node for the button.
func set_option_details(a: Action) -> void:
	# Summon buttons display details for actions, so we cast to check.
	_option_details = a
	$HBoxContainer/Label.set_text(_option_details.name)
	$HBoxContainer/RangeDisplay.update_action(_option_details)


## Populates the UI elements of this node with details relevant to the specified
## summon.
func set_summon_details(summon_name: String, summon_handler: Summon) -> void:
	var spawn_action: Action = summon_handler.spawn_actions[summon_name]
	set_option_details(spawn_action)
	var summon_details: SummonData = summon_handler.available_summons[summon_name]
	if summon_details.wisp_pool_meets_requirements(summon_handler.wisp_pool):
		$InactiveFilter.visible = true
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_STOP
		$InactiveFilter/Label.text = _wisp_cost_text(summon_details)
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Creates a string that describes the components of the WispCost for a summon.
func _wisp_cost_text(summon_details: SummonData) -> String:
	var text: String = "wisp cost\n"
	for element in summon_details.cost_summary:
		text += "{0} -{2}-\n".format(
				[
					Element.Type.find_key(element),
					summon_details.cost_summary[element]
				]
		)
	return text
