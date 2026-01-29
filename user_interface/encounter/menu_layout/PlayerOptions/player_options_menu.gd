class_name PlayerOptionsMenu
extends Control
## Displays the actions available to the current active player character.
##
## Handles the population of the actions menu. Also handles the display
## of the details of a selected action. Buttons for action options are not
## created and destroyed when a different action is selected. Instead, the
## buttons are revealed or hidden as needed.


## The options available to a player character.
enum Options {
	MOVE, ## The character moves around the map.
	TECHNIQUE, ## The character uses a technique action.
	SPELL, ## The character uses a spell action.
	SUMMON, ## The character manifests a summon, using their spawn action.
	ITEM, ## The character uses an item, and the action associated with it.
	WAIT, ## The character ends their turn.
}

## The button for movement.
@onready var _movement_button: Button = $PlayerActions/VBoxContainer/Movement
## The button for techniques.
@onready var _technique_button: Button = $PlayerActions/VBoxContainer/Technique
## The button for spells.
@onready var _spell_button: Button = $PlayerActions/VBoxContainer/Spell
## The button for summons.
@onready var _summon_button: Button = $PlayerActions/VBoxContainer/Summon
## The button for items.
@onready var _item_button: Button = $PlayerActions/VBoxContainer/Summon
## The button for waiting.
@onready var _wait_button: Button = $PlayerActions/VBoxContainer/Wait
## The container that holds the options for a selected action.
@onready var _action_options: PlayerActionOptions = $ActionOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display()


## Handles button input.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_selector_select"):
		var option_button := get_viewport().gui_get_focus_owner() as Button
		if option_button != null:
			option_button.emit_signal("pressed")


## Shows this menu, setting the control focus to the movement button.
func display() -> void:
	show()
	_movement_button.call_deferred("grab_focus")


## Hides this menu.
func dismiss() -> void:
	hide()


## Populates the action options menu with the listed techniques. Hides the
## technique button if no actions are provided.
func populate_technique_options(technique_actions: Array[Action]) -> void:
	if technique_actions.size() == 0:
		_technique_button.hide()
		return
	_technique_button.show()
	_action_options.populate_technique_options(technique_actions)


## Clears out the recorded technique options.
func clear_technique_options() -> void:
	_action_options.clear_technique_options()


## Populates the action options menu with the listed spells. Hides the spell
## button if no actions are provided.
func populate_spell_options(spell_actions: Array[Action]) -> void:
	if spell_actions.size() == 0:
		_spell_button.hide()
		return
	_spell_button.show()
	_action_options.populate_spell_options(spell_actions)


## Clears out the recorded spell options.
func clear_spell_options() -> void:
	_action_options.clear_spell_options()


## Populates the action options menu with the listed summon spawn actions.
## Hides the summon button if no actions are provided.
func populate_summon_options(summon_actions: Array[Action]) -> void:
	if summon_actions.size() == 0:
		_summon_button.hide()
		return
	_summon_button.show()
	_action_options.populate_summon_options(summon_actions)


## Clears out the recorded summon options.
func clear_summon_options() -> void:
	_action_options.clear_summon_options()


## Populate the action options menu with the listed item actions. Hides the
## item button if no actions are provided.
func populate_item_options(item_actions: Array[Action]) -> void:
	if item_actions.size() == 0:
		_item_button.hide()
		return
	_item_button.show()
	_action_options.populate_item_options(item_actions)


## Clears out the recorded item options.
func clear_item_options() -> void:
	_action_options.clear_item_options()


## Clears out the recorded options for all action types.
func clear_all_options() -> void:
	_action_options.clear_all_options()
