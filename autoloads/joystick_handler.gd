extends Control
"""
Handles the detection and management of joystick input. Allows for tap behavior
and holding to be considered a sequence of taps instead of a continuous ipnut.
"""


# Flag that tracks if the mouse is being used for input or not.
var _mouse_active: bool = false
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
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scale_to_window()


func _input(event: InputEvent):
	if event is InputEventMouse and not _mouse_active:
		_mouse_active = true
		_swap_to_mouse()
	elif not event is InputEventMouse and _mouse_active:
		_mouse_active = false
		_swap_to_joystick()


# Reveals the mouse cursor at the last recorded position.
func _swap_to_mouse() -> void:
	print("mouse swap")
	warp_mouse(_mouse_position)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


# Hides the mouse cursor.
func _swap_to_joystick() -> void:
	print("joystick swap")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


# Scales the viewport size to match the window.
func _scale_to_window() -> void:
	rect_size = OS.window_size
