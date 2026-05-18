@tool
extends Node3D
class_name EncounterCamera
## Handles the camera for the Encounter scene.
##
## Handles positioning, rotating, and resizing camera dimensions.


## Indicates that the camera has shifted focus point due to edge detection.
## Passes along the new map tile that is being focused on.
signal focus_moved_by_edge(new_focus_tile)

## Defines the radian values that correspond to the vertices of a hexagon.
##    0
## 5 / \ 1
##  |   |
## 4 \ / 2
##    3
const HEX_VERTEX_RADIANS: Array[float] = [
	0.0,
	-PI / 3.0,
	-2.0 * PI / 3.0,
	PI,
	2.0 * PI / 3.0,
	PI / 3.0
]

## The default distance the camera is to be set from the focus point.
@export var default_distance: float = 15.0: set = set_default_distance
## The upper boundary for vertical rotation in degrees.
@export_range(45.0, 90.0, 0.1) var vert_panning_u_bound: float = 75.0:
	set = set_vert_panning_u_bound
## The lower boundary for vertical rotation in degrees.
@export_range(0.0, 45.0, 0.1) var vert_panning_l_bound: float = 30.0:
	set = set_vert_panning_l_bound
## The threshold of mouse movement required to trigger a rotation change.
@export_range(1.0, 5.0, 0.01) var mouse_drag_threshold: float = 1.0
## The percentage of lateral mouse movement to use when updating the camera.
@export_range(0.1, 2.0, 0.1) var mouse_lateral_multiplier: float = 0.3
## The speed the camera vertically pans when using joystick input.
@export_range(50.0, 500.0) var joystick_vert_pan_speed: float = 100.0
## The speed the camera horizontally pans when using joystick input.
@export_range(50.0, 500.0) var joystick_lateral_pan_speed: float = 100.0
## The speed the camera moves to the default position.
@export_range(1.0, 30.0) var reset_speed = 10.0

## The midpoint between the vertical rotation bounds. Considered the default
## rotation for the camera.
var _vert_pan_midpoint: float = _panning_vertical_midpoint()
## The index position of a hex tile that is considered to be the top, relative
## to the camera position.
##    0
## 5 / \ 1
##  |   |
## 4 \ / 2
##    3
var _relative_top_vertex: int = 0:
	set = set_relative_top_vertex
## Flag that indicates if the camera focus point is able to be updated via
## screen edge detection.
var _focus_point_locked: bool = false
## The default orientation of the camera
var _default_orientation: Vector3

## The edges of the screen.
@onready var _screen_edge_detector: ScreenEdgeDetector = $ScreenEdgeDetector
## The point the camera looks at.
@onready var _focus_pt: MapTileTrackingPoint = $MapTileTrackingPoint
## The camera node.
@onready var _camera: Camera3D = $MapTileTrackingPoint/Camera3D


## Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect(
			"position_camera_focus",
			Callable(self, "_on_SignalBus_position_camera_focus")
	)
	_check_for_required_parameters()
	_focus_pt.rotation = Vector3(deg_to_rad(_vert_pan_midpoint), 0.0, 0.0)
	_default_orientation = _focus_pt.rotation
	set_camera_distance(default_distance)


## Determines if the camera focus point is able to be updated using screen edge
## detection.
func is_focus_point_locked() -> bool:
	return _focus_point_locked


## Sets the value of the default distance.
func set_default_distance(distance: float) -> void:
	default_distance = distance
	if Engine.is_editor_hint():
		set_camera_distance(distance)


## Sets the value of the upper vertical panning bound.
func set_vert_panning_u_bound(bound: float) -> void:
	vert_panning_u_bound = bound
	_vert_pan_midpoint = _panning_vertical_midpoint()
	if Engine.is_editor_hint():
		_focus_pt.rotation.x = deg_to_rad(_vert_pan_midpoint)


