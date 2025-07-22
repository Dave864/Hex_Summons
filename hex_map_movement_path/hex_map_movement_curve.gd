class_name HexMapMovementCurve
extends Curve3D
"""
Curve that defines the movement path for a character on a HexMap.
"""


signal movement_finished(final_position)

# The current offset of the movement path
var _offset: float = 0.0
# The length of the path. Used for converting _unit_offset into the correct
# offset value for getting the current position.
var _path_length: float = 0.0


# Updates the offset amount by the given value.
func move_offset(offset_update: float) -> void:
	if get_point_count() <= 1:
		emit_signal("movement_finished", get_current_pos())
		return
	_offset = offset_update
	if _offset >= _path_length:
		_offset = _path_length
		emit_signal("movement_finished", get_current_pos())


# Gets the current global position of the path at its current progression.
func get_current_pos() -> Vector3:
	# Position does not update on a path of only one point. That point is still
	# defined and should be given instead.
	if get_point_count() == 1:
		return get_point_position(0)
	return interpolate_baked(_offset)


# Creates a path curve using the provided array of map tile coordinates.
func create_path(_step_coordinates: PoolVector3Array) -> void:
	pass


# Creates a straight-line path from the starting coordinate to the ending coordinate.
func create_line_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	add_point(step_coordinates[0])
	if step_coordinates.size() == 1:
		return
	add_point(step_coordinates[-1])
	_path_length = get_baked_length()


# Creates a single bezier-line path from the starting coordinate to the ending
# coordinate.
func create_bezier_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	if step_coordinates.size() == 1:
		add_point(step_coordinates[0])
		return
	# Update the in and out controls based on the height difference.
	var height_diff: float = step_coordinates[-1].y - step_coordinates[0].y
	var in_val: float = 1.0 + height_diff if height_diff > 0.0 else 1.0
	var out_val: float = 1.0 + abs(height_diff) if height_diff < 0.0 else 1.0
	add_point(step_coordinates[0], Vector3.ZERO, Vector3(0.0, out_val, 0.0))
	add_point(step_coordinates[-1], Vector3(0.0, in_val, 0.0), Vector3.ZERO)
	_path_length = get_baked_length()


# Create a series of straight-line paths from one coordinate to the next.
func create_segmented_line_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	if step_coordinates.size() == 1:
		add_point(step_coordinates[0])
		return
	for coord in step_coordinates:
		add_point(coord)
	_path_length = get_baked_length()


# Create a series of straight-line and bezier-line paths from one coordinate to the
# next, depending on the Y difference of the next coordinate.
func create_segmented_bezier_path(step_coordinates: PoolVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	if step_coordinates.size() == 1:
		add_point(step_coordinates[0])
		return
	for i in step_coordinates.size() - 1:
		var cur_coord: Vector3 = step_coordinates[i]
		var next_coord: Vector3 = step_coordinates[i + 1]
		var height_diff: float = next_coord.y - cur_coord.y
		var in_val: float = 1.0 + height_diff if height_diff > 0.0 else 0.0
		var out_val: float = 1.0 + abs(height_diff) if height_diff < 0.0 else 0.0
		if i == 0:
			add_point(cur_coord, Vector3.ZERO, Vector3(0.0, out_val, 0.0))
		else:
			set_point_out(i, Vector3(0.0, out_val, 0.0))
		add_point(next_coord, Vector3(0.0, in_val, 0.0), Vector3.ZERO)
	_path_length = get_baked_length()



# Resets the offset value and the curve shape.
func reset_path() -> void:
	_offset = 0.0
	_path_length = 0.0
	clear_points()


# Called when a new instance of this object is created.
func _init() -> void:
	_offset = 0.0
	_path_length = 0.0


# Validates that a provided path has at least one point.
func _assert_path_present(path: PoolVector3Array) -> void:
	assert(
			path.size() > 0,
			"Error: Attempted to define a movement path with no points."
	)

