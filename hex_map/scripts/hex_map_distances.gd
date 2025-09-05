class_name HexMapDistances
extends Resource
"""
Stores the distance maps for all tiles for a given hex map.
"""


export(Dictionary) var d_maps = {}


# Gets the distance map at the given map index. Returns null if the index is not
# present.
func at(index: int) -> DistanceMap:
	if not d_maps.has(index):
		return null
	return d_maps[index]


# Creates the distance maps for a given map.
func create_from_map(map_tiles: Array, hm_astar: HexMapAStar) -> void:
	# Enable all connections to make sure distance can be found.
	hm_astar.set_all_disabled(false)
	var index: int
	for tile in map_tiles:
		index = tile.map_coordinate.get_index()
		d_maps[index] = hm_astar.get_full_distance_map(index)
	# Reset for future range finder operations.
	hm_astar.set_all_disabled()


# Clears out the recorded DistanceMaps.
func clear() -> void:
	for i in d_maps.keys():
		d_maps[i].free()
		d_maps.erase(i)


# Checks if distances have been created.
func distances_present() -> bool:
	return not d_maps.empty()
