class_name HexMapDistances
extends Resource
## Stores the distance maps for all tiles for a given hex map.


## The extension for files that store the serialized data for this resource
const FILE_EXTENSION: String = "distances"

var d_maps: Dictionary[int, DistanceMap] = {}


## Gets the distance map at the given map index. Returns null if the index is not
## present.
func at(index: int) -> DistanceMap:
	if not d_maps.has(index):
		return null
	return d_maps[index]


## Clears out the recorded DistanceMaps.
func clear() -> void:
	for i in d_maps.keys():
		d_maps.erase(i)


## Checks if distances have been created.
func distances_present() -> bool:
	return not d_maps.is_empty()
