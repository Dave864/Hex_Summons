tool
extends Spatial
class_name EncounterCamera
"""
Handles the camera for the Encounter scene. Handles positioning, rotating, and 
resizing camera dimensions.
"""


# Defines the radians values that correspond to the vertices of a hexagon.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
const HEX_VERTEX_RADIANS: Array = [
	0.0,
	-PI / 3.0,
	-2.0 * PI / 3.0,
	PI,
	2.0 * PI / 3.0,
	PI / 3.0
]

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
# The speed the camera moves to the default position.
export (float, 1.0, 30.0) var reset_speed = 10.0

# The midpoint between the vertical rotation bounds. Considered the default rotation
# for the camera.
var _vert_pan_midpoint: float = _panning_vertical_midpoint() setget , get_vert_pan_midpoint
# The index position of a hex tile that is considered to be the top, relative
# to the camera position.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
var _relative_top_vertex: int = 0 setget set_relative_top_vertex, get_relative_top_vertex
# The default orientation of the camera
var _default_orientation: Vector3

onready var _focus_pt: Position3D = $FocusPoint
onready var _camera: Camera = $FocusPoint/Camera


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


# Get the vertical pan midpoint.
func get_vert_pan_midpoint() -> float:
	return _vert_pan_midpoint


# Set the relative top vertex.
func set_relative_top_vertex(new_top: int) -> void:
	assert(
			new_top >= 0 and new_top < 6,
			"New relative vertex for EncounterCamera is out of bounds for a hex."
	)
	_relative_top_vertex = new_top
	SignalBus.emit_top_vertex_changed(new_top)


# Gets the orientation of the focus point. Normalizes the y rotation beforehand.
func get_focus_point_orientation() -> Vector3:
	var original_rotation: Vector3 = _focus_pt.rotation
	original_rotation.y = _normalize_lateral_rotation(original_rotation.y)
	return original_rotation


# Get the relative top vertex.
func get_relative_top_vertex() -> int:
	return _relative_top_vertex


# Handles vertical camera panning from mouse drag.
func vertical_pan_mouse(vert_motion: float) -> void:
	if abs(vert_motion) < mouse_drag_threshold:
		return
	var rotation: float = rad2deg(_focus_pt.rotation.x)
	# Vertical rotation is negative to position the camera above
	# the encounter map.
	rotation += -vert_motion
	_focus_pt.rotation.x = deg2rad(_bind_vertical_rotation(rotation))


# Handles lateral camera panning from mouse drag.
func lateral_pan_mouse(lateral_motion: float) -> void:
	_focus_pt.rotation.y -= deg2rad(lateral_motion * mouse_lateral_multiplier)
	_focus_pt.rotation.y = _normalize_lateral_rotation(_focus_pt.rotation.y)


# Handles vertical camera panning from joystick input.
func vertical_pan_joystick(delta: float) -> void:
	var vertical_move: float = Input.get_axis("right_joystick_d", "right_joystick_u")
	if abs(vertical_move) == 0.0:
		return
	var rotation: float = rad2deg(_focus_pt.rotation.x)
	# Vertical rotation is negative to position the camera above
	# the encounter map.
	rotation += -vertical_move * joystick_vert_pan_speed * delta
	_focus_pt.rotation.x = deg2rad(_bind_vertical_rotation(rotation))


# Handles lateral camera panning from joystick input.
func lateral_pan_joystick(delta: float) -> void:
	var horizontal_move: float = Input.get_axis("right_joystick_l", "right_joystick_r")
	if abs(horizontal_move) == 0.0:
		return
	_focus_pt.rotation.y -= deg2rad(horizontal_move * joystick_lateral_pan_speed * delta)
	_focus_pt.rotation.y = _normalize_lateral_rotation(_focus_pt.rotation.y)


# Positions the camera at a given distance away from the focus point.
func set_camera_distance(distance: float) -> void:
	_camera.translation.z = distance


# Reorients the camera to the target orientation by a certain amount. If no
# target orientation is specified, defaults to the default orientation.
func interpolate_camera_rotation(
	original_o: Vector3,
	weight: float,
	target_o: Vector3 = _default_orientation
):
	_focus_pt.rotation = original_o.linear_interpolate(
			target_o,
			weight
	)


# Determines which radian rotation is closest to the camera's current rotation.
func get_closest_vertex_radian() -> float:
	var focus_radian: float = _normalize_lateral_rotation(_focus_pt.rotation.y)
	var closest_radian: float = focus_radian
	for v in range(HEX_VERTEX_RADIANS.size()):
		var next_v: int = posmod(v + 1, 6)
		var v_radian: float = HEX_VERTEX_RADIANS[v]
		# Make sure that the segment defined by vertices 2 and 3 is not skipped.
		var next_v_radian: float = (
			-HEX_VERTEX_RADIANS[next_v] if next_v == 3
			else HEX_VERTEX_RADIANS[next_v]
		)
		var mid_radian: float = (v_radian + next_v_radian) / 2.0
		if v_radian > focus_radian and mid_radian < focus_radian:
			closest_radian = v_radian
			set_relative_top_vertex(v)
		elif next_v_radian < focus_radian and mid_radian > focus_radian:
			closest_radian = next_v_radian
			set_relative_top_vertex(next_v)
	return closest_radian


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_focus_pt.rotation = Vector3(deg2rad(_vert_pan_midpoint), 0.0, 0.0)
	_default_orientation = _focus_pt.rotation
	set_camera_distance(default_distance)


# Calculates the midpoint between the vertical bounds.
func _panning_vertical_midpoint() -> float:
	return (vert_panning_u_bound + vert_panning_l_bound) / -2.0


# Binds the provided vertical rotation wihtin the upper and lower bounds.
# Rotation is in degrees.
func _bind_vertical_rotation(rotation: float) -> float:
	return (
		-vert_panning_u_bound if rotation < -vert_panning_u_bound
		else -vert_panning_l_bound if rotation > -vert_panning_l_bound
		else rotation
	)


# Normalizes the provided lateral rotation to be within the allowed degrees
# for a circle. Rotation is in radians.
func _normalize_lateral_rotation(rotation: float) -> float:
	return (
		abs(rotation) if is_equal_approx(abs(rotation), PI)
		else rotation - 2.0 * PI if rotation > PI
		else rotation + 2.0 * PI if rotation < -PI
		else rotation
	)


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
