class_name EncounterUI
extends Control
## Manages the various UI elements of an Encounter scene.
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
	"res://user_interface/encounter/test_labels/" \
	+ "CharacterSummary/CharacterSummary.tscn"
)
## Flag that describes the options currently on display.
var _current_selection: Options = Options.NONE:
	get = get_current_selection,
	set = set_current_selection
## The PlayerCharacter that the UI is displaying the details of.
var _focused_character: Character = null
## Holds references for all player characters in the party. Used for toggling
## UI elements in PartyStats container.
var _party_stat_map: Dictionary[int, UserCharacterStatsUI] = {}
## The techniques the focused character has access to.
var _techniques: Array[Action] = []:
	get = get_techniques
## The spells the focused character has access to.
var _spells: Array[Action] = []:
	get = get_spells
## Reference to the node that handles summons.
var _summon: Summon = null:
	set = set_summon

@onready var initiative_tracker: InitiativeTracker = $InitiativeTracker
@onready var active_character_ui: UserCharacterStatsUI = $ActiveCharacterStats
@onready var enemy_stats: VBoxContainer = $EnemyStats
@onready var party_stats: VBoxContainer = $PartyStats
@onready var options: HBoxContainer = $Options
@onready var sub_options: SubOptions = $SubOptions
@onready var movement_button: PlayerOptionButton = $Options/MovementButton
@onready var technique_button: PlayerOptionButton = $Options/TechniqueButton
@onready var spell_button: PlayerOptionButton = $Options/SpellButton
@onready var summon_button: PlayerOptionButton = $Options/SummonButton
@onready var item_button: PlayerOptionButton = $Options/ItemButton
@onready var end_button: PlayerOptionButton = $Options/EndButton


## Sets the selection flag.
func set_current_selection(new_flag: Options) -> void:
	_current_selection = new_flag
	_update_sub_options()


## Gets the value of the selection flag.
func get_current_selection() -> Options:
	return _current_selection


## Get the current player the UI is focused on.
func get_focused_character() -> PlayerCharacter:
	return _focused_character


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the new focused player as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[new_player.get_instance_id()].hide()
	_focused_character = new_player
	_summon.summoner = _focused_character
	_techniques = _focused_character.get_techniques()
	_spells = _focused_character.get_spells()
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_player_stats(_focused_character)
	_show_active_options()


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the summoner as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[_summon.summoner.get_instance_id()].hide()
	_focused_character = _summon
	# Set to empty as to not erase the techniques list of previous focused
	# player character.
	_techniques = []
	_spells = _summon.turn_actions
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_summon_stats(_summon)
	_show_active_options()


## Get the techniques of the focused player.
func get_techniques() -> Array[Action]:
	return _techniques


## Get the spells of the focused player.
func get_spells() -> Array[Action]:
	return _spells


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


## Updates the disabled flag for all user options depending on if the active
## focused character is a player or summon.
func set_active_options() -> void:
	if _summon.is_active() and _summon == _focused_character:
		_set_active_summon_options()
	else:
		_set_active_player_options()


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
	movement_button.disable()
	technique_button.disable()
	spell_button.disable()
	summon_button.disable()
	item_button.disable()
	end_button.disable()


## Reset all PlayerOptionButtons.
func reset_all_options() -> void:
	technique_button.reset()
	spell_button.reset()
	summon_button.reset()
	item_button.reset()
	end_button.reset()


## Initializes the party character details in the UI.
func track_party_members(players: Array) -> void:
	var p_count: int = int(min(players.size(), MAX_PARTY_SIZE))
	var height: int = (
			FULL_PARTY_HEIGHT if p_count == MAX_PARTY_SIZE
			else PART_PARTY_HEIGHT
	)
	party_stats.set_deferred("size", Vector2(PARTY_WIDTH, height))
	for i: int in p_count:
		var player_stats: UserCharacterStatsUI = party_stats.get_child(i)
		var player: PlayerCharacter = players[i]
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


## Helper function for set_focused_character and set_summon_as_focus. Reveals the
## ActiveCharacterStats node and toggles the active options.
func _show_active_options() -> void:
	active_character_ui.show()
	reset_all_options()
	set_active_options()
	_set_character_option_focus_neighbors()


## Updates the disabled flag for all player options depending on respective
## criteria.
func _set_active_player_options() -> void:
	movement_button.disable(false)
	technique_button.disable(_techniques.size() <= 0)
	spell_button.disable(_spells.size() <= 0)
	var disable_summon: bool = (
		_summon.is_active()
		or _summon.available_summons.size() <= 0
	)
	summon_button.disable(disable_summon)
	# TODO: item option will depend on different logic that has yet to
	# be implemented.
	item_button.disable()
	end_button.disable(false)


## Updates the disabled flag for all summon options depending on respective
## criteria.
func _set_active_summon_options() -> void:
	movement_button.disable(false)
	technique_button.disable()
	spell_button.disable(_spells.size() <= 0)
	summon_button.disable()
	summon_button.disable()
	item_button.disable()
	end_button.disable()


## Sets the focus neighbors for the character options.
func _set_character_option_focus_neighbors() -> void:
	var active_options: Array[Control] = []
	for option_node: Control in options.get_children():
		if not option_node.disabled:
			active_options.append(option_node)
		else:
			option_node.focus_neighbor_top = option_node.get_path()
			option_node.focus_neighbor_bottom = option_node.get_path()
			option_node.focus_neighbor_left = option_node.get_path()
			option_node.focus_previous = option_node.get_path()
			option_node.focus_neighbor_right = option_node.get_path()
			option_node.focus_next = option_node.get_path()
	
	for i: int in active_options.size():
		active_options[i].focus_neighbor_top = active_options[i].get_path()
		active_options[i].focus_neighbor_bottom = active_options[i].get_path()
		# Arrays indexed at -1 refers to the last element.
		active_options[i].focus_neighbor_left = active_options[i - 1].get_path()
		active_options[i].focus_previous = active_options[i - 1].get_path()
		var n: int = i + 1 if i < active_options.size() - 1 else 0
		active_options[i].focus_neighbor_right = active_options[n].get_path()
		active_options[i].focus_next = active_options[n].get_path()


## Update the SubOptions element with the currently selected option
func _update_sub_options() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			sub_options.populate_techinques(_techniques)
		Options.SPELL:
			sub_options.populate_spells(_spells)
		Options.SUMMON:
			sub_options.populate_summons(_summon)
		Options.ITEM:
			pass
		_:
			pass


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
