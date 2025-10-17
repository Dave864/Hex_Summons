extends MarginContainer
class_name SubOptionButton
"""
Button that describes a possible sub-option for a given option.
"""


# Indicates when the option described by the button has been selected.
signal option_selected(option_info)

var _option_details: Node = null: get = get_option_details, set = set_option_details
var _player: PlayerCharacter = null: set = set_player


# Set the action details for the button.
func set_option_details(a: Node) -> void:
	_option_details = a
	$Button.set_text(_option_details.name)


# Get the action details for the button.
func get_option_details() -> Node:
	return _option_details


# Set the player character reference for the owner of the action this UI element
# describes.
func set_player(p: PlayerCharacter) -> void:
	_player = p


# Sets the right focus neighbor for controller support.
func set_focus_neighbor_right(neighbor: SubOptionButton) -> void:
	$Button.set_focus_neighbor(MARGIN_RIGHT, neighbor.get_button().get_path())
	# Prevents the action buttons from being reached whil sub options are open.
	$Button.set_focus_neighbor(MARGIN_BOTTOM, "")
	neighbor.set_focus_neighbor(MARGIN_LEFT, $Button.get_path())


# Returns the "Button" node.
func get_button() -> Node:
	return $Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()


# Virtual function. Evaluates the current state of the action to see if the
# option is confirmed.
func _process_button_press() -> void:
	emit_signal("option_selected", _option_details)


# Emit a signal indicating that the button was pressed.
func _on_Button_pressed() -> void:
	_process_button_press()


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var button_node: Button = get_node_or_null("Button")
	assert(
			button_node != null,
			"SubOptionButton %s does not have a Button node." % [name]
	)
