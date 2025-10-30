class_name SpellButton
extends SubOptionButton
"""
Button that describes a possible spell.
"""


# Set the action details for the button.
func set_option_details(a: Node) -> void:
	_option_details = a as Action
	$HBoxContainer/Label.set_text(_option_details.name)
	$HBoxContainer/RangeDisplay.update_action(_option_details)
	
	var cooldown: Cooldown = _option_details.get_node_or_null("Cooldown")
	if cooldown != null and cooldown.is_active():
		$InactiveFilter.visible = true
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_STOP
		$InactiveFilter/Label.text = str(cooldown.get_countdown())
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$InactiveFilter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$InactiveFilter/Label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Virtual function. Evaluates the current state of the action to see if the
# option is confirmed.
func _process_button_press() -> void:
	var cooldown: Cooldown = _option_details.get_node_or_null("Cooldown")
	if cooldown == null or not cooldown.is_active():
		emit_signal("option_selected", _option_details)
