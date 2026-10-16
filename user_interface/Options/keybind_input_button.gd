class_name KeybindInputButton
extends Button
## Button that lets a player select the key used for a specific input.
##
## Able to specify the key source for the input (gamepad or mouse & keyboard),
## tracking the selection for each source as a string that is relevant to
## Godot's project input map. Does not override the input, merely specify the
## desired keybind.


## Text displayed when no value is assigned.
const UNASSIGNED := "NONE"
## Shorthand for InputController's GAMEPAD Source enum.
const SOURCE_GAMEPAD := InputController.Source.GAMEPAD
## Shorthand for InputController's KEYBOARD_AND_MOUSE Source enum.
const SOURCE_KEYMOUSE := InputController.Source.KEYBOARD_AND_MOUSE
## Shorthand for InputController's NONE Source enum.
const SOURCE_NONE := InputController.Source.NONE

## The source to look at for the key binding.
@export var key_source := InputController.Source.NONE
## The input the key will be bound to.
@export var input_bind := ""

## Records the keybind values for the given input for each input source.
var key_bind: Dictionary[InputController.Source, String] = {
	SOURCE_GAMEPAD: UNASSIGNED,
	SOURCE_KEYMOUSE: UNASSIGNED,
	SOURCE_NONE: UNASSIGNED,
}


## Sets the display to match the current settings.
func _ready() -> void:
	if InputMap.has_action(input_bind):
		for event: InputEvent in InputMap.action_get_events(input_bind):
			if (
				event is InputEventMouse
				or event is InputEventKey
				and key_bind[SOURCE_KEYMOUSE] == UNASSIGNED
			):
				key_bind[SOURCE_KEYMOUSE] = event.as_text()
			elif (
				event is InputEventJoypadMotion
				or event is InputEventJoypadButton
				and key_bind[SOURCE_GAMEPAD] == UNASSIGNED
			):
				key_bind[SOURCE_GAMEPAD] = event.as_text()
			else:
				# Only a single key from each input source should be exposed
				# by this button, so we only look at the first ones that appear
				# for each input event.
				break
	_update_display()


## Resets the current bindings to unassigned.
func clear_keybinds() -> void:
	key_bind[SOURCE_GAMEPAD] = UNASSIGNED
	key_bind[SOURCE_KEYMOUSE] = UNASSIGNED
	_update_display()


## Resets the current gamepad binding to unassigned.
func clear_gamepad_keybind() -> void:
	key_bind[SOURCE_GAMEPAD] = UNASSIGNED
	_update_display()


## Resets the current keymouse binding to unassigned.
func clear_keymouse_keybind() -> void:
	key_bind[SOURCE_KEYMOUSE] = UNASSIGNED
	_update_display()


## Updates the display to reflect the current keybind.
func _update_display() -> void:
	text = key_bind[key_source]


## Triggers a wait event for a new input key.
func _on_pressed() -> void:
	Popup.new()
	pass # Replace with function body.
