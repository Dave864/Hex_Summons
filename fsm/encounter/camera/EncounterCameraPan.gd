extends EncounterCameraState
"""
The logic for what happens when an EncounterCamera scene is in the `Pan` state.
The encounter camera is moved around a rotation point based on given mouse or
joystick input. Goes to the 'Reset' state when the assigned input is recieved.
"""


# Flag indicating that the camera should pan based on mouse movement.
var pan_camera: bool = false
# Flag indicating that the joystick is being used for movement.
var joytick_pan: bool = false
# The value of the mouse motion.
var mouse_motion: Vector2 = Vector2.ZERO


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	enc_camera.set_relative_top_vertex(0)


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
		var camera_move: Vector2 = Vector2(
				Input.get_axis("ui_camera_d", "ui_camera_u"),
				Input.get_axis("ui_camera_l", "ui_camera_r")
		)
		if joytick_pan and camera_move == Vector2.ZERO:
			joytick_pan = false
			state_machine.transition_to(NORMALIZE)
		elif !joytick_pan and camera_move != Vector2.ZERO:
			joytick_pan = true


# Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	enc_camera.vertical_pan_joystick(delta)
	enc_camera.lateral_pan_joystick(delta)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
