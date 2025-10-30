class_name SubOptions
extends ScrollContainer
## Manages the creation and removal of sub-option buttons for a given option category.
##
## Manages SubOptionButton nodes that represent options for either techniques,
## spells, summons, or items. This includes the creation of new nodes, the removal
## of current nodes, and the accessing of specific nodes.


## Indicates that one of the sub-options was selected
signal option_selected(option_info)
## Indicates that a sub-option of type Action was selected. 
signal action_selected(action_info)

var _options: Array = []
var _technique_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/TechniqueButton/TechniqueButton.tscn"
)
var _spell_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/SpellButton/SpellButton.tscn"
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
func populate_techinques(player: PlayerCharacter, techniques: Array) -> void:
	_populate_sub_options(techniques, player, _technique_button)


## Populate the sub-options container with spells.
func populate_spells(player: PlayerCharacter, spells: Array) -> void:
	_populate_sub_options(spells, player, _spell_button)


## Clear out the sub-options container.
func clear_sub_options() -> void:
	for option_button in _sub_options_container.get_children():
		option_button.disconnect(
				"option_selected",
				Callable(self, "_on_SubOptionButton_option_selected")
		)
		_sub_options_container.remove_child(option_button)
		option_button.queue_free()
		_options.clear()
	_set_neighbors()


## Get the option stored at the specified index.
func get_option_at_index(index: int) -> Action:
	return _options[index]


## Sets the focus for the SubOption at the given child index.
func grab_focus_at_index(index: int) -> void:
	_sub_options_container.get_child(index).get_button().call_deferred("grab_focus")


## Sets the focus neighbors of the currently populated sub options.
func _set_neighbors() -> void:
	for i in range(_sub_options_container.get_child_count() - 1):
		var current_option: SubOptionButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)


## Create the buttons for the given sub-options.
func _populate_sub_options(
	options: Array,
	player: PlayerCharacter,
	button: PackedScene
) -> void:
	for option in options:
		var new_button: SubOptionButton = button.instantiate()
		new_button.set_option_details(option)
		new_button.set_player(player)
		new_button.connect(
			"option_selected",
			Callable(self, "_on_SubOptionButton_option_selected")
		)
		_options.append(option)
		_sub_options_container.add_child(new_button)
	_set_neighbors()


## Emits the "action_selected" signal when one of the button options has been pressed.
func _on_SubOptionButton_option_selected(option_info: Node) -> void:
	emit_signal("option_selected", option_info)


## Emits the "action_selected" signal when either a technique or spell option has
## been chosen.
func _on_SubOptionButton_action_selected(action_info: Action) -> void:
	emit_signal("action_selected", action_info)
