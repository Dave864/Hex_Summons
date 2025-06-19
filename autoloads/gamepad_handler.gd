extends Node
"""
Handles the detection and management of gamepad input. Allows for joystick holding
to be considered a sequence of taps.
"""


signal left_joystick_pulsed(direction)
signal right_joystick_pulsed(direction)

# The time it takes for holding a joystick direction to emit a "pulse".
const JOYSTICK_PULSE_TIME: float = 0.0

# Timer for left joystick pulse.
var _left_joystick_time: float = 0.0
# Timer for right joystick pulse.
var _right_joystick_time: float = 0.0


# Get the direction of the left joystick input.
func left_joystick_dir() -> Vector2:
	return Input.get_vector(
			"left_joystick_l",
			"left_joystick_r",
			"left_joystick_u",
			"left_joystick_d"
	)


# Get the direction of the right joystick input.
func right_joystick_dir() -> Vector2:
	return Input.get_vector(
			"right_joystick_l",
			"right_joystick_r",
			"right_joystick_u",
			"right_joystick_d"
	)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event: InputEvent):
	pass
