tool
class_name MapTile
extends Area
"""
Represents an individual map tile.
"""


enum SelectionType {
	NONE,
	PLAYER,
	ALLY,
	RANGE,
	EFFECT_RANGE,
	EFFECT_ORIGIN,
	TARGET,
}

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
# Flag that indicates if the tile is avaiable to be selected
var _selection_type: int = false setget set_selection_type, get_selection_type

# Updates the height of the map tile.
func set_height(value: int) -> void:
	height = value
	_update_tile_shape_height()
	_update_collision_shape_height()
	_update_highlighter_position()
	"""
	TODO: Remove label.
	"""
	$Label3D.text = str("%d:%d" % [_index, height])


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
	"""
	TODO: Remove label.
	"""
	$Label3D.text = str("%d:%d" % [_index, height])


# Get the cube coordinates of the MapTile.
func get_cube_coord() -> Vector3:
	return _cube_coord


# Set the cube coordinates of the MapTile.
func set_cube_coord(value: Vector3) -> void:
	_cube_coord = value


# Set the value of the selectable flag.
func set_selection_type(value: int) -> void:
	_selection_type = value
	_set_highlighter()


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
			return _occupant is PlayerCharacter or _occupant == null
		Constants.MapOccupants.ENEMY:
			return _occupant is EnemyCharacter or _occupant == null
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ErrorUtil.connect_signal(self, "area_entered", self, "_on_MapTile_area_entered")
	ErrorUtil.connect_signal(self, "area_exited", self, "_on_MapTile_area_exited")
	
	_set_highlighter()


# Runs every frame.
func _process(_delta: float) -> void:
	pass


# Activates the highlighter based on the _is_selectable flag.
func _set_highlighter() -> void:
	match _selection_type:
		SelectionType.PLAYER:
			_set_highlighter_color(Constants.COLOR_CHARACTER_ORIGIN)
			$Highlighter.show()
		SelectionType.ALLY:
			_set_highlighter_color(Constants.COLOR_ALLY_ORIGIN)
			$Highlighter.show()
		SelectionType.RANGE:
			_set_highlighter_color(Constants.COLOR_AREA_RANGE)
			$Highlighter.show()
		SelectionType.EFFECT_ORIGIN:
			_set_highlighter_color(Constants.COLOR_EFFECT_ORIGIN)
			$Highlighter.show()
		SelectionType.EFFECT_RANGE:
			_set_highlighter_color(Constants.COLOR_EFFECT_RANGE)
			$Highlighter.show()
		SelectionType.TARGET:
			_set_highlighter_color(Constants.COLOR_TARGET_SELECT)
			$Highlighter.show()
		_:
			$Highlighter.hide()


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
	$Highlighter.translation = Vector3(0.0, y_translate, 0.0)
	"""
	TODO: remove label
	"""
	$Label3D.translation = Vector3(0.0, y_translate, 0.2)


# Changes the color of the tile highlighter
func _set_highlighter_color(color: Color) -> void:
	var m: Material = $Highlighter.get_surface_material(0)
	m.albedo_color = color
	$Highlighter.set_surface_material(0, m)


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
