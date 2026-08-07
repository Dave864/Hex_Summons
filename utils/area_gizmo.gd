@tool
@abstract
class_name AreaGizmo
extends MeshInstance3D
## Base class for meshes that serve as gizmos that denote the area encompassed
## by a specific 3D shape, be it a plane or some volume.


## The color the gizmo will be.
@export var color := Color.BLACK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## Draws the mesh that visualizes the shape. The mesh is not drawn when the game
## is running.
@abstract func draw_mesh() -> void


## Gets a random point within the area.
@abstract func get_random_point() -> Vector3
