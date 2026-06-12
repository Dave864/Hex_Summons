@tool
class_name CircleSpawnArea
extends SpawnArea
## Defines a circular area where EncounterSpawn may be instanced.


## The number of segments in the debug circle mesh.
const SEGMENT_COUNT := 16

## The radius of the spawn area.
@export_range(1.0, 100.0, 0.01) var radius := 1.0:
	set(value):
		radius = value
		if is_node_ready():
			_update_debug_mesh()


## Updates the debug mesh to the current dimensions.
func _update_debug_mesh() -> void:
	if not Engine.is_editor_hint():
		return
	var circle_mesh := ImmediateMesh.new()
	circle_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	var angle_step := TAU / SEGMENT_COUNT
	for i in SEGMENT_COUNT:
		var vertex_1 := Vector3.RIGHT.rotated(Vector3.UP, angle_step * i)
		var vertex_2 := Vector3.RIGHT.rotated(Vector3.UP, angle_step * (i + 1))
		vertex_1 += _debug_mesh.position
		vertex_2 += _debug_mesh.position
		circle_mesh.surface_add_vertex(vertex_1 * radius)
		circle_mesh.surface_add_vertex(vertex_2 * radius)
	circle_mesh.surface_end()
	_debug_mesh.mesh = circle_mesh


## Gets random xz coordinates from within the defined spawn area.
func _determine_xz_position() -> Vector2:
	var random_angle := randf_range(0.0, TAU)
	var random_dist := randf_range(0.0, radius)
	var xz_pos := Vector2.from_angle(random_angle).normalized() * random_dist
	return xz_pos + Vector2(global_position.x, global_position.z)
