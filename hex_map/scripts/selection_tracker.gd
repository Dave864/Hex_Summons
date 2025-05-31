class_name SelectionTracker
extends Node
"""
Keeps track of the tiles that are currently highlighted. Requires a reference
to the map tiles and Pathfinder.
"""


export(NodePath) var map_tiles_reference = null
export(NodePath) var pathfinder_reference = null

var _map_tiles: Tiles = null
var _pathfinder: Pathfinder = null
var _highlighted_map_indexes: Array = []
var _selectable_map_indexes: Array = []


# Highlight the specified tiles as movement for the given player character.
# Setting start_id to -1 indicates that we want to use the current player position
# to determine where to set the Player highlight.
func highlight_player_movement(
	tile_indexes: Array,
	pc: PlayerCharacter,
	start_id: int = -1
) -> void:
	for i in tile_indexes:
		var tile: MapTile = _map_tiles[i]
		if tile.get_current_occupant() == null:
			if i == start_id:
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.NONE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().name == pc.name:
			if start_id < 0 or start_id == pc.get_map_index_at():
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(tile.get_map_index())


# Highlight the specified tiles as being within the area range of an action.
func highlight_player_action_area(tile_indexes: Array, pc: PlayerCharacter) -> void:
	var map_section: Array = _map_tiles.get_tiles_from_ids(tile_indexes)
	
	var area_range_indices: Array = _pathfinder.get_traversable_tiles(
		pc.get_map_index_at(),
		pc.stats.get_movement_range(),
		map_section
	)
	
	for i in area_range_indices:
		var tile: MapTile = _map_tiles[i]
		if i == pc.get_map_index_at():
			tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant() == null:
			tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.TARGET)
			_highlighted_map_indexes.append(tile.get_map_index())
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(tile.get_map_index())


# Highlight the selector for the specified tiles to represent the effect area
# of an action.
func highlight_effect_area(tile_indexes: Array, ignore_heights: bool) -> void:
	var map_section: Array = _map_tiles.get_tiles_from_ids(tile_indexes)
	
	if !ignore_heights:
		pass
	
	for tile in map_section:
		if tile.get_current_occupant() == null:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_selector_type(HexHighlighter.Option.TARGET)
			_selectable_map_indexes.append(tile.get_map_index())
		else:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.get_map_index())


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for i in _highlighted_map_indexes:
		_map_tiles[i].set_highlight_type(HexHighlighter.Option.NONE)
	_highlighted_map_indexes.clear()


# Clear selector highlights from all tiles.
func clear_selector_highlights() -> void:
	for i in _selectable_map_indexes:
		_map_tiles[i].set_selector_type(HexHighlighter.Option.NONE)
	_selectable_map_indexes.clear()


# Called when the node enters the scene tree for the first time.
func _ready():
	_map_tiles = get_node(map_tiles_reference)
	_pathfinder = get_node(pathfinder_reference)
