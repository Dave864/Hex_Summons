class_name AdjacentPointArea
extends DirectionalAreaRange
## Describes an area range that is a single point next to the emission point
## (i.e. a line of length 2 that ignores the emission point).


## Returns 1 as the adajent point is only one tile away.
func get_reach() -> int:
	return 1


## Determines which map tile is the adjacent point to the start index, oriented
## to face the specified direction (0 - 5). Does not account for tile heights.
func get_dir_area_indexes(start: int, dir: int, hm: HexMap) -> Array[int]:
	var start_coord: Vector3 = (
		hm.get_tile_at(start).map_coordinate.get_cube_coord()
	)
	var point_coord: Vector3 = HexUtil.cube_at_distance(start_coord, 1, dir)
	var adjacent_tile_id: int = HexUtil.cube_to_index(
			point_coord,
			hm.get_x_count()
	)
	return [adjacent_tile_id]


## Modifies a RangeDisplay hex matrix so that it reflects the details of this
## AdjacentPointArea.
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
	var ray_coord: Vector3 = HexUtil.cube_at_distance(
			start_coord,
			1,
			HexUtil.HexDirection.RIGHT
	)
	var hex_index: Vector2 = HexUtil.cube_to_offset(ray_coord)
	d_matrix.set_details(hex_index, outline_type, fill_type)
