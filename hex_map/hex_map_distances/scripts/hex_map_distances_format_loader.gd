@tool
class_name HexMapDistancesFormatLoader
extends ResourceFormatLoader
## ResourceFormatLoader for HexMapDistances resource.


func _get_recognized_extensions() -> PackedStringArray:
	# only saves to ".gamedata" files
	return PackedStringArray([HexMapDistances.FILE_EXTENSION])


func _recognize(resource: Resource) -> bool:
	return resource is HexMapDistances


func _handles_type(type: StringName) -> bool:
	return type == "Resource"


func _get_resource_script_class(path: String) -> String:
	if path.get_extension() == HexMapDistances.FILE_EXTENSION:
		return "HexMapDistances"
	return ""


func _get_resource_type(path: String) -> String:
	if path.get_extension() == HexMapDistances.FILE_EXTENSION:
		return "Resource"
	return ""


func _load(
	path: String,
	_original_path: String,
	_use_sub_threads: bool,
	_cache_mode: int
) -> Variant:
	var hex_map_distances:= HexMapDistances.new()
	#TODO: set up logic for using open_encrypted
	var file := FileAccess.open(path, FileAccess.READ)
	var distance_map_size: int = file.get_32()
	for i: int in distance_map_size:
		var origin_index: int = file.get_32()
		var distance_map_data: Dictionary[int, DistanceData] = {}
		for j: int in distance_map_size:
			var tile_index: int = file.get_32()
			distance_map_data[tile_index] = DistanceData.new(
					file.get_32(),
					file.get_float()
			)
		hex_map_distances.d_maps[origin_index] = DistanceMap.new(
				origin_index,
				distance_map_data
		)
	file.close()
	return hex_map_distances
