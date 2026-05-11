class_name LineArea
extends DirectionalAreaRange
## Describes a directional area of a line of points.


## Describes the number of tiles within the line.
@export_range(2, 100) var length: int = 2


## Returns the length of the line. Used when determining which tiles are
## affected by tile heights.
func get_reach() -> int:
	return length


## Determines which map tiles are in the line area positioned at the start
## index, oriented to face the specified direction (0 - 5). Does not account
## for tile heights.
func get_dir_area_indexes(start: int, dir: int, hm: HexMap) -> Array[int]:
	var tile_ids: Array[int] = []
	tile_ids.append(start)
	var start_coord: Vector3 = (
		hm.get_tile_at(start).map_coordinate.get_cube_coord()
	)
	for i: int in range(1, length + 1):
		var coord: Vector3 = HexUtil.cube_at_distance(start_coord, i, dir)
		if hm.is_valid_cube(coord):
			var tile_id: int = HexUtil.cube_to_index(coord, hm.get_x_count())
			tile_ids.append(tile_id)
	return tile_ids


## Modifies a RangeDisplay hex matrix so that it reflects the details of this
## LineArea.
func update_range_display(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	d_matrix: DisplayMatrix
) -> void:
	var start_coord: Vector3 = HexUtil.index_to_cube(
			int(center_point.y * d_matrix.get_col_count() + center_point.x),
			d_matrix.get_col_count()
	)
	_update_hex_matrix(d_matrix, center_point, outline_type, fill_type)
	for i: int in range(1, length + 1):
		var ray_coord: Vector3 = HexUtil.cube_at_distance(
				start_coord,
				i,
				HexUtil.HexDirection.RIGHT
		)
		var hex_index: Vector2 = HexUtil.cube_to_offset(ray_coord)
		if _is_index_in_matrix(hex_index, d_matrix):
			_update_hex_matrix(d_matrix, hex_index, outline_type, fill_type)
