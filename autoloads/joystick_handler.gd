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
func update_mouse_tracker() -> void:
	print("tracked position: (%d, %d)" % [_mouse_position.x, _mouse_position.y])
	_mouse_position = get_viewport().get_mouse_position()


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	_scale_to_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# 
func _input(event: InputEvent):
	if _is_mouse_event(event) and not _mouse_active:
		_mouse_active = true
		_swap_to_mouse()
	elif not _is_mouse_event(event) and _mouse_active:
		_mouse_active = false
		_swap_to_joystick()


# Check if a given event is a mouse click or mouse movement.
func _is_mouse_event(event: InputEvent) -> bool:
	return event is InputEventMouseButton or event is InputEventMouseMotion


# Reveals the mouse cursor at the last recorded position.
func _swap_to_mouse() -> void:
	warp_mouse(_mouse_position)
#	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


# Hides the mouse cursor.
func _swap_to_joystick() -> void:
	update_mouse_tracker()
#	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


# Scales the viewport size to match the window.
func _scale_to_window() -> void:
	rect_size = OS.window_size
