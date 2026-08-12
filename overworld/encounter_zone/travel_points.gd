@tool
@abstract
class_name TravelPoints
extends Node3D
## Holds a collection of points in 3D space that serve as travel points for
## overworld characters.
##
## Defines a helper that populates a defined area with a selected number of
## points. Places new points on the nav mesh the area is above or on the plane
## if no such mesh is found.


## The different ways the points can be distributed.
enum DistributionMethod {
	RANDOM, # A number of points are placed randomly across the area.
	GRID, # Points are spaced evenly across the area.
}

## The color the gizmo will be.
const GIZMO_COLOR := Color.BLACK
## Name of the gizmo used for debugging.
const GIZMO_NAME := "AreaGizmo"

## The current way points are created.
@export var distribution: DistributionMethod = DistributionMethod.RANDOM:
	set(value):
		distribution = value
		notify_property_list_changed()
		if is_node_ready() and Engine.is_editor_hint():
			_create_points()
## The point density for the grid layout.
@export_range(0.01, 2.0, 0.01) var grid_scale: float = 0.5:
	set(value):
		grid_scale = value
		if is_node_ready() and Engine.is_editor_hint():
			_create_points()
## The number of random points to create.
@export_range(1, 1000, 1) var random_count: int = 1:
	set(value):
		random_count = value
		if is_node_ready() and Engine.is_editor_hint():
			_create_points()
## Places all existing points at new random locations.
@export_tool_button("Reroll Positions") var reroll_function := (
	_reroll_point_positions
)
## Relevels all positions so that they are on a map collision shape is able.
@export_tool_button("Relevel Positions") var relevel_function := (
	_relevel_point_positions
)

## The available travel points.
var points_list: Array[Marker3D] = []


## Gets the travel points present.
func _ready() -> void:
	_create_gizmo()
	if Engine.is_editor_hint():
		_create_gizmo()
	for point: Node in get_children():
		if point is Marker3D:
			points_list.append(point)


## Conditionally hides various parameters based on the set distribution mode.
func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "grid_scale"
		and distribution != DistributionMethod.GRID
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "random_count"
		and distribution != DistributionMethod.RANDOM
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "reroll_function"
		and distribution != DistributionMethod.RANDOM
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR


## Creates the travel points in a uniform pattern, placing them on a nav mesh if
## the plane is above one.
func _create_points() -> void:
	_clear_all_points()
	var nav_finder := _make_nav_finder()
	
	var points_layout := _get_points_layout()
	var count := 0
	for point_position: Vector3 in points_layout:
		nav_finder.position = point_position
		nav_finder.force_raycast_update()
		if nav_finder.is_colliding():
			point_position = nav_finder.get_collision_point()
		else:
			point_position += global_position
		_add_point(point_position, count)
		count += 1
	
	remove_child(nav_finder)
	nav_finder.queue_free()


## Goes gets new random positions for all points.
func _reroll_point_positions() -> void:
	var nav_finder := _make_nav_finder()
	var index := 0
	for point_position: Vector3 in _get_random_layout():
		nav_finder.position = point_position
		nav_finder.force_raycast_update()
		if nav_finder.is_colliding():
			point_position = nav_finder.get_collision_point()
		else:
			point_position += global_position
		points_list[index].global_position = point_position
		points_list[index].global_rotation = Vector3.ZERO
		index += 1
	remove_child(nav_finder)
	nav_finder.queue_free()


## Reevaluates the position of travel points, placing them on a nav mesh if
## one is detected.
func _relevel_point_positions() -> void:
	var nav_finder := _make_nav_finder()
	for point: Marker3D in points_list:
		nav_finder.position = Vector3(
				point.position.x,
				0.0,
				point.position.z
		)
		nav_finder.force_raycast_update()
		if nav_finder.is_colliding():
			point.global_position = nav_finder.get_collision_point()
		point.global_rotation = Vector3.ZERO
	remove_child(nav_finder)
	nav_finder.queue_free()


## Erases all points recorded, removing them from the scene tree.
func _clear_all_points() -> void:
	for point: Marker3D in points_list:
		remove_child(point)
		point.queue_free()
	points_list.clear()


## Creates a RayCast3D node to be used for detecting points on a nav mesh.
func _make_nav_finder() -> RayCast3D:
	var nav_finder := RayCast3D.new()
	add_child(nav_finder)
	if Engine.is_editor_hint():
		nav_finder.set_owner(get_tree().edited_scene_root)
	nav_finder.set_collision_mask_value(Constants.MAP_LAYER, true)
	nav_finder.global_rotation = Vector3.ZERO
	nav_finder.target_position = Vector3(0.0, -10.0, 0.0)
	return nav_finder


## Creates the gizmo used to visualize the area where the points will be placed.
@abstract func _create_gizmo() -> void


## Gets the layout of points in the defined shape.
func _get_points_layout() -> PackedVector3Array:
	match distribution:
		DistributionMethod.GRID:
			return _get_grid_layout()
		DistributionMethod.RANDOM:
			return _get_random_layout()
		_:
			return []


## Gets a layout of random points in the area.
func _get_random_layout() -> PackedVector3Array:
	var layout: PackedVector3Array = []
	for i: int in random_count:
		layout.append(_get_random_point())
	return layout


## Gets a grid layout of points in the area.
@abstract func _get_grid_layout() -> PackedVector3Array


## Gets the point layout for a single grid space.
@abstract func _grid_section_layout(section_center: Vector3) -> PackedVector3Array


## Helper function for _grid_section_layout. Checks if a point is within the
## defined area.
@abstract func _is_point_in_area(point: Vector3) -> bool


## Gets a random point in the defined shape.
@abstract func _get_random_point() -> Vector3


## Creates a new travel point at the specified position.
func _add_point(global_point_position: Vector3, count: int) -> void:
	var point := Marker3D.new()
	add_child(point)
	if Engine.is_editor_hint():
		point.set_owner(get_tree().edited_scene_root)
	point.global_position = global_point_position
	point.global_rotation = Vector3.ZERO
	point.name = "Point{0}".format([count])
	points_list.append(point)
