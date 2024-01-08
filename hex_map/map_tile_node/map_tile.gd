tool
class_name MapTile
extends Area
"""
Represents an individual map tile.
"""


# References the MapTile nodes that are adjacent to this one.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3
var _adjacent_tiles: Array = [null, null, null, null, null, null] \
	setget , get_adjacent
# The index position of the map tile when it is part 
# of a collection of tiles.
var _index: int = -1 setget set_index, get_index
# The cube coordinates of the map tile.
#     -z
# +y   |  +x
#   \ / \ /
#    |   |
#   / \ / \
# -x   |  -y
#     +z
var _cube_coord: Vector3 = Vector3.ZERO setget set_cube_coord, get_cube_coord
# The current occupant of the tile.
var _occupant: Character = null setget , get_current_occupant
# Flag that indicates if the tile is avaiable to move to
var _is_movement_active: bool = false setget set_movement_active, get_movement_active


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self, "_on_MapTile_area_entered")
	connect("area_exited", self, "_on_MapTile_area_exited")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _is_movement_active:
		$Highlighter.show()
	else:
		$Highlighter.hide()


# Gets the adjacent tile of the specified position.
func get_adjacent_tile(position: int) -> Spatial:
	return _adjacent_tiles[position]


# Sets the adjacent tile of the specified position.
func set_adjacent_tile(position: int, map_tile: Area):
	_adjacent_tiles[position] = map_tile


# Gets the array pf all adjacent tiles.
func get_adjacent() -> Array:
	return _adjacent_tiles


# Get the index value of the MapTile.
func get_index() -> int:
	return _index


# Set the index value of the MapTile.
func set_index(value: int):
	_index = value


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3):
	_cube_coord = value


# Set the value of the movement flag.
func set_movement_active(value: bool):
	_is_movement_active = value


# Get the value of the movement flag.
func get_movement_active() -> bool:
	return _is_movement_active


# Gets the current character occupying this tile.
func get_current_occupant() -> Character:
	return _occupant


# Check if the tile is able to be moved through by the specifed character.
func can_character_pass(character_type: int) -> bool:
	match character_type:
		Constants.MapOccupants.PLAYER:
			return _occupant is PlayerCharacter or _occupant == null
		Constants.MapOccupants.ENEMY:
			return _occupant is EnemyCharacter or _occupant == null
		_:
			return true


# Checks whether the Map Tile is an active element of the map.
func is_active() -> bool:
	return visible


func _on_MapTile_area_entered(area):
	# Add entered character as this tile's occupant.
	if area is PlayerCharacter or area is EnemyCharacter:
		_occupant = area


func _on_MapTile_area_exited(area):
	if area is PlayerCharacter or area is EnemyCharacter:
		_occupant = null
