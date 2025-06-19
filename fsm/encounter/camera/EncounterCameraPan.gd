extends EncounterCameraState
"""
The logic for what happens when an EncounterCamera scene is in the `Pan` state.
The encounter camera is moved around a rotation point based on given mouse or
joystick input. Goes to the 'Reset' state when the assigned input is recieved.
"""


# Flag indicating that the camera should pan based on mouse movement.
var pan_camera: bool = false
# Flag indicating that the joystick is being used for movement.
var joystick_pan: bool = false
# The value of the mouse motion.
var mouse_motion: Vector2 = Vector2.ZERO


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_camera_pan"):
		pan_camera = true
	if event.is_action_released("ui_camera_pan"):
		pan_camera = false
		state_machine.transition_to(NORMALIZE)
	if event.is_action_pressed("ui_camera_reset"):
		state_machine.transition_to(RESET)
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
	if event is InputEventMouse and pan_camera:
		enc_camera.vertical_pan_mouse(mouse_motion.y)
		enc_camera.lateral_pan_mouse(mouse_motion.x)
	if event is InputEventJoypadMotion:
		var camera_move: Vector2 = GamepadHandler.right_joystick_dir()
		if joystick_pan and is_zero_approx(camera_move.x):
			joystick_pan = false
			state_machine.transition_to(NORMALIZE)
		elif !joystick_pan and !is_zero_approx(camera_move.x):
			joystick_pan = true


# Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	enc_camera.vertical_pan_joystick(delta)
	enc_camera.lateral_pan_joystick(delta)
