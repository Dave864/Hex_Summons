class_name DistanceMap
extends Object
## Records the travel and tile distances of all points in a hex map from a specific
## origin point.
##
## The logic for actually populating the distance map is in HexMapAStar.


const TILE_KEY: String = "tile"
const TRAVEL_KEY: String = "travel"

## The origin point for the distance map.
var origin: int = -1
## Stores the travel and tile distances from the origin point.
var _d_map: Dictionary[int, Dictionary] = {}


## Initializes the data for this DistanceMap.
func _init(o: int = -1, d_map: Dictionary[int, Dictionary] = {}) -> void:
	origin = o
	_d_map = d_map


## Returns the number of elements in the DistanceMap.
func size() -> int:
	return _d_map.size()


## Checks if the DistanceMap has a given index.
func has(index: int) -> bool:
	return _d_map.has(index)


## Adds the specific distance details for the given index.
func add(index: int, distance_details: Dictionary[String, float]) -> void:
	_d_map[index] = distance_details


## Removes the data at the given index from the distance map. Returns the data
## that was removed. Returns an empty Dictionary if the index is not present.
func remove(index: int) -> Dictionary[String, float]:
	if not _d_map.has(index):
		return {}
	var removed_details: Dictionary[String, float] = _d_map[index]
	_d_map.erase(index)
	return removed_details


## Returns the map indexes the distance map tracks.
func tile_ids() -> Array[int]:
	return _d_map.keys()


## Gets the tile distance of the given tile. Returns -1 if the index is not present.
func tile_dist_at(index: int) -> int:
	if not _d_map.has(index):
		return -1
	return _d_map[index][TILE_KEY]


## Gets the travel distance of the given tile. Returns -1 if the index is not present.
func travel_dist_at(index: int) -> float:
	if not _d_map.has(index):
		return -1.0
	return _d_map[index][TRAVEL_KEY]


## Returns a Dictionary describing all distances of the given tile. Returns an
## empty Dictionaru if the index is not present.
func all_dist_at(index: int) -> Dictionary[String, float]:
	if not _d_map.has(index):
		return {}
	return _d_map[index]


## Gets the area map that reaches out to a given tile radius.
func map_from_tile_dist(radius: int) -> Dictionary[int, Dictionary]:
	var area_map: Dictionary[int, Dictionary] = {}
	for id: int in _d_map.keys():
		if _d_map[id][TILE_KEY] <= radius:
			area_map[id] = _d_map[id]
	return area_map


## Gets the area map that reaches out to a given travel radius.
func map_from_travel_dist(radius: int) -> Dictionary[int, Dictionary]:
	var area_map: Dictionary[int, Dictionary] = {}
	for id in _d_map.keys():
		if _d_map[id][TRAVEL_KEY] <= radius:
			area_map[id] = _d_map[id]
	return area_map
