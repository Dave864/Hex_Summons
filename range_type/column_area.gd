class_name ColumnArea
extends AreaRange
## Describes a range whose area starts from a point and reaches out in a diamond
## shape.


## Describes how wide the diamond area is.
@export_range(0, 100) var spread: int = 0
## Describes how far out the range extends away from the start point.
@export_range(1, 100) var distance: int = 1


## Returns the reach of the ColumnArea. Used when determining which tiles are
## affected by tile heights.
func get_reach() -> int:
	return distance + spread


## Determines which map tiles are in the column area positioned at the start index,
## oriented to face the specified direction (0 - 5). Does not account for tile
## heights.
func get_dir_area_indexes(start: int, dir: int, hm: HexMap) -> Array[int]:
	var left_dir: int = dir - 1 if dir > 0 else 5
	var right_dir: int = dir + 1 if dir < 5 else 0
	var tile_ids: Array[int] = []
	var start_coord: Vector3 = (
			hm.get_tile_at(start) \
			.map_coordinate.get_cube_coord()
	)
	tile_ids.append(start)
	for s in range(spread + 1):
		var left_coord: Vector3 = HexUtil.cube_at_distance(
				start_coord,
				s,
				left_dir
		)
		var right_coord: Vector3 = HexUtil.cube_at_distance(
				start_coord,
				s,
				right_dir
		)
		if s > 0:
			if hm.is_valid_cube(left_coord):
				var tile_id = HexUtil.cube_to_index(
						left_coord,
						hm.get_x_count()
				)
				tile_ids.append(tile_id)
			if hm.is_valid_cube(right_coord):
				var tile_id = HexUtil.cube_to_index(
						right_coord,
						hm.get_x_count()
				)
				tile_ids.append(tile_id)
		# Add additional tiles to fully fill in the "column" shape. Without the
		# extra tiles, the shape is a chevron.
		for d in range(distance + spread - s + 1):
			# Only cast ray from starting point when spread is at 0.
			if s == 0:
				var ray_coord: Vector3 = HexUtil.cube_at_distance(
						start_coord,
						d,
						dir
				)
				if hm.is_valid_cube(ray_coord):
					var tile_id = HexUtil.cube_to_index(
							ray_coord,
							hm.get_x_count()
					)
					tile_ids.append(tile_id)
			# Cast rays from both left and right points.
			else:
				var ray_coord_l: Vector3 = HexUtil.cube_at_distance(
						left_coord,
						d,
						dir
				)
				var ray_coord_r: Vector3 = HexUtil.cube_at_distance(
						right_coord,
						d,
						dir
				)
				if hm.is_valid_cube(ray_coord_l):
					var tile_id = HexUtil.cube_to_index(
							ray_coord_l,
							hm.get_x_count()
					)
					tile_ids.append(tile_id)
				if hm.is_valid_cube(ray_coord_r):
					var tile_id = HexUtil.cube_to_index(
							ray_coord_r,
							hm.get_x_count()
					)
					tile_ids.append(tile_id)
	return tile_ids


## Gets all tiles that could fall within range of this column area. If this
## column area was applied in all directions at once, what tiles would be in
## that area?
func get_area_indexes(start: int, hm: HexMap) -> Array[int]:
	# Using as set to prevent duplicates as GDScript does not have a Set data
	# structure.
	var total_coverage: Dictionary[int, bool] = {}
	for dir: int in 6:
		for index: int in get_dir_area_indexes(start, dir, hm):
			total_coverage[index] = true
	return total_coverage.keys()


## Modifies a RangeDisplay hex matrix so that it reflects the details of this
## ColumnArea.
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
	for s in range(spread + 1):
		var left_coord: Vector3 = HexUtil.cube_at_distance(
				start_coord,
				s,
				HexUtil.HexDirection.UPPER_RIGHT
		)
		var right_coord: Vector3 = HexUtil.cube_at_distance(
				start_coord,
				s,
				HexUtil.HexDirection.BOTTOM_RIGHT
		)
		if s > 0:
			var left_index: Vector2 = HexUtil.cube_to_offset(left_coord)
			var right_index: Vector2 = HexUtil.cube_to_offset(right_coord)
			if _is_index_in_matrix(left_index, d_matrix):
				_update_hex_matrix(d_matrix, left_index, outline_type, fill_type)
			if _is_index_in_matrix(right_index, d_matrix):
				_update_hex_matrix(d_matrix, right_index, outline_type, fill_type)
		# Add additional tiles to fully fill in the "column" shape. Without the
		# extra tiles, the shape is a chevron.
		for d in range(distance + spread - s + 1):
			# Only cast ray from starting point when spread is at 0.
			if s == 0:
				var ray_coord: Vector3 = HexUtil.cube_at_distance(
						start_coord,
						d,
						HexUtil.HexDirection.RIGHT
				)
				var hex_index: Vector2 = HexUtil.cube_to_offset(ray_coord)
				if _is_index_in_matrix(hex_index, d_matrix):
					_update_hex_matrix(d_matrix, hex_index, outline_type, fill_type)
			# Cast rays from both left and right points.
			else:
				var ray_coord_l: Vector3 = HexUtil.cube_at_distance(
						left_coord,
						d,
						HexUtil.HexDirection.RIGHT
				)
				var ray_hex_l: Vector2 = HexUtil.cube_to_offset(ray_coord_l)
				var ray_coord_r: Vector3 = HexUtil.cube_at_distance(
						right_coord,
						d,
						HexUtil.HexDirection.RIGHT
				)
				var ray_hex_r: Vector2 = HexUtil.cube_to_offset(ray_coord_r)
				if _is_index_in_matrix(ray_hex_l, d_matrix):
					_update_hex_matrix(d_matrix, ray_hex_l, outline_type, fill_type)
				if _is_index_in_matrix(ray_hex_r, d_matrix):
					_update_hex_matrix(d_matrix, ray_hex_r, outline_type, fill_type)
