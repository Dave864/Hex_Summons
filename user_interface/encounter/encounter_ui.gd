class_name EncounterUI
extends Control
## Manages the various UI elements of an Encounter scene.
##
## EncounterUI handles the overall management of the various UI nodes used
## during an encounter. This scene also provides a convenient access point for
## said UI nodes. The nodes are the InitiativeTracker, the SummonPool,
## PlayerStats, an PlayerOptionButtons for movement, techniques, summons, items,
## and end.


## Indicates that the UI is waiting to be activated.
signal is_waiting()

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
	"res://user_interface/encounter/test_labels/CharacterSummary/CharacterSummary.tscn"
)
## Flag that describes the options currently on display.
var _current_selection: Options = Options.NONE:
	get = get_current_selection,
	set = set_current_selection
## The PlayerCharacter that the UI is displaying the details of.
var _focused_player: PlayerCharacter = null:
	get = get_focused_player,
	set = set_focused_player
## Holds references for all player characters in the party. Used for toggling
## UI elements in PartyStats container.
var _party_stat_map: Dictionary[int, PlayerStatsUI] = {}
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
@onready var active_player_stats: PlayerStatsUI = $ActivePlayerStats
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


## Emits the is_waiting signal.
func emit_is_waiting() -> void:
	emit_signal("is_waiting")


## Sets the selection flag.
func set_current_selection(new_flag: Options) -> void:
	_current_selection = new_flag
	_update_sub_options()


## Gets the value of the selection flag.
func get_current_selection() -> Options:
	return _current_selection


## Updates the player character being focused on.
func set_focused_player(new_player: PlayerCharacter) -> void:
	var player_connected: bool = (
			_focused_player != null 
			and _focused_player.stats.is_connected(
				"health_changed",
				Callable(active_player_stats, "_on_Character_hp_changed")
			)
	)
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	if player_connected:
		_focused_player.stats.disconnect(
				"health_changed",
				Callable(active_player_stats, "_on_Character_hp_changed")
		)
	if _focused_player != null:
		_party_stat_map[_focused_player.get_instance_id()].show()
	# Hide the party stats of the new focused player as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[new_player.get_instance_id()].hide()
	_focused_player = new_player
	_techniques = _focused_player.get_techniques()
	_spells = _focused_player.get_spells()
	
	# Not all members of the party are being displayed in the PartyStats
	# container, so the partial height should be used to keep the UI display
	# from being too spread out.
	party_stats.size.y = PART_PARTY_HEIGHT
	active_player_stats.set_stats(_focused_player)
	active_player_stats.show()
	
	reset_all_options()
	set_active_options()
	_set_player_option_focus_neighbors()


## Get the current character the UI is focused on.
func get_focused_player() -> PlayerCharacter:
	return _focused_player


## Get the techniques of the focused player.
func get_techniques() -> Array[Action]:
	return _techniques


## Get the spells of the focused player.
func get_spells() -> Array[Action]:
	return _spells


## Set the Summon node reference.
func set_summon(summon: Summon) -> void:
	_summon = summon


## Sets the focused character as the summon.
func set_focused_summon() -> void:
	pass


## Get an action from the currently active sub-options selection.
func get_sub_option_at_index(index: int) -> Action:
	var a: Action
	match _current_selection:
		Options.TECHNIQUE:
			a = sub_options.get_option_at_index(index)
		Options.SPELL:
			a = sub_options.get_option_at_index(index)
		Options.SUMMON:
			a = null
		_:
			a = null
	return a


## Sets the focus to the specified index for sub options.
func grab_focus_for_sub_option_at_index(index: int) -> void:
	sub_options.grab_focus_at_index(index)


## Updates the disabled flag for all player options depending on respective
## criteria.
func set_active_options() -> void:
	movement_button.disable(false)
	technique_button.disable(_techniques.size() <= 0)
	spell_button.disable(_spells.size() <= 0)
	summon_button.disable(_summon.available_summons.size() <= 0)
	# TODO: item option will depend on different logic that has yet to
	# be implemented.
	item_button.disable()
	end_button.disable(false)


## Hides the active player stats and reveals the relevant party summary for the
## "active" character.
func hide_active_stats() -> void:
	active_player_stats.hide()
	if _focused_player != null:
		party_stats.size.y = (
				FULL_PARTY_HEIGHT if _party_stat_map.size() == MAX_PARTY_SIZE
				else PART_PARTY_HEIGHT
		)
		_party_stat_map[_focused_player.get_instance_id()].show()


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
	for i in p_count:
		var player_stats: PlayerStatsUI = party_stats.get_child(i)
		var player: PlayerCharacter = players[i]
		_party_stat_map[player.get_instance_id()] = player_stats
		player_stats.set_stats(player)
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


## Sets the focus neighbors for the player options.
func _set_player_option_focus_neighbors() -> void:
	var a_ops: Array = []
	for p_op in options.get_children():
		if not p_op.disabled:
			a_ops.append(p_op)
		else:
			p_op.focus_neighbor_top = p_op.get_path()
			p_op.focus_neighbor_bottom = p_op.get_path()
			p_op.focus_neighbor_left = p_op.get_path()
			p_op.focus_previous = p_op.get_path()
			p_op.focus_neighbor_right = p_op.get_path()
			p_op.focus_next = p_op.get_path()
	
	for i in range(a_ops.size()):
		a_ops[i].focus_neighbor_top = a_ops[i].get_path()
		a_ops[i].focus_neighbor_bottom = a_ops[i].get_path()
		# Arrays indexed at -1 refers to the last element.
		a_ops[i].focus_neighbor_left = a_ops[i - 1].get_path()
		a_ops[i].focus_previous = a_ops[i - 1].get_path()
		var n: int = i + 1 if i < a_ops.size() - 1 else 0
		a_ops[i].focus_neighbor_right = a_ops[n].get_path()
		a_ops[i].focus_next = a_ops[n].get_path()


## Update the SubOptions element with the currently selected option
func _update_sub_options() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			sub_options.populate_techinques(_focused_player, _techniques)
		Options.SPELL:
			sub_options.populate_spells(_focused_player, _spells)
		Options.SUMMON:
			sub_options.populate_summons(_focused_player, _summon)
		Options.ITEM:
			pass
		_:
			pass
