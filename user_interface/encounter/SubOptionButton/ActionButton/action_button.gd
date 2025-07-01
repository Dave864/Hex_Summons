class_name ActionButton
extends SubOptionButton
"""
Button that describes a possible action for a given option.
"""


# Set the action details for the button.
func set_option_details(a: Node) -> void:
	_option_details = a
	$HBoxContainer/Label.set_text(_option_details.name)
	$HBoxContainer/RangeDisplay.update_action(_option_details)
