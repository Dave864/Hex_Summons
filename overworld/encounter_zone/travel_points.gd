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
enum DistributionSystem {
	RANDOM, # Use random points from anywhere in the area.
	GRID, # Use only a set of points spaced evenly across the area.
	CUSTOM_RANDOM, # A number of points are placed randomly across the area.
	CUSTOM_GRID, # Points are spaced evenly across the area.
}

## The color the gizmo will be.
const GIZMO_COLOR := Color.BLACK
## Name of the area gizmo used for debugging.
const AREA_GIZMO_NAME := "AreaGizmo"
## Name of the grid points gizmo.
const GRID_POINTS_GIZMO_NAME := "GridPointsGizmo"
## The number of times a random point is re-rolled before short-circuiting.
const REROLL_COUNT := 10

## The current way points are created.
@export var distribution: DistributionSystem = DistributionSystem.RANDOM:
	set(value):
		distribution = value
		notify_property_list_changed()
		if is_node_ready() and Engine.is_editor_hint():
			_create_points()
## The point density for the grid layout.
@export_range(0.01, 1.0, 0.01) var grid_scale: float = 0.5:
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
## Recreates all grid points for current point density.
@export_tool_button("Regenerate Points") var regen_points_function := (
	_create_points
)
## Relevels all positions so that they are on a map collision shape is able.
@export_tool_button("Relevel Positions") var relevel_function := (
	_relevel_point_positions
)

## The available travel points.
var points_list: Array[Marker3D] = []

## Gizmo that reflects the points that will be present in the `GRID`
## distribution system.
var _grid_points_gizmo: MeshInstance3D = null
## The ray used for map detection.
var _raycast: RayCast3D = null


## Gets the travel points present.
func _ready() -> void:
	_create_gizmo()
	_create_grid_gizmo()
	_make_raycast()
	if Engine.is_editor_hint():
		_create_gizmo()
	for point: Node in get_children():
		if point is Marker3D:
			points_list.append(point)


