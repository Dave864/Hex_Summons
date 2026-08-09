@tool
class_name TravelPointsRect
extends TravelPoints
## Holds a collection of points in 3D space that are within a defined
## rectangular area that will serve as travel points for overworld characters.
##
## Defines a helper that populates a defined area with a selected number of
## points. If the plane defined by the rectangle is above a nav mesh, the points
## are placed on said mesh. The points are placed on the plane itself if no
## such mesh is detected.


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

## The gizmo that defines the plane the points can be placed.
var _rect_gizmo: AreaGizmoRect = null


## Creates the gizmo used to visualize the area where the points will be placed.
func _create_gizmo() -> void:
	if has_node(GIZMO_NAME):
		_rect_gizmo = get_node(GIZMO_NAME) as AreaGizmoRect
	else:
		_rect_gizmo = AreaGizmoRect.new(GIZMO_COLOR, height, length)
		add_child(_rect_gizmo)
		if Engine.is_editor_hint():
			_rect_gizmo.set_owner(get_tree().edited_scene_root)
		_rect_gizmo.name = GIZMO_NAME
	if Engine.is_editor_hint():
		_rect_gizmo.draw_mesh()


## Gets a grid layout of points in the rectangle.
func _get_grid_layout() -> PackedVector3Array:
	return []


## Gets a random point in the rectangle.
func _get_random_point() -> Vector3:
	var half_length := length / 2.0
	var half_height := height / 2.0
	var point := Vector3(
		randf_range(-half_length, half_length),
		0.0,
		randf_range(-half_height, half_height)
	)
	return point
