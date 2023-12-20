class_name RangeFinder
extends Spatial
# RangeFinder handles calculations related to pathfinding and distance
# It works off of the TileManager node


# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

onready var _tiles: TilesManager = get_node("../TilesManager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Gets the tile at the specific index
func tile_at_index(index: int) -> Node:
	return _tiles.get_child(index)


# Gets the tile at the specific cube coordinates
func tile_at_cube_coord(c_coordinates: Vector3) -> Node:
	return null
