class_name EncounterSprite
extends Sprite3D
"""
Sprite3D node that constantly adjusts its position based on camera position so
that the sprite image is aligned with the pixel grid.
"""


var _drop_plane: Plane = Plane.PLANE_XZ
var _ray_origin: Vector3 = Vector3.ZERO
var _ray_normal: Vector3 = Vector3.ZERO

onready var _camera: Camera = get_viewport().get_camera()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. Adjusts the sprite position so that it is aligned with
# the pixel coordinates.
func _process(_delta):
	visible = not _camera.is_position_behind(global_transform.origin)
	if not visible:
		return
	_drop_plane.d = translation.y
	var r_pos: Vector2 = _camera.unproject_position(global_translation).round()
	_ray_origin = _camera.project_ray_origin(r_pos)
	_ray_normal = _camera.project_ray_normal(r_pos)
	var world_pos: Vector3 = _drop_plane.intersects_ray(_ray_origin, _ray_normal)
	if world_pos != null:
		global_translation = world_pos
