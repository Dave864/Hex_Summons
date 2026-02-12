class_name EncounterUIButtonLayout
extends Control
## Manages the various UI elements of an Encounter scene. Uses a button focused
## layout.
##
## EncounterUI handles the overall management of the various UI nodes used
## during an encounter. This scene also provides a convenient access point for
## said UI nodes. The nodes are the InitiativeTracker, the SummonPool,
## PlayerStats, an PlayerOptionButtons for movement, techniques, summons, items,
## and end.


## The maximumum number of players that can be in an encounter.
const MAX_PARTY_SIZE: int = 4
## The width of the PartyStats container node.
const PARTY_WIDTH: int = 128
## The height used for the PartyStats container node when not displaying the
## maximum party count.
const PART_PARTY_HEIGHT: int = 168
## The height used for the PartyStats container node when displaying the
## maximum party count.
const FULL_PARTY_HEIGHT: int = 224

enum Options {
	MOVE,
	TECHNIQUE,
	SPELL,
	SUMMON,
	ITEM,
	NONE,
}


# TODO: Currently loading CharacterSummary scene to visualize the hp values
# of enemy characters
var _character_summary: PackedScene = preload(
	"res://user_interface/encounter/button_layout/test_labels/" \
	+ "CharacterSummary/CharacterSummary.tscn"
)
## Flag that describes the options currently on display.
var _current_selection: Options = Options.NONE
## The character that the UI is displaying the details of, either a PlayerCharacter
## or Summon.
var _focused_character: Character = null
## Holds references for all player characters in the party. Used for toggling
## UI elements in PartyStats container.
var _party_stat_map: Dictionary[int, UserCharacterStatsUI] = {}
## Reference to the node that handles summons.
var _summon: Summon = null:
	set = set_summon

@onready var initiative_tracker: InitiativeTracker = $InitiativeTracker
@onready var active_character_ui: UserCharacterStatsUI = $ActiveCharacterStats
@onready var enemy_stats: VBoxContainer = $EnemyStats
@onready var party_stats: VBoxContainer = $PartyStats
@onready var options_menu: PlayerOptionsButtonLayout = $PlayerOptionsButtonLayout
@onready var sub_options: SubOptions = $SubOptions


## Sets the selection flag.
func set_current_selection(new_flag: Options) -> void:
	_current_selection = new_flag


## Get the current character the UI is focused on.
func get_focused_character() -> Character:
	return _focused_character


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the new focused player as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[new_player.get_instance_id()].hide()
	_focused_character = new_player
	_summon.summoner = _focused_character
	options_menu.clear_all_options()
	options_menu.populate_technique_options(_focused_character.get_techniques())
	options_menu.populate_spell_options(_focused_character.get_spells())
	options_menu.populate_summon_options(_summon)
	options_menu.populate_item_options([])
	options_menu.set_focus_neighbors()
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_player_stats(_focused_character)
	active_character_ui.show()


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the summoner as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[_summon.summoner.get_instance_id()].hide()
	_focused_character = _summon
	options_menu.clear_all_options()
	options_menu.populate_spell_options(_summon.turn_actions)
	options_menu.set_focus_neighbors()
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_summon_stats(_summon)
	active_character_ui.show()


## Set the Summon node reference.
func set_summon(summon: Summon) -> void:
	_summon = summon
	initiative_tracker.set_summon_reference(_summon)
	if _focused_character != null:
		_summon.summoner = _focused_character


## Get an action from the currently active sub-options selection.
func get_sub_option_at_index(index: int) -> Action:
	var a: Action
	match _current_selection:
		Options.TECHNIQUE:
			a = sub_options.get_action_at_index(index)
		Options.SPELL:
			a = sub_options.get_action_at_index(index)
		Options.SUMMON:
			a = sub_options.get_action_at_index(index)
		_:
			a = null
	return a


## Sets the focus to the specified index for sub options.
func grab_focus_for_sub_option_at_index(index: int) -> void:
	sub_options.grab_focus_at_index(index)


## Updates the disabled flag to true for all active user options.
func set_active_options() -> void:
	options_menu.disable_menu(false)


