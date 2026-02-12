class_name EncounterUIMenuLayout
extends Control
## Manages the UI elements of an Encounter scene. Uses a traditional menu layout.
##
## This handles the overall management of the various UI nodes used during an
## encounter. Also provides a convenient access point for said nodes: 
## InitiativeTracker, StandbyHighlightPool, PartyCharacterStats, and
## PlayerOptionsMenu.


## Holds references for all player characters in the party. Used for toggling
## UI elements in PartyStats container.
var _party_stat_map: Dictionary[int, HighlightCharacterStatsUI] = {}
## The character that is the focus of the UI. Either a player character or a
## summon.
var _focused_character: Character = null
## Manages the summons.
var _summon_manager: Summon = null:
	set = set_summon

## The node that displays and manages the initiatve order.
@onready var initiative_tracker: InitiativeTracker = $InitiativeTracker
## Menu that displays the options available to a player character.
@onready var _player_options_menu: PlayerOptionsMenuLayout = $PlayerOptionsMenuLayout
## Container holding all displays for player characters.
@onready var _party_stats_container: VBoxContainer = $PartyStatsContainer


## Get the current player the UI is focused on.
func get_focused_character() -> PlayerCharacter:
	return _focused_character


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_set_highlight_for_focus_character(false)
	_focused_character = new_player
	_summon_manager.summoner = _focused_character
	_set_highlight_for_focus_character(true)
	_player_options_menu.clear_all_options()
	_player_options_menu.populate_technique_options(_focused_character.get_techniques())
	_player_options_menu.populate_spell_options(_focused_character.get_spells())
	_player_options_menu.populate_summon_options(_summon_manager)
	# TODO: Add call to get items when items are implemented.
	_player_options_menu.populate_item_options([])
	display_player_menu(true)


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_set_highlight_for_focus_character(false)
	_focused_character = _summon_manager
	_get_focus_display().set_summon_stats(_summon_manager)
	_set_highlight_for_focus_character(true)
	_player_options_menu.clear_all_options()
	_player_options_menu.populate_spell_options(_summon_manager.turn_actions)
	display_player_menu(true)


## Initializes the party character details in the UI.
func track_party_members(players: Array[PlayerCharacter]) -> void:
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


## Displays or hides the player options menu.
func display_player_menu(display: bool) -> void:
	if display:
		_player_options_menu.display()
	else:
		_player_options_menu.dismiss()


## Disables or enables all buttons in the player options menu.
func disable_player_menu(disable: bool) -> void:
	_player_options_menu.disable_menu(disable)


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
	_get_focus_display().set_highlight(active)


## Updates the PartyCharacterStats node of the summoner to show the summon's
## details.
func _on_Summon_activated(summoner_id: int) -> void:
	_party_stat_map[summoner_id].set_summon_stats(_summon_manager)


## Updates the PartyCharacterStats node of the summoner to revert back to
## showing said character's details.
func _on_Summon_deactivated() -> void:
	# Summon is deactivated on start, before its reference in this node is set.
	if _summon_manager == null:
		return
	var summoner: PlayerCharacter = _summon_manager.summoner
	_get_focus_display().set_player_stats(summoner)
	# This will allow for the party stats to be properly updated.
	_focused_character = summoner
	_summon_manager.summoner = null
