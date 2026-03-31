@abstract
class_name PlayerOptionsUI
extends Control
## Base class for node that displays the actions available to the current
## active player character.


## Indicates that the wait button has been selected.
signal wait_selected()

## The categories of options.
enum Option {
	MOVE, ## The character moves around the map.
	TECHNIQUE, ## The character uses a technique action.
	SPELL, ## The character uses a spell action.
	SUMMON, ## The character manifests a summon, using their spawn action.
	ITEM, ## The character uses an item, and the action associated with it.
	WAIT, ## The character ends their turn.
}

## The button for movement.
@export var _movement_button: BaseButton = null
## The button for techniques.
@export var _technique_button: BaseButton = null
## The button for spells.
@export var _spell_button: BaseButton = null
## The button for summons.
@export var _summon_button: BaseButton = null
## The button for items.
@export var _item_button: BaseButton = null
## The button for wait.
@export var _wait_button: BaseButton = null

## Tracks the currently active option.
var _active_option: Option = Option.WAIT


## Hides this menu from display.
func _ready() -> void:
	dismiss()


## Handles button input.
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_selector_select"):
		var option_button := get_viewport().gui_get_focus_owner() as BaseButton
		if option_button == _movement_button and _active_option == Option.MOVE:
			SignalBus.emit_move_path_requested()
		elif option_button.toggle_mode:
			option_button.button_pressed = !option_button.button_pressed
		else:
			option_button.emit_signal("pressed")
	if event.is_action_pressed("ui_encounter_movement"):
		_movement_button.button_pressed = true
	if (
		not _technique_button.disabled
		and event.is_action_pressed("ui_encounter_option_1")
	):
		_technique_button.button_pressed = not _technique_button.button_pressed
	if (
		not _spell_button.disabled
		and event.is_action_pressed("ui_encounter_option_2")
	):
		_spell_button.button_pressed = not _spell_button.button_pressed
	if (
		not _summon_button.disabled
		and event.is_action_pressed("ui_encounter_option_3")
	):
		_summon_button.button_pressed = not _summon_button.button_pressed
	if (
		not _item_button.disabled
		and event.is_action_pressed("ui_encounter_option_4")
	):
		_item_button.button_pressed = not _item_button.button_pressed
	if event.is_action_pressed("ui_encounter_player_end"):
		_on_Wait_pressed()


## Shows this menu, setting the control focus to the movement button.
func display() -> void:
	show()
	_movement_button.call_deferred("grab_focus")
	_movement_button.button_pressed = true


## Hides this menu, resetting all option buttons.
func dismiss() -> void:
	hide()
	clear_all_options()
	_movement_button.set_pressed_no_signal(false)
	_technique_button.set_pressed_no_signal(false)
	_spell_button.set_pressed_no_signal(false)
	_summon_button.set_pressed_no_signal(false)
	_item_button.set_pressed_no_signal(false)
	_wait_button.set_pressed_no_signal(false)


## Disables or enables all the options and any displayed action options. Buttons
## with no present options are always set to disabled.
func disable_menu(disable: bool) -> void:
	_movement_button.disabled = disable
	_wait_button.disabled = disable


## Sets the focus neighbors for the options buttons based on the current
## disabled states for each.
func set_focus_neighbors() -> void:
	var active_options: Array[BaseButton] = []
	var option_buttons: Array[BaseButton] = [
		_movement_button,
		_technique_button,
		_spell_button,
		_summon_button,
		_item_button,
		_wait_button
	]
	for option_node: BaseButton in option_buttons:
		if not option_node.disabled:
			active_options.append(option_node)
		else:
			# Set neighbors of disabled options to themselves to prevent them
			# from being automatically set.
			option_node.focus_neighbor_top = option_node.get_path()
			option_node.focus_neighbor_bottom = option_node.get_path()
			option_node.focus_neighbor_left = option_node.get_path()
			option_node.focus_previous = option_node.get_path()
			option_node.focus_neighbor_right = option_node.get_path()
			option_node.focus_next = option_node.get_path()
	_set_focus_neighbors_for_active_options(active_options)


