class_name PopupConfirmInput
extends Panel
## Popup that prompts for the user to provide input.
##
## Informs the user if a different input source is used other than the one that
## triggered a key rebind.


## The text that displays when the popup first appears.
const ENTER_INPUT_TEXT := "Enter Input."
## The text that displays when switching to keyboard input when expecting input
## from gamepad.
const GAMEPAD_EXPECTED_TEXT := (
		"Detecting input from Keyboard!\nExpecting input from Gamepad."
)
## The text that displays when switching to gamepad input when expecting input
## from keyboard.
const KEYMOUSE_EXPECTED_TEXT := (
		"Detecting input from Gamepad!\nExpecting input from Keyboard."
)

## Expected input source.
var expected_input_source: InputController.Source

## The last focused control.
var _prior_focus: Control

## Label that displays the popup messages.
@onready var popup_label: Label = $Label


## Updates popup text if input source is different from what is expected.
func _process(_delta: float) -> void:
	if not visible:
		return
	if InputController.get_source() != expected_input_source:
		if expected_input_source == InputController.Source.GAMEPAD:
			popup_label.text = GAMEPAD_EXPECTED_TEXT
		else:
			popup_label.text = KEYMOUSE_EXPECTED_TEXT


## Reveals this popup when a KeybindInputButton requests a new input bind.
func _on_KeybindInputButton_new_bind_requested(
	input_source: InputController.Source
) -> void:
	expected_input_source = input_source
	popup_label.text = ENTER_INPUT_TEXT
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	show()
	_prior_focus = get_viewport().gui_get_focus_owner()
	grab_focus()


## Hides this popup when KeybindInputButton sets a new input bind.
func _on_KeybindInputButton_new_bind_set(_id: int) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hide()
	_prior_focus.call_deferred("grab_focus")
