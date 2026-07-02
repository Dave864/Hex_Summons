class_name RoamArea
extends Node3D
## Defines a circular area that obtains random points that an EncounterSpawn
## travels to.


## The length of the raycast.
const Y_RAYCAST_LENGTH := 10.0
## The number of points queued for use.
const POINT_QUEUE_LIMIT := 10

## The radius of the area.
var radius: float = 0.0
## The minimum distance between two sequential points.
var min_distance: float = 0.0

## RayCast used for determining the y-axis for random points.
var _y_cast: RayCast3D
## A collection of random points.
var _points_pool: PackedVector3Array
## The index of the next point in the queue.
var _next_index: int


## Set up the initial points pool when entering the scene tree.
func _ready() -> void:
	# Rotate raycast so that it is always pointing down regardless of the
	# rotation of this RoamArea.
	_y_cast.global_rotation = Vector3.ZERO
	# Negative index indicates that the pool has not been set yet.
	_next_index = -1
	_update_points_pool()
	_next_index = 0


## Defines a new roam area.
func _init(new_radius: float, new_minimum: float) -> void:
	radius = new_radius
	min_distance = new_minimum
	_y_cast = RayCast3D.new()
	add_child(_y_cast)
	_y_cast.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	_y_cast.set_collision_mask_value(Constants.MAP_LAYER, true)
	_y_cast.target_position = Vector3(0.0, -Y_RAYCAST_LENGTH, 0.0)
	_points_pool.resize(POINT_QUEUE_LIMIT)


## Gets the next point to roam to.
func get_next_point() -> Vector3:
	var next_point := _points_pool[_next_index]
	_next_index = _next_index + 1 if _next_index < POINT_QUEUE_LIMIT - 1 else 0
	if _next_index == 0:
		_update_points_pool()
	return next_point


## Updates the points pool.
func _update_points_pool() -> void:
	_points_pool[0] = _determine_point(
			_next_index if _next_index < 0 else POINT_QUEUE_LIMIT - 1
	)
	for i: int in range(1, POINT_QUEUE_LIMIT):
		_points_pool[i] = _determine_point(i - 1)


## Gets a random point defined by the roam area.
func _determine_point(previous_point_index: int) -> Vector3:
	var ray_origin := Vector3.ZERO
	if previous_point_index < 0 or previous_point_index >= POINT_QUEUE_LIMIT:
		ray_origin = _cast_origin_in_area()
	else:
		var prior_point := _points_pool[previous_point_index]
		ray_origin = _cast_origin_from_previous(prior_point)
	# Apply global Euler rotation to match the ray cast position to RoamArea's
	# orientation.
	ray_origin = ray_origin.rotated(Vector3.UP, deg_to_rad(global_rotation.y))
	ray_origin = ray_origin.rotated(Vector3.RIGHT, deg_to_rad(global_rotation.x))
	ray_origin = ray_origin.rotated(Vector3.BACK, deg_to_rad(global_rotation.z))
	# Make the ray cast position reference be the center of RoamArea instead of
	# origin.
	ray_origin += global_position
	return _cast_map_point(ray_origin)


## Gets a random ray cast origin from anywhere whithin the roam area.
func _cast_origin_in_area() -> Vector3:
	var angle := randf_range(0.0, TAU)
	# Ensure uniform distribution across the circle area.
	var distance := sqrt(randf() * pow(radius, 2.0))
	var xz_pos := Vector2.from_angle(angle).normalized() * distance
	return Vector3(xz_pos.x, 0.0, xz_pos.y)


## Gets a random ray cast origin that is at least a minimum distance away from
## the last roam point.
func _cast_origin_from_previous(prior_point: Vector3) -> Vector3:
	var ray_origin := Vector3.ZERO
	# Set position reference to be at origin so that the random point
	# calculations are easier.
	prior_point -= global_position
	# Raycast origin is calculated within the xz plane, so prior point is placed
	# within said plane so calculations are consistent. 
	prior_point.y = 0.0
	# TODO: Find range of valid angles to use.
	# TODO: Pick random angle and find valid radius values.
	# TODO: Pick random radius from valid values
	# TODO: Using origin in area while I get help with logic for this method. Use
	# ray_origin once logic is determined.
	return _cast_origin_in_area()


## Cast a ray from the origin to determine the point to use as a roam target.
func _cast_map_point(origin: Vector3) -> Vector3:
	_y_cast.global_position = origin
	_y_cast.force_raycast_update()
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point()
	printerr("RoamArea {0} could not find overworld map.".format([get_instance_id()]))
	return origin
