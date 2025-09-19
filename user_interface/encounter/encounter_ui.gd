class_name EncounterUI
extends Control
"""
Manages the various UI elements of an encounter.
"""


# Inidicates that the UI is waiting to be activated.
signal is_waiting()

enum Options {
	MOVE,
	TECHNIQUE,
	SPELL,
	SUMMON,
	ITEM,
	NONE,
}

var hm_astar: HexMapAStar = null

"""
TODO: Currently loading CharacterSummary scene to visualize the hp values of characters
"""
var _character_summary: PackedScene = preload(
	"res://user_interface/encounter/test_labels/CharacterSummary/CharacterSummary.tscn"
)
var _current_selection: int = Options.NONE setget set_current_selection, get_current_selection
# The player character that will interface with the UI.
var _player: PlayerCharacter = null setget set_focused_player, get_focused_player
var _techniques: Array = [] setget , get_techniques
var _spells: Array = [] setget , get_spells

onready var initiative_tracker: InitiativeTracker = $InitiativeTracker
onready var active_player_stats: ActivePlayerStats = $ActivePlayerStats
onready var enemy_stats: VBoxContainer = $EnemyStats
onready var party_stats: VBoxContainer = $PartyStats
onready var options: HBoxContainer = $Options
onready var sub_options: SubOptions = $SubOptions
onready var technique_button: PlayerOptionButton = $Options/TechniqueButton
onready var spell_button: PlayerOptionButton = $Options/SpellButton
onready var summon_button: PlayerOptionButton = $Options/SummonButton
onready var item_button: PlayerOptionButton = $Options/ItemButton
onready var end_button: PlayerOptionButton = $Options/EndButton


# Emits the is_waiting signal.
func emit_is_waiting() -> void:
	emit_signal("is_waiting")


# Sets the selection flag.
func set_current_selection(new_flag: int) -> void:
	_current_selection = new_flag
	_update_sub_options()


# Gets the value of the selection flag.
func get_current_selection() -> int:
	return _current_selection


# Updates the player character being focused on.
func set_focused_player(new_player: PlayerCharacter) -> void:
	_player = new_player
	_techniques = _player.get_techniques()
	_spells = _player.get_spells()
	
	active_player_stats.set_stats(_player)
	active_player_stats.show()
	
	activate_active_options()
	reset_all_options()


# Get the current player the UI is focused on.
func get_focused_player() -> PlayerCharacter:
	return _player


# Get the techniques of the focused player.
func get_techniques() -> Array:
	return _techniques


# Get the spalls of the focused player.
func get_spells() -> Array:
	return _spells


# Get an action from the currently active sub-options selection.
func get_sub_option_at_index(index: int) -> Action:
	var a: Action
	match _current_selection:
		Options.TECHNIQUE:
			a = sub_options.get_action_at_index(index)
		Options.SPELL:
			a = sub_options.get_action_at_index(index)
		Options.SUMMON:
			a = null
		_:
			a = null
	return a


# Sets the focus to the specified index for sub options.
func grab_focus_for_sub_option_at_index(index: int) -> void:
	sub_options.grab_focus_at_index(index)


# Updates the disabled flag for all player options depending on respective
# criteria.
func activate_active_options() -> void:
	technique_button.set_disabled(_techniques.size() <= 0)
	spell_button.set_disabled(_spells.size() <= 0)
	"""
	TODO: summon option will depend on different logic that has yet to be implemented.
	"""
	summon_button.set_disabled(true)
	"""
	TODO: item option will depend on different logic that has yet to be implemented.
	"""
	item_button.set_disabled(true)


# Set all player options to disabled.
func disable_all_options() -> void:
	technique_button.set_disabled(true)
	spell_button.set_disabled(true)
	summon_button.set_disabled(true)
	item_button.set_disabled(true)
	end_button.set_disabled(true)


# Reset all PlayerOptionButtons.
func reset_all_options() -> void:
	technique_button.reset()
	spell_button.reset()
	summon_button.reset()
	item_button.reset()
	end_button.reset()


# Adds the player character details to the UI.
func track_party_member(p: PlayerCharacter) -> void:
	var p_label: CharacterSummary = _character_summary.instance()
	p_label.set_name(p.name)
	p_label.set_hp(
			p.stats.get_stat(Stat.Type.CUR_HEALTH),
			p.stats.get_stat(Stat.Type.CUR_HEALTH)
	)
	p_label.set_text_alignment(Label.ALIGN_LEFT)
	p.stats.connect("health_changed", p_label, "_on_Character_hp_changed")
	party_stats.add_child(p_label)


# Adds the enemy character details to the UI.
func track_enemy(e: EnemyCharacter) -> void:
	var e_label: CharacterSummary = _character_summary.instance()
	e_label.set_name(e.name)
	e_label.set_hp(
			e.stats.get_stat(Stat.Type.CUR_HEALTH),
			e.stats.get_stat(Stat.Type.CUR_HEALTH)
	)
	e_label.set_text_alignment(Label.ALIGN_RIGHT)
	e.stats.connect("health_changed", e_label, "_on_Character_hp_changed")
	enemy_stats.add_child(e_label)


# Update the SubOptions element with the currently selected option
func _update_sub_options() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			sub_options.populate(_player, _techniques)
		Options.SPELL:
			sub_options.populate(_player, _spells)
		Options.SUMMON:
			pass
		_:
			pass
