tool
extends Spatial
class_name EncounterCamera
"""
Handles the camera for the Encounter scene. Handles positioning, rotating, and 
resizing camera dimensions.
"""


# The default distance the camera is to be set from the focus point.
export (float, 0.0, 50.0) var default_distance = 15.0 setget set_default_distance
# The boundaries for vertical rotation.
export (float, 0.0, 90.0) var vert_panning_u_bound = 75.0 setget set_vert_panning_u_bound
export (float, 0.0, 90.0) var vert_panning_l_bound = 30.0 setget set_vert_panning_l_bound
# The threshold of mouse movement required to trigger a rotation change.
export (float, 1.0, 5.0) var mouse_drag_threshold = 1.0
# The percentage of lateral mouse movement to use when updating the camera.
export (float, 0.1, 2.0) var mouse_lateral_multiplier = 0.3
# The speed the camera vertically pans when using joystick input.
export (float, 50.0, 500.0) var joystick_vert_pan_speed = 100.0
# The speed the camera horizontally pans when using joystick input.
export (float, 50.0, 500.0) var joystick_lateral_pan_speed = 100.0

# The midpoint between the vertical rotation bounds. Considered the default rotation
# for the camera.
var _vert_pan_midpoint: float = _panning_vertical_midpoint() setget , get_vert_pan_midpoint

onready var _focus_pt: Position3D = $FocusPoint
onready var _camera: Camera = $FocusPoint/Camera


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_focus_pt.rotation.x = deg2rad(_vert_pan_midpoint)
	set_camera_distance(default_distance)


# Sets the value of the default distance.
func set_default_distance(distance: float) -> void:
	default_distance = distance
	if Engine.is_editor_hint():
		set_camera_distance(distance)


# Sets the value of the upper vertical panning bound.
func set_vert_panning_u_bound(bound: float) -> void:
	vert_panning_u_bound = bound
	_vert_pan_midpoint = _panning_vertical_midpoint()
	if Engine.is_editor_hint():
		_focus_pt.rotation.x = deg2rad(_vert_pan_midpoint)


# Sets the value of the lower vertical panning bound.
func set_vert_panning_l_bound(bound: float) -> void:
	vert_panning_l_bound = bound
	_vert_pan_midpoint = _panning_vertical_midpoint()
	if Engine.is_editor_hint():
		_focus_pt.rotation.x = deg2rad(_vert_pan_midpoint)


# Handles vertical camera panning from mouse drag.
func vertical_pan_mouse(vert_motion: float) -> void:
	if abs(vert_motion) < mouse_drag_threshold:
		return
	var rotation: float = rad2deg(_focus_pt.rotation.x)
	# Vertical rotation should be negative to position the camera above
	# the encounter map.
	rotation += -vert_motion
	rotation = (
		-vert_panning_u_bound if rotation < -vert_panning_u_bound
		else -vert_panning_l_bound if rotation > -vert_panning_l_bound
		else rotation
	)
	_focus_pt.rotation.x = deg2rad(rotation)


# Handles lateral camera panning from mouse drag.
func lateral_pan_mouse(lateral_motion: float) -> void:
	_focus_pt.rotation.y -= deg2rad(lateral_motion * mouse_lateral_multiplier)


# Handles vertical camera panning from joystick input.
func vertical_pan_joystick(delta: float) -> void:
	var vertical_move: float = Input.get_axis("ui_camera_d", "ui_camera_u")
	if abs(vertical_move) == 0.0:
		return
	var rotation: float = rad2deg(_focus_pt.rotation.x)
	# Vertical rotation should be negative to position the camera above
	# the encounter map.
	rotation += -vertical_move * joystick_vert_pan_speed * delta
	rotation = (
		-vert_panning_u_bound if rotation < -vert_panning_u_bound
		else -vert_panning_l_bound if rotation > -vert_panning_l_bound
		else rotation
	)
	_focus_pt.rotation.x = deg2rad(rotation)


# Handles lateral camera panning from joystick input.
func lateral_pan_joystick(delta: float) -> void:
	var horizontal_move: float = Input.get_axis("ui_camera_l", "ui_camera_r")
	if abs(horizontal_move) == 0.0:
		return
	_focus_pt.rotation.y -= deg2rad(horizontal_move * joystick_lateral_pan_speed * delta)


# Positions the camera at a given distance away from the focus point.
func set_camera_distance(distance: float) -> void:
	_camera.translation.z = distance


# Get the vertical pan midpoint.
func get_vert_pan_midpoint() -> float:
	return _vert_pan_midpoint


# Calculates the midpoint between the vertical bounds.
func _panning_vertical_midpoint() -> float:
	return (vert_panning_u_bound + vert_panning_l_bound) / -2.0


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	# Check that all elements are present.
	assert(
			_focus_pt != null,
			ErrorUtil.missing_required_parameter(name, "FocusPoint")
	)
	assert(_camera != null, ErrorUtil.missing_required_parameter(name, "Camera"))
	# Check vertical panning bounds.
	assert(
			vert_panning_l_bound < vert_panning_u_bound,
			"Lower vertical panning bounds are equal or higher than upper bounds."
	)
	# Check the camera status.
	assert(
			_camera.projection == Camera.PROJECTION_ORTHOGONAL,
			"EncounterCamera projection is not Orthogonal."
	)
	assert(
			_camera.translation.x == 0.0 and _camera.translation.y == 0.0,
			"EncounterCamera camera distance translation is not bound along the z-axis."
	)
	assert(
			_camera.rotation == Vector3.ZERO,
			"EncounterCamera camera rotation is not zero"
	)
