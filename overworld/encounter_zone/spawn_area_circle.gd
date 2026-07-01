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
	_debug_mesh.set_surface_override_material(0, _debug_mesh_material())


## Gets a random position in the defined spawn area plane.
func _random_area_position() -> Vector3:
	var random_angle := randf_range(0.0, TAU)
	# Ensure uniform disturbution across the enitre area.
	var random_dist := sqrt(randf_range(0.0, 1.0) * pow(radius, 2.0))
	var xz_pos := Vector2.from_angle(random_angle).normalized() * random_dist
	return Vector3(xz_pos.x, 0.0, xz_pos.y)
