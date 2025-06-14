class_name ColumnArea
extends AreaRange
"""
Describes a range whose area starts from a point and reaches out in a diamond
shape.
"""


# Describes how wide the diamond area is.
export (int, 0, 100) var spread = 0
# Describes how far out the range extends away from the start point.
export (int, 1, 100) var distance = 1


# Returns the reach of the ColumnArea. Used when determining which tiles are
# affected by tile heights.
func get_reach() -> int:
	return distance + spread


# Determines which map tiles are in the column area positioned at the start index,
# oriented to face the specified direction (0 - 5). Does not account for tile
# heights.
func determine_directional_area_indexes(start: int, dir: int, map_tiles: Tiles) -> Array:
	var left_dir: int = dir - 1 if dir > 0 else 5
	var right_dir: int = dir + 1 if dir < 5 else 0
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	tile_ids.append(start)
	for s in range(spread + 1):
		var left_coord: Vector3 = HexUtil.cube_at_distance(start_coord, s, left_dir)
		var right_coord: Vector3 = HexUtil.cube_at_distance(start_coord, s, right_dir)
		if s > 0:
			if map_tiles.is_valid_cube(left_coord):
				var tile_id = HexUtil.cube_to_index(
						left_coord,
						map_tiles.get_x_count()
				)
				tile_ids.append(tile_id)
			if map_tiles.is_valid_cube(right_coord):
				var tile_id = HexUtil.cube_to_index(
						right_coord,
						map_tiles.get_x_count()
				)
				tile_ids.append(tile_id)
		# Add additional tiles to fully fill in the "column" shape. Without the
		# extra tiles, the shape is a chevron.
		for d in range(distance + spread - s + 1):
			# Only cast ray from starting point when spread is at 0.
			if s == 0:
				var ray_coord: Vector3 = HexUtil.cube_at_distance(start_coord, d, dir)
				if map_tiles.is_valid_cube(ray_coord):
					var tile_id = HexUtil.cube_to_index(
						ray_coord,
						map_tiles.get_x_count()
					)
					tile_ids.append(tile_id)
			# Cast rays from both left and right points.
			else:
				var ray_coord_l: Vector3 = HexUtil.cube_at_distance(left_coord, d, dir)
				var ray_coord_r: Vector3 = HexUtil.cube_at_distance(right_coord, d, dir)
				if map_tiles.is_valid_cube(ray_coord_l):
					var tile_id = HexUtil.cube_to_index(
						ray_coord_l,
						map_tiles.get_x_count()
					)
					tile_ids.append(tile_id)
				if map_tiles.is_valid_cube(ray_coord_r):
					var tile_id = HexUtil.cube_to_index(
						ray_coord_r,
						map_tiles.get_x_count()
					)
					tile_ids.append(tile_id)
	return tile_ids


# Modifies a RangeDisplay hex matrix so that it reflects the details of this ColumnArea.
func populate_range_display_matrix(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	hex_matrix: Array
) -> void:
	pass
