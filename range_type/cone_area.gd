class_name ConeArea
extends AreaRange
"""
Describes a range whose area can be described as a cone.
"""


# Describes how wide the cone area is.
export (int, 0, 5) var spread = 0
# Describes how far out the cone extends away from the start point.
export (int, 1, 100) var distance = 1


# Returns the reach of the ConeArea. Used when determining which tiles are
# affected by tile heights.
func get_reach() -> int:
	return distance


# Determines which map tiles are in the cone area position at the start index,
# oriented to face the specified direction (0 - 5). Does not account for tile
# heights.
func determine_directional_area_indexes(
	start: int,
	dir: int,
	map_tiles: Tiles
) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	tile_ids.append(start)
	for s in range(spread + 1):
		var cur_dir: int = dir + s
		# Keep the direction witin the bounds of 0 - 5.
		cur_dir -= 0 if cur_dir < 6 else 6
		for d in range(distance):
			var cur_coord: Vector3 = HexUtil.cube_at_distance(
					start_coord,
					d + 1,
					cur_dir
			)
			if map_tiles.is_valid_cube(cur_coord):
				var tile_id = HexUtil.cube_to_index(
						cur_coord,
						map_tiles.get_x_count()
				)
				tile_ids.append(tile_id)
			# Don't cast ray if this is the last origin line to add.
			if s < spread:
				_determine_ray_indexes(d, cur_dir, cur_coord, map_tiles, tile_ids)
	return tile_ids


# Modifies a RangeDisplay hex matrix so that it reflects the details of this ConeArea.
func populate_range_display_matrix(
	center_point: Vector2,
	outline_type: int,
	fill_type: int,
	hex_matrix: Array
) -> void:
	var start_coord: Vector3 = HexUtil.index_to_cube(
			center_point.y * hex_matrix[0].size() + center_point.x,
			hex_matrix[0].size()
	)
	var dir: int = _get_initial_direction()
	for s in range(spread + 1):
		var cur_dir: int = dir + s
		# Keep the direction witin the bounds of 0 - 5.
		cur_dir -= 0 if cur_dir < 6 else 6
		for d in range(distance):
			var cur_coord: Vector3 = HexUtil.cube_at_distance(
					start_coord,
					d + 1,
					cur_dir
			)
			var cur_index: Vector2 = HexUtil.cube_to_offset(cur_coord)
			if _is_index_in_matrix(cur_index, hex_matrix):
				_update_hex_matrix(hex_matrix, cur_index, outline_type, fill_type)
			# Don't cast ray if this is the last origin line to add.
			if s < spread:
				_determine_ray_displays(
						d,
						cur_dir,
						cur_coord,
						hex_matrix,
						outline_type,
						fill_type
				)


# Helper function that gets the tile indexes of the "ray" from a specific tile.
func _determine_ray_indexes(
		distance_step: int,
		cur_dir: int,
		cur_coord: Vector3,
		map_tiles: Tiles, 
		tile_ids: Array
) -> void:
	for i in distance_step:
		# The ray is cast two positions clockwise from the origin direction
		var ray_dir: int = cur_dir + 2 if cur_dir < 4 else cur_dir - 4
		var ray_coord: Vector3 = HexUtil.cube_at_distance(
				cur_coord,
				i + 1,
				ray_dir
		)
		if map_tiles.is_valid_cube(ray_coord):
			var tile_id = HexUtil.cube_to_index(
					ray_coord,
					map_tiles.get_x_count()
			)
			tile_ids.append(tile_id)


# Helper function that updates the hex matrix details for a "ray" cast from 
# a specific tile.
func _determine_ray_displays(
		distance_step: int,
		cur_dir: int,
		cur_coord: Vector3,
		hex_matrix: Array,
		outline_type: int,
		fill_type: int
) -> void:
	for i in distance_step:
		# The ray is cast two positions clockwise from the origin direction
		var ray_dir: int = cur_dir + 2 if cur_dir < 4 else cur_dir - 4
		var ray_coord: Vector3 = HexUtil.cube_at_distance(
				cur_coord,
				i + 1,
				ray_dir
		)
		var ray_index: Vector2 = HexUtil.cube_to_offset(ray_coord)
		if _is_index_in_matrix(ray_index, hex_matrix):
			_update_hex_matrix(hex_matrix, ray_index, outline_type, fill_type)


# Helper for populate_range_display. Determines which direction to start from
# given the current ConeArea dimensions for the purposes of orienting the display.
# The direction will orient the cone area to the right of the emission point.
func _get_initial_direction() -> int:
	return posmod(HexUtil.HexDirection.RIGHT - floor(spread / 2), 5)
