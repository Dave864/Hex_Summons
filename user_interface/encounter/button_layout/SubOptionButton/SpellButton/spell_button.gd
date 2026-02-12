class_name SpellButton
extends SubOptionButton
## SubOptionButton that describes a spell.
##
## Derived class of SubOptionButton. Works with Action nodes that describe
## "spells". A spell is an Action with a WispCost node.


## Virtual function. Set the spell action details for the button.
func set_option_details(a: Action) -> void:
	# Spell buttons display details for actions, so we cast to check.
	_option_details = a
	_content_label.set_text(_option_details.name)
	_range_display.update_action(_option_details)
	
	var wisp_cost: WispCost = _option_details.get_node_or_null("WispCost")
	if wisp_cost != null and not wisp_cost.is_met():
		_inactive_filter.visible = true
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_STOP
		_inactive_label.text = _wisp_cost_text(wisp_cost)
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Creates a string that describes the components of the WispCost.
func _wisp_cost_text(wc: WispCost) -> String:
	var cost_text: String = "wisp cost\n"
	for element in wc.cost_summary:
		cost_text += "{0} {1} -{2}-\n".format(
				[
					Element.Type.find_key(element),
					wc.req_summary[element],
					wc.cost_summary[element]
				]
		)
	for element in wc.req_summary:
		if not wc.cost_summary.has(element):
			cost_text += "{0} {1}\n".format(
					[
						Element.Type.find_key(element),
						wc.req_summary[element]
					]
			)
	return cost_text


## Virtual function. Evaluates the current state of the action to see if the
## option is confirmed.
func _process_button_press() -> void:
	var wisp_cost: WispCost = _option_details.get_node_or_null("WispCost")
	if wisp_cost == null or wisp_cost.is_met():
		SignalBus.emit_character_action_selected(_option_details)
