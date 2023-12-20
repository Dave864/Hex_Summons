tool
class_name RangeFinder
extends Spatial
# RangeFinder handles calculations related to pathfinding and distance
# It works off of the TileManager node


var _tm: TilesManager


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Get the TilesManager node
# Workaround of the TileManager node not being found when get_node() is used
# during onready or _ready()
func _get_tiles_manager():
	_tm = get_node("../TilesManager") if _tm == null else _tm


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Gets the tile at the specific index
func get_tile_at_index(index: int) -> Node:
	_get_tiles_manager()
	return _tm.get_child(index)


# Gets the tile at the specific cube coordinates
func get_tile_at_cube_coord(c_coordinates: Vector3) -> Node:
	_get_tiles_manager()
	return null
