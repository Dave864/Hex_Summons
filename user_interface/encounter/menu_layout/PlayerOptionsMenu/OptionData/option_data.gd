class_name OptionData
extends Panel
## A panel that displays the details of an action.
##
## Able to show details for techniques and spells.


## The panel display for the range of the action.
@onready var _range_display: RangeDisplay = $RangeDisplay
## The label that describes the cost for the action, either cooldown or wisp.
@onready var _cost_label: Label = $Cost


## Updates the display with the details of the action.
func update_action(new_action: Action) -> void:
	_range_display.update_action(new_action)
	var cooldown_node: Cooldown = new_action.get_node_or_null("Cooldown")
	if cooldown_node != null:
		_cost_label.text = get_cooldown_text(cooldown_node)
		return
	var wisp_cost_node: WispCost = new_action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text = get_wisp_cost_text(wisp_cost_node)
		return


## Creates a string that describes the cooldown for an action.
func get_cooldown_text(cooldown: Cooldown) -> String:
	var text: String = "cooldown: {0}/{1}"
	text.format([cooldown.get_countdown(), cooldown.turn_count])
	return text


## Creates a string that describes the wisp cost for an action.
func get_wisp_cost_text(wc: WispCost) -> String:
	var text: String = "wisp cost\n"
	for element in wc.cost_summary:
		text += "{0} {1} -{2}-\n".format(
				[
					Element.Type.find_key(element),
					wc.req_summary[element],
					wc.cost_summary[element]
				]
		)
	for element in wc.req_summary:
		if not wc.cost_summary.has(element):
			text += "{0} {1}\n".format(
					[
						Element.Type.find_key(element),
						wc.req_summary[element]
					]
			)
	return text


## Updates the data details to reflect the selected action.
func _on_ActionOptionButton_action_selected(action: Action) -> void:
	update_action(action)
