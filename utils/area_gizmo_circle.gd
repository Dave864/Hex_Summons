@tool
class_name AreaGizmoCircle
extends AreaGizmo
## Creates a mesh of a ring with the specified radius and color.
##
## The mesh is used to indicate an area that a circle of a given radius will
## cover.


## The number of segments in the gizmo circle mesh.
const SEGMENT_COUNT := 16

@export var radius: float = 1.0:
	set(value):
		radius = value
		if is_node_ready():
			draw_mesh()


## Defines the parameters for a new circle gizmo.
func _init(new_color: Color = Color.BLACK, new_radius: float = 0.0) -> void:
	color = new_color
	radius = new_radius


## Draws a circle mesh.
func draw_mesh() -> void:
	if not Engine.is_editor_hint() and not debug_mode:
		return
	var circle_mesh := ImmediateMesh.new()
	circle_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	var angle_step := TAU / SEGMENT_COUNT
	for i in SEGMENT_COUNT:
		var vertex_1 := Vector3.RIGHT.rotated(Vector3.UP, angle_step * i)
		var vertex_2 := Vector3.RIGHT.rotated(Vector3.UP, angle_step * (i + 1))
		vertex_1 += position
		vertex_2 += position
		circle_mesh.surface_add_vertex(vertex_1 * radius)
		circle_mesh.surface_add_vertex(vertex_2 * radius)
	circle_mesh.surface_end()
	mesh = circle_mesh
	set_surface_override_material(0, _mesh_material())
