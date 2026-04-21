class_name SelectionTracker
extends Node
## Keeps track of the tiles that are currently highlighted for an action.
##
## Looks at a HexMap node and updates the tile highlights and selection
## indicators. Its state machine (fsm) uses the passed selector node to
## determine which tiles to update.


## Indicates that the tracker has confirmed the details of a spawn action for
## a summon character.
signal spawn_action_confirmed(name, emission_position)
## Indicates that the encounter camera should focus on a new point.
signal new_focus_point(new_position)
## Indicates if the camera focus is locked to a point.
signal camera_focus_locked(is_locked)

## The encounter map the tracker will highlight.
@export var hex_map: HexMap = null
## The selector node that marks a focused tile.
@export var selector: Selector = null

## The active character, usually a PlayerCharacter or Summon.
var focused_character: Character = null:
	set = set_focused_character
## The tile index the focused player is at.
var player_index: int:
	get:
		if focused_character == null:
			return -1
		return focused_character.map_coordinate.get_tile_index()
## The index currently selected for movement. Returns player index if less
## than 0.
var target_index: int = -1:
	get:
		return target_index if target_index >= 0 else player_index
## Stores the distance map of the source range.
var source_d_map: DistanceMap = null

## Reference to player characters.
var _player_characters: Array[Character] = []
## Reference to enemy characters.
var _enemy_characters: Array[Character] = []
## The action whose ranges are being displayed.
var _action: Action = null
## The points of the movement path for the currently selected destination.
var _move_path: PackedVector3Array = []
## The name of the currently active summon.
var _summon: String = ""
## Caches the tile ids of action effect areas at different emission points.
var _ranges_cache: Dictionary[int, Array] = {}
## Caches the characters the action will hit when cast at different emission
## points
var _targets_cache: Dictionary[int, Array] = {}
## Stores the tiles of the active character's movement range.
var _movement_tile_ids: Array[int] = []
## The indexes of the tiles in the hex map that are currently highlighted.
var _highlighted_map_indexes: Array[int] = []
## The indexes of the tiles in the hex map that have their selector markers
## active.
var _selectable_map_indexes: Array[int] = []
## Reference to the Tiles node of the hex_map.
var _map_tiles: Tiles:
	get:
		return hex_map.get_tiles_node()

## The position of the sprite used to show where a player character will be
## placed when the turn is concluded.
@onready var _ghost_position: Marker3D = $GhostPosition


## Emits the spawn_action_confirmed signal with the summon name and emission
## position.
func emit_spawn_action_confirmed() -> void:
	emit_signal("spawn_action_confirmed", _summon, _action.get_emission_pos())


## Emits the camera_reposition signal with the position the encounter camera
## should point to.
func emit_new_focus_point(new_position: Vector3) -> void:
	emit_signal("new_focus_point", new_position)


## Emits a false camera_focus_locked signal, indicating that the focus is locked
## and thus unable to be moved using screen edge detection.
func emit_camera_focus_locked() -> void:
	emit_signal("camera_focus_locked", true)


## Emits a true camera_focus_locked signal, indicating that the focus is
## unlocked and thus able to be moved using screen edge detection.
func emit_camera_focus_unlocked() -> void:
	emit_signal("camera_focus_locked", false)


## Returns the stored player characters.
func get_players_referece() -> Array[Character]:
	return _player_characters


## Sets the reference to the player characters.
func set_players_reference(player_list: Array[Character]) -> void:
	_player_characters = player_list


## Returns the stored enemy characters.
func get_enemies_reference() -> Array[Character]:
	return _enemy_characters


## Sets the reference to the enemy characters.
func set_enemies_reference(enemy_list: Array[Character]) -> void:
	_enemy_characters = enemy_list


