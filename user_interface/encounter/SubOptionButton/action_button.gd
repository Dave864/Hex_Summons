class_name ActionButton
extends SubOptionButton
"""
Button that describes a possible action for a given option.
"""


# Set the action details for the button.
func set_action_details(a: Action) -> void:
	_action_details = a
	$Button.set_text(_action_details.name)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var button_node: Button = get_node_or_null("Button")
	assert(
			button_node != null,
			"ActionNode node does not have a Button node."
	)
