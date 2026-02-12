class_name EncounterUI
extends Control
## Base class for scenes that manage the various UI elements of an Encounter
## scene.
##
## EncounterUI handles the overall management of the various UI nodes used
## during an encounter. This scene also provides a convenient access point for
## said UI nodes. The common nodes are InitiativeTracker and StandbyPool.


## Holds references for all player characters in the party. Used for toggling
## UI elements in PartyStats container.
var _party_stat_map: Dictionary[int, UserCharacterStatsUI] = {}
## The character that is the focus of the UI. Either a player character or a
## summon.
var _focused_character: Character = null
## Manages the summons.
var _summon_manager: Summon = null:
	set = set_summon

## The node that displays and manages the initiatve order.
@onready var initiative_tracker: InitiativeTracker = $InitiativeTracker
## Container holding all displays for player characters.
@onready var _party_stats_container: Container = $PartyStatsContainer


## Get the current player the UI is focused on.
func get_focused_character() -> PlayerCharacter:
	return _focused_character


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_focused_character = new_player


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_focused_character = _summon_manager


## Set the Summon node reference.
func set_summon(summon: Summon) -> void:
	_summon_manager = summon
	initiative_tracker.set_summon_reference(_summon_manager)
	if _focused_character != null:
		_summon_manager.summoner = _focused_character


## Initializes the party character details in the UI.
func track_party_members(players: Array[Character]) -> void:
	for i: int in players.size():
		var player_stats: UserCharacterStatsUI = _party_stats_container.get_child(i)
		var player: PlayerCharacter = players[i] as PlayerCharacter
		_party_stat_map[player.get_instance_id()] = player_stats
		player_stats.set_player_stats(player)
