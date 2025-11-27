class_name SelectionTracker
extends Node
## Keeps track of the tiles that are currently highlighted. Requires a reference
## to the map tiles.


@export var map_tiles_reference: NodePath = NodePath("")

var _highlighted_map_indexes: Array = []
var _selectable_map_indexes: Array = []

@onready var _map_tiles: Tiles = get_node(map_tiles_reference)


## Highlight the specified tiles as movement for the given player character.
## Setting player_index to -1 indicates that we want to use the current player position
## to determine where to set the Player highlight.
func highlight_player_movement(
	tile_ids: Array,
	pc: PlayerCharacter,
	player_index: int = -1
) -> void:
	# Activate the selector at the player's current position.
	var player_tile: MapTile = _map_tiles.get_at(pc.map_coordinate.get_tile_index())
	player_tile.set_selector_type(HexHighlighter.Option.MOVE)
	
	# Set the tile highlights.
	for i in tile_ids:
		var tile: MapTile = _map_tiles.get_at(i)
		if tile.occupant.get_current_occupant() == null:
			if i == player_index:
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
		elif (
			tile.occupant.get_current_occupant().get_type() 
			== Character.Type.ENEMY
		):
			tile.set_highlight_type(HexHighlighter.Option.NONE)
		elif tile.occupant.get_current_occupant().name == pc.name:
			if player_index < 0 or player_index == pc.map_coordinate.get_tile_index():
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
		_highlighted_map_indexes.append(tile.map_coordinate.get_tile_index())


## Highlight the specified tiles as being within the source range of an action.
func highlight_action_source_area(tile_ids: Array, pc: PlayerCharacter) -> void:
	for index in tile_ids:
		var tile: MapTile = _map_tiles.get_at(index)
		if index == pc.map_coordinate.get_tile_index():
			tile.set_highlight_type(HexHighlighter.Option.PLAYER)
		elif tile.occupant.get_current_occupant() == null:
			tile.set_highlight_type(HexHighlighter.Option.RANGE)
		elif tile.occupant.get_current_occupant().get_type() == Character.Type.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.TARGET)
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
		_highlighted_map_indexes.append(index)


## Highlight the selector for the specified tiles to represent the effect area
## of an action.
func select_effect_range(
		tile_ids: Array,
		caster_index: int,
		emission_index: int,
		ignore_caster: bool,
		effect_is_cardinal: bool
) -> void:
	var map_section: Array = _map_tiles.get_from_ids(tile_ids)
	for tile in map_section:
		var occupant: Character = tile.occupant.get_current_occupant()
		var tile_index: int = tile.map_coordinate.get_tile_index()
		if tile_index == emission_index:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_ORIGIN)
		elif occupant == null:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
		elif occupant.get_type() == Character.Type.ENEMY:
			tile.set_selector_type(HexHighlighter.Option.TARGET)
		elif tile_index == caster_index and ignore_caster:
			if effect_is_cardinal:
				tile.set_selector_type(HexHighlighter.Option.NONE)
			else:
				tile.set_selector_type(HexHighlighter.Option.GRAY)
		else:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
		_selectable_map_indexes.append(tile_index)


## Clear the higlights from all tiles.
func clear_highlights() -> void:
	for i in _highlighted_map_indexes:
		_map_tiles.get_at(i).set_highlight_type(HexHighlighter.Option.NONE)
	_highlighted_map_indexes.clear()


## Clear selector highlights from all tiles.
func clear_selector_highlights() -> void:
	for i in _selectable_map_indexes:
		_map_tiles.get_at(i).set_selector_type(HexHighlighter.Option.NONE)
	_selectable_map_indexes.clear()


## Called when the node enters the scene tree for the first time.
func _ready():
	pass
