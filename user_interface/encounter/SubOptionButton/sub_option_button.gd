extends MarginContainer
class_name SubOptionButton
## Button that describes a possible sub-option for a given option.
##
## A base class used to describe the common parameters and functionality of
## buttons used to describe either a specific spell, a technique, a summon, or
## an item.


## Indicates when the option described by the button has been selected.
signal option_selected(option_info)

## The details of the option described by this button.
var _option_details: Node = null: get = get_option_details, set = set_option_details
## The player the sub option belongs to.
var _player: PlayerCharacter = null: set = set_player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()


## Virtual function. Set the action details for the button. Can be either an
## action, a summon, or an item depending on the derived class.
func set_option_details(a: Node) -> void:
	_option_details = a
	$Button.set_text(_option_details.name)


## Get the details of the option described the button.
func get_option_details() -> Node:
	return _option_details


## Set the player character reference for the owner of the option this UI element
## describes.
func set_player(p: PlayerCharacter) -> void:
	_player = p


## Sets the right focus neighbor for controller support.
func set_focus_neighbor_right(neighbor: SubOptionButton) -> void:
	$Button.set_focus_neighbor(SIDE_RIGHT, neighbor.get_button().get_path())
	# Prevents the action buttons from being reached while sub options are open.
	$Button.set_focus_neighbor(SIDE_BOTTOM, "")
	neighbor.set_focus_neighbor(SIDE_LEFT, $Button.get_path())


## Returns the "Button" node.
func get_button() -> Node:
	return $Button


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var button_node: Button = get_node_or_null("Button")
	assert(
			button_node != null,
			"SubOptionButton %s does not have a Button node." % [name]
	)


## Virtual function. The behavior that is to happen when the button is pressed.
## By default, it will simply emit the "option_selected" signal.
func _process_button_press() -> void:
	emit_signal("option_selected", _option_details)


## Catches the signal for when the button is pressed.
func _on_Button_pressed() -> void:
	_process_button_press()
