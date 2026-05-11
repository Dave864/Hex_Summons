class_name PlayerActionOptions
extends PanelContainer
## Manages the tracking and populating of buttons for selecting an action of
## a given category.
##
## Buttons for action options are not created and destroyed when a different
## action is selected. Instead, the buttons are revealed or hidden as needed.


## The categories of options.
enum Option {
	TECHNIQUE, ## The character uses a technique action.
	SPELL, ## The character uses a spell action.
	SUMMON, ## The character manifests a summon, using their spawn action.
	ITEM, ## The character uses an item, and the action associated with it.
	NONE, ## No action options displayed.
}

## The control node that displays the specific details of a highlighted action.
@export var action_display: OptionData = null
## The currently displayed action options.
var _active_option: Option = Option.NONE
## The current set of options for techniques.
var _technique_options: Array[ActionOptionButton] = []
## The current set of options for spells.
var _spell_options: Array[ActionOptionButton] = []
## The current set of options for summons.
var _summon_options: Array[ActionOptionButton] = []
## The current set of options for items.
var _item_options: Array[ActionOptionButton] = []
## The container that holds the options.
@onready var _action_options_container: VBoxContainer = (
	$ScrollContainer/VBoxContainer
)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	action_display.hide()


## Disables or enables the currently displayed options.
func disable_active_options(disable: bool) -> void:
	var active_options: Array[ActionOptionButton]
	match _active_option:
		Option.TECHNIQUE:
			active_options = _technique_options
		Option.SPELL:
			active_options = _spell_options
		Option.SUMMON:
			active_options = _summon_options
		Option.ITEM:
			active_options = _item_options
		_:
			return
	for option: ActionOptionButton in active_options:
		option.disabled = disable


## Populates the action options menu with the listed techniques.
func populate_technique_options(technique_actions: Array[Action]) -> void:
	if technique_actions.size() == 0:
		return
	_create_buttons_for_technique_options(technique_actions)


## Clears out the recorded technique options.
func clear_technique_options() -> void:
	for i: int in _technique_options.size():
		_technique_options[i].queue_free()
	_technique_options.clear()


## Checks if there are techniques loaded.
func has_techniques() -> bool:
	return _technique_options.size() > 0


## Populates the action options menu with the listed spells.
func populate_spell_options(spell_actions: Array[Action]) -> void:
	if spell_actions.size() == 0:
		return
	_create_buttons_for_spell_options(spell_actions)


## Clears out the recorded spell options.
func clear_spell_options() -> void:
	for i: int in _spell_options.size():
		_spell_options[i].queue_free()
	_spell_options.clear()


## Checks if there are spells loaded.
func has_spells() -> bool:
	return _spell_options.size() > 0


## Populates the action options menu with the listed summon spawn actions.
func populate_summon_options(summon_manager: Summon) -> void:
	if summon_manager.available_summons.size() == 0:
		return
	_create_buttons_for_summon_options(summon_manager)


## Clears out the recorded summon options.
func clear_summon_options() -> void:
	for i: int in _summon_options.size():
		_summon_options[i].queue_free()
	_summon_options.clear()


## Checks if there are summons loaded.
func has_summons() -> bool:
	return _summon_options.size() > 0


## Populate the action options menu with the listed item actions.
func populate_item_options(item_actions: Array[Action]) -> void:
	if item_actions.size() == 0:
		return
	_create_buttons_for_item_options(item_actions)


## Clears out the recorded item options.
func clear_item_options() -> void:
	for i: int in _item_options.size():
		_item_options[i].queue_free()
	_item_options.clear()


## Checks if there are items loaded.
func has_items() -> bool:
	return _item_options.size() > 0


## Clears out the recorded options for all action types.
func clear_all_options() -> void:
	clear_technique_options()
	clear_spell_options()
	clear_summon_options()
	clear_item_options()


## Creates buttons for the provided techniques, setting up the focus neighbors.
func _create_buttons_for_technique_options(techniques: Array[Action]) -> void:
	for technique: Action in techniques:
		_create_action_option_button(
				_technique_options,
				technique,
				"_on_TechniqueOptionButton_action_highlighted"
		)
	_set_end_button_neighbors(_technique_options)


## Creates buttons for the provided spells, setting up the focus neighbors.
func _create_buttons_for_spell_options(spells: Array[Action]) -> void:
	for spell: Action in spells:
		_create_action_option_button(
				_spell_options,
				spell,
				"_on_SpellOptionButton_action_highlighted"
		)
	_set_end_button_neighbors(_spell_options)


