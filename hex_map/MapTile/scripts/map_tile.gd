@tool
class_name MapTile
extends Area3D
## Represents an individual map tile.


## Indicates that the mouse is hovering over this tile.
signal mouse_hovered(map_tile)
## Indicates the tile height has been changed.
signal height_changed(new_height)

## How far above the top of the tile the highlighters are placed.
const HIGHLIGHTER_Y_OFFSET := 0.01
## How far above the top of the tile a selector highlighter is placed. 
const SELECTOR_Y_OFFSET := 0.125
## How big a tile highlighter is compared to the tile when both the selector and
## tile highlighter are active.
const OVERLAP_RATIO := 0.75

## The height of the tile.
@export_range(0, 100) var height = 0:
	set = set_height
## Highlighter that indicates a tile is being selected.
@export var selector_highlighter: HexHighlighter = null
## Highlighter that indicates a tile is being highlighted.
@export var tile_highlighter: HexHighlighter = null

## The coordinate of this tile in a map.
@onready var map_coordinate: MapCoordinate = $MapCoordinate
## The character currently occupying this tile.
@onready var occupant: Occupant = $Occupant

## References the MapTile nodes that are adjacent to this one.
##  0  / \  1
##  5 |   | 2
##  4  \ /  3
var _adjacent_tiles: Array[MapTile] = [null, null, null, null, null, null]
## Flag that indicates the highlight of the tile.
var _highlight_type: int = HexHighlighter.Option.NONE
## Flag that indicates the selector of the tile.
var _selector_type: int = HexHighlighter.Option.NONE


func _ready() -> void:
	set_height(height)
	$DebugLabel.update_label_display(height)


## Updates the height of the map tile.
func set_height(value: int) -> void:
	height = value
	var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")
	if collision_shape == null:
		return
	var y_pos: float = height * HexUtil.HEX_TILE_UNIT_HEIGHT
	collision_shape.position.y = y_pos
	# Do not update height of map_coordinate if has yet to be set.
	if map_coordinate != null:
		map_coordinate.position.y = y_pos
	emit_signal("height_changed", value)
	_update_highlighter_positions()


## Gets the adjacent tile of the specified direction.
func get_adjacent_tile(direction: HexUtil.HexDirection) -> Node3D:
	return _adjacent_tiles[direction]


## Sets the adjacent tile of the specified direction.
func set_adjacent_tile(direction: HexUtil.HexDirection, map_tile: Area3D):
	_adjacent_tiles[direction] = map_tile
	$DebugLabel.update_label_display(height)


## Gets the array of all adjacent tiles.
func get_all_adjacent() -> Array[MapTile]:
	return _adjacent_tiles


## Set the value of the highlight flag.
func set_highlight_type(value: int) -> void:
	_highlight_type = value
	tile_highlighter.set_option(_highlight_type)
	tile_highlighter.set_highlighter_transparency(Constants.OPACITY_FULL)


## Get the value of the highlight flag.
func get_highlight_type() -> int:
	return _highlight_type


## Set the value of the selector flag.
func set_selector_type(value: int) -> void:
	_selector_type = value
	selector_highlighter.set_option(_selector_type)
	if value != HexHighlighter.Option.NONE:
		selector_highlighter.offset_render_priority(1)
	selector_highlighter.set_highlighter_transparency(Constants.OPACITY_FULL)
	var highlighter_mesh: CylinderMesh = tile_highlighter.mesh
	if (
		value != HexHighlighter.Option.NONE
		and _highlight_type != HexHighlighter.Option.NONE
	):
		tile_highlighter.offset_render_priority(1)
		highlighter_mesh.top_radius = OVERLAP_RATIO * HexUtil.HEX_TILE_RADIUS
		highlighter_mesh.bottom_radius = OVERLAP_RATIO * HexUtil.HEX_TILE_RADIUS
	else:
		tile_highlighter.reset_render_priority()
		highlighter_mesh.top_radius = HexUtil.HEX_TILE_RADIUS
		highlighter_mesh.bottom_radius = HexUtil.HEX_TILE_RADIUS


## Get the values of the selector flag.
func get_selector_type() -> int:
	return _selector_type


## Checks whether the Map Tile is an active element of the map.
func is_active() -> bool:
	return visible


## Return the translation that a character will be placed at when moving onto
## the tile.
func get_character_position() -> Vector3:
	return map_coordinate.global_position


## Update the position of the tile highlighters so that they are on top of
## the tile.
func _update_highlighter_positions() -> void:
	var y_translate: float = (
		HIGHLIGHTER_Y_OFFSET + (height * HexUtil.HEX_TILE_UNIT_HEIGHT)
	)
	tile_highlighter.position = Vector3(0.0, y_translate, 0.0)
	y_translate = SELECTOR_Y_OFFSET + (height * HexUtil.HEX_TILE_UNIT_HEIGHT)
	selector_highlighter.position = Vector3(0.0, y_translate, 0.0)
	## TODO: remove label when finished with map logic implementation
	$DebugLabel.position = Vector3(0.0, y_translate, 0.2)


func _on_MapTile_mouse_entered() -> void:
	if InputController.get_source() == InputController.Source.KEYBOARD_AND_MOUSE:
		emit_signal("mouse_hovered", self)
