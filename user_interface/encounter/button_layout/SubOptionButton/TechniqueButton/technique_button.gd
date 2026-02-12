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
	_content_label.set_text(_option_details.name)
	_range_display.update_action(_option_details)
	
	var cooldown: Cooldown = _option_details.get_node_or_null("Cooldown")
	if cooldown != null and cooldown.is_active():
		_inactive_filter.visible = true
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_STOP
		_inactive_label.text = str(cooldown.get_countdown())
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		_inactive_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_inactive_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Virtual function. Evaluates the current state of the action to see if the
## option is confirmed.
func _process_button_press() -> void:
	var cooldown: Cooldown = _option_details.get_node_or_null("Cooldown")
	if cooldown == null or not cooldown.is_active():
		SignalBus.emit_character_action_selected(_option_details)
