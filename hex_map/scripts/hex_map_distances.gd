class_name HexMapDistances
extends Resource
## Stores the distance maps for all tiles for a given hex map.


@export var d_maps: Dictionary = {}
@export var map_hash: int = -1


## Gets the distance map at the given map index. Returns null if the index is not
## present.
func at(index: int) -> DistanceMap:
	if not d_maps.has(index):
		return null
	return DistanceMap.new(index, d_maps[index])


## Clears out the recorded DistanceMaps.
func clear() -> void:
	for i in d_maps.keys():
		d_maps[i].free()
		d_maps.erase(i)


## Checks if distances have been created.
func distances_present() -> bool:
	return not d_maps.is_empty()
