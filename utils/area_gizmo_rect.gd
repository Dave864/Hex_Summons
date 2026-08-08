@tool
class_name AreaGizmoRect
extends AreaGizmo
## Creates a mesh of a rectangle with the specified length, width, and color.
##
## The mesh is used to indicate an area that a rectangle of a given size will
## cover.


## Indicates if the area is a square.
@export var is_square := false:
	set(value):
		is_square = value
		if is_square:
			height = length
## The length of the rectangle (x-axis). Dimension used when the area is a square.
@export var length := 1.0:
	set(value):
		length = value
		if is_square:
			height = length
		if is_node_ready():
			draw_mesh()
## The height of the reactangle (z-axis).
@export var height := 1.0:
	set(value):
		height = length if is_square else value
		if is_node_ready():
			draw_mesh()

## Half of the length.
var _half_length: float:
	get():
		return length / 2
## Half of the height.
var _half_height: float:
	get():
		return height / 2


## Defines the parameters for a new rectangle gizmo.
func _init(
	new_color: Color = Color.BLACK,
	new_height: float = 1.0,
	new_length: float = 1.0
) -> void:
	color = new_color
	length = new_length
	height = new_height
	is_square = length == height


## Draws a rectangular mesh
func draw_mesh() -> void:
	if not Engine.is_editor_hint() and not debug_mode:
		return
	var rect_mesh := ImmediateMesh.new()
	rect_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	rect_mesh.surface_add_vertex(Vector3(-_half_length, 0.0, _half_height))
	rect_mesh.surface_add_vertex(Vector3(_half_length, 0.0, _half_height))
	rect_mesh.surface_add_vertex(Vector3(_half_length, 0.0, -_half_height))
	rect_mesh.surface_add_vertex(Vector3(-_half_length, 0.0, -_half_height))
	rect_mesh.surface_add_vertex(Vector3(-_half_length, 0.0, _half_height))
	rect_mesh.surface_end()
	mesh = rect_mesh
	set_surface_override_material(0, _mesh_material())
