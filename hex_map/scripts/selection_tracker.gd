class_name SelectionTracker
extends Node
"""
Keeps track of the tiles that are currently highlighted. Requires a reference
to the map tiles and Pathfinder.
"""


export(NodePath) var map_tiles_reference = null
export(NodePath) var range_finder_reference = null

var _map_tiles: Tiles = null
var _range_finder: RangeFinder = null
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
		var tile: MapTile = _map_tiles.get_tile_at_index(i)
		if tile.occupant.get_current_occupant() == null:
			if i == start_id:
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.map_coordinate.get_map_index())
		elif (
			tile.occupant.get_current_occupant().get_type() 
			== Constants.MapOccupants.ENEMY
		):
			tile.set_highlight_type(HexHighlighter.Option.NONE)
			_highlighted_map_indexes.append(tile.map_coordinate.get_map_index())
		elif tile.occupant.get_current_occupant().name == pc.name:
			if start_id < 0 or start_id == pc.get_map_index_at():
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.map_coordinate.get_map_index())
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(tile.map_coordinate.get_map_index())


# Highlight the specified tiles as being within the source range of an action.
func highlight_action_source_area(tile_indexes: Array, pc: PlayerCharacter) -> void:
#	var map_section: Array = _map_tiles.get_tiles_from_ids(tile_indexes)
	
#	var source_range_indices: Array = _range_finder.get_traversable_tiles(
#		pc.get_map_index_at(),
#		pc.stats.get_movement_range(),
#		map_section
#	)
	
	for index in tile_indexes:
		var tile: MapTile = _map_tiles.get_tile_at_index(index)
		if index == pc.get_map_index_at():
			tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			_highlighted_map_indexes.append(index)
		elif tile.occupant.get_current_occupant() == null:
			tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(index)
		elif tile.occupant.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.TARGET)
			_highlighted_map_indexes.append(index)
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(index)


# Highlight the selector for the specified tiles to represent the effect area
# of an action.
func highlight_effect_area(tile_indexes: Array, ignore_heights: bool) -> void:
	var map_section: Array = _map_tiles.get_tiles_from_ids(tile_indexes)
	
	if !ignore_heights:
		pass
	
	for tile in map_section:
		var occupant: Character = tile.occupant.get_current_occupant()
		if occupant == null:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.map_coordinate.get_map_index())
		elif occupant.get_type() == Constants.MapOccupants.ENEMY:
			tile.set_selector_type(HexHighlighter.Option.TARGET)
			_selectable_map_indexes.append(tile.map_coordinate.get_map_index())
		else:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.map_coordinate.get_map_index())


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for i in _highlighted_map_indexes:
		_map_tiles.get_tile_at_index(i).set_highlight_type(HexHighlighter.Option.NONE)
	_highlighted_map_indexes.clear()


# Clear selector highlights from all tiles.
func clear_selector_highlights() -> void:
	for i in _selectable_map_indexes:
		_map_tiles.get_tile_at_index(i).set_selector_type(HexHighlighter.Option.NONE)
	_selectable_map_indexes.clear()


# Called when the node enters the scene tree for the first time.
func _ready():
	_map_tiles = get_node(map_tiles_reference)
	_range_finder = get_node(range_finder_reference)
