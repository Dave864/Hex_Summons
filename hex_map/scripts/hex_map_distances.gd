class_name HexMapDistances
extends Resource
"""
Stores the distance maps for all tiles for a given hex map.
"""


var _d_maps: Dictionary = {}


# Gets the distance map at the given map index. Returns null if the index is not
# present.
func distances_at(index: int) -> DistanceMap:
	if not _d_maps.has(index):
		return null
	return _d_maps[index]


# Creates the distance maps for a given map.
func create_from_map(map_tiles: Array, hm_astar: HexMapAStar) -> void:
	# Enable all connections to make sure distance can be found.
	hm_astar.set_all_disabled(false)
	var index: int
	for tile in map_tiles:
		index = tile.map_coordinate.get_index()
		_d_maps[index] = hm_astar.get_full_distance_map(index)
	# Reset for future range finder operations.
	hm_astar.set_all_disabled()


# Checks if the distances has been created.
func distances_present() -> bool:
	return _d_maps.empty()
