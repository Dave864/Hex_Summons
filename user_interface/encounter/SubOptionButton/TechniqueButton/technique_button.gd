class_name TechniqueButton
extends SubOptionButton
## SubOptionButton that describes a technique.
##
## Derived class of SubOptionButton. Works with Action nodes that describe
## "techniques". A technique is an Action with a Cooldown node.


## Virtual function. Set the technique action details for the button.
func set_option_details(a: Action) -> void:
	# Technique buttons display details for actions, so we cast to check.
	_option_details = a
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


## Virtual function. Evaluates the current state of the action to see if the
## option is confirmed.
func _process_button_press() -> void:
	var cooldown: Cooldown = _option_details.get_node_or_null("Cooldown")
	if cooldown == null or not cooldown.is_active():
		SignalBus.emit_character_action_selected(_option_details)
