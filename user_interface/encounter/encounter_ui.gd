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

var hm_astar: HexMapAStar = null

var _current_selection: int = Options.NONE setget set_current_selection, get_current_selection
# The player character that will interface with the UI.
var _player: PlayerCharacter = null setget set_focused_player, get_focused_player
var _techniques: Array = [] setget , get_techniques
var _spells: Array = [] setget , get_spells

onready var initiative_tracker = $InitiativeTracker
onready var active_player_stats = $ActivePlayerStats
onready var sub_options = $SubOptions
onready var options = $Options
onready var technique_button = $Options/TechniqueButton
onready var spell_button = $Options/SpellButton
onready var summon_button = $Options/SummonButton
onready var end_button = $Options/EndButton


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


# Toggle the disabled flag for options.
func toggle_options() -> void:
	technique_button.disabled = !technique_button.disabled
	spell_button.disabled = !spell_button.disabled
	summon_button.disabled = !summon_button.disabled
	end_button.disabled = !end_button.disabled


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
