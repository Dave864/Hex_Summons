extends Control
"""
Handles the detection and management of joystick input. Allows for tap behavior
and holding to be considered a sequence of taps instead of a continuous ipnut.
"""


enum InputSource {
	MOUSE,
	JOYSTICK,
	NONE
}


var input_source: int = InputSource.NONE
# Keeps track of the mouse position. Used for switching between joypad and mouse
# input.
var _mouse_position: Vector2 = Vector2.ZERO


# Updates the recorded mouse position.
func update_mouse_tracker_2d(pos: Vector2) -> void:
	_mouse_position = pos


# Updates the recorded mouse position for a 3d coordinate.
func update_mouse_tracker_3d(pos: Vector3) -> void:
	_mouse_position = get_viewport().get_camera().unproject_position(pos)


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_mouse_tracker_2d(get_viewport().get_mouse_position())
	_scale_to_window()


func _input(event: InputEvent):
	var left_dir_vec: Vector2 = _left_joystick_dir()
	var right_dir_vec: Vector2 = _right_joystick_dir()
	if event is InputEventMouse and not input_source == InputSource.MOUSE:
		_swap_to_mouse()
	elif (
		event is InputEventJoypadMotion
		and (left_dir_vec != Vector2.ZERO or right_dir_vec != Vector2.ZERO)
		and not input_source == InputSource.JOYSTICK
	):
		_swap_to_joystick()


# Get the direction of the left joystick input.
func _left_joystick_dir() -> Vector2:
	return Input.get_vector(
			"left_joystick_l",
			"left_joystick_r",
			"left_joystick_u",
			"left_joystick_d"
	)


# Get the direction of the right joystick input.
func _right_joystick_dir() -> Vector2:
	return Input.get_vector(
			"right_joystick_l",
			"right_joystick_r",
			"right_joystick_u",
			"right_joystick_d"
	)


# Reveals the mouse cursor at the last recorded position.
func _swap_to_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	warp_mouse(_mouse_position)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	input_source = InputSource.MOUSE


# Hides the mouse cursor.
func _swap_to_joystick() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_source = InputSource.JOYSTICK


# Scales the viewport size to match the window.
func _scale_to_window() -> void:
	rect_size = OS.window_size