## Creates buttons for the available summons, setting up the focus neighbors.
func _create_buttons_for_summon_options(summon_manager: Summon) -> void:
	for summon_name: String in summon_manager.spawn_actions:
		_create_summon_option_button(
				summon_name,
				summon_manager.spawn_actions[summon_name],
				summon_manager
		)
	_set_end_button_neighbors(_summon_options)


## Creates buttons for the provided item actions, setting up the focus neighbors. 
func _create_buttons_for_item_options(item_actions: Array[Action]) -> void:
	for action: Action in item_actions:
		_create_action_option_button(
				_item_options,
				action,
				"_on_ActionOptionButton_action_highlighted"
		)
	_set_end_button_neighbors(_item_options)


## Sets the neighbors for the first and last buttons in the option container.
func _set_end_button_neighbors(
	option_container: Array[ActionOptionButton]
) -> void:
	var first_button: ActionOptionButton = option_container[0]
	var last_button: ActionOptionButton = option_container[-1]
	first_button.focus_previous = last_button.get_path()
	first_button.focus_neighbor_top = last_button.get_path()
	last_button.focus_next = first_button.get_path()
	last_button.focus_neighbor_bottom = first_button.get_path()


## Creates a new button for the given action option.
func _create_action_option_button(
	option_container: Array[ActionOptionButton],
	action: Action,
	action_display_function: String
) -> void:
	var option_button := ActionOptionButton.new(action)
	option_button.connect(
			"action_highlighted",
			Callable(action_display, action_display_function)
	)
	_action_options_container.add_child(option_button)
	_set_button_neighbors(option_button, option_container)


## Creates a new button for the given summon option.
func _create_summon_option_button(
	summon_name: String,
	spawn_action: Action,
	summon_manager: Summon
) -> void:
	var option_button := SummonOptionButton.new(
			summon_name, 
			spawn_action,
			summon_manager
	)
	option_button.connect(
			"action_highlighted",
			Callable(action_display, "_on_SummonOptionButton_action_highlighted")
	)
	_action_options_container.add_child(option_button)
	_set_button_neighbors(option_button, _summon_options)


## Sets the neighbors for the button. 
func _set_button_neighbors(
	option_button: ActionOptionButton,
	option_container: Array[ActionOptionButton]
) -> void:
	if option_container.size() > 0:
		var previous_button: ActionOptionButton = option_container[-1]
		previous_button.focus_next = option_button.get_path()
		option_button.focus_previous = previous_button.get_path()
	option_button.hide()
	option_container.append(option_button)


## Hides the buttons for the currently active option, setting the active option
## to NONE.
func _hide_active_options() -> void:
	match _active_option:
		Option.TECHNIQUE:
			_display_buttons(_technique_options, false)
		Option.SPELL:
			_display_buttons(_spell_options, false)
		Option.SUMMON:
			_display_buttons(_summon_options, false)
		Option.ITEM:
			_display_buttons(_item_options, false)
	_active_option = Option.NONE


## Updates the display status for the buttons of the provided action options.
func _display_buttons(
	action_options: Array[ActionOptionButton],
	make_visible: bool = true
) -> void:
	if make_visible and action_options.size() > 0:
		# Want to tell the selector to display the range for this action.
		action_options[0].emit_signal("pressed")
		action_options[0].call_deferred("grab_focus")
	for option_button: ActionOptionButton in action_options:
		option_button.visible = make_visible


## Helper function for toggled button functions. Shows the action options menu
## as well as the action display.
func _show_menu() -> void:
	action_display.show()
	show()
	_hide_active_options()


## Hides the currently displayed action options.
func _on_Movement_toggled(_toggled_on: bool) -> void:
	hide()
	action_display.hide()
	_hide_active_options()


## Toggles the options for techniques.
func _on_Technique_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_show_menu()
		_display_buttons(_technique_options)
		_active_option = Option.TECHNIQUE
	else:
		_on_Movement_toggled(true)


## Toggles the options for spells.
func _on_Spell_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_show_menu()
		_display_buttons(_spell_options)
		_active_option = Option.SPELL
	else:
		_on_Movement_toggled(true)


## Toggles the options for summons.
func _on_Summon_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_show_menu()
		_display_buttons(_summon_options)
		_active_option = Option.SUMMON
	else:
		_on_Movement_toggled(true)


## Toggles the options for items.
func _on_Item_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_show_menu()
		_display_buttons(_item_options)
		_active_option = Option.ITEM
	else:
		_on_Movement_toggled(true)


## Hides this UI element, clearing out the saved action options.
func _on_Wait_pressed() -> void:
	hide()
	action_display.hide()
	clear_all_options()