## Updates the character that is the reference for selections.
func set_focused_character(new_focus: Character) -> void:
	focused_character = new_focus
	if _enemy_characters.size() == 0:
		return
	_movement_tile_ids.clear()
	var ghost_sprite: EncounterSprite = $GhostPosition/GhostSprite
	if focused_character == null:
		ghost_sprite.texture = null
		return
	ghost_sprite.texture = focused_character.character_sprite.texture
	ghost_sprite.set_y_offset(focused_character.character_sprite.get_y_offset())
	_movement_tile_ids = hex_map.range_finder.get_character_travesible_tiles(
			focused_character,
			_enemy_characters
	)


## Returns the action that is being focused on.
func get_focus_action() -> Action:
	return _action


## Updates the action whose ranges are to be displayed. Creates a distance
## map of the action's source range, accounting for dead range. Clears out the
## ranges and targets cache.
func set_focus_action(new_action: Action) -> void:
	var update_ranges: bool = _action != new_action
	if update_ranges:
		_action = new_action
	# Checks if the focus character has moved to a different spot if a distance
	# map for the source range has been previously made. If the character has
	# not moved, we can reuse the previous cache values and distance map.
	elif source_d_map != null and source_d_map.origin == player_index:
		return
	_ranges_cache.clear()
	_targets_cache.clear()
	if source_d_map != null:
		source_d_map.free()
	# We do not need to create a distance map for the source range in this
	# instance.
	if _action == null:
		return
	var d_map: DistanceMap = hex_map.range_finder.dist_maps.at(player_index)
	var source_reach: int = _action.stats.source_range.get_reach()
	source_d_map = (
			d_map.map_from_tile_dist(source_reach)
			if _action.stats.source_ignore_heights
			else d_map.map_from_travel_dist(source_reach)
	)
	var dead_indexes: Array[int] = _action.stats.dead_range.get_area_indexes(
			player_index,
			hex_map
	)
	var dead_reach: int = _action.stats.dead_range.get_reach()
	for index in dead_indexes:
		if (
			index != player_index 
			and source_d_map.has(index)
			and (
				_action.stats.source_ignore_heights or
				source_d_map.travel_dist_at(index) <= dead_reach
			)
		):
			source_d_map.remove(index)
	if _summon != "":
		_remove_characters_from_source_range()


## Gets the currently recorded movement path.
func get_movement_path() -> PackedVector3Array:
	return _move_path


## Updates the recorded movement path.
func set_movement_path(new_path: PackedVector3Array) -> void:
	_move_path = new_path


## Gets the name of the active summon.
func get_active_summon() -> String:
	return _summon


## Updates the name of the active summon.
func set_active_summon(summon_name: String) -> void:
	_summon = summon_name


## Returns the targets that are hit by the focused action in its current state.
func get_tracked_targets() -> Array[Character]:
	var targets: Array[Character] = []
	if _action.is_directional():
		var dir: HexUtil.HexDirection = _action.get_emission_direction()
		if _targets_cache.has(dir):
			targets = _targets_cache[dir]
		return targets
	else:
		var index: int = _action.get_emission_map_index()
		if _targets_cache.has(index):
			targets = _targets_cache[index]
		return targets


## Sets the update function for the selector.
func set_selector_update(update_function: Callable) -> void:
	selector.set_update_selection_func(update_function)


## Returns the tile ids for the movement area of the focus character.
func get_movement_area_ids() -> Array[int]:
	return _movement_tile_ids


## Highlight the specified tiles as movement for the given character.
## Setting start_index to -1 indicates that we want to use the current
## character position to determine where to set the character highlight.
func highlight_player_movement(start_index: int = -1) -> void:
	# Activate the selector at the character's current position.
	var character_tile: MapTile = _map_tiles.get_at(player_index)
	character_tile.set_selector_type(HexHighlighter.Option.SELECT_MOVE)
	
	# Set the tile highlights.
	for i: int in _movement_tile_ids:
		var tile: MapTile = _map_tiles.get_at(i)
		var occupant: Character = tile.occupant.get_current_occupant()
		if occupant == null:
			if i == start_index:
				tile.set_highlight_type(HexHighlighter.Option.ORIGIN_PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE_MOVE)
		elif occupant.get_type() == Character.Type.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.ORIGIN_ENEMY)
		elif occupant.get_instance_id() == focused_character.get_instance_id():
			if start_index < 0 or start_index == player_index:
				tile.set_highlight_type(HexHighlighter.Option.ORIGIN_PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE_MOVE)
		else:
			tile.set_highlight_type(HexHighlighter.Option.ORIGIN_ALLY)
		_highlighted_map_indexes.append(tile.map_coordinate.get_tile_index())


