extends MarginContainer
class_name SubOptionsButton
"""
Button that describes a possible sub-option for a given option.
"""


# Indicates when the option described by the button has been selected.
signal action_selected(action_info)

var _action_details: Action = null setget set_action_details, get_action_details
var _player: PlayerCharacter = null setget set_player


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


# Set the player character reference for the owner of the action this UI element
# describes.
func set_player(p: PlayerCharacter) -> void:
	_player = p


# Sets the right focus neighbor for controller support.
func set_focus_neighbor_right(neighbor: SubOptionsButton) -> void:
	$Button.set_focus_neighbour(MARGIN_RIGHT, neighbor.get_button().get_path())
	# Prevents the action buttons from being reached whil sub options are open.
	$Button.set_focus_neighbour(MARGIN_BOTTOM, "")
	neighbor.set_focus_neighbour(MARGIN_LEFT, $Button.get_path())


# Returns the "Button" node.
func get_button() -> Node:
	return $Button


# Emit a signal indicating that the button was pressed.
func _on_Button_pressed() -> void:
	emit_signal("action_selected", _action_details)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var button_node: Button = get_node_or_null("Button")
	assert(
			button_node != null,
			"SubOptions node does not have a Button node."
	)
