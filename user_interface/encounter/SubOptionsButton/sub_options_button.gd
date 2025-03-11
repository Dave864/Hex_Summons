extends MarginContainer
class_name SubOptionsButton
"""
Button that describes a possible sub-option for a given option.
"""


var _action_details: Action = null setget set_action_details, get_action_details


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Set the action details for the button.
func set_action_details(a: Action) -> void:
	_action_details = a
	$Button.set_text(_action_details.name)


# Get the action details for the button.
func get_action_details() -> Action:
	return _action_details


# Sets the right focus neighbor for controller support.
func set_focus_neighbor_right(neighbor: SubOptionsButton) -> void:
	$Button.set_focus_neighbour(MARGIN_RIGHT, neighbor.get_button().get_path())
	neighbor.set_focus_neighbour(MARGIN_LEFT, $Button.get_path())


# Returns the "Button" node.
func get_button() -> Node:
	return $Button


# Emit a signal indicating that the button was pressed.
func _on_Button_pressed() -> void:
	SignalBus.emit_signal("player_action_selected", _action_details)


# Emit a signal indicating that the button was hovered over.
func _on_Button_mouse_entered() -> void:
	pass
#	SignalBus.emit_signal("player_action_hovered", _action_details)
