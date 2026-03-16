@tool
class_name HexMesh
extends Node3D
## A collection of meshes that represents an individual map tile.
##
## Comprised of a top mesh and a series of side meshes stacked on top of each
## other.


## The side mesh of the hex tile.
var _hex_side_mesh: PackedScene = preload(
		"res://hex_map/MapTile/HexMesh/HexSideMesh.tscn"
)

## The top mesh of the hex tile.
@onready var _hex_top_mesh: Node3D = $HexTopMesh
## Contains all of the side segments for this tile.
@onready var _side_segments: Node3D = $SideSegments
## Referene to the scene tree root.
@onready var _root_node: Node = get_tree().edited_scene_root


## Creates a name for a side segment with the given index.
func _side_segment_name(index: int) -> String:
	return "HexSideSegment%d" % index


## Adds a number of side segments, positioning them on top of any existing ones.
func _add_side_segments(add_count: int) -> void:
	var start_count: int = _side_segments.get_child_count()
	for i: int in add_count:
		var new_segment: Node3D = _hex_side_mesh.instantiate()
		_side_segments.add_child(new_segment)
		new_segment.set_owner(_root_node)
		new_segment.name = _side_segment_name(i + start_count)
		new_segment.position.y = (start_count + i) * HexUtil.HEX_TILE_UNIT_HEIGHT


## Removes a number of side segments, starting from the highest positioned one.
func _remove_side_segments(remove_count: int) -> void:
	for i: int in remove_count:
		var last_segment_index: int = _side_segments.get_child_count() - 1
		var last_segment: Node3D = _side_segments.get_child(last_segment_index)
		_side_segments.remove_child(last_segment)
		last_segment.queue_free()


## Triggers an update to the shape height.
func _on_HeightSource_height_changed(height: int) -> void:
	# This function is called before the node is fully ready while part of the
	# MapTile scene.
	if not is_node_ready():
		return
	_hex_top_mesh.position.y = height * HexUtil.HEX_TILE_UNIT_HEIGHT
	var segments_count: int = _side_segments.get_child_count()
	if height == segments_count:
		return
	var difference: int = abs(segments_count - height)
	if height > segments_count:
		_add_side_segments(difference)
	else:
		_remove_side_segments(difference)
