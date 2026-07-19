class_name HexMapMovementCurve
extends Curve3D
## Curve that defines the movement path for a character on a HexMap.


## Indicates that the path has been fully traversed.
signal movement_finished(final_position)

## The current offset of the movement path
var _offset: float = 0.0
## The length of the path. Used for converting _unit_offset into the correct
## offset value for getting the current position.
var _path_length: float = 0.0
## The directions the character will face while traveling on the path.
var _path_directions: Array[DirectionSegment] = []
## The index of the current direction segment.
var _direction_segment: int = 0


## Called when a new instance of this object is created.
func _init() -> void:
	_offset = 0.0
	_path_length = 0.0


## Updates the offset amount by the given value.
func move_offset(offset_update: float) -> void:
	if get_point_count() <= 1:
		emit_signal("movement_finished", get_current_pos())
		return
	_offset = offset_update
	for i: int in _path_directions.size():
		var segment := _path_directions[i]
		if segment.start <= _offset and segment.end > _offset:
			_direction_segment = i
			break
	if _offset >= _path_length:
		_offset = _path_length
		emit_signal("movement_finished", get_current_pos())


## Gets the current global position of the path at its current progression.
func get_current_pos() -> Vector3:
	# Position does not update on a path of only one point. That point is still
	# defined and should be given instead.
	if get_point_count() == 1:
		return get_point_position(0)
	return sample_baked(_offset)


## Gets the current travel direction of the path at its current progression.
## Returns a zero vector if no directions are recorded.
func get_current_direction() -> Vector2:
	if _path_directions.size() == 0:
		return Vector2.ZERO
	return _path_directions[_direction_segment].direction


## Creates a straight-line path from the starting coordinate to the ending
## coordinate.
func create_line_path(step_coordinates: PackedVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	add_point(step_coordinates[0])
	if step_coordinates.size() == 1:
		return
	add_point(step_coordinates[-1])
	_path_length = get_baked_length()
	_add_direction_segment(
			step_coordinates[0],
			step_coordinates[-1],
			0.0,
			_path_length
	)


## Creates a single bezier-line path from the starting coordinate to the ending
## coordinate.
func create_bezier_path(step_coordinates: PackedVector3Array) -> void:
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
	_add_direction_segment(
			step_coordinates[0],
			step_coordinates[-1],
			0.0,
			_path_length
	)


## Create a series of straight-line paths from one coordinate to the next.
func create_segmented_line_path(step_coordinates: PackedVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	if step_coordinates.size() == 1:
		add_point(step_coordinates[0])
		return
	var prior_step: float = 0.0
	var current_step: float = 0.0
	for i: int in step_coordinates.size():
		add_point(step_coordinates[i])
		if i > 0:
			current_step = get_baked_length()
			_add_direction_segment(
					step_coordinates[i - 1],
					step_coordinates[i],
					prior_step,
					current_step
			)
			prior_step = current_step
	_path_length = get_baked_length()


## Create a series of straight-line and bezier-line paths from one coordinate to
## the next, depending on the Y difference of the next coordinate.
func create_segmented_bezier_path(step_coordinates: PackedVector3Array) -> void:
	_assert_path_present(step_coordinates)
	_offset = 0.0
	if step_coordinates.size() == 1:
		add_point(step_coordinates[0])
		return
	var prior_step: float = 0.0
	var current_step: float = 0.0
	for i: int in step_coordinates.size() - 1:
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
		current_step = get_baked_length()
		_add_direction_segment(
				cur_coord,
				next_coord,
				prior_step,
				current_step
		)
		prior_step = current_step
	_path_length = get_baked_length()



## Resets the offset value and the curve shape.
func reset_path() -> void:
	_offset = 0.0
	_path_length = 0.0
	clear_points()
	_path_directions.clear()
	_direction_segment = 0


## Adds a direction segment based on the positions and offsets.
func _add_direction_segment(
	pos_1: Vector3,
	pos_2: Vector3,
	start: float,
	end: float
) -> void:
	var direction := pos_1.direction_to(pos_2)
	var segment_direction := Vector2(direction.x, direction.z).normalized()
	_path_directions.append(DirectionSegment.new(segment_direction, start, end))


## Validates that a provided path has at least one point.
func _assert_path_present(path: PackedVector3Array) -> void:
	assert(
			path.size() > 0,
			"Error: Attempted to define a movement path with no points."
	)


class DirectionSegment:
## Describes the travel direction for a given segment of path.
	
	
	## The direction for the segment.
	var direction: Vector2
	## The starting point of the segment in terms of path offset.
	var start: float
	## The ending point of the segment in terms of path offset.
	var end: float
	
	
	## Creates a new segment instance.
	func _init(
		new_direction: Vector2,
		start_offset: float,
		end_offset: float
	) -> void:
		direction = new_direction
		start = start_offset
		end = end_offset
