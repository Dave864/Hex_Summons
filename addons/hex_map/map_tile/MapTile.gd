extends Spatial


# Flag that indicates whether the tile is active or not
export var active: bool = true setget ,is_active

# References the MapTile nodes that are adjacent to this one
#  0  /\  1
#    /  \
# 5 |    | 2
#   |    |
#    \  /
#  4  \/  3
var _adjacent_tiles: Array = [null, null, null, null, null, null]
# Tracks the index position of the map tile when it is part 
# of a collection of tiles
var _index: int setget set_index, get_index


# Called when the node enters the scene tree for the first time.
func _ready():
	if !active:
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Gets the adjacent tile of the specified position
func get_adjacent_tile(position: int) -> Node:
	return _adjacent_tiles[position]


# Gets the adjacent tile of the specified position
func set_adjacent_tile(position: int, map_tile: Node):
	_adjacent_tiles[position] = map_tile


# Gets the index value of the Map Tile
func get_index():
	return _index


# Sets the index value of the Map Tile
func set_index(value: int):
	_index = value
	


# Checks whether the Map Tile is an active element of the map
func is_active() -> bool:
	return active
