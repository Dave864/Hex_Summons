tool
class_name MapTile
extends Spatial
"""
Represents an individual map tile.
"""


signal height_changed(new_height)

const HIGHLIGHTER_Y_OFFSET = 0.01
const SELECTOR_Y_OFFSET = 0.125

# The height of the tile.
export(int, 0, 20) var height = 0 setget set_height
# References the MapTile nodes that are adjacent to this one.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3

onready var map_coordinate: MapCoordinate = $MapCoordinate
onready var occupant: Occupant = $Occupant

var _adjacent_tiles: Array = [null, null, null, null, null, null] \
	setget , get_all_adjacent
# Flag that indicates the highlight of the tile.
var _highlight_type: int = HexHighlighter.Option.NONE setget set_highlight_type, get_highlight_type
# Flag that indicates the selector of the tile.
var _selector_type: int = HexHighlighter.Option.NONE setget set_selector_type, get_selector_type


# Updates the height of the map tile.
func set_height(value: int) -> void:
	height = value
	emit_signal("height_changed", value)
	_update_highlighter_positions()


# Gets the adjacent tile of the specified position.
func get_adjacent_tile(position: int) -> Spatial:
	return _adjacent_tiles[position]


# Sets the adjacent tile of the specified position.
func set_adjacent_tile(position: int, map_tile: Area):
	_adjacent_tiles[position] = map_tile


# Gets the array pf all adjacent tiles.
func get_all_adjacent() -> Array:
	return _adjacent_tiles


# Set the value of the highlight flag.
func set_highlight_type(value: int) -> void:
	_highlight_type = value
	$TileHighlighter.set_option(_highlight_type)
	$TileHighlighter.set_transparency(Constants.OPACITY_FULL)


# Get the value of the highlight flag.
func get_highlight_type() -> int:
	return _highlight_type


# Set the value of the selector flag.
func set_selector_type(value: int) -> void:
	_selector_type = value
	$SelectorHighlighter.set_option(_selector_type)
	$SelectorHighlighter.set_transparency(Constants.OPACITY_FULL)


# Get the values of the selector flag.
func get_selector_type() -> int:
	return _selector_type


# Checks whether the Map Tile is an active element of the map.
func is_active() -> bool:
	return visible


# Return the translation that a character will be placed at when moving onto the
# tile.
func character_position() -> Vector3:
	var cp: Vector3 = $Coordinate.translation
	cp.y = Constants.HEX_TILE_UNIT_HEIGHT * height
	return cp


# Update the position of the tile highlighters so that they are on top of the tile.
func _update_highlighter_positions() -> void:
	var y_translate: float = HIGHLIGHTER_Y_OFFSET + (height * Constants.HEX_TILE_UNIT_HEIGHT)
	$TileHighlighter.translation = Vector3(0.0, y_translate, 0.0)
	y_translate = SELECTOR_Y_OFFSET + (height * Constants.HEX_TILE_UNIT_HEIGHT)
	$SelectorHighlighter.translation = Vector3(0.0, y_translate, 0.0)
	"""
	TODO: remove label
	"""
	$DebugLabel.translation = Vector3(0.0, y_translate, 0.2)
