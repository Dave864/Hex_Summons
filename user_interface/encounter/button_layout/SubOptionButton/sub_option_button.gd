class_name SubOptionButton
extends Button
## Button that describes a possible sub-option for a given option.
##
## A base class used to describe the common parameters and functionality of
## buttons used to describe either a specific spell, a technique, a summon, or
## an item.


## The details of the option described by this button.
var _option_details: Action = null

## The description for the action displayed.
@onready var _content_label: Label = $MarginContainer/HBoxContainer/Label
## The display for the action's range data.
@onready var _range_display: RangeDisplay = $MarginContainer/HBoxContainer/RangeDisplay
## Panel that obfuscates the details of the action to indicate that it is
## unavailable as an option. Used in child classes.
@warning_ignore("unused_private_class_variable")
@onready var _inactive_filter: Panel = $MarginContainer/InactiveFilter
## Label describing the cost requirements needed for the action to be available.
## Set and used in child classes.
@warning_ignore("unused_private_class_variable")
@onready var _inactive_label: Label = $MarginContainer/InactiveFilter/Label


## Virtual function. Set the action details for the button. Can be either an
## action, a summon, or an item depending on the derived class.
func set_option_details(a: Action) -> void:
	_option_details = a
	_range_display.update_action(_option_details)
	_content_label.text = _option_details.name


## Get the details of the option described the button.
func get_option_details() -> Action:
	return _option_details


## Sets the right focus neighbor for controller support.
func set_focus_neighbor_right(neighbor: SubOptionButton) -> void:
	set_focus_neighbor(SIDE_RIGHT, neighbor.get_path())
	focus_next = neighbor.get_path()
	# Prevents the action buttons from being reached while sub options are open.
	set_focus_neighbor(SIDE_BOTTOM, "")
	neighbor.set_focus_neighbor(SIDE_LEFT, get_path())
	neighbor.focus_previous = get_path()


## Virtual function. The behavior that is to happen when the button is pressed.
## By default, the SignalBus will emit the "character_action_selected" signal.
func _process_button_press() -> void:
	SignalBus.emit_character_action_selected(_option_details)


## Catches the signal for when the button is pressed.
func _on_pressed() -> void:
	_process_button_press()
