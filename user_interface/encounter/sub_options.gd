class_name SubOptions
extends ScrollContainer
"""
Manages the SubOptions UI element in the EncounterUI.
"""


# Indicates that an action has been selected.
signal option_selected(option_info)

var _actions: Array = []
var _action_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/ActionButton/ActionButton.tscn"
)
# var _technique_button: PackedScene = preload("")
# var _spell_button: PackedScene = preload("")

@onready var _sub_options_container: HBoxContainer = $HBoxContainer


# Reveal this UI element and enable it to be found by the mouse.
func activate() -> void:
	_sub_options_container.mouse_filter = Control.MOUSE_FILTER_PASS
	show()


# Hide this UI element and do not allow mouse input to be caught by it.
func deactivate() -> void:
	_sub_options_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


# Populate the sub-options container with techniques.
func populate_techinques(player: PlayerCharacter, techniques: Array) -> void:
	for technique in techniques:
		var new_button: SubOptionButton = _action_button.instantiate()
		new_button.set_option_details(technique)
		new_button.set_player(player)
		new_button.connect(
			"option_selected",
			Callable(self, "_on_SubOptionButton_option_selected")
		)
		_actions.append(technique)
		_sub_options_container.add_child(new_button)


# Populate the sub-options container with spells.
func populate_spells(player: PlayerCharacter, spells: Array) -> void:
	for spell in spells:
		var new_button: SubOptionButton = _action_button.instantiate()
		new_button.set_option_details(spell)
		new_button.set_player(player)
		new_button.connect(
			"option_selected",
			Callable(self, "_on_SubOptionButton_option_selected")
		)
		_actions.append(spell)
		_sub_options_container.add_child(new_button)
	_set_neighbors()


# Clear out the sub-options container.
func clear_sub_options() -> void:
	for option_button in _sub_options_container.get_children():
		option_button.disconnect(
				"option_selected",
				Callable(self, "_on_SubOptionButton_option_selected")
		)
		_sub_options_container.remove_child(option_button)
		option_button.queue_free()
		_actions.clear()
	_set_neighbors()


# Get the action stored at the specified index.
func get_action_at_index(index: int) -> Action:
	return _actions[index]


# Sets the focus for the SubOption at the given index.
func grab_focus_at_index(index: int) -> void:
	_sub_options_container.get_child(index).get_button().call_deferred("grab_focus")


# Sets the focus neighbors of the currently populated sub options.
func _set_neighbors() -> void:
	for i in range(_sub_options_container.get_child_count() - 1):
		var current_option: SubOptionButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)


# Emits the "action_selected" signal when one of the button options has been pressed.
func _on_SubOptionButton_option_selected(option_info: Node) -> void:
	emit_signal("option_selected", option_info)
