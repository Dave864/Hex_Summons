class_name SpellButton
extends SubOptionButton
## SubOptionButton that describes a spell.
##
## Derived class of SubOptionButton. Works with Action nodes that describe
## "spells". A spell is an Action with a WispCost node.


signal spell_selected(spell_details)


# Virtual function. Set the spell action details for the button.
func set_option_details(a: Node) -> void:
	# Spell buttons display details for actions, so we cast to check.
	_option_details = a as Action
	$HBoxContainer/Label.set_text(_option_details.name)
	$HBoxContainer/RangeDisplay.update_action(_option_details)
	
	var wisp_cost: WispCost = _option_details.get_node_or_null("WispCost")
	if wisp_cost != null and not wisp_cost.is_met():
		$InactiveFilter.visible = true
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_STOP
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Virtual function. Evaluates the current state of the action to see if the
# option is confirmed.
func _process_button_press() -> void:
	var wisp_cost: WispCost = _option_details.get_node_or_null("WispCost")
	if wisp_cost == null or wisp_cost.is_met():
		emit_signal("spell_selected", _option_details)
