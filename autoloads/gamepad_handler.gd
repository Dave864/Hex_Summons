extends Node
## Handles the detection and management of gamepad input.


## Indicates that the left joystick has sent an input signal from being held.
signal left_joystick_pulsed(direction)
## Indicates that the right joystick has sent an input signal from being held.
signal right_joystick_pulsed(direction)

## The time it takes for holding a joystick direction to echo.
const ECHO_TIME: float = 0.25
## The time it takes for holding a joystick direction to quickly echo.
const FAST_ECHO_TIME: float = 0.1
## The number of echoes required before using fast echo time.
const FAST_TIME_ECHO_COUNT: int = 2

## Flag for left joystick hold.
var _left_hold: bool = false
## Flag for right joystick hold.
var _right_hold: bool = false
## Timer for left joystick echo.
var _left_joystick_time: float = 0.0
## Timer for right joystick echo.
var _right_joystick_time: float = 0.0
## Counter for number of times left joystick has echoed.
var _left_echo_count: int = 0
## Counter for number of times right joystick has echoed.
var _right_echo_count: int = 0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_left_hold = false
	_right_hold = false


## Catches joystick motion and starts the time for holds.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		_left_hold = not left_joystick_dir().is_zero_approx()
		if not _left_hold:
			_left_joystick_time = 0.0
			_left_echo_count = 0
		_right_hold = not right_joystick_dir().is_zero_approx()
		if not _right_hold:
			_right_joystick_time = 0.0
			_right_echo_count = 0


## Updates the echo timer for left and right joystick.
func _process(delta: float) -> void:
	if _left_hold:
		_handle_left_echo(delta)
	if _right_hold:
		_handle_right_echo(delta)


## Get the direction of the left joystick input.
func left_joystick_dir() -> Vector2:
	return Input.get_vector(
			"left_joystick_l",
			"left_joystick_r",
			"left_joystick_u",
			"left_joystick_d"
	).normalized()


## Get the direction of the right joystick input.
func right_joystick_dir() -> Vector2:
	return Input.get_vector(
			"right_joystick_l",
			"right_joystick_r",
			"right_joystick_u",
			"right_joystick_d"
	).normalized()


## Updates the timer for left echo.
func _handle_left_echo(delta: float) -> void:
	if is_zero_approx(_left_joystick_time):
		left_joystick_pulsed.emit(left_joystick_dir())
		_left_echo_count += 1
	_left_joystick_time += delta
	if (
		(
			_left_echo_count > FAST_TIME_ECHO_COUNT
			and _left_joystick_time > FAST_ECHO_TIME
		)
		or _left_joystick_time > ECHO_TIME
	):
		_left_joystick_time = 0.0


## Updates the timer for right echo.
func _handle_right_echo(delta: float) -> void:
	if is_zero_approx(_right_joystick_time):
		right_joystick_pulsed.emit(right_joystick_dir())
		_right_echo_count += 1
	_right_joystick_time += delta
	if (
		(
			_right_echo_count > FAST_TIME_ECHO_COUNT
			and _right_joystick_time > FAST_ECHO_TIME
		)
		or _right_joystick_time > ECHO_TIME
	):
		_right_joystick_time = 0.0
