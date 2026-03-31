class_name PlayerOptionsMenuLayout
extends PlayerOptionsUI
## Displays the actions available to the current active player character in a
## menu style layout.
##
## Handles the population of the actions menu.


## The container that holds the options for a selected action.
@onready var _action_options: PlayerActionOptions = $ActionOptions


## Disables or enables the options and any displayed action options. Buttons
## with no present options are always set to disabled.
func disable_menu(disable: bool) -> void:
	super.disable_menu(disable)
	_technique_button.disabled = (
		true if not _action_options.has_techniques()
		else disable
	)
	_spell_button.disabled = (
		true if not _action_options.has_spells()
		else disable
	)
	_summon_button.disabled = (
		true if not _action_options.has_summons()
		else disable
	)
	_item_button.disabled = (
		true if not _action_options.has_items()
		else disable
	)
	_action_options.disable_active_options(disable)


## Populates the action options menu with the listed techniques. Hides the
## technique button if no actions are provided.
func populate_technique_options(technique_actions: Array[Action]) -> void:
	if technique_actions.size() == 0:
		_technique_button.hide()
		return
	_technique_button.show()
	_action_options.populate_technique_options(technique_actions)


## Clears out the recorded technique options, hiding the technique button.
func clear_technique_options() -> void:
	_action_options.clear_technique_options()
	_technique_button.hide()


## Populates the action options menu with the listed spells. Hides the spell
## button if no actions are provided.
func populate_spell_options(spell_actions: Array[Action]) -> void:
	if spell_actions.size() == 0:
		_spell_button.hide()
		return
	_spell_button.show()
	_action_options.populate_spell_options(spell_actions)


## Clears out the recorded spell options, hiding the spell button.
func clear_spell_options() -> void:
	_action_options.clear_spell_options()
	_spell_button.hide()


## Populates the action options menu with the listed summon spawn actions.
## Hides the summon button if no actions are provided.
func populate_summon_options(summon_manager: Summon) -> void:
	if summon_manager == null or summon_manager.available_summons.size() == 0:
		_summon_button.hide()
		return
	_summon_button.show()
	_action_options.populate_summon_options(summon_manager)


## Clears out the recorded summon options, hiding the summon button.
func clear_summon_options() -> void:
	_action_options.clear_summon_options()
	_summon_button.hide()


## Populate the action options menu with the listed item actions. Hides the
## item button if no actions are provided.
func populate_item_options(item_actions: Array[Action]) -> void:
	if item_actions.size() == 0:
		_item_button.hide()
		return
	_item_button.show()
	_action_options.populate_item_options(item_actions)


## Clears out the recorded item options, hiding the item button.
func clear_item_options() -> void:
	_action_options.clear_item_options()
	_item_button.hide()


## Clears out the recorded options for all action types, hiding all buttons.
func clear_all_options() -> void:
	_action_options.clear_all_options()
	_technique_button.hide()
	_spell_button.hide()
	_summon_button.hide()
	_item_button.hide()


## Focus neighbors do not need to be updated, as they are hidden when disabled.
func _set_focus_neighbors_for_active_options(
	_active_options: Array[BaseButton]
) -> void:
	pass
