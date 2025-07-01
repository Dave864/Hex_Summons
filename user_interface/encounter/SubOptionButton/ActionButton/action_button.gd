class_name ActionButton
extends SubOptionButton
"""
Button that describes a possible action for a given option.
"""


func _ready() -> void:
	_check_for_required_parameters()
	_option_details = get_node(option_ref)
	
	$HBoxContainer/Label.set_text(_option_details.name)
	$HBoxContainer/RangeDisplay.update_range_display(_option_details)