## Highlight the specified tiles as being within the source range of the 
## focused action.
func highlight_action_source_area() -> void:
	for index: int in source_d_map.tile_ids():
		var tile: MapTile = _map_tiles.get_at(index)
		var occupant: Character = tile.occupant.get_current_occupant()
		if index == player_index:
			tile.set_highlight_type(HexHighlighter.Option.ORIGIN_PLAYER)
		elif occupant == null:
			tile.set_highlight_type(HexHighlighter.Option.RANGE_SOURCE)
		elif occupant.get_type() == Character.Type.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.ORIGIN_ENEMY)
		else:
			tile.set_highlight_type(HexHighlighter.Option.ORIGIN_ALLY)
		_highlighted_map_indexes.append(index)


## Activate the selector highlights for the tiles of a positional effect range
## cast at the focused action's current emission point. Prints an error message
## if the focused action is not positional.
func indicate_positional_effect_range() -> void:
	if _action == null:
		printerr("No action has been set as focus.")
		return
	if _action.is_directional():
		printerr(
				"Attempted to get positional effect range from directional "
				+ "action {0}.".format([_action.name])
		)
		return
	var tile_ids: Array[int] = []
	var emission_pt: int = _action.get_emission_map_index()
	if _ranges_cache.has(emission_pt):
		tile_ids = _ranges_cache[emission_pt]
	else:
		tile_ids = _action.stats.effect_range.get_area_indexes(
				emission_pt,
				hex_map
		)
		if _action.stats.effect_ignore_heights:
			# Updates the range cache.
			_ranges_cache[emission_pt] = tile_ids
			_indicate_effect_range(tile_ids)
			_track_targets(emission_pt, tile_ids)
			return
		var d_map: DistanceMap = hex_map.range_finder.dist_maps.at(emission_pt)
		var reach: int = _action.stats.effect_range.get_reach()
		var effect_d_map: DistanceMap = d_map.map_from_travel_dist(reach)
		var valid_ids: Array[int] = []
		for index: int in tile_ids:
			if effect_d_map.has(index):
				valid_ids.append(index)
		tile_ids = valid_ids
		# Updates the range cache.
		_ranges_cache[emission_pt] = tile_ids
	_indicate_effect_range(tile_ids)
	_track_targets(emission_pt, tile_ids)


## Activate the selector highlights for the tiles of a directional effect range
## cast in the focused action's emission direction. Prints an error message if
## the focused action is not directional.
func indicate_directional_effect_range() -> void:
	if _action == null:
		printerr("No action has been set as focus.")
		return
	if not _action.is_directional():
		printerr(
				"Attempted to get directional effect range from positional "
				+ "action {0}.".format([_action.name])
		)
		return
	var emission_dir: int = _action.get_emission_direction() as int
	var tile_ids: Array[int] = []
	if _ranges_cache.has(emission_dir):
		tile_ids = _ranges_cache[emission_dir]
	else:
		var emission_pt: int = _action.get_emission_map_index()
		tile_ids = _action.stats.effect_range.get_dir_area_indexes(
				emission_pt,
				emission_dir,
				hex_map
		)
		# Don't need to check if effect tiles are reachable if tile heights are
		# ignored.
		if _action.stats.effect_ignore_heights:
			# Updates the range cache.
			_ranges_cache[emission_dir] = tile_ids
			_indicate_effect_range(tile_ids)
			_track_targets(emission_dir, tile_ids)
			return
		var d_map: DistanceMap = hex_map.range_finder.dist_maps.at(emission_pt)
		var reach: int = _action.stats.effect_range.get_reach()
		var effect_d_map: DistanceMap = d_map.map_from_travel_dist(reach)
		var valid_ids: Array[int] = []
		for index: int in tile_ids:
			if effect_d_map.has(index):
				valid_ids.append(index)
		tile_ids = valid_ids
		# Updates the range cache.
		_ranges_cache[emission_dir] = tile_ids
	_indicate_effect_range(tile_ids)
	_track_targets(emission_dir, tile_ids)


