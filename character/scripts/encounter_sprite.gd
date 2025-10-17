class_name EncounterSprite
extends Sprite3D
"""
Sprite3D node that constantly adjusts its position based on camera position so
that the sprite image is aligned with the pixel grid.
"""


@export var character_pos_ref: NodePath = NodePath("")

var _drop_plane: Plane = Plane.PLANE_XZ
var _global_pos: Vector3 = Vector3.ZERO
var _ray_origin: Vector3 = Vector3.ZERO
var _ray_normal: Vector3 = Vector3.ZERO

@onready var _camera: Camera3D = get_viewport().get_camera_3d()
@onready var _char_pos: Marker3D = get_node(character_pos_ref)
@onready var _y_offset: float = position.y


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	pixel_size = Constants.WORLD_PIXEL_SIZE
	fixed_size = true
	billboard = BaseMaterial3D.BILLBOARD_ENABLED


# Called every frame. Adjusts the sprite position so that it is aligned with
# the pixel coordinates.
func _process(_delta):
	visible = not _camera.is_position_behind(global_transform.origin)
	if not visible:
		return
	_drop_plane.d = _y_offset + _char_pos.global_position.y
	_global_pos = _char_pos.global_position
	_global_pos.y += _y_offset
	var r_pos: Vector2 = _camera.unproject_position(_global_pos).round()
	_ray_origin = _camera.project_ray_origin(r_pos)
	_ray_normal = _camera.project_ray_normal(r_pos)
	var world_pos: Vector3 = _drop_plane.intersects_ray(_ray_origin, _ray_normal)
	global_position = world_pos


func _check_for_required_parameters() -> void:
	assert(
			character_pos_ref != null,
			"EncounterSprite missing character position reference."
	)
