class_name DistanceMap
extends Object
"""
Records the travel and tile distances of all points in a hex map from a specific
origin point. The logic for actually populating the distance map is in
HexMapAStar.
"""


const TILE_KEY: String = "tile"
const TRAVEL_KEY: String = "travel"

# The origin point for the distance map.
var origin: int = -1
# Stores the travel and tile distances from the origin point.
var _d_map: Dictionary = {}


# Returns the number of elements in the DistanceMap.
func size() -> int:
	return _d_map.size()


# Gets the tile distance of the given tile. Returns -1 if the index is not present.
func tile_dist_at(index: int) -> int:
	if not _d_map.has(index):
		return -1
	return _d_map[index][TILE_KEY]


# Gets the travel distance of the given tile. Returns -1 if the index is not present.
func travel_dist_at(index: int) -> float:
	if not _d_map.has(index):
		return -1.0
	return _d_map[index][TRAVEL_KEY]


# Gets the area map that reaches out to a given tile radius.
func create_map_for_tile_area(radius: int) -> Dictionary:
	var area_map: Dictionary = {}
	for id in _d_map.keys():
		if _d_map[id][TILE_KEY] <= radius:
			area_map[id] = _d_map[id]
	return area_map


# Gets the area map that reaches out to a given travel radius.
func create_map_for_travel_area(radius: int) -> Dictionary:
	var area_map: Dictionary = {}
	for id in _d_map.keys():
		if _d_map[id][TRAVEL_KEY] <= radius:
			area_map[id] = _d_map[id]
	return area_map


# Initializes the data for this DistanceMap.
func _init(o: int = -1, d_map: Dictionary = {}) -> void:
	origin = o
	_d_map = d_map
