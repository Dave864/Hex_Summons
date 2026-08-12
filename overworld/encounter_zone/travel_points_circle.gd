@tool
class_name TravelPointsCircle
extends TravelPoints
## Holds a collection of points in 3D space that are within a defined circular
## area that will serve as travel points for overworld characters.
##
## Defines a helper that populates a defined area with a selected number of
## points. If the plane defined by the circle is above a nav mesh, the points
## are placed on said mesh. The points are placed on the plane itself if no
## such mesh is detected.


## The radius of the circle plane.
@export_range(1.0, 100.0, 0.01) var radius := 5.0:
	set(value):
		radius = value
		if is_node_ready() and _circle_gizmo != null:
			_circle_gizmo.radius = radius
			if distribution == TravelPoints.DistributionMethod.GRID:
				_create_points()

## The gizmo that defines the plane the points can be placed.
var _circle_gizmo: AreaGizmoCircle = null


## Creates the gizmo used to visualize the area where the points will be placed.
func _create_gizmo() -> void:
	if has_node(GIZMO_NAME):
		_circle_gizmo = get_node(GIZMO_NAME) as AreaGizmoCircle
	else:
		_circle_gizmo = AreaGizmoCircle.new(GIZMO_COLOR, radius)
		add_child(_circle_gizmo)
		if Engine.is_editor_hint():
			_circle_gizmo.set_owner(get_tree().edited_scene_root)
		_circle_gizmo.name = GIZMO_NAME
	if Engine.is_editor_hint():
		_circle_gizmo.draw_mesh()


## Gets a grid layout of points in the circle.
func _get_grid_layout() -> PackedVector3Array:
	var layout: PackedVector3Array = []
	for x: int in 2 * ceili(radius):
		for z: int in 2 * ceili(radius):
			var section_corner = Vector3(
					-ceilf(radius) + x,
					0.0,
					-ceilf(radius) + z
			)
			layout.append_array(_grid_section_layout(section_corner))
	return layout


## Gets the point layout for a single grid space.
func _grid_section_layout(section_corner: Vector3) -> PackedVector3Array:
	var section_layout: PackedVector3Array = []
	var point_space := 1.0 / grid_scale
	for x: int in grid_scale:
		var x_pos: float = point_space * x + point_space / 2.0
		for z: int in grid_scale:
			var z_pos: float = point_space * z + point_space / 2.0
			var point := Vector3(x_pos, 0.0, z_pos) + section_corner
			if _is_point_in_area(point):
				section_layout.append(point)
	return section_layout


## Helper function for _grid_section_layout. Checks if a point is within the
## defined circle.
func _is_point_in_area(point: Vector3) -> bool:
	return Vector2(point.x, point.z).length_squared() <= pow(radius, 2.0)


## Gets a random point in the circle.
func _get_random_point() -> Vector3:
	var random_angle := randf_range(0.0, TAU)
	# Ensure uniform disturbution across the entire area.
	var random_dist := randf() * radius
	var xz_pos := Vector2.from_angle(random_angle).normalized() * random_dist
	return Vector3(xz_pos.x, 0.0, xz_pos.y)
