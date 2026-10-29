extends Node
## Manages swapping between input sources.


## Indicates that the source for the input has changed.
signal input_source_changed()

## The options for input sources.
enum Source {
	KEYBOARD_AND_MOUSE,
	GAMEPAD,
	NONE,
}

## The current source of input.
var _source := Source.GAMEPAD: get = get_source
## Flag indicating that we are pausing signaling source changed to gamepad to
## allow for mouse hover to clear.
var _paused_for_hover_clear := false


## Swaps between gamepad and mouse & keyboard input.
func _input(event: InputEvent) -> void:
	# Return early for joypad motion when pausing to prevent stutter switchng
	# between input sources.
	if (
			_source == Source.NONE
			or (
				_paused_for_hover_clear
				and event is InputEventJoypadMotion
			)
	):
		return
	elif _paused_for_hover_clear:
		_paused_for_hover_clear = false
		input_source_changed.emit()
	elif (
			(event is InputEventMouse or event is InputEventKey)
			and not source_is_keymouse()
	):
		_swap_to_mouse_keyboard()
	elif (
			(
				event is InputEventJoypadMotion
				and (
					not GamepadHandler.left_joystick_dir().is_zero_approx()
					or not GamepadHandler.right_joystick_dir().is_zero_approx()
				)
			) or event is InputEventJoypadButton
			and not source_is_gamepad()
	):
		_swap_to_gamepad()


## Gets the current input source.
func get_source() -> Source:
	return _source


## Determines if the input source is from gamepad.
func source_is_gamepad() -> bool:
	return _source == Source.GAMEPAD


## Determines if the input source is from keyboard and mouse
func source_is_keymouse() -> bool:
	return _source == Source.KEYBOARD_AND_MOUSE


## Reveals the mouse cursor at the last recorded position.
func _swap_to_mouse_keyboard() -> void:
	MouseHandler.activate()
	_source = Source.KEYBOARD_AND_MOUSE
	input_source_changed.emit()


## Hides the mouse cursor and readies the input to swap.
func _swap_to_gamepad() -> void:
	MouseHandler.deactivate()
	_source = Source.GAMEPAD
	_paused_for_hover_clear = true
