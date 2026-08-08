@tool
@abstract
class_name AreaGizmo
extends MeshInstance3D
## Base class for meshes that serve as gizmos that denote the area encompassed
## by a specific 3D shape, be it a plane or some volume.


## The color the gizmo will be.
@export var color := Color.BLACK:
	set(value):
		color = value
		if is_node_ready():
			draw_mesh()
## Indicates that the gizmo should appear in game.
@export var debug_mode := false


## Draws the gizmo shape if in the editor. Hide if otherwise.
func _ready() -> void:
	if not Engine.is_editor_hint() and not debug_mode:
		return
	draw_mesh()


## Draws the mesh that visualizes the shape. The mesh is not drawn when the game
## is running.
@abstract func draw_mesh() -> void


## Creates a material for the gizmo mesh.
func _mesh_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	# The material is unshaded to allow it to be visible regardless of shadows.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
