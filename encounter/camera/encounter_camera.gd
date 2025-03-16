tool
extends Spatial
class_name EncounterCamera
"""
Handles the camera for the Encounter scene. Handles positioning, rotating, and 
resizing camera dimensions.
"""


export (float, 0.0, 20.0) var default_distance = 10.0 setget set_default_distance
export (float, 0.0, 90.0) var vert_panning_u_bound = 75.0 setget set_vert_panning_u_bound
export (float, 0.0, 90.0) var vert_panning_l_bound = 10.0 setget set_vert_panning_l_bound

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
func _process(delta):	
	if _mouse_active and _pan_camera:
		print(_mouse_motion)


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