## Conditionally hides various parameters based on the set distribution mode.
func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "grid_scale"
		and distribution != DistributionSystem.GRID
		and distribution != DistributionSystem.CUSTOM_GRID
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "random_count"
		and distribution != DistributionSystem.CUSTOM_RANDOM
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "reroll_function"
		and distribution != DistributionSystem.CUSTOM_RANDOM
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "regen_points_function"
		and distribution != DistributionSystem.CUSTOM_GRID
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if (
		property.name == "relevel_function"
		and distribution != DistributionSystem.CUSTOM_RANDOM
		and distribution != DistributionSystem.CUSTOM_GRID
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR


## Gets a random travel point in global space. Returns an infinite vector if
## no valid point is found.
func get_a_global_point() -> Vector3:
	var global_point := Vector3.INF
	match distribution:
		DistributionSystem.RANDOM:
			_raycast.position = _get_random_point_in_shape()
			_raycast.force_raycast_update()
			if _raycast.is_colliding():
				global_point = _raycast.get_collision_point()
		DistributionSystem.GRID:
			var points := _get_grid_layout()
			_raycast.position = points[randi() % points.size()]
			_raycast.force_raycast_update()
			if _raycast.is_colliding():
				global_point = _raycast.get_collision_point()
		_:
			if points_list.size() > 0:
				global_point = _get_random_point_in_list()
	if not global_point.is_finite():
		printerr("Could not find a valid random point.")
	return global_point


## Gets a random travel point in global space that is in a specific range of a
## reference point.
func get_a_global_point_in(max_range: float, ref_point: Vector3) -> Vector3:
	var global_point := get_a_global_point()
	for i: int in REROLL_COUNT:
		var point_ping := get_a_global_point()
		if point_ping.distance_squared_to(ref_point) <= pow(max_range, 2.0):
			global_point = point_ping
			break
	return global_point


## Gets a random travel point in global space that is at least some distance
## away from a reference point.
func get_a_global_point_beyond(min_dist: float, ref_point: Vector3) -> Vector3:
	var global_point := get_a_global_point()
	for i: int in REROLL_COUNT:
		var point_ping := get_a_global_point()
		if point_ping.distance_squared_to(ref_point) > pow(min_dist, 2.0):
			global_point = point_ping
			break
	return global_point


## Gets a random travel point in global space that is within a specific range
## band relative to a reference point. Returns any random point if no points
## are found.
func get_a_global_point_within(
	min_dist: float,
	max_dist: float,
	ref_point: Vector3
) -> Vector3:
	var global_point := get_a_global_point()
	var distance := 0.0
	for i: int in REROLL_COUNT:
		var point_ping := get_a_global_point()
		distance = point_ping.distance_squared_to(ref_point)
		if (
			distance > pow(min_dist, 2.0)
			and distance <= pow(max_dist, 2.0)
		):
			global_point = point_ping
			break
	return global_point


## Creates the travel points in some pattern, placing them on a nav mesh if
## the plane is above one.
func _create_points() -> void:
	_clear_all_points()
	if distribution == DistributionSystem.GRID:
		_create_grid_gizmo()
		return
	elif _grid_points_gizmo != null:
		remove_child(_grid_points_gizmo)
		_grid_points_gizmo.queue_free()
		_grid_points_gizmo = null
	if distribution == DistributionSystem.RANDOM:
		return
	
	var points_layout: PackedVector3Array
	match distribution:
		DistributionSystem.CUSTOM_GRID:
			points_layout = _get_grid_layout()
		DistributionSystem.CUSTOM_RANDOM:
			points_layout = _get_random_layout()
		_:
			points_layout = []
	
	var count := 0
	for point_position: Vector3 in points_layout:
		_raycast.position = point_position
		_raycast.force_raycast_update()
		if _raycast.is_colliding():
			point_position = _raycast.get_collision_point()
		else:
			point_position += global_position
		_add_point(point_position, count)
		count += 1
	_raycast.position = Vector3.ZERO


## Goes gets new random positions for all points.
func _reroll_point_positions() -> void:
	_clean_up_removed_points()
	var random_position: Vector3
	for i: int in points_list.size():
		random_position = _get_random_point_in_shape()
		_raycast.position = random_position
		_raycast.force_raycast_update()
		if _raycast.is_colliding():
			random_position = _raycast.get_collision_point()
		else:
			random_position += global_position
		points_list[i].global_position = random_position
		points_list[i].global_rotation = Vector3.ZERO
	_raycast.position = Vector3.ZERO


## Reevaluates the position of travel points, placing them on a nav mesh if
## one is detected.
func _relevel_point_positions() -> void:
	_clean_up_removed_points()
	for point: Marker3D in points_list:
		_raycast.position = Vector3(
				point.position.x,
				0.0,
				point.position.z
		)
		_raycast.force_raycast_update()
		if _raycast.is_colliding():
			point.global_position = _raycast.get_collision_point()
		point.global_rotation = Vector3.ZERO
	_raycast.position = Vector3.ZERO


## Goes through the points list and removes removed points.
func _clean_up_removed_points() -> void:
	var new_list: Array[Marker3D] = []
	for point: Marker3D in points_list:
		if point.is_inside_tree():
			new_list.append(point)
		else:
			point.queue_free()
	points_list = new_list


## Erases all points recorded, removing them from the scene tree.
func _clear_all_points() -> void:
	for point: Marker3D in points_list:
		# Possible for tracked points to not be in the scene tree due to having
		# been removed in editor.
		if point.is_inside_tree():
			remove_child(point)
		point.queue_free()
	points_list.clear()


## Creates a RayCast3D node to be used for detecting points on a map collider.
func _make_raycast() -> void:
	var raycast_name := "RayCast3D"
	if has_node(raycast_name):
		_raycast = get_node(raycast_name)
		return
	_raycast = RayCast3D.new()
	_raycast.name = raycast_name
	add_child(_raycast)
	if Engine.is_editor_hint():
		_raycast.set_owner(get_tree().edited_scene_root)
	_raycast.set_collision_mask_value(Constants.MAP_LAYER, true)
	_raycast.global_rotation = Vector3.ZERO
	_raycast.target_position = Vector3(0.0, -10.0, 0.0)
	_raycast.position = Vector3.ZERO


## Creates the gizmo used to visualize the area where the points will be placed.
@abstract func _create_gizmo() -> void


## Creates a gizmo to vizualize the points in a grid.
func _create_grid_gizmo() -> void:
	if distribution != DistributionSystem.GRID:
		return
	if not has_node(GRID_POINTS_GIZMO_NAME):
		_grid_points_gizmo = MeshInstance3D.new()
		add_child(_grid_points_gizmo)
		_grid_points_gizmo.name = GRID_POINTS_GIZMO_NAME
		_grid_points_gizmo.set_owner(get_tree().edited_scene_root)
	# Should not be adjusting travel point details when the game is running,
	# but should set reference to gizmo for consistency.
	elif not Engine.is_editor_hint():
		_grid_points_gizmo = get_node(GRID_POINTS_GIZMO_NAME)
		return
	
	var mesh_material := StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.albedo_color = GIZMO_COLOR
	
	var points_mesh := ImmediateMesh.new()
	var points := _get_grid_layout()
	if points.size() == 0:
		_grid_points_gizmo.mesh = points_mesh
		return
	points_mesh.surface_begin(Mesh.PRIMITIVE_POINTS)
	for point: Vector3 in points:
		points_mesh.surface_add_vertex(point)
	points_mesh.surface_end()
	_grid_points_gizmo.mesh = points_mesh
	_grid_points_gizmo.set_surface_override_material(0, mesh_material)


## Gets a layout of random points in the area.
func _get_random_layout() -> PackedVector3Array:
	var layout: PackedVector3Array = []
	for i: int in random_count:
		layout.append(_get_random_point_in_shape())
	return layout


## Gets a grid layout of points in the area.
@abstract func _get_grid_layout() -> PackedVector3Array


## Helper function for _grid_section_layout. Checks if a point is within the
## defined area.
@abstract func _is_point_in_area(point: Vector3) -> bool


## Gets a random point in the defined shape.
@abstract func _get_random_point_in_shape() -> Vector3


## Gets a random point within the current list of points.
func _get_random_point_in_list() -> Vector3:
	if points_list.size() == 0:
		return Vector3.ZERO
	return points_list[randi() % points_list.size()].global_position


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
