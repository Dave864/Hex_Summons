class_name EncounterUI
extends Control
"""
Manages the various UI elements of an encounter.
"""


# Used to indicate that the FSM should be set to the 'Standby' state.
signal set_FSM_to_standby()
# Indicates that the FSM should be set to the 'Pause' state.
signal set_FSM_to_pause()
# Indicates when a player turn has ended.
signal player_turn_ended(player_info)
# Indicates when a player action has been selected.
signal player_action_selected(player_info, action_info)
# Indicates that an action type selection (Technique, Spell, etc.) has been canceled.
signal player_action_type_canceled()

enum Options {
	MOVE,
	TECHNIQUE,
	SPELL,
	SUMMON,
	ITEM,
	NONE,
}

# Reference to this node's FSM
export(NodePath) var fsm_path = null

var fsm: StateMachine = null
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
onready var technique_button: LabeledIconButton = $Options/TechniqueButton
onready var spell_button: LabeledIconButton = $Options/SpellButton
onready var summon_button: LabeledIconButton = $Options/SummonButton
#onready var item_button: LabeledIconButton = $Options/ItemButton
onready var end_button: LabeledIconButton = $Options/EndButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	fsm = get_node(fsm_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
	
	if _techniques.size() > 0:
		technique_button.show()
	else:
		technique_button.hide()
	if _spells.size() > 0:
		spell_button.show()
	else:
		spell_button.hide()
	"""
	TODO: summon option will depend on different logic that has yet to be implemented.
	"""
	summon_button.hide()


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


# Toggle the disabled flag for options.
func toggle_options() -> void:
	technique_button.disabled = !technique_button.disabled
	spell_button.disabled = !spell_button.disabled
	summon_button.disabled = !summon_button.disabled
	end_button.disabled = !end_button.disabled


# Adds the player character details to the UI.
func track_party_member(p: PlayerCharacter) -> void:
	var p_label: CharacterSummary = _character_summary.instance()
	p_label.set_name(p.name)
	p_label.set_hp(p.stats.get_cur_health(), p.stats.get_max_health())
	p_label.set_text_alignment(Label.ALIGN_LEFT)
#	p.stats.connect("hp_changed", p_label, "_on_Character_hp_changed")
	party_stats.add_child(p_label)


# Adds the enemy character details to the UI.
func track_enemy(e: EnemyCharacter) -> void:
	var e_label: CharacterSummary = _character_summary.instance()
	e_label.set_name(e.name)
	e_label.set_hp(e.stats.get_cur_health(), e.stats.get_max_health())
	e_label.set_text_alignment(Label.ALIGN_RIGHT)
#	e.stats.connect("hp_changed", e_label, "_on_Character_hp_changed")
	enemy_stats.add_child(e_label)


# Emits the 'player_turn_ended' signal.
func emit_player_turn_ended() -> void:
	emit_signal("player_turn_ended", get_focused_player())


# Emits the 'player_action_selected' signal.
func emit_player_action_selected(action_info: Action) -> void:
	emit_signal("player_action_selected", get_focused_player(), action_info)


# Emits the 'player_action_type_canceled' signal.
func emit_player_action_type_canceled() -> void:
	emit_signal("player_action_type_canceled")


# Update the SubOptions element with the currently selected option
func _update_sub_options() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			sub_options.populate_sub_options(_player, _techniques)
		Options.SPELL:
			sub_options.populate_sub_options(_player, _spells)
		Options.SUMMON:
			pass
		_:
			pass


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		fsm_path != null,
		"EncounterUI has not set the path for the FSM."
	)


# Triggered when a player character is the current active character in the
# turn order. Causes the EncounterUI FSM to go to 'Standby'.
func _on_Encounter_player_turn_started(player_info: PlayerCharacter) -> void:
	set_focused_player(player_info)
	emit_signal("set_FSM_to_standby")


# Triggered when a move tile has been selected.
# Causes the EncounterUI FSM to go to 'Pause'.
func _on_Encounter_move_tile_selected(_path_details: PoolVector3Array) -> void:
	emit_signal("set_FSM_to_pause")


# Triggered when a player character indicates that the selector is needed.
# Causes the EncounterUI FSM to go to `Pause`.
func _on_PlayerCharacter_selector_required() -> void:
	emit_signal("set_FSM_to_standby")
