extends EncounterCameraState
"""
The logic for what happens when an EncounterCamera scene is in the `Pan` state.
The encounter camera is moved around a rotation point based on given mouse or
joystick input. Goes to the 'Reset' state when the assigned input is recieved.
"""


# The index position of a hex tile that is considered to be the top, relative
# to the camera position.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
var relative_top_vertex: int = 0
# Flag indicating that mouse input is to be used.
var _mouse_active: bool = false
# Flag indicating that the camera should pan based on mouse movement.
var _pan_camera: bool = false
# The value of the mouse motion.
var _mouse_motion: Vector2 = Vector2.ZERO


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	relative_top_vertex = 0


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	_mouse_active = _event is InputEventMouse
	if _event.is_action_pressed("ui_camera_pan"):
		_pan_camera = true
	if _event.is_action_released("ui_camera_pan"):
		_pan_camera = false
	if _event is InputEventMouseMotion:
		_mouse_motion = _event.relative
	if _mouse_active and _pan_camera:
		enc_camera.vertical_pan_mouse(_mouse_motion.y)
		enc_camera.lateral_pan_mouse(_mouse_motion.x)
	if _event.is_action_pressed("ui_camera_reset"):
		print("reset camera")


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	enc_camera.vertical_pan_joystick(_delta)
	enc_camera.lateral_pan_joystick(_delta)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
