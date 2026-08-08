@tool
class_name SpawnAreaCircle
extends SpawnArea
## Defines a circular area where EncounterSpawn may be instanced.


## The number of segments in the debug circle mesh.
const SEGMENT_COUNT := 16

## The radius of the spawn area.
@export_range(1.0, 100.0, 0.01) var radius := 1.0:
	set(value):
		radius = value
		if is_node_ready() and _circle_gizmo != null:
			_circle_gizmo.radius = radius

## The gizmo visualizing the circle the spawn area covers.
var _circle_gizmo: AreaGizmoCircle = null


## Gets the reference to the circle gizmo, or creates one if none is present.
func _instance_gizmo() -> void:
	if has_node(GIZMO_NAME):
		_circle_gizmo = get_node(GIZMO_NAME) as AreaGizmoCircle
	else:
		_circle_gizmo = AreaGizmoCircle.new(GIZMO_COLOR, radius)
		add_child(_circle_gizmo)
		_circle_gizmo.name = GIZMO_NAME
		if Engine.is_editor_hint():
			_circle_gizmo.set_owner(get_tree().edited_scene_root)
	if Engine.is_editor_hint():
		_circle_gizmo.draw_mesh()


## Gets a random position in the defined spawn area plane.
func _random_area_position(roam_offset: float) -> Vector3:
	var random_angle := randf_range(0.0, TAU)
	# Ensure uniform disturbution across the enitre area.
	var random_dist := sqrt(randf() * pow(radius - roam_offset, 2.0))
	var xz_pos := Vector2.from_angle(random_angle).normalized() * random_dist
	return Vector3(xz_pos.x, 0.0, xz_pos.y)


## Define a roam area for an EncounterSpawn.
func _define_roam_area(spawner: EncounterSpawn) -> void:
	spawner.roam_area = RoamArea.new(radius / 2.0, radius / 4.0)
