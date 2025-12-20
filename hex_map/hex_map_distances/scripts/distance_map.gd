class_name DistanceMap
extends Object
## Records the travel and tile distances of all points in a hex map from a
## specific origin point.
##
## The logic for actually populating the distance map is in HexMapAStar.


## The origin point for the distance map.
var origin: int = -1
## Stores the travel and tile distances from the origin point.
var _d_map: Dictionary[int, DistanceData] = {}


## Initializes the data for this DistanceMap.
func _init(o: int = -1, d_map: Dictionary[int, DistanceData] = {}) -> void:
	origin = o
	_d_map = d_map


## Returns the number of elements in the DistanceMap.
func size() -> int:
	return _d_map.size()


## Checks if the DistanceMap has a given index.
func has(index: int) -> bool:
	return _d_map.has(index)


## Adds the specific distance details for the given index.
func add(index: int, distance_details: DistanceData) -> void:
	_d_map[index] = distance_details


## Removes the data at the given index from the distance map. Returns the data
## that was removed. Returns an empty Dictionary if the index is not present.
func remove(index: int) -> DistanceData:
	if not _d_map.has(index):
		return null
	var removed_details: DistanceData = _d_map[index]
	_d_map.erase(index)
	return removed_details


## Returns the map indexes the distance map tracks.
func tile_ids() -> Array[int]:
	return _d_map.keys()


## Gets the tile distance of the given tile. Returns -1 if the index is not present.
func tile_dist_at(index: int) -> int:
	if not _d_map.has(index):
		return -1
	return _d_map[index].tile


## Gets the travel distance of the given tile. Returns -1 if the index is not present.
func travel_dist_at(index: int) -> float:
	if not _d_map.has(index):
		return -1.0
	return _d_map[index].travel


## Returns a DistanceData object describing all distances of the given tile.
## Returns null if the index is not present.
func all_dist_at(index: int) -> DistanceData:
	if not _d_map.has(index):
		return null
	return _d_map[index]


## Creates a new area map that reaches out to a given tile radius.
func map_from_tile_dist(radius: int) -> DistanceMap:
	var area_map: Dictionary[int, DistanceData] = {}
	for id: int in _d_map.keys():
		if _d_map[id].tile <= radius:
			area_map[id] = _d_map[id]
	return DistanceMap.new(origin, area_map)


## Creates a new area map that reaches out to a given travel radius.
func map_from_travel_dist(radius: int) -> DistanceMap:
	var area_map: Dictionary[int, DistanceData] = {}
	for id in _d_map.keys():
		if _d_map[id].travel <= radius:
			area_map[id] = _d_map[id]
	return DistanceMap.new(origin, area_map)
