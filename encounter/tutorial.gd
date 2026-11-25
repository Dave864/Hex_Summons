class_name Tutorial
extends Encounter
## Manages the events of the tutorial encounter.
##
## The tutorial is a structured combat encounter that walks the user through
## different aspects of a combat encounter.


## Denotes the current step in the tutorial the player is at.
enum Step{
	INTRO,
	MOVEMENT,
	TECHNIQUE,
	SPELL,
	SUMMON,
	END,
}

@export_group("Text Dialogue", "dialogue_")
## The dialogue introducing the basic conceit of an encounter.
@export_multiline var dialogue_intro := ""
## The dialogue explaining movement.
@export_multiline var dialogue_move := ""
## The dialogue explaining techniques.
@export_multiline var dialogue_technique := ""
## The dialogue explaining spells.
@export_multiline var dialogue_spell := ""
## The dialogue explaining summons.
@export_multiline var dialogue_summon := ""
@export_group("Objective Summary", "tooltip_objective_")
## The tooltip describing the movement objective.
@export_multiline var tooltip_objective_movement := ""
## The tooltip summarizing the technique objective.
@export_multiline var tooltip_objective_technique := ""
## The tooltip summarizong the spell objective.
@export_multiline var tooltip_objective_spell := ""
## The tooltip summarizing the summon objective.
@export_multiline var tooltip_objective_summon := ""
@export_group("Camera Tooltips", "tooltip_")
## The tooltip dialogue for gamepad camera movement.
@export_multiline var tooltip_movement_gamepad := ""
## The tooltip dialogue for keyboard & mouse camera movement.
@export_multiline var tooltip_movement_keymouse := ""
@export_group("Player Transition Areas", "transition_area_")
## The area the player must be in to start the technique tutorial.
@export var transition_area_technique: PackedInt32Array = []
## The area the player must be in to start the spell tutorial.
@export var transition_area_spell: PackedInt32Array = []
## The area the player must be in to start the summon tutorial.
@export var transition_area_summon: PackedInt32Array = []
@export_group("Spawn Areas", "spawn_area_")
## The tiles the enemies will spawn in for the technique tutorial.
@export var spawn_area_technique: PackedInt32Array = []
## The tiles the enemies will spawn in for the spell tutorial.
@export var spawn_area_spell: PackedInt32Array = []
## The tiles the enemies will spawn in for the summon tutorial.
@export var spawn_area_summon: PackedInt32Array = []


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	hex_map = $SelectionTracker/TutorialMap
	selection_tracker.hex_map = hex_map
	_connect_map_to_selector()
	ui.show()
	ui.set_summon(summon)
	_load_players()


## Resets the initiative tracker to match current characters.
func reset_initative_tracker() -> void:
	var characters: Array[Character] = []
	characters.append_array(players.keys())
	characters.append_array(enemies)
	ui.initiative_tracker.populate_initiative(characters)
