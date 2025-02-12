class_name EncounterUI
extends Control
"""
Manages the various UI elements of an encounter.
"""


enum Options {
	MOVE,
	TECHNIQUE,
	SPELL,
	SUMMON,
	NONE,
}

var _current_selection: int = Options.NONE setget set_current_selection, get_current_selection
# The player character that will interface with the UI.
var _player: PlayerCharacter = null
var _techniques: Array = []
var _spells: Array = []

onready var sub_options = $SubOptions
onready var options = $Options
onready var move_button = $Options/MoveButton
onready var technique_button = $Options/TechniqueButton
onready var spell_button = $Options/SpellButton
onready var summon_button = $Options/SummonButton
onready var end_button = $Options/EndButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Update the SubOptions element with the currently selected option
func _update_sub_options() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			sub_options.populate_sub_options(_techniques)
		Options.SPELL:
			sub_options.populate_sub_options(_spells)
		Options.SUMMON:
			pass
		_:
			pass


# Sets the selection flag.
func set_current_selection(new_flag: int) -> void:
	_current_selection = new_flag
	_update_sub_options()


# Gets the value of the selection flag.
func get_current_selection() -> int:
	return _current_selection


# Updates the player character being focused on when the signal `player_turn_started`
# is emitted.
func update_focused_player(new_player: PlayerCharacter) -> void:
	_player = new_player
	_techniques = _player.get_techniques()
	_spells = _player.get_spells()
