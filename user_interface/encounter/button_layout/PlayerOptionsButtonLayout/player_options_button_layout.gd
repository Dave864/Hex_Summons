class_name PlayerOptionsButtonLayout
extends PlayerOptionsUI
## Displays the actions available to the current active player character in a
## button style layout.
##
## Handles the population of the actions menu.


## The container for all buttons for selecting and displaying the options for
## a given action type.
@onready var _sub_options: SubOptions = $SubOptions


## Disables or enables the options and any displayed action options. Buttons
## with no present options are always set to disabled.
func disable_menu(disable: bool) -> void:
	_movement_button.disable(disable)
	_wait_button.disable(disable)
	_technique_button.disable(
			true if not _sub_options.has_techniques()
			else disable
	)
	_spell_button.disable(true if not _sub_options.has_spells() else disable)
	_summon_button.disable(
			true if not _sub_options.has_summons()
			else disable
	)
	_item_button.disable(true if not _sub_options.has_items() else disable)
	_sub_options.disable_active_options(disable)


## Populates the action options menu with the listed techniques. Hides the
## technique button if no actions are provided.
func populate_technique_options(technique_actions: Array[Action]) -> void:
	if technique_actions.size() == 0:
		_technique_button.disable(true)
		return
	_sub_options.populate_techinques(technique_actions)


## Clears out the recorded technique options.
func clear_technique_options() -> void:
	_sub_options.clear_techniques()


## Populates the action options menu with the listed spells. Hides the spell
## button if no actions are provided.
func populate_spell_options(spell_actions: Array[Action]) -> void:
	if spell_actions.size() == 0:
		_spell_button.disable(true)
		return
	_sub_options.populate_spells(spell_actions)


## Clears out the recorded spell options.
func clear_spell_options() -> void:
	_sub_options.clear_spells()


## Populates the action options menu with the listed summon spawn actions.
## Hides the summon button if no actions are provided.
func populate_summon_options(summon_manager: Summon) -> void:
	if summon_manager.available_summons.size() == 0:
		_summon_button.disable(true)
		return
	_summon_button.disable(false)
	_sub_options.populate_summons(summon_manager)


## Clears out the recorded summon options.
func clear_summon_options() -> void:
	_sub_options.clear_summons()


## Populate the action options menu with the listed item actions. Hides the
## item button if no actions are provided.
func populate_item_options(item_actions: Array[Action]) -> void:
	if item_actions.size() == 0:
		_item_button.disable(true)
		return
	_item_button.disable(false)
	_sub_options.populate_items(item_actions)


## Clears out the recorded item options.
func clear_item_options() -> void:
	_sub_options.clear_items()


## Clears out the recorded options for all action types.
func clear_all_options() -> void:
	_sub_options.clear_all()


## Sets the focus neighbors for the active options. The options are arranged
## horizontally.
func _set_focus_neighbors_for_active_options(
	active_options: Array[BaseButton]
) -> void:
	for i: int in active_options.size():
		active_options[i].focus_neighbor_top = active_options[i].get_path()
		active_options[i].focus_neighbor_bottom = active_options[i].get_path()
		# Arrays indexed at -1 refers to the last element.
		active_options[i].focus_neighbor_left = active_options[i - 1].get_path()
		active_options[i].focus_previous = active_options[i - 1].get_path()
		var n: int = i + 1 if i < active_options.size() - 1 else 0
		active_options[i].focus_neighbor_right = active_options[n].get_path()
		active_options[i].focus_next = active_options[n].get_path()
