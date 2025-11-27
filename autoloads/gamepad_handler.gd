extends Node
## Handles the detection and management of gamepad input.


## Indicates that the left joystick has sent an input signal from being held.
signal left_joystick_pulsed(direction)
## Indicates that the right joystick has sent an input signal from being held.
signal right_joystick_pulsed(direction)

## The time it takes for holding a joystick direction to emit a "pulse".
const PULSE_TIME: float = 0.3

## Flag for left joystick hold.
var _left_hold: bool = false
## Flag for right joystick hold.
var _right_hold: bool = false
## Timer for left joystick pulse.
var _left_joystick_time: float = 0.0
## Timer for right joystick pulse.
var _right_joystick_time: float = 0.0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_left_hold = false
	_right_hold = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		_left_hold = left_joystick_dir() != Vector2.ZERO
		_left_joystick_time = 0.0 if not _left_hold else _left_joystick_time
		_right_hold = right_joystick_dir() != Vector2.ZERO
		_right_joystick_time = 0.0 if not _right_hold else _right_joystick_time


func _process(delta: float) -> void:
	if _left_hold:
		_handle_left_pulse(delta)
	if _right_hold:
		_handle_right_pulse(delta)


## Get the direction of the left joystick input.
func left_joystick_dir() -> Vector2:
	return Input.get_vector(
			"left_joystick_l",
			"left_joystick_r",
			"left_joystick_u",
			"left_joystick_d"
	)


## Get the direction of the right joystick input.
func right_joystick_dir() -> Vector2:
	return Input.get_vector(
			"right_joystick_l",
			"right_joystick_r",
			"right_joystick_u",
			"right_joystick_d"
	)


## Updates the timer for left pulse.
func _handle_left_pulse(delta: float) -> void:
	if is_zero_approx(_left_joystick_time):
		emit_signal("left_joystick_pulsed", left_joystick_dir())
	_left_joystick_time += delta
	if _left_joystick_time > PULSE_TIME:
		_left_joystick_time = 0.0


## Updates the timer for right pulse.
func _handle_right_pulse(delta: float) -> void:
	if is_zero_approx(_right_joystick_time):
		emit_signal("right_joystick_pulsed", right_joystick_dir())
	_right_joystick_time += delta
	if _right_joystick_time > PULSE_TIME:
		_right_joystick_time = 0.0