## Sets the value of the lower vertical panning bound.
func set_vert_panning_l_bound(bound: float) -> void:
	vert_panning_l_bound = bound
	_vert_pan_midpoint = _panning_vertical_midpoint()
	if Engine.is_editor_hint():
		_focus_pt.rotation.x = deg_to_rad(_vert_pan_midpoint)


## Get the vertical pan midpoint.
func get_vert_pan_midpoint() -> float:
	return _vert_pan_midpoint


## Set the relative top vertex.
func set_relative_top_vertex(new_top: int) -> void:
	assert(
			new_top >= 0 and new_top < 6,
			"New relative vertex for EncounterCamera is out of bounds for a hex."
	)
	_relative_top_vertex = new_top
	SignalBus.emit_top_vertex_changed(new_top)


## Gets the orientation of the focus point. Normalizes the y rotation beforehand.
func get_focus_point_orientation() -> Vector3:
	var original_rotation: Vector3 = _focus_pt.rotation
	original_rotation.y = _normalize_lateral_rotation(original_rotation.y)
	return original_rotation


## Get the relative top vertex.
func get_relative_top_vertex() -> int:
	return _relative_top_vertex


## Disable the screen edge detection.
func disable_edge_detection() -> void:
	_screen_edge_detector.disable()


## Enable the screen edge detection.
func enable_edge_detection() -> void:
	_screen_edge_detector.enable()


## Handles vertical camera rotation from mouse drag.
func vertical_rotation_mouse(v_motion: float) -> void:
	if abs(v_motion) < mouse_drag_threshold:
		return
	var vert_rot: float = rad_to_deg(_focus_pt.rotation.x)
	# Vertical rotation is negative to position the camera above
	# the encounter map.
	vert_rot += -v_motion
	_focus_pt.rotation.x = deg_to_rad(_bind_vertical_rotation(vert_rot))


## Handles lateral camera rotation from mouse drag.
func lateral_rotation_mouse(l_motion: float) -> void:
	_focus_pt.rotation.y -= deg_to_rad(l_motion * mouse_lateral_multiplier)
	_focus_pt.rotation.y = _normalize_lateral_rotation(_focus_pt.rotation.y)


## Handles vertical camera rotation from joystick input.
func vertical_rotation_joystick(delta: float) -> void:
	var v_move: float = Input.get_axis("right_joystick_d", "right_joystick_u")
	if abs(v_move) == 0.0:
		return
	var vert_rot: float = rad_to_deg(_focus_pt.rotation.x)
	# Vertical rotation is negative to position the camera above
	# the encounter map.
	vert_rot += -v_move * joystick_vert_pan_speed * delta
	_focus_pt.rotation.x = deg_to_rad(_bind_vertical_rotation(vert_rot))


## Handles lateral camera rotation from joystick input.
func lateral_rotation_joystick(delta: float) -> void:
	var h_move: float = Input.get_axis("right_joystick_l", "right_joystick_r")
	if abs(h_move) == 0.0:
		return
	_focus_pt.rotation.y -= deg_to_rad(h_move * joystick_lateral_pan_speed * delta)
	_focus_pt.rotation.y = _normalize_lateral_rotation(_focus_pt.rotation.y)


## Positions the camera at a given distance away from the focus point.
func set_camera_distance(distance: float) -> void:
	_camera.position.z = distance


## Reorients the camera to the target orientation by a certain amount. If no
## target orientation is specified, defaults to the default orientation.
func interpolate_camera_rotation(
	original_o: Vector3,
	weight: float,
	target_orientation: Vector3 = _default_orientation
):
	_focus_pt.rotation = original_o.lerp(target_orientation, weight)


## Determines which radian rotation is closest to the camera's current rotation.
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


## Snap the focus point.
func move_focus_snap(new_focus_point: Vector3) -> void:
	_focus_pt.movement_type = TrackingPoint.MovementType.SNAP
	await move_focus(new_focus_point)


## Move the focus point using its linear speed.
func move_focus_linear(new_focus_point: Vector3) -> void:
	_focus_pt.movement_type = TrackingPoint.MovementType.LINEAR
	await move_focus(new_focus_point)


