class_name ConeArea
extends AreaRange
"""
Describes a range whose area can be described as a cone.
"""


# Describes how wide the cone area is.
export (int, 0, 5) var spread = 0
# Describes how far out the cone extends away from the start point.
export (int, 1, 100) var distance = 1


# Determines which map tiles are in the cone area position at the start index,
# oriented to face the specified direction (0 - 5). Does not account for tile
# heights.
func determine_cone_area_indexes(start: int, dir: int, map_tiles: Tiles) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = map_tiles.get_tile_at_index(start).map_coordinate.get_cube_coord()
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
				tile_ids.append(cur_coord)
			# Don't cast ray if this is the last origin line to add.
			if s < spread:
				for i in range(d):
					# The ray is cast two positions clockwise from the origin direction
					var ray_dir: int = cur_dir + 2 if cur_dir < 4 else cur_dir - 4
					var ray_coord: Vector3 = HexUtil.cube_at_distance(
							cur_coord,
							i + 1,
							ray_dir
					)
					if map_tiles.is_valid_cube(ray_coord):
						tile_ids.append(ray_coord)
	return tile_ids
