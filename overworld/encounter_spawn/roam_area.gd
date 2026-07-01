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


## Defines a new roam area.
func _init(
	new_radius: float,
	new_minimum: float,
	global_orientation: Vector3
) -> void:
	radius = new_radius
	min_distance = new_minimum
	global_rotation = global_orientation
	_y_cast = RayCast3D.new()
	add_child(_y_cast)
	_y_cast.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	_y_cast.set_collision_mask_value(Constants.MAP_LAYER, true)
	# Rotate raycast so that it is always pointing down regardless of the
	# rotation of this RoamArea.
	_y_cast.global_rotation = Vector3.ZERO
	_y_cast.target_position = Vector3(0.0, -Y_RAYCAST_LENGTH, 0.0)
	_points_pool.resize(POINT_QUEUE_LIMIT)
	_next_index = 0


## Gets the next point to roam to.
func get_next_point() -> Vector3:
	var next_point := _points_pool[_next_index]
	_next_index = _next_index + 1 if _next_index < POINT_QUEUE_LIMIT - 1 else 0
	return next_point


## Gets a random point defined by the roam area.
func _determine_point(previous_point_index: int) -> Vector3:
	var ray_origin := Vector3.ZERO
	if previous_point_index < 0 or previous_point_index >= POINT_QUEUE_LIMIT:
		var angle := randf_range(0.0, TAU)
		# Ensure uniform distribution across the circle area.
		var distance := sqrt(randf_range(0.0, 1.0) * pow(radius, 2.0))
		var xz_pos := Vector2.from_angle(angle).normalized() * distance
		ray_origin.x = xz_pos.x
		ray_origin.z = xz_pos.y
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


## Gets a random ray cast origin that is at least a minimum distance away from
## the last roam point.
func _cast_origin_from_previous(prior_point: Vector3) -> Vector3:
	return Vector3.ZERO


## Cast a ray from the origin to determine the point to use as a roam target.
func _cast_map_point(origin: Vector3) -> Vector3:
	_y_cast.global_position = origin
	_y_cast.force_raycast_update()
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point()
	printerr("RoamArea {0} could not find overworld map.".format([get_instance_id()]))
	return origin


## 
func _determine_points() -> void:
	pass
