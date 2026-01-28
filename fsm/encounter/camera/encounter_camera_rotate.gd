class_name EncounterCameraRotate
extends EncounterCameraState
## The logic for what happens when an EncounterCamera scene is in the `Rotate`
## state.
##
## The encounter camera is moved around a rotation point based on given mouse or
## joystick input. Goes to the 'Reset' state when the assigned input is recieved.


## Flag indicating that the camera should rotate based on mouse movement.
var rotate_camera: bool = false
## Flag indicating that the joystick is being used for movement.
var joystick_rotate: bool = false
## The value of the mouse motion.
var mouse_motion: Vector2 = Vector2.ZERO


## Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_camera_pan"):
		rotate_camera = true
		if not enc_camera.is_focus_point_locked():
			enc_camera.disable_edge_detection()
	if event.is_action_released("ui_camera_pan"):
		rotate_camera = false
		if not enc_camera.is_focus_point_locked():
			enc_camera.enable_edge_detection()
		state_machine.transition_to(NORMALIZE)
	if event.is_action_pressed("ui_camera_reset"):
		state_machine.transition_to(RESET)
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
	if event is InputEventMouse and rotate_camera:
		enc_camera.vertical_rotation_mouse(mouse_motion.y)
		enc_camera.lateral_rotation_mouse(mouse_motion.x)
	if event is InputEventJoypadMotion:
		var camera_move: Vector2 = GamepadHandler.right_joystick_dir()
		if joystick_rotate and is_zero_approx(camera_move.x):
			joystick_rotate = false
			state_machine.transition_to(NORMALIZE)
		elif !joystick_rotate and !is_zero_approx(camera_move.x):
			joystick_rotate = true


## Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	enc_camera.vertical_rotation_joystick(delta)
	enc_camera.lateral_rotation_joystick(delta)
