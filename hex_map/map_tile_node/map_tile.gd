tool
class_name MapTile
extends Area
"""
Represents an individual map tile.
"""


enum NeighborPosition {
	UPPER_LEFT,
	UPPER_RIGHT,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	LEFT,
}

# The height of the tile.
export(int, 0, 20) var height = 0 setget set_height
# References the MapTile nodes that are adjacent to this one.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3
var _adjacent_tiles: Array = [null, null, null, null, null, null] \
	setget , get_adjacent
# The index position of the map tile when it is part 
# of a collection of tiles.
var _map_index: int = -1 setget set_map_index, get_map_index
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
# Flag that indicates if the tile is avaiable to be selected
var _selection_type: int = false setget set_selection_type, get_selection_type


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ErrorUtil.connect_signal(self, "area_entered", self, "_on_MapTile_area_entered")
	ErrorUtil.connect_signal(self, "area_exited", self, "_on_MapTile_area_exited")


# Updates the height of the map tile.
func set_height(value: int) -> void:
	height = value
	_update_tile_shape_height()
	_update_collision_shape_height()
	_update_highlighter_position()
	"""
	TODO: Remove label.
	"""
	_update_label_display()


# Gets the adjacent tile of the specified position.
func get_adjacent_tile(position: int) -> Spatial:
	return _adjacent_tiles[position]


# Sets the adjacent tile of the specified position.
func set_adjacent_tile(position: int, map_tile: Area):
	_adjacent_tiles[position] = map_tile
	"""
	TODO: Remove label.
	"""
	_update_label_display()


# Gets the array pf all adjacent tiles.
func get_adjacent() -> Array:
	return _adjacent_tiles


# Get the index value of the MapTile.
func get_map_index() -> int:
	return _map_index


# Set the index value of the MapTile.
func set_map_index(value: int):
	_map_index = value
	"""
	TODO: Remove label.
	"""
	_update_label_display()


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3) -> void:
	_cube_coord = value


# Set the value of the selectable flag.
func set_selection_type(value: int) -> void:
	_selection_type = value
	$HexHighlighter.set_option(_selection_type)


# Get the value of the selectable flag.
func get_selection_type() -> int:
	return _selection_type


# Gets the current character occupying this tile.
func get_current_occupant() -> Character:
	return _occupant


# Check if the tile is able to be moved through by the specifed character type.
func can_character_pass(character_type: int) -> bool:
	match character_type:
		Constants.MapOccupants.PLAYER:
			return _occupant == null or _occupant.get_type() == Constants.MapOccupants.PLAYER
		Constants.MapOccupants.ENEMY:
			return _occupant == null or _occupant.get_type() == Constants.MapOccupants.ENEMY
		_:
			return true


# Checks whether the Map Tile is an active element of the map.
func is_active() -> bool:
	return visible


# Return the coordinate that a character will be placed at when moving onto the
# tile.
func character_position() -> Vector3:
	var cp: Vector3 = translation
	cp.y = Constants.HEX_TILE_UNIT_HEIGHT * height
	return cp


# Updates the shape mesh so that it reflects the current height.
func _update_tile_shape_height() -> void:
	$TileShape.mesh.set_height(Constants.HEX_TILE_UNIT_HEIGHT * (1 + height))
	# Move the shape so that the bottom is always at -0.25
	var y_translate: float = (Constants.HEX_TILE_UNIT_HEIGHT / 2) * (height - 1)
	$TileShape.set_translation(Vector3(0.0, y_translate, 0.0))


# Updates the collision shape mesh so that it reflects the current height.
func _update_collision_shape_height() -> void:
	var points: PoolVector3Array = $CollisionShape.shape.get_points()
	for i in range(6):
		var h: float = 0.25 + (Constants.HEX_TILE_UNIT_HEIGHT * height)
		points[i] = Vector3(points[i].x, h, points[i].z)
	$CollisionShape.shape.set_points(points)


# Update the position of the tile highlighter so that it is on top of the tile.
func _update_highlighter_position() -> void:
	var y_translate: float = 0.01 + (height * Constants.HEX_TILE_UNIT_HEIGHT)
	$HexHighlighter.translation = Vector3(0.0, y_translate, 0.0)
	"""
	TODO: remove label
	"""
	$Label3D.translation = Vector3(0.0, y_translate, 0.2)


func _on_MapTile_area_entered(area) -> void:
	# Add entered character as this tile's occupant.
	if (
		_occupant == null 
		and (area is PlayerCharacter or area is EnemyCharacter)
	):
		_occupant = area


func _on_MapTile_area_exited(area) -> void:
	if _occupant != null and area.name == _occupant.name:
		_occupant = null


"""
TODO: Label is here for debugging purposes. Will need to be removed.
"""
func _update_label_display() -> void:
	var format: String = "[%d:%d]\n%s %s\n%s    %s\n%s %s"
	var n0: String = String(_adjacent_tiles[0].get_index()) if _adjacent_tiles[0] != null else "N"
	var n1: String = String(_adjacent_tiles[1].get_index()) if _adjacent_tiles[1] != null else "N"
	var n2: String = String(_adjacent_tiles[2].get_index()) if _adjacent_tiles[2] != null else "N"
	var n3: String = String(_adjacent_tiles[3].get_index()) if _adjacent_tiles[3] != null else "N"
	var n4: String = String(_adjacent_tiles[4].get_index()) if _adjacent_tiles[4] != null else "N"
	var n5: String = String(_adjacent_tiles[5].get_index()) if _adjacent_tiles[5] != null else "N"
	
	$Label3D.text = str(format % [_map_index, height, n0, n1, n5, n2, n4, n3])
	
