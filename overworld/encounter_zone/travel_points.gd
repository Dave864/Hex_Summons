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


## The color the gizmo will be.
const GIZMO_COLOR := Color.BLACK
## Name of the gizmo used for debugging.
const GIZMO_NAME := "AreaGizmo"

## The number of points to create.
@export_range(1, 1000, 1) var point_count = 1:
	set(value):
		point_count = value
		if is_node_ready() and Engine.is_editor_hint():
			_create_points()

## The available travel points.
var points_list: Array[Marker3D] = []


## Gets the travel points present.
func _ready() -> void:
	_create_gizmo()
	for point: Node in get_children():
		if point is Marker3D:
			points_list.append(point)


## Creates the travel points in a uniform pattern, placing them on a nav mesh if
## the plane is above one.
func _create_points() -> void:
	var nav_finder := _make_nav_finder()
	
	var points_layout := _get_points_layout()
	var count := 0
	for point_position: Vector3 in points_layout:
		nav_finder.position = point_position
		nav_finder.force_raycast_update()
		if nav_finder.is_colliding():
			point_position = nav_finder.get_collision_point()
		_add_point(point_position, count)
		count += 1
	
	remove_child(nav_finder)
	nav_finder.queue_free()


## Reevaluates the position of travel points, placing them on a nav mesh if
## one is detected.
func _reset_point_positions() -> void:
	var nav_finder := _make_nav_finder()
	for point: Marker3D in points_list:
		nav_finder.position = point.position
		nav_finder.force_raycast_update()
		if nav_finder.is_colliding():
			point.position = nav_finder.get_collision_point()
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
	nav_finder.target_position = Vector3(0.0, -INF, 0.0)
	return nav_finder


## Creates the gizmo used to visualize the area where the points will be placed.
@abstract func _create_gizmo() -> void


## Gets the uniform layout of points in the defined shape.
@abstract func _get_points_layout() -> PackedVector3Array


## Creates a new travel point at the specified position.
func _add_point(point_position: Vector3, count: int) -> void:
	var point := Marker3D.new()
	add_child(point)
	if Engine.is_editor_hint():
		point.set_owner(get_tree().edited_scene_root)
	point.position = point_position
	point.name = "Point{0}".format([count])
	points_list.append(point)
