class_name RangeFinder
extends Node
"""
A collection of calculations and algorithms used for various encounter map 
actions that depend on getting a range of tiles or paths to tiles.
"""


var _z_count: int setget set_z_count
var _x_count: int setget set_x_count
var _map_tiles: Array = [] setget set_map_tiles, get_map_tiles
var _current_range: Array = []
var _current_char_type: int setget set_char_type


func _init(
	x_value: int,
	z_value: int,
	current_char: int,
	initial_map: Array = []
) -> void:
	_x_count = x_value
	_z_count = z_value
	_current_char_type = current_char
	set_map_tiles(initial_map)


func set_z_count(value: int) -> void:
	_z_count = value


func set_x_count(value: int) -> void:
	_x_count = value


func set_map_tiles(new_map: Array) -> void:
	_map_tiles = new_map


func get_map_tiles() -> Array:
	return _map_tiles


func set_char_type(type: int) -> void:
	_current_char_type = type


# Recalculates the astar connnections for the map in its current state.
#func refresh_astar_connections(current_char_type: int) -> void:
#	_current_char_type = current_char_type
#
#	# Empty out the current astar map and resize if necessary.
#	clear()
#	if get_point_capacity() < _map_tiles.size():
#		reserve_space(_map_tiles.size())
#
#	# Add the tiles to the astar map.
#	var tile_weight: float
#	for tile in _map_tiles:
#		# Only add tile if it is active
#		if tile.is_active():
#			# Set the weight to 50 if the tile is occupied by a character
#			# of the opposing faction.
#			tile_weight = 1.0 if tile.can_character_pass(_current_char_type) else 50.0
#			add_point(tile.get_index(), tile.translation, tile_weight)
#
#	# Set up the connections for the astar map.
#	for tile in _map_tiles:
#		# Set up connections for active tiles.
#		if tile.is_active():
#			for neighbor in tile.get_adjacent():
#				# Connect non empty and active neighbors.
#				if neighbor != null and neighbor.is_active():
#					connect_points(
#						tile.get_index(), 
#						neighbor.get_index()
#					)


# Determine the astar connections for a map section centered on the character.
func astar_for_range(
	character: Character, 
	range_type: int = Constants.RangeTypes.MOVE
) -> void:
	_current_range = _get_movement_range(character)
	
	# Empty out the current astar map and resize if necessary.
#	clear()
#	if get_point_capacity() < _current_range.size():
#		reserve_space(_current_range.size())
#
#	# Add the tiles to the astar map.
#	var tile_weight: float
#	for tile in _current_range:
#		# Set the weight to 50 if the tile is occupied by a character
#		# of the opposing faction.
#		tile_weight = 1.0 if tile.can_character_pass(_current_char_type) else 50.0
#		add_point(tile.get_index(), tile.translation, tile_weight)
#
#	# Set up the connections for the astar map.
#	for tile in _current_range:
#		# Set up connections for active tiles.
#		for neighbor in tile.get_adjacent():
#			# Connect non empty and active neighbors.
#			if neighbor != null and neighbor.get_movement_active():
#				connect_points(
#					tile.get_index(), 
#					neighbor.get_index()
#				)


# Clear the highlighted movement tiles.
func clear_movement_highlight() -> void:
	for tile in _current_range:
		tile.set_movement_active(false)
#	clear()


# Get the tiles that are within movement reach of the character.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-obstacles
func _get_movement_range(character: Character) -> Array:
	var movement: int = character.stats.get_mvmt()
	# Keeps track of which tiles have been visited.
	var visited: Dictionary = {}
	# An array of map tiles that can be reached within the movement value. 
	var fringes: Array = []
	fringes.append([_map_tiles[character.get_index_at()]])
	
	for i in range(1, movement + 1):
		fringes.append([])
		for tile in fringes[i - 1]:
			for neighbor in tile.get_adjacent():
				if (
					neighbor != null and
					!visited.has(neighbor.get_index()) and 
					neighbor.is_active() and
					neighbor.can_character_pass(_current_char_type)
				):
					visited[neighbor.get_index()] = neighbor
					neighbor.set_movement_active(true)
					fringes[i].append(neighbor)
	
	return visited.values()
