@tool
class_name HexMapDistancesFormatSaver
extends ResourceFormatSaver
## ResourceFormatSaver for HexMapDistances resource.


func _recognize(resource: Resource) -> bool:
	return resource is HexMapDistances


func _get_recognized_extensions(_resource: Resource) -> PackedStringArray:
	return PackedStringArray([HexMapDistances.FILE_EXTENSION])


func _save(resource: Resource, path: String, _flags: int) -> Error:
	assert(resource is HexMapDistances)
	var hex_map_distances := resource as HexMapDistances
	# TODO: set up logic for using open_encrypted
	var file := FileAccess.open(path, FileAccess.WRITE)
	# Store number of distance maps in order to properly load the data from file.
	# The number of distance maps is the same as the size of said maps.
	if not file.store_32(hex_map_distances.d_maps.size()):
		return Error.ERR_FILE_CANT_WRITE
	for origin_index: int in hex_map_distances.d_maps:
		if not file.store_32(origin_index):
			return Error.ERR_FILE_CANT_WRITE
		var distance_map: DistanceMap = hex_map_distances.at(origin_index)
		for tile_index: int in distance_map.tile_ids():
			if not file.store_32(tile_index):
				return Error.ERR_FILE_CANT_WRITE
			if not file.store_32(distance_map.tile_dist_at(tile_index)):
				return Error.ERR_FILE_CANT_WRITE
			if not file.store_float(distance_map.travel_dist_at(tile_index)):
				return Error.ERR_FILE_CANT_WRITE
	file.close()
	return Error.OK
