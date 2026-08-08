@tool
class_name SpawnAreaRect
extends SpawnArea
## Defines a rectangular area where EncounterSpawn may be instanced.


## Indicates if the area is a square.
@export var is_square := false:
	set(value):
		is_square = value
		if is_square:
			height = length
## The length of the rectangle (x-axis). Dimension used when the area is a square.
@export_range(0.01, 100.0, 0.01) var length := 1.0:
	set(value):
		length = value
		if is_square:
			height = length
		if is_node_ready() and _rect_gizmo != null:
			_rect_gizmo.length = length
## The height of the reactangle (z-axis).
@export_range(0.01, 100.0, 0.01) var height := 1.0:
	set(value):
		height = length if is_square else value
		if is_node_ready() and _rect_gizmo != null:
			_rect_gizmo.height = height

## Half of the length.
var _half_length: float:
	get():
		return length / 2
## Half of the height.
var _half_height: float:
	get():
		return height / 2
## The gizmo visualizing the rectangle the spawn area covers.
var _rect_gizmo: AreaGizmoRect = null


## Gets the reference to the rectangle gizmo, or creates one if none is present.
func _instance_gizmo() -> void:
	if has_node(GIZMO_NAME):
		_rect_gizmo = get_node(GIZMO_NAME) as AreaGizmoRect
	else:
		_rect_gizmo = AreaGizmoRect.new(GIZMO_COLOR, height, length)
		add_child(_rect_gizmo)
		_rect_gizmo.name = GIZMO_NAME
		if Engine.is_editor_hint():
			_rect_gizmo.set_owner(get_tree().edited_scene_root)
	if Engine.is_editor_hint():
		_rect_gizmo.draw_mesh()


## Gets a random position in the defined spawn area plane.
func _random_area_position(roam_offset: float) -> Vector3:
	return Vector3(
		randf_range(roam_offset - _half_length, _half_length - roam_offset),
		0.0,
		randf_range(roam_offset - _half_height, _half_height - roam_offset)
	)


## Define a roam area for an EncounterSpawn.
func _define_roam_area(spawner: EncounterSpawn) -> void:
	var area_radius := (
			_half_height if _half_height < _half_length
			else _half_length
	)
	spawner.roam_area = RoamArea.new(area_radius, area_radius / 2.0)