## Clear the higlights from all tiles.
func clear_highlights() -> void:
	for i in _highlighted_map_indexes:
		_map_tiles.get_at(i).set_highlight_type(HexHighlighter.Option.NONE)
	_highlighted_map_indexes.clear()


## Clear selector highlights from all tiles.
func clear_indicators() -> void:
	for i in _selectable_map_indexes:
		_map_tiles.get_at(i).set_selector_type(HexHighlighter.Option.NONE)
	_selectable_map_indexes.clear()


## Shows or hides the ghost sprite. If set to reveal, the ghost sprite will be
## hidden if it is placed at the same point as the current focused character.
func show_ghost_sprite(reveal: bool) -> void:
	if reveal and focused_character != null:
		var character_pos: Vector3 = (
			hex_map.get_tile_at(player_index).get_character_position()
		)
		reveal = !character_pos.is_equal_approx(_ghost_position.position)
	_ghost_position.visible = reveal


## Places the ghost sprite at the specified position.
func place_ghost_sprite(new_position: Vector3) -> void:
	_ghost_position.position = new_position


## Removes tile indices that contain a character from the current source range.
## Used for spawn actions to prevent their emission point from being placed on
## tiles with characters.
func _remove_characters_from_source_range() -> void:
	for tile_id: int in source_d_map.tile_ids():
		var map_tile: MapTile = hex_map.get_tile_at(tile_id)
		if map_tile.occupant.get_current_occupant() != null:
			source_d_map.remove(tile_id)


## Activate the selector for the specified tiles to represent the effect area
## of an action.
func _indicate_effect_range(tile_ids: Array[int]) -> void:
	var map_section: Array[MapTile] = _map_tiles.get_from_ids(tile_ids)
	for tile: MapTile in map_section:
		var occupant: Character = tile.occupant.get_current_occupant()
		var tile_index: int = tile.map_coordinate.get_tile_index()
		if tile_index == _action.get_emission_map_index():
			tile.set_selector_type(HexHighlighter.Option.ORIGIN_EFFECT)
		elif occupant == null:
			tile.set_selector_type(HexHighlighter.Option.RANGE_EFFECT)
		elif occupant.get_type() == Character.Type.ENEMY:
			tile.set_selector_type(HexHighlighter.Option.TARGET_ENEMY)
		elif tile_index == player_index and _action.stats.effect_ignores_caster:
			if _action.is_directional():
				tile.set_selector_type(HexHighlighter.Option.NONE)
			else:
				tile.set_selector_type(HexHighlighter.Option.SELECT_GRAY)
		else:
			tile.set_selector_type(HexHighlighter.Option.RANGE_EFFECT)
		_selectable_map_indexes.append(tile_index)


## Takes in an array of tile ids for an effect range and tracks which characters
## are affected.
func _track_targets(key: int, effect_ids: Array[int]) -> void:
	if _targets_cache.has(key):
		return
	var targets: Array[Character] = []
	var target_types: Dictionary[ActionEffect.Target, bool] = (
		_action.get_target_types()
	)
	var target_enemy: bool = target_types.has(ActionEffect.Target.OPPONENTS)
	var target_ally: bool = target_types.has(ActionEffect.Target.ALLIES)
	var target_self: bool = target_types.has(ActionEffect.Target.SELF)
	for index: int in effect_ids:
		var tile: MapTile = hex_map.get_tile_at(index)
		var c: Character = tile.occupant.get_current_occupant()
		if c == null:
			continue
		if (
			target_ally
			or (target_enemy and c is EnemyCharacter)
			or (
				c.map_coordinate.get_tile_index() == player_index
				and target_self
			)
		):
			targets.append(c)
	_targets_cache[key] = targets
