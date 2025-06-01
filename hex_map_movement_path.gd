class_name HexMapMovementPath
extends Path
"""
Base class for adjustable movement paths for HexMap movement.
"""


signal movement_finished()


# Updates the unit offset amount by the given value.
func move_unit_offset(offset_update: float) -> void:
	$PathFollow.unit_offset = offset_update
	if $PathFollow.unit_offset >= 1.0:
		emit_signal("movement_finished")


# Gets the current global position of the path at its current progression.
func get_current_pos() -> Vector3:
	return $PathFollow/Position3D.global_translation


# Creates a path curve using the provided array of map tile coordinates.
func create_path(_step_coordinates: Array) -> void:
	pass


# Creates a straight-line path from the starting coordinate to the ending coordinate.
func create_line_path(step_coordinates: Array) -> void:
	curve.add_point(step_coordinates[0])
	curve.add_point(step_coordinates[-1])
	# Initialize start.
	$PathFollow.unit_offset = 0.0


# Creates a single bezier-line path from the starting coordinate to the ending coordinate.
func create_bezier_path(step_coordinates: Array) -> void:
	# Update the in and out controls based on the height difference.
	var height_diff: float = step_coordinates[-1].y - step_coordinates[0].y
	var in_val: float = 1.0 + height_diff if height_diff > 0.0 else 1.0
	var out_val: float = 1.0 + abs(height_diff) if height_diff < 0.0 else 1.0
	curve.add_point(step_coordinates[0], Vector3.ZERO, Vector3(0.0, out_val, 0.0))
	curve.add_point(step_coordinates[-1], Vector3(0.0, in_val, 0.0), Vector3.ZERO)
	# Initialize start.
	$PathFollow.unit_offset = 0.0


# Create a series of straight-line paths from one coordinate to the next.
func create_segmented_line_path(step_coordinates: Array) -> void:
	for coord in step_coordinates:
		curve.add_point(coord)
	# Initialize start.
	$PathFollow.unit_offset = 0.0


# Create a series of straight-line and bezier-line paths from one coordinate to the
# next, depending on the Y difference of the next coordinate.
func create_segmented_bezier_path(step_coordinates: Array) -> void:
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
	# Initialize start.
	$PathFollow.unit_offset = 0.0



# Resets the offset value and the curve shape.
func reset_path() -> void:
	$PathFollow.unit_offset = 0.0
	curve.clear_points()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
