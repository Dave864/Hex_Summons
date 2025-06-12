class_name SubOptions
extends ScrollContainer
"""
Manages the SubOptions UI element in the EncounterUI.
"""


# Indicates that an action has been selected.
signal action_selected(action_info)

var _actions: Array = []
var _sub_option_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/SubOptionButton.tscn"
)
var _action_button: PackedScene = preload(
		"res://user_interface/encounter/" \
		+ "SubOptionButton/ActionButton.tscn"
)

onready var _sub_options_container: HBoxContainer = $HBoxContainer


# Populate the sub-options container.
func populate(player: PlayerCharacter, player_actions: Array) -> void:
	for pa in player_actions:
		var new_button: SubOptionButton = _sub_option_button.instance()
		new_button.set_action_details(pa)
		new_button.set_player(player)
		new_button.connect(
				"action_selected",
				self,
				"_on_SubOptionButton_action_selected"
		)
		_actions.append(pa)
		_sub_options_container.add_child(new_button)
	for i in range(_sub_options_container.get_child_count() - 1):
		var current_option: SubOptionButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)


# Clear out the sub-options container.
func clear_sub_options() -> void:
	for option_button in _sub_options_container.get_children():
		option_button.disconnect(
				"action_selected",
				self,
				"_on_SubOptionButton_action_selected"
		)
		_sub_options_container.remove_child(option_button)
		option_button.queue_free()
		_actions.clear()


# Get the action stored at the specified index.
func get_action_at_index(index: int) -> Action:
	return _actions[index]


# Sets the focus for the SubOption at the given index.
func grab_focus_at_index(index: int) -> void:
	_sub_options_container.get_child(index).get_button().grab_focus()


func _populate_with_actions() -> void:
	pass


func _populate_with_sub_options() -> void:
	pass


# Emits the "action_selected" signal when one of the button options has been pressed.
func _on_SubOptionButton_action_selected(action_info: Action) -> void:
	emit_signal("action_selected", action_info)
