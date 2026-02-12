class_name SummonButton
extends SubOptionButton
## SubOptionButton that describes a summon.
##
## Derived class of SubOptionButton. Displays the details of the spawn action of
## a summon, which is identical to a spell. Works with the Summon node of the
## encounter scene, as that organizes summon spawn actions differently compared
## to how spell actions are normally structured.


## The name of the summon the displayed spawn action is for.
var _summon_name: String = ""
## The handler for the encounter scene summon.
var _summon_handler: Summon = null


## Returns the name of the summon whose spawn action is displayed.
func get_summon_name() -> String:
	return _summon_name


## Virtual function. Set the action detail node for the button.
func set_option_details(a: Action) -> void:
	# Summon buttons display details for actions, so we cast to check.
	_option_details = a
	_range_display.update_action(_option_details)


## Populates the UI elements of this node with details relevant to the specified
## summon.
func set_summon_details(summon_name: String, summon_handler: Summon) -> void:
	_summon_handler = summon_handler
	_summon_name = summon_name
	_content_label.set_text(_summon_name)
	var spawn_action: Action = _summon_handler.spawn_actions[_summon_name]
	set_option_details(spawn_action)
	var summon_details: SummonData = _summon_handler.available_summons[_summon_name]
	if summon_details.wisp_pool_meets_requirements(WispController.standby_pool):
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		_inactive_filter.visible = true
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_STOP
		_inactive_label.text = _wisp_cost_text(summon_details)
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_STOP


## Creates a string that describes the components of the WispCost for a summon.
func _wisp_cost_text(summon_details: SummonData) -> String:
	var cost_text: String = "wisp cost\n"
	var cost: Dictionary[Element.Type, int] = summon_details.cost_summary()
	for element: Element.Type in cost:
		cost_text += "{0} -{2}-\n".format(
				[
					Element.Type.find_key(element),
					cost[element]
				]
		)
	return cost_text


## Virtual function. The behavior that is to happen when the button is pressed.
## Emits the "spawn_action_selected" signal and updates the WispCost data of the 
## spawn action described by this button to match the wisp cost of the summon
## the spawn action is for.
func _process_button_press() -> void:
	if _summon_handler == null or _summon_name == "":
		printerr("No summon handler or summon name specified for SummonButton.")
		return
	_summon_handler.set_cost_for_spawn_action(_summon_name)
	SignalBus.emit_spawn_action_selected(_summon_name, _option_details)
