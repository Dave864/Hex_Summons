class_name HexMapMovementPath
extends Path
"""
Base class for adjustable movement paths for HexMap movement.
"""


signal movement_finished(final_position)


# Updates the offset amount by the given value.
func move_offset(offset_update: float) -> void:
	if curve.get_point_count() <= 1:
		emit_signal("movement_finished", get_current_pos())
		return
	$PathFollow.set_offset(offset_update)
	if $PathFollow.unit_offset >= 1.0:
		emit_signal("movement_finished", get_current_pos())


# Gets the current global position of the path at its current progression.
func get_current_pos() -> Vector3:
	# Position does not update on a path of only one point. That point is still
	# defined and should be given instead.
	if curve.get_point_count() == 1:
		return curve.get_point_position(0)
	return $PathFollow/Position3D.global_translation


# Creates a path curve using the provided array of map tile coordinates.
func create_path(_step_coordinates: PoolVector3Array) -> void:
	pass


# Creates a straight-line path from the starting coordinate to the ending coordinate.
func create_line_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	$PathFollow.set_offset(0.0)
	curve.add_point(step_coordinates[0])
	if step_coordinates.size() == 1:
		return
	curve.add_point(step_coordinates[-1])


# Creates a single bezier-line path from the starting coordinate to the ending
# coordinate.
func create_bezier_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	$PathFollow.set_offset(0.0)
	if step_coordinates.size() == 1:
		curve.add_point(step_coordinates[0])
		return
	# Update the in and out controls based on the height difference.
	var height_diff: float = step_coordinates[-1].y - step_coordinates[0].y
	var in_val: float = 1.0 + height_diff if height_diff > 0.0 else 1.0
	var out_val: float = 1.0 + abs(height_diff) if height_diff < 0.0 else 1.0
	curve.add_point(step_coordinates[0], Vector3.ZERO, Vector3(0.0, out_val, 0.0))
	curve.add_point(step_coordinates[-1], Vector3(0.0, in_val, 0.0), Vector3.ZERO)


# Create a series of straight-line paths from one coordinate to the next.
func create_segmented_line_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	$PathFollow.set_offset(0.0)
	if step_coordinates.size() == 1:
		curve.add_point(step_coordinates[0])
		return
	for coord in step_coordinates:
		curve.add_point(coord)


# Create a series of straight-line and bezier-line paths from one coordinate to the
# next, depending on the Y difference of the next coordinate.
func create_segmented_bezier_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	$PathFollow.set_offset(0.0)
	if step_coordinates.size() == 1:
		curve.add_point(step_coordinates[0])
		return
	for i in step_coordinates.size() - 1:
		var cur_coord: Vector3 = step_coordinates[i]
		var next_coord: Vector3 = step_coordinates[i + 1]
		var height_diff: float = next_coord.y - cur_coord.y
		var in_val: float = 1.0 + height_diff if height_diff > 0.0 else 0.0
		var out_val: float = 1.0 + abs(height_diff) if height_diff < 0.0 else 0.0
		if i == 0:
			curve.add_point(cur_coord, Vector3.ZERO, Vector3(0.0, out_val, 0.0))
		else:
			curve.set_point_out(i, Vector3(0.0, out_val, 0.0))
		curve.add_point(next_coord, Vector3(0.0, in_val, 0.0), Vector3.ZERO)



# Resets the offset value and the curve shape.
func reset_path() -> void:
	$PathFollow.set_offset(0.0)
	curve.clear_points()


# Validates that a provided path has at least one point.
func _assert_path_present(path: PoolVector3Array) -> void:
	assert(
			path.size() > 0,
			"Error: Attempted to define a movement path with no points."
	)
