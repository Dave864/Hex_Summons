class_name SubOptions
extends ScrollContainer
"""
Manages the SubOptions UI element in the EncounterUI.
"""


var _actions: Array = []
var _sub_options_button: PackedScene = preload(
	"res://user_interface/encounter/SubOptionsButton/SubOptionsButton.tscn"
)

onready var _sub_options_container: HBoxContainer = $HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Populate the sub-options container.
func populate_sub_options(player_actions: Array) -> void:
	for pa in player_actions:
		var new_button: SubOptionsButton = _sub_options_button.instance()
		new_button.set_action_details(pa)
		_actions.append(pa)
		_sub_options_container.add_child(new_button)
	for i in range(_sub_options_container.get_child_count() - 1):
		var current_option: SubOptionsButton = _sub_options_container.get_child(i)
		var right_neighor: SubOptionsButton = _sub_options_container.get_child(i + 1)
		current_option.set_focus_neighbor_right(right_neighor)


# Clear out the sub-options container.
func clear_sub_options() -> void:
	for option in _sub_options_container.get_children():
		_sub_options_container.remove_child(option)
		option.queue_free()
		_actions.clear()


# Get the action stored at the specified index.
func get_action_at_index(index: int) -> Action:
	return _actions[index]


# Sets the focus for the SubOption at the given index.
func grab_focus_at_index(index: int) -> void:
	_sub_options_container.get_child(index).get_button().grab_focus()
