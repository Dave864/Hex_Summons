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
## The index of the current point in the queue.
var _current_index: int


## Set up the initial points pool when entering the scene tree.
func _ready() -> void:
	# Rotate raycast so that it is always pointing down regardless of the
	# rotation of this RoamArea.
	_y_cast.global_rotation = Vector3.ZERO
	# Negative index indicates that the pool has not been set yet.
	_current_index = -1
	#_update_points_pool()
	_points_pool[0] = _determine_point(_current_index)
	_current_index = 0


## Defines a new roam area.
func _init(new_radius: float, new_minimum: float) -> void:
	assert(
			new_radius > 0.0,
			"RoamArea radius is not a positive value."
	)
	assert(
			new_minimum > 0.0,
			"RoamArea min_distance is not a positive value."
	)
	assert(
			new_minimum < new_radius,
			"RoamArea radius not greater than min_distance"
	)
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
	var prior_index := _current_index
	_current_index = posmod(_current_index + 1, POINT_QUEUE_LIMIT)
	_points_pool[_current_index] = _determine_point(prior_index)
	#if _next_index == 0:
		#_update_points_pool()
	return _points_pool[_current_index]


## Updates the points pool.
func _update_points_pool() -> void:
	_points_pool[0] = _determine_point(
			_current_index if _current_index < 0 else POINT_QUEUE_LIMIT - 1
	)
	for i: int in range(1, POINT_QUEUE_LIMIT):
		_points_pool[i] = _determine_point(i - 1)


## Gets a random point defined by the roam area.
func _determine_point(prior_index: int) -> Vector3:
	var ray_origin := Vector3.ZERO
	if (
		is_zero_approx(min_distance)
		or prior_index < 0
		or prior_index >= POINT_QUEUE_LIMIT
	):
		ray_origin = _cast_origin_in_area()
	else:
		var prior_point := _points_pool[prior_index]
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


## Gets a random ray cast origin from anywhere within the roam area.
func _cast_origin_in_area() -> Vector3:
	var angle := randf_range(0.0, TAU)
	# Ensure uniform distribution across the circle area.
	var distance := sqrt(randf() * pow(radius, 2.0))
	var xz_pos := Vector2.from_angle(angle).normalized() * distance
	return Vector3(xz_pos.x, 0.0, xz_pos.y)


## Gets a random ray cast origin that is at least a minimum distance away from
## the last roam point.
func _cast_origin_from_previous(last_roam_point: Vector3) -> Vector3:
	# Set position reference to be at origin so that the random point
	# calculations are easier.
	last_roam_point -= global_position
	var prior_pos := Vector2(last_roam_point.x, last_roam_point.z)
	var ray_vector := _get_random_direction(prior_pos)
	var xz_pos := _get_random_point_on_ray(prior_pos, ray_vector)
	return Vector3(xz_pos.x, 0.0, xz_pos.y)


## Gets a random direction vector based on a specified exclusion zone center.
## The returned vector will be a direction where the boundary of the zone falls
## within the boundaries of RoamArea.
## Reference: https://www.johndcook.com/blog/2023/08/27/intersect-circles/
func _get_random_direction(exclusion_center: Vector2) -> Vector2:
	# Roam area centered at origin, so distance to exclusion center from
	# RoamArea center is length of vector.
	var d := exclusion_center.length()
	# Rename relevant parameters for conciseness.
	var r0 := radius
	var r1 := min_distance
	if d < abs(r0 - r1) or d > r0 + r1:
		# Exclusion zone does not overlap boundaries of RoamArea so any
		# direction is valid.
		return Vector2.from_angle(randf() * TAU).normalized()
	var u := exclusion_center.normalized()
	var x_vec := (pow(d, 2.0) - pow(r1, 2.0) + pow(r0, 2.0)) * u / (2 * d)
	var u_perp := Vector2(u.y, -u.x)
	var a_half := (
		sqrt(
				(-d + r1 - r0)
				* (-d - r1 + r0)
				* (-d + r1 + r0)
				* (d + r0 + r1)
		) / d * 0.5
	)
	var intersect_1 := x_vec - u_perp * a_half
	var intersect_2 := x_vec + u_perp * a_half
	var v1 := intersect_1 - exclusion_center
	var v2 := intersect_2 - exclusion_center
	var angle := v1.angle_to(v2)
	# Want to get the value of the angle that points towards the center of
	# RoamArea. Negative angle points away from RoamArea center.
	if angle < 0.0:
		angle += TAU
	return v1.normalized().rotated(randf() * angle)


## Gets a random position along a ray cast in a given direction. The returned
## position will always be within the bounds of the RoamArea, and at least
## min_distance away from the starting point of the ray.
## Reference: https://www.scratchapixel.com/lessons/3d-basic-rendering/
## minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
func _get_random_point_on_ray(
	ray_start: Vector2,
	ray_direction: Vector2
) -> Vector2:
	var a := ray_direction.dot(ray_direction)
	var b := 2.0 * ray_direction.dot(ray_start)
	var c := ray_start.dot(ray_start) - pow(radius, 2.0)
	var discriminent := pow(b, 2.0) - 4.0 * a * c
	var max_dist: float
	if discriminent < 0.0:
		printerr("Cannot find random point in RoamArea.")
		return ray_start
	elif is_zero_approx(discriminent):
		max_dist = -b / (2.0 * a)
	else:
		var s := 1.0 if b > 0 else -1.0
		var q := (b + s * sqrt(discriminent)) / -2.0
		var x0 := q / a
		var x1 := c / q
		max_dist = x0 if x0 > 0 else x1
	return ray_direction * randf_range(min_distance, max_dist) + ray_start


## Cast a ray from the origin to determine the point to use as a roam target.
func _cast_map_point(origin: Vector3) -> Vector3:
	_y_cast.global_position = origin
	_y_cast.force_raycast_update()
	if _y_cast.is_colliding():
		return _y_cast.get_collision_point()
	printerr(
			"RoamArea {0} could not find overworld map."
			.format([get_instance_id()])
	)
	return origin
