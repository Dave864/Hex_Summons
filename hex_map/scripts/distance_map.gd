class_name DistanceMap
extends Object
"""
Records the travel and tile distances of all points in a hex map from a specific
origin point. The logic for actually populating the distance map are in
HexMapAStar. This object serves as a way to provide more explicit operations for
interacting with the data of the distance map.
"""


const TILE_KEY = "tile"
const TRAVEL_KEY = "travel"

# The origin point for the distance map.
var origin: int = -1
# Stores the travel and tile distances from the origin point.
var _d_map: Dictionary = {}


# Gets the tile distance of the given tile. Returns -1 if the index is not present.
func tile_dist_at(index: int) -> int:
	if not _d_map.has(index):
		return -1
	return _d_map[index][TILE_KEY]


# Gets the travek distance of the given tile. Returns -1 if the index is not present.
func travel_dist_at(index: int) -> float:
	if not _d_map.has(index):
		return -1.0
	return _d_map[index][TRAVEL_KEY]


# Gets a new distance map that reaches out to a given tile radius.
func create_map_for_tile_area(radius: int) -> DistanceMap:
	var _area_map: Dictionary = {}
	for id in _d_map.keys():
		if _d_map[id][TILE_KEY] <= radius:
			_area_map[id] = _d_map[id]
	var d_map: DistanceMap = DistanceMap.new(origin, _area_map)
	return d_map


# Gets a new distance map that reaches out to a given travel radius.
func create_map_for_travel_area(radius: int) -> DistanceMap:
	var _area_map: Dictionary = {}
	for id in _d_map.keys():
		if _d_map[id][TRAVEL_KEY] <= radius:
			_area_map[id] = _d_map[id]
	var d_map: DistanceMap = DistanceMap.new(origin, _area_map)
	return d_map


# Initializes the data for this DistanceMap.
func _init(o: int, d_map: Dictionary) -> void:
	origin = o
	_d_map = d_map