## Hides the active player stats and reveals the relevant party summary for the
## "active" character.
func hide_active_stats() -> void:
	active_character_ui.hide()
	if _focused_character != null:
		party_stats.size.y = (
				FULL_PARTY_HEIGHT if _party_stat_map.size() == MAX_PARTY_SIZE
				else PART_PARTY_HEIGHT
		)
		var character_id: int
		if _focused_character == _summon and _summon.is_active():
			character_id = _summon.summoner.get_instance_id()
		else:
			character_id = _focused_character.get_instance_id()
		_party_stat_map[character_id].show()


## Set all player options to disabled.
func disable_all_options() -> void:
	options_menu.disable_menu(true)


## Reset all PlayerOptionButtons.
func reset_all_options() -> void:
	#technique_button.reset()
	#spell_button.reset()
	#summon_button.reset()
	#item_button.reset()
	#end_button.reset()
	pass


## Initializes the party character details in the UI.
func track_party_members(players: Array[Character]) -> void:
	var p_count: int = int(min(players.size(), MAX_PARTY_SIZE))
	var height: int = (
			FULL_PARTY_HEIGHT if p_count == MAX_PARTY_SIZE
			else PART_PARTY_HEIGHT
	)
	party_stats.set_deferred("size", Vector2(PARTY_WIDTH, height))
	for i: int in p_count:
		var player_stats: UserCharacterStatsUI = party_stats.get_child(i)
		var player: PlayerCharacter = players[i] as PlayerCharacter
		_party_stat_map[player.get_instance_id()] = player_stats
		player_stats.set_player_stats(player)
		player_stats.show()


## Adds the enemy character details to the UI.
## TODO: This is to allow for CharacterSummary nodes to be used for testing
## purposes.
func track_enemy(e: EnemyCharacter) -> void:
	var e_label: CharacterSummary = _character_summary.instantiate()
	e_label.set_character_name(e.name)
	e_label.set_hp(
			e.stats.get_stat(Stat.Type.CUR_HEALTH),
			e.stats.get_stat(Stat.Type.CUR_HEALTH)
	)
	e_label.set_enemy_wisp_count()
	e_label.set_text_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
	e.stats.connect(
			"health_changed",
			Callable(e_label, "_on_Character_hp_changed")
	)
	enemy_stats.add_child(e_label)


## Helper function for set_focused_character and set_summon_as_focus. Reveals the
## focused player's party stats UI node.
func _show_focused_character_in_party() -> void:
	# Not all members of the party are being displayed in the PartyStats
	# container, so the partial height should be used to keep the UI display
	# from being too spread out.
	party_stats.size.y = PART_PARTY_HEIGHT
	# Reveal the party stats of focused character as their details in the
	# ActivePlayerStats node will be overridden.
	if _focused_character != null:
		var character_id: int
		if _focused_character == _summon and _summon.is_active():
			character_id = _summon.summoner.get_instance_id()
		else:
			character_id = _focused_character.get_instance_id()
		_party_stat_map[character_id].show()


## Disconnects the focused character from the ActiveCharacterStats node.
func _disconnect_focus_player_health_changed() -> void:
	var character_connected: bool = (
			_focused_character != null 
			and _focused_character.stats.is_connected(
				"health_changed",
				Callable(active_character_ui, "_on_Character_hp_changed")
			)
	)
	if character_connected:
		_focused_character.stats.disconnect(
				"health_changed",
				Callable(active_character_ui, "_on_Character_hp_changed")
		)


## Updates the PartyCharacterStats node of the summoner to show the summon's
## details.
func _on_Summon_activated(summoner_id: int) -> void:
	_party_stat_map[summoner_id].set_summon_stats(_summon)


## Updates the PartyCharacterStats node of the summoner to revert back to
## showing said character's details.
func _on_Summon_deactivated() -> void:
	# Summon is deactivated on start, before its reference in this node is set.
	if _summon == null:
		return
	var summoner: PlayerCharacter = _summon.summoner
	_party_stat_map[summoner.get_instance_id()].set_player_stats(summoner)
	# This will allow for the party stats to be properly updated.
	_focused_character = summoner
	_summon.summoner = null
