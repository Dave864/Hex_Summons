class_name EncounterUIMenuLayout
extends EncounterUI
## Manages the UI elements of an Encounter scene. Uses a traditional menu layout.
##
## This handles the overall management of the various UI nodes used during an
## encounter. Also provides a convenient access point for said nodes: 
## InitiativeTracker, StandbyHighlightPool, PartyCharacterStats, and
## PlayerOptionsMenu.


## Sets the reference to the player options menu node.
func _ready() -> void:
	_player_options_menu = $PlayerOptionsMenuLayout
	standby_wisp_pool.set_wisp_pool(WispController.standby_pool)


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_focused_character = new_player
	_summon_manager.summoner = _focused_character
	_set_highlight_for_focus_character(true)
	_player_options_menu.clear_all_options()
	_player_options_menu.populate_technique_options(
			_focused_character.get_techniques()
	)
	_player_options_menu.populate_spell_options(_focused_character.get_spells())
	_player_options_menu.populate_summon_options(_summon_manager)
	# TODO: Add call to get items when items are implemented.
	_player_options_menu.populate_item_options([])
	display_player_menu(true)


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_focused_character = _summon_manager
	_get_focus_display().set_summon_stats(_summon_manager)
	_set_highlight_for_focus_character(true)
	_player_options_menu.clear_all_options()
	_player_options_menu.populate_spell_options(_summon_manager.turn_actions)
	display_player_menu(true)


## Virutal function. Displays or hides the player options menu.
func display_player_menu(display: bool) -> void:
	super.display_player_menu(display)
	# When player menu hidden, highlighted chracter should be reset.
	if not display:
		_set_highlight_for_focus_character(false)


## Initializes the party character details in the UI.
func track_party_members(players: Array[Character]) -> void:
	for i: int in players.size():
		var stats_display: UserCharacterStatsUI = _party_stats_container.get_child(i)
		var player: PlayerCharacter = players[i]
		_party_stat_map[player.get_instance_id()] = stats_display
		stats_display.set_player_stats(player)
		stats_display.show()


## Set the Summon node reference.
func set_summon(summon: Summon) -> void:
	_summon_manager = summon
	initiative_tracker.set_summon_reference(_summon_manager)
	if _focused_character != null:
		_summon_manager.summoner = _focused_character


## Gets the UI display for the focus character.
func _get_focus_display() -> HighlightCharacterStatsUI:
	if _focused_character == null:
		printerr("No focus character set. Focus display could not be identified.")
		return null
	elif _focused_character == _summon_manager:
		return _party_stat_map[_summon_manager.summoner.get_instance_id()]
	else:
		return _party_stat_map[_focused_character.get_instance_id()]


## Updates the highlight for the UI details of the current focus character.
func _set_highlight_for_focus_character(active: bool) -> void:
	if _focused_character != null:
		_get_focus_display().set_highlight(active)