## Populates the action options menu with the listed techniques. Hides the
## technique button if no actions are provided.
@abstract func populate_technique_options(technique_actions: Array[Action]) -> void


## Clears out the recorded technique options.
@abstract func clear_technique_options() -> void


## Populates the action options menu with the listed spells. Hides the spell
## button if no actions are provided.
@abstract func populate_spell_options(spell_actions: Array[Action]) -> void


## Clears out the recorded spell options.
@abstract func clear_spell_options() -> void


## Populates the action options menu with the listed summon spawn actions.
## Hides the summon button if no actions are provided.
@abstract func populate_summon_options(summon_manager: Summon) -> void


## Clears out the recorded summon options.
@abstract func clear_summon_options() -> void


## Populate the action options menu with the listed item actions. Hides the
## item button if no actions are provided.
@abstract func populate_item_options(item_actions: Array[Action]) -> void


## Clears out the recorded item options.
@abstract func clear_item_options() -> void


## Clears out the recorded options for all action types.
@abstract func clear_all_options() -> void


## Helper function for set_focus_neighbors. Sets the neighbors for active options.
@abstract func _set_focus_neighbors_for_active_options(
	active_options: Array[BaseButton]
) -> void


## Sets the button_pressed flag of the button for the option to false.
func _depress_option_button(option: Option) -> void:
	match option:
		Option.MOVE:
			_movement_button.button_pressed = false
		Option.TECHNIQUE:
			_technique_button.button_pressed = false
		Option.SPELL:
			_spell_button.button_pressed = false
		Option.SUMMON:
			_summon_button.button_pressed = false
		Option.ITEM:
			_item_button.button_pressed = false
		Option.WAIT:
			_wait_button.button_pressed = false


## Toggles the current active button off if it is not movement. Does not toggle
## the movement button off.
func _on_Movement_toggled(toggled_on: bool) -> void:
	if toggled_on and _active_option != Option.MOVE:
		_depress_option_button(_active_option)
		SignalBus.emit_character_action_type_canceled()
		_active_option = Option.MOVE
		_movement_button.call_deferred("grab_focus")


## Toggles the techinque button. When toggled on, the last active button is toggled
## off. When toggled off, toggles the movement button on if this option is active.
func _on_Technique_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_movement_button.button_pressed = _active_option == Option.TECHNIQUE
		return
	_technique_button.grab_focus()
	var last_option: Option = _active_option
	_active_option = Option.TECHNIQUE
	if last_option != Option.TECHNIQUE:
		_depress_option_button(last_option)


## Toggles the spell button. When toggled on, the last active button is toggled
## off. When toggled off, toggles the movement button on if this option is active.
func _on_Spell_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_movement_button.button_pressed = _active_option == Option.SPELL
		return
	_spell_button.grab_focus()
	var last_option: Option = _active_option
	_active_option = Option.SPELL
	if last_option != Option.SPELL:
		_depress_option_button(last_option)


## Toggles the summon button. When toggled on, the last active button is toggled
## off. When toggled off, toggles the movement button on if this option is active.
func _on_Summon_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_movement_button.button_pressed = _active_option == Option.SUMMON
		return
	_summon_button.grab_focus()
	var last_option: Option = _active_option
	_active_option = Option.SUMMON
	if last_option != Option.SUMMON:
		_depress_option_button(last_option)


## Toggles the item button. When toggled on, the last active button is toggled
## off. When toggled off, toggles the movement button on if this option is active.
func _on_Item_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_movement_button.button_pressed = _active_option == Option.ITEM
		return
	_item_button.grab_focus()
	var last_option: Option = _active_option
	_active_option = Option.ITEM
	if last_option != Option.ITEM:
		_depress_option_button(last_option)


## Hides this menu when the "Wait" button has been pressed.
func _on_Wait_pressed() -> void:
	_wait_button.grab_focus()
	_active_option = Option.WAIT
	emit_signal("wait_selected")
	dismiss()
