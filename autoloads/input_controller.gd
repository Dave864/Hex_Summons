extends Node
"""
Manages swapping between input sources.
"""


enum Source {
	KEYBOARD_AND_MOUSE,
	GAMEPAD,
	NONE
}

var _source: int = Source.NONE setget, get_source


# Gets the current input source.
func get_source() -> int:
	return _source


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Swaps between gamepad and mouse & keyboard input.
func _input(event: InputEvent) -> void:
	var left_dir_vec: Vector2 = GamepadHandler.left_joystick_dir()
	var right_dir_vec: Vector2 = GamepadHandler.right_joystick_dir()
	if (
		(event is InputEventMouse or event is InputEventKey)
		and not _source == Source.KEYBOARD_AND_MOUSE
	):
		_swap_to_mouse_keyboard()
	elif (
		(
			event is InputEventJoypadMotion
			and (left_dir_vec != Vector2.ZERO or right_dir_vec != Vector2.ZERO)
		) or event is InputEventJoypadButton
		and not _source == Source.GAMEPAD
	):
		_swap_to_gamepad()


# Reveals the mouse cursor at the last recorded position.
func _swap_to_mouse_keyboard() -> void:
	MouseHandler.activate()
	_source = Source.KEYBOARD_AND_MOUSE


# Hides the mouse cursor.
func _swap_to_gamepad() -> void:
	MouseHandler.deactivate()
	_source = Source.GAMEPAD
