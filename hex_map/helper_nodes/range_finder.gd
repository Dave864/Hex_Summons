tool
class_name RangeFinder
extends Spatial
# RangeFinder handles calculations related to pathfinding and distance


var _z_count: int setget set_z_count
var _x_count: int setget set_x_count


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Get the TilesManager node
# Workaround of the TileManager node not being found when get_node() is used
# during onready or _ready()
#func _get_tiles_manager():
#	_tm = get_node("../TilesManager") if _tm == null else _tm


# Converts the cube coordinates to the corresponding index
func _cube_to_index(coord: Vector3) -> int:
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * _x_count) + x_pos


func set_z_count(value: int):
	_z_count = value


func set_x_count(value: int):
	_x_count = value