## Move the focus point using its decaying speed.
func move_focus_decay(new_focus_point: Vector3) -> void:
	_focus_pt.movement_type = TrackingPoint.MovementType.DECAYING
	await move_focus(new_focus_point)


## Move the focus point using its current speed settings.
func move_focus(new_focus_point: Vector3) -> void:
	_focus_pt.update_destination(new_focus_point)
	await _focus_pt.new_point_reached
	SignalBus.emit_camera_target_reached()


## Calculates the midpoint between the vertical bounds.
func _panning_vertical_midpoint() -> float:
	return (vert_panning_u_bound + vert_panning_l_bound) / -2.0


## Binds the provided vertical rotation wihtin the upper and lower bounds.
## Rotation is in degrees.
func _bind_vertical_rotation(vert_rot: float) -> float:
	return (
		-vert_panning_u_bound if vert_rot < -vert_panning_u_bound
		else -vert_panning_l_bound if vert_rot > -vert_panning_l_bound
		else vert_rot
	)


## Normalizes the provided lateral rotation to be within the allowed degrees
## for a circle. Rotation is in radians.
func _normalize_lateral_rotation(lat_rot: float) -> float:
	return (
		abs(lat_rot) if is_equal_approx(abs(lat_rot), PI)
		else lat_rot - 2.0 * PI if lat_rot > PI
		else lat_rot + 2.0 * PI if lat_rot < -PI
		else lat_rot
	)


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	# Check that all elements are present.
	assert(
			_focus_pt != null,
			ErrorUtil.missing_required_parameter(name, "FocusPoint")
	)
	assert(
			_camera != null,
			ErrorUtil.missing_required_parameter(name, "Camera3D")
	)
	# Check vertical panning bounds.
	assert(
			vert_panning_l_bound < vert_panning_u_bound,
			"Lower vertical panning bounds are not below upper bounds."
	)
	# Check the camera status.
	assert(
			_camera.projection == Camera3D.PROJECTION_ORTHOGONAL,
			"EncounterCamera projection is not Orthogonal."
	)
	var camera_bound_to_z_axis: bool = (
		is_zero_approx(_camera.position.x)
		and is_zero_approx(_camera.position.y)
	)
	assert(
			camera_bound_to_z_axis,
			"EncounterCamera camera distance position not bound along z-axis."
	)
	assert(
			_camera.rotation.is_zero_approx(),
			"EncounterCamera camera rotation is not zero"
	)


## Moves the focus point to the position indicated by the selection tracker.
func _on_SelectionTracker_new_focus_point(new_position: Vector3) -> void:
	move_focus_linear(new_position)


## Disables or enables the screen edge detection if the selection tracker has
## locked or unlocked the camera focus respectively.
func _on_SelectionTracker_camera_focus_locked(is_locked: bool) -> void:
	_focus_point_locked = is_locked
	if _focus_point_locked:
		disable_edge_detection()
	else:
		enable_edge_detection()


## Moves the focus point to the tile in the adjacent direction.
func _on_ScreenEdgeDetector_edge_hit() -> void:
	if not _focus_pt.is_moving():
		_focus_pt.move_to_adjacent_tile(
				_screen_edge_detector.get_hex_direction_to_edge(),
				TrackingPoint.MovementType.LINEAR
		)
		emit_signal("focus_moved_by_edge", _focus_pt.get_map_tile())


## Moves the focus point to the specified position in the specified movement
## pattern.
func _on_SignalBus_position_camera_focus(
	new_position: Vector3,
	movement_type: TrackingPoint.MovementType
) -> void:
	match movement_type:
		TrackingPoint.MovementType.SNAP:
			move_focus_snap(new_position)
		TrackingPoint.MovementType.LINEAR:
			move_focus_linear(new_position)
		TrackingPoint.MovementType.DECAYING:
			move_focus_decay(new_position)
