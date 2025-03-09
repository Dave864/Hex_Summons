class_name SubOptions
extends ScrollContainer
"""
Manages the SubOptions UI element in the EncounterUI.
"""


var sub_options: Array = []
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
		_sub_options_container.add_child(new_button)


# Clear out the sub-options container.
func clear_sub_options() -> void:
	for option in _sub_options_container.get_children():
		_sub_options_container.remove_child(option)
		option.queue_free()
