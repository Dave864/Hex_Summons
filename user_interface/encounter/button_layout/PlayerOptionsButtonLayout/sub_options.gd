class_name SubOptions
extends ScrollContainer
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

## Reference to the scene used to display sub-options for techniques.
var _technique_button: PackedScene = preload(
		"res://user_interface/encounter/button_layout/" \
		+ "SubOptionButton/TechniqueButton/TechniqueButton.tscn"
)
## Reference to the scene used to display sub-options for spells.
var _spell_button: PackedScene = preload(
		"res://user_interface/encounter/button_layout/" \
		+ "SubOptionButton/SpellButton/SpellButton.tscn"
)
## Reference to the scene used to display sub-options for summons.
var _summon_button: PackedScene = preload(
		"res://user_interface/encounter/button_layout/" \
		+ "SubOptionButton/SummonButton/SummonButton.tscn"
)
## The currently displayed action options.
var _active_option: Option = Option.NONE
## The current set of options for techniques.
var _technique_options: Array[SubOptionButton] = []
## The current set of options for spells.
var _spell_options: Array[SubOptionButton] = []
## The current set of options for summons.
var _summon_options: Array[SubOptionButton] = []
## The current set of options for items.
var _item_options: Array[SubOptionButton] = []

## The container that holds the options.
@onready var _sub_options_container: HBoxContainer = $HBoxContainer


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


## Disables or enables the currently displayed options.
func disable_active_options(disable: bool) -> void:
	var active_options: Array[SubOptionButton]
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
	for option: SubOptionButton in active_options:
		option.disabled = disable


## Reveal this UI element and enable it to be found by the mouse.
func activate() -> void:
	_sub_options_container.mouse_filter = Control.MOUSE_FILTER_PASS
	show()


## Hide this UI element and do not allow mouse input to be caught by it.
func deactivate() -> void:
	_sub_options_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


## Populate the sub-options container with techniques.
func populate_techinques(techniques: Array[Action]) -> void:
	_populate_sub_options(techniques, _technique_options, _technique_button)


## Clears out the recorded technique buttons.
func clear_techniques() -> void:
	_technique_options.clear()


## Checks if there are techniques loaded.
func has_techniques() -> bool:
	return _technique_options.size() > 0


## Populate the sub-options container with spells.
func populate_spells(spells: Array[Action]) -> void:
	_populate_sub_options(spells, _spell_options, _spell_button)


## Clears out the recorded spell buttons.
func clear_spells() -> void:
	_spell_options.clear()


## Checks if there are spells loaded.
func has_spells() -> bool:
	return _spell_options.size() > 0


## Populate the sub-options container with summon options.
func populate_summons(summon_handler: Summon) -> void:
	for summon_name: String in summon_handler.available_summons:
		var new_button: SummonButton = _summon_button.instantiate()
		_summon_options.append(new_button)
		_sub_options_container.add_child(new_button)
		new_button.set_summon_details(summon_name, summon_handler)
	_set_neighbors(_summon_options)


## Clears out the recorded summon buttons.
func clear_summons() -> void:
	_summon_options.clear()


## Checks if there are summons loaded.
func has_summons() -> bool:
	return _summon_options.size() > 0


## Populate the sub-options container with item actions.
func populate_items(item_actions: Array[Action]) -> void:
	# Currently, there is no dedicated sub option button for items.
	_populate_sub_options(item_actions, _item_options, _technique_button)


## Clears out the recorded item buttons.
func clear_items() -> void:
	_item_options.clear()


## Checks if there are items loaded.
func has_items() -> bool:
	return _item_options.size() > 0


## Clear out the sub-options container.
func clear_all() -> void:
	for option_button in _sub_options_container.get_children():
		_sub_options_container.remove_child(option_button)
		option_button.queue_free()
	clear_techniques()
	clear_spells()
	clear_summons()
	clear_items()


## Get the action stored at the specified index of the active option.
func get_action_at_index(index: int) -> Action:
	match _active_option:
		Option.TECHNIQUE:
			return _technique_options[index].get_option_details()
		Option.SPELL:
			return _spell_options[index].get_option_details()
		Option.SUMMON:
			return _summon_options[index].get_option_details()
		Option.ITEM:
			return _item_options[index].get_option_details()
		_:
			printerr("No action type currently selected")
			return null


## Gets the SubOptionButton node at the specified index of the active option.
func get_SubOptionButton_at_index(index: int) -> SubOptionButton:
	match _active_option:
		Option.TECHNIQUE:
			return _technique_options[index]
		Option.SPELL:
			return _spell_options[index]
		Option.SUMMON:
			return _summon_options[index]
		Option.ITEM:
			return _item_options[index]
		_:
			printerr("No action type currently selected")
			return null


## Sets the focus for the SubOption at the given child index.
func grab_focus_at_index(index: int) -> void:
	var action_option: Node = _sub_options_container.get_child(index)
	action_option.get_button().call_deferred("grab_focus")


## Sets the focus neighbors of the given sub options.
func _set_neighbors(sub_options: Array[SubOptionButton]) -> void:
	if sub_options.size() == 0:
		return
	for i in range(sub_options.size() - 1):
		var current_option: SubOptionButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)
	sub_options[-1].set_focus_neighbor_right(sub_options[0])


## Create the buttons for the given sub-options.
func _populate_sub_options(
	options: Array[Action],
	option_buttons: Array[SubOptionButton],
	button: PackedScene
) -> void:
	for option: Action in options:
		var new_button: SubOptionButton = button.instantiate()
		option_buttons.append(new_button)
		_sub_options_container.add_child(new_button)
		new_button.set_option_details(option)
	_set_neighbors(option_buttons)


## Updates the display status for the buttons of the provided action options.
func _display_buttons(
	action_options: Array[SubOptionButton],
	make_visible: bool = true
) -> void:
	if make_visible and action_options.size() > 0:
		var first_option_button: SubOptionButton = action_options[0]
		# Want to tell the selector to display the range for this action.
		first_option_button.emit_signal("pressed")
		first_option_button.call_deferred("grab_focus")
	for option_button: SubOptionButton in action_options:
		option_button.visible = make_visible


## Hides the buttons for the currently active option, setting the active option
## to NONE. Hides all options if there is no active option set.
func _hide_active_options() -> void:
	if _active_option == Option.NONE or _active_option == Option.TECHNIQUE:
		_display_buttons(_technique_options, false)
	if _active_option == Option.NONE or _active_option == Option.SPELL:
		_display_buttons(_spell_options, false)
	if _active_option == Option.NONE or _active_option == Option.SUMMON:
		_display_buttons(_summon_options, false)
	if _active_option == Option.NONE or _active_option == Option.ITEM:
		_display_buttons(_item_options, false)
	_active_option = Option.NONE



## Helper function for pressed button functions. Shows this menu and hides the
## buttons from the last selection.
func _show_menu() -> void:
	activate()
	_hide_active_options()


## Hides the currently displayed action options.
func _on_Movement_toggled(_toggled_on: bool) -> void:
	deactivate()
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
	deactivate()
	clear_all()
