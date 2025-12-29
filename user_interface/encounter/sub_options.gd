class_name SubOptions
extends ScrollContainer
## Manages the creation and removal of sub-option buttons for a given option
## category.
##
## Manages SubOptionButton nodes that represent actions for either techniques,
## spells, summons, or items. This includes the creation of new nodes, the
## removal of current nodes, and the accessing of specific nodes.


## Stores all action sub options.
var _options: Array[Action] = []
## Reference to the scene used to display sub-options for techniques.
var _technique_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/TechniqueButton/TechniqueButton.tscn"
)
## Reference to the scene used to display sub-options for spells.
var _spell_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/SpellButton/SpellButton.tscn"
)
## Reference to the scene used to display sub-options for summons.
var _summon_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/SummonButton/SummonButton.tscn"
)

@onready var _sub_options_container: HBoxContainer = $HBoxContainer


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
	_populate_sub_options(techniques, _technique_button)


## Populate the sub-options container with spells.
func populate_spells(spells: Array[Action]) -> void:
	_populate_sub_options(spells, _spell_button)


## Populate the sub-options container with summon options.
func populate_summons(summon_handler: Summon) -> void:
	for summon_name: String in summon_handler.available_summons:
		var new_button: SummonButton = _summon_button.instantiate()
		new_button.set_summon_details(summon_name, summon_handler)
		_options.append(new_button.get_option_details())
		_sub_options_container.add_child(new_button)
	_set_neighbors()


## Clear out the sub-options container.
func clear_selection() -> void:
	for option_button in _sub_options_container.get_children():
		_sub_options_container.remove_child(option_button)
		option_button.queue_free()
		_options.clear()
	_set_neighbors()


## Get the action stored at the specified index.
func get_action_at_index(index: int) -> Action:
	return _options[index]


## Gets the SubOptionButton node at the specified index.
func get_SubOptionButton_at_index(index: int) -> SubOptionButton:
	return _sub_options_container.get_child(index) as SubOptionButton


## Sets the focus for the SubOption at the given child index.
func grab_focus_at_index(index: int) -> void:
	var action_option: Node = _sub_options_container.get_child(index)
	action_option.get_button().call_deferred("grab_focus")


## Sets the focus neighbors of the currently populated sub options.
func _set_neighbors() -> void:
	for i in range(_sub_options_container.get_child_count() - 1):
		var current_option: SubOptionButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)


## Create the buttons for the given sub-options.
func _populate_sub_options(
	options: Array[Action],
	button: PackedScene
) -> void:
	for option: Action in options:
		var new_button: SubOptionButton = button.instantiate()
		new_button.set_option_details(option)
		_options.append(option)
		_sub_options_container.add_child(new_button)
	_set_neighbors()
