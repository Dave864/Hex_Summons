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
var _player: PlayerCharacter = null setget set_player
var _techniques: Array = []
var _spells: Array = []

onready var _sub_options = $SubOptions
onready var _move_button = $Options/MoveButton
onready var _technique_button = $Options/TechniqueButton
onready var _spell_button = $Options/SpellButton
onready var _summon_button = $Options/SummonButton
onready var _end_button = $Options/EndButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Sets the player that will be interacting with the UI.
func set_player(new_player: PlayerCharacter) -> void:
	_player = new_player
	_techniques = _player.get_techniques()
	_spells = _player.get_spells()


# Sets the selection flag.
func set_current_selection(new_flag: int) -> void:
	_current_selection = new_flag


# Gets the value of the selection flag.
func get_current_selection() -> int:
	return _current_selection


# Update the SubOptions element with the currently selected option
func getSubOptions() -> void:
	match _current_selection:
		Options.TECHNIQUE:
			pass
		Options.SPELL:
			pass
		Options.SUMMON:
			pass
		_:
			pass
