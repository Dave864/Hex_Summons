extends Control
"""
Handles mouse input and keeps track of the last relevant position.
"""


# Keeps track of the mouse position.
var _world_position: Vector3 = Vector3.ZERO setget , get_world_position
var _drop_plane: Plane = Plane.PLANE_XZ
# Keeps track of the mouse position.
var _last_position: Vector2 = Vector2.ZERO

onready var _camera: Camera = get_tree().root.get_camera()


func get_world_position() -> Vector3:
	return _world_position


# Updates the recorded mouse position.
func update_mouse_tracker_2d(pos: Vector2) -> void:
	_last_position = pos


# Updates the recorded mouse position for a 3d coordinate.
func update_mouse_tracker_3d(pos: Vector3) -> void:
	_last_position = get_viewport().get_camera().unproject_position(pos)


# Reveals the mouse cursor and positions it to the last recorded position.
func activate() -> void:
	warp_mouse(_last_position)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Hides the mouse cursor and renders it unable to move.
func deactivate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_mouse_tracker_2d(get_viewport().get_mouse_position())
	_scale_to_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	_world_position = _screen_point_to_ray()


# Determine the world position of the mouse.
func _screen_point_to_ray() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = _camera.project_ray_origin(mouse_pos)
	var ray_normal: Vector3 = _camera.project_ray_normal(mouse_pos)
	var world_pos = _drop_plane.intersects_ray(ray_origin, ray_normal)
	if world_pos == null:
		return Vector3.ZERO
	else:
		return world_pos


# Scales the viewport size to match the window.
func _scale_to_window() -> void:
	rect_size = OS.window_size
