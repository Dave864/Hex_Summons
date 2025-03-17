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

var _vert_pan_midpoint: float = _panning_vertical_midpoint()
var _mouse_active: bool
var _pan_camera: bool
var _mouse_motion: Vector2

onready var _focus_pt: Position3D = $FocusPoint
onready var _camera: Camera = $FocusPoint/Camera


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_focus_pt.rotation.x = deg2rad(_vert_pan_midpoint)
	set_camera_distance(default_distance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _mouse_active and _pan_camera and abs(_mouse_motion.y) > mouse_drag_threshold:
		var rotation: float = rad2deg(_focus_pt.rotation.x)
		# Vertical rotation should be negative to position the camera above
		# the encounter map.
		rotation += -_mouse_motion.y
		rotation = (
			-vert_panning_u_bound if rotation < -vert_panning_u_bound
			else -vert_panning_l_bound if rotation > -vert_panning_l_bound
			else rotation
		)
		_focus_pt.rotation.x = deg2rad(rotation)


# Handles mouse and joystick input.
func _unhandled_input(event: InputEvent) -> void:
	_mouse_active = event is InputEventMouse
	if event.is_action_pressed("ui_camera_pan"):
		_pan_camera = true
	if event.is_action_released("ui_camera_pan"):
		_pan_camera = false
	if event is InputEventMouseMotion:
		_mouse_motion = event.relative
	
	if !Engine.is_editor_hint():
		var vertical_move: float = Input.get_axis("ui_camera_d", "ui_camera_u")
		var horizontal_move: float = Input.get_axis("ui_camera_l", "ui_camera_r")


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


# Positions the camera at a given distance away from the focus point.
func set_camera_distance(distance: float) -> void:
	_camera.translation.z = distance


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
