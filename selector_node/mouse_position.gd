class_name MousePosition
extends Position3D
"""
Determines the position of the mouse on the screen relative to the game world
"""

onready var _camera: Camera = get_tree().root.get_camera()

# The calculated world position of the mouse
var _position: Vector3 = Vector3.ZERO setget , get_mouse_position
var _drop_plane: Plane = Plane.PLANE_XZ


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	_position = _screen_point_to_ray()


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


func get_mouse_position() -> Vector3:
	return _position
